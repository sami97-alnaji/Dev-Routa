import 'dart:async';
import 'dart:typed_data';

import 'package:grpc/grpc.dart';

import '../../../core/security/secret_masker.dart';
import '../data/generated/google/protobuf/descriptor.pb.dart' as descriptor;
import '../data/generated/reflection/grpc/reflection/v1/reflection.pb.dart'
    as reflection;
import '../data/generated/reflection/grpc/reflection/v1/reflection.pbgrpc.dart'
    as reflection_grpc;
import '../data/grpc_descriptor_loader.dart';
import '../domain/grpc_reflection_models.dart';

class GrpcReflectionOperation {
  GrpcReflectionOperation._(this.result, this._cancel);

  final Future<GrpcReflectionResult> result;
  final Future<void> Function() _cancel;

  Future<void> cancel() => _cancel();
}

class GrpcReflectionService {
  GrpcReflectionService.forChannel(this._channel)
    : _client = reflection_grpc.ServerReflectionClient(_channel);

  factory GrpcReflectionService.connect({
    required String host,
    required int port,
    bool allowPlaintext = false,
  }) {
    final normalizedHost = host.trim();
    if (normalizedHost.isEmpty ||
        normalizedHost.contains('://') ||
        normalizedHost.contains('/') ||
        normalizedHost.contains('\\') ||
        port < 1 ||
        port > 65535) {
      throw ArgumentError('A valid gRPC host and port are required.');
    }
    return GrpcReflectionService.forChannel(
      ClientChannel(
        normalizedHost,
        port: port,
        options: ChannelOptions(
          credentials: allowPlaintext
              ? const ChannelCredentials.insecure()
              : const ChannelCredentials.secure(),
        ),
      ),
    );
  }

  final ClientChannel _channel;
  final reflection_grpc.ServerReflectionClient _client;
  bool _closed = false;
  ResponseStream<reflection.ServerReflectionResponse>? _activeCall;
  StreamController<reflection.ServerReflectionRequest>? _activeRequests;

  GrpcReflectionOperation discover({
    Map<String, String> metadata = const <String, String>{},
    Duration deadline = const Duration(seconds: 10),
    Iterable<String> runtimeSecrets = const <String>[],
    int maximumServices = 256,
    int maximumDescriptorFiles = 256,
    int maximumDescriptorBytes = 4 * 1024 * 1024,
    int maximumDependencyDepth = 32,
    int maximumResponses = 1024,
  }) {
    if (_closed) throw StateError('The reflection service is closed.');
    if (_activeCall != null) {
      throw StateError('A reflection operation is already active.');
    }
    final secrets = runtimeSecrets.toList();
    final requests = StreamController<reflection.ServerReflectionRequest>();
    final call = _client.serverReflectionInfo(
      requests.stream,
      options: CallOptions(metadata: metadata, timeout: deadline),
    );
    _activeCall = call;
    _activeRequests = requests;
    final rawFuture =
        _discover(
          call,
          requests,
          secrets,
          maximumServices,
          maximumDescriptorFiles,
          maximumDescriptorBytes,
          maximumDependencyDepth,
          maximumResponses,
        ).whenComplete(() {
          secrets.clear();
          _activeCall = null;
          _activeRequests = null;
        });
    final result = Completer<GrpcReflectionResult>();
    final deadlineTimer = Timer(deadline, () {
      if (result.isCompleted) return;
      result.completeError(
        const GrpcReflectionException(
          category: GrpcReflectionFailureCategory.deadlineExceeded,
          message: 'Reflection deadline exceeded.',
          statusCode: StatusCode.deadlineExceeded,
        ),
      );
      unawaited(call.cancel());
      if (!requests.isClosed) unawaited(requests.close());
    });
    unawaited(
      rawFuture.then(
        (value) {
          deadlineTimer.cancel();
          if (!result.isCompleted) result.complete(value);
        },
        onError: (Object error, StackTrace stackTrace) {
          deadlineTimer.cancel();
          if (!result.isCompleted) result.completeError(error, stackTrace);
        },
      ),
    );
    return GrpcReflectionOperation._(result.future, () async {
      deadlineTimer.cancel();
      if (!result.isCompleted) {
        result.completeError(
          const GrpcReflectionException(
            category: GrpcReflectionFailureCategory.cancelled,
            message: 'Reflection was cancelled.',
            statusCode: StatusCode.cancelled,
          ),
        );
      }
      await call.cancel();
      if (!requests.isClosed) await requests.close();
    });
  }

  Future<GrpcReflectionResult> _discover(
    ResponseStream<reflection.ServerReflectionResponse> call,
    StreamController<reflection.ServerReflectionRequest> requests,
    List<String> runtimeSecrets,
    int maximumServices,
    int maximumDescriptorFiles,
    int maximumDescriptorBytes,
    int maximumDependencyDepth,
    int maximumResponses,
  ) async {
    final iterator = StreamIterator<reflection.ServerReflectionResponse>(call);
    var responseCount = 0;
    final files = <String, Uint8List>{};
    var totalBytes = 0;

    Future<reflection.ServerReflectionResponse> exchange(
      reflection.ServerReflectionRequest request,
    ) async {
      requests.add(request);
      if (!await iterator.moveNext()) {
        throw const GrpcReflectionException(
          category: GrpcReflectionFailureCategory.malformedDescriptorResponse,
          message: 'Reflection stream ended before a response.',
        );
      }
      if (++responseCount > maximumResponses) {
        throw const GrpcReflectionException(
          category: GrpcReflectionFailureCategory.limitsExceeded,
          message: 'Reflection response limit exceeded.',
        );
      }
      final response = iterator.current;
      if (response.hasErrorResponse()) {
        throw _protocolError(response.errorResponse, runtimeSecrets);
      }
      return response;
    }

    void addDescriptorBytes(List<int> bytes) {
      descriptor.FileDescriptorProto file;
      try {
        file = descriptor.FileDescriptorProto.fromBuffer(bytes);
      } on Object {
        throw const GrpcReflectionException(
          category: GrpcReflectionFailureCategory.malformedDescriptorResponse,
          message: 'Server returned an invalid FileDescriptorProto.',
        );
      }
      if (file.name.isEmpty) {
        throw const GrpcReflectionException(
          category: GrpcReflectionFailureCategory.malformedDescriptorResponse,
          message: 'Server returned a descriptor without a filename.',
        );
      }
      final copy = Uint8List.fromList(bytes);
      final old = files[file.name];
      if (old != null && !_equalBytes(old, copy)) {
        throw const GrpcReflectionException(
          category: GrpcReflectionFailureCategory.descriptorConflict,
          message: 'Server returned conflicting descriptors for one filename.',
        );
      }
      if (old == null) {
        if (files.length >= maximumDescriptorFiles ||
            totalBytes + copy.length > maximumDescriptorBytes) {
          throw const GrpcReflectionException(
            category: GrpcReflectionFailureCategory.limitsExceeded,
            message: 'Reflected descriptor limits exceeded.',
          );
        }
        files[file.name] = copy;
        totalBytes += copy.length;
      }
    }

    try {
      final listed = await exchange(
        reflection.ServerReflectionRequest(listServices: ''),
      );
      if (!listed.hasListServicesResponse()) {
        throw const GrpcReflectionException(
          category: GrpcReflectionFailureCategory.malformedDescriptorResponse,
          message: 'Reflection list-services response is missing.',
        );
      }
      final services =
          listed.listServicesResponse.service
              .map((item) => item.name)
              .where(
                (name) =>
                    name.isNotEmpty &&
                    name != 'grpc.reflection.v1.ServerReflection',
              )
              .toSet()
              .toList()
            ..sort();
      if (services.length > maximumServices) {
        throw const GrpcReflectionException(
          category: GrpcReflectionFailureCategory.limitsExceeded,
          message: 'Reflected service limit exceeded.',
        );
      }
      for (final service in services) {
        final response = await exchange(
          reflection.ServerReflectionRequest(fileContainingSymbol: service),
        );
        if (!response.hasFileDescriptorResponse()) {
          throw const GrpcReflectionException(
            category: GrpcReflectionFailureCategory.malformedDescriptorResponse,
            message: 'Reflection descriptor response is missing.',
          );
        }
        for (final bytes
            in response.fileDescriptorResponse.fileDescriptorProto) {
          addDescriptorBytes(bytes);
        }
      }

      for (var depth = 0; depth <= maximumDependencyDepth; depth++) {
        final missing = <String>{};
        for (final bytes in files.values) {
          final file = descriptor.FileDescriptorProto.fromBuffer(bytes);
          missing.addAll(
            file.dependency.where((name) => !files.containsKey(name)),
          );
        }
        if (missing.isEmpty) break;
        if (depth == maximumDependencyDepth) {
          throw const GrpcReflectionException(
            category: GrpcReflectionFailureCategory.limitsExceeded,
            message: 'Reflection dependency depth exceeded.',
          );
        }
        final names = missing.toList()..sort();
        for (final name in names) {
          final response = await exchange(
            reflection.ServerReflectionRequest(fileByFilename: name),
          );
          if (!response.hasFileDescriptorResponse()) {
            throw const GrpcReflectionException(
              category:
                  GrpcReflectionFailureCategory.malformedDescriptorResponse,
              message: 'Reflection dependency response is missing.',
            );
          }
          for (final bytes
              in response.fileDescriptorResponse.fileDescriptorProto) {
            addDescriptorBytes(bytes);
          }
        }
      }
      await requests.close();
      await iterator.cancel();
      final orderedNames = files.keys.toList()..sort();
      final set = descriptor.FileDescriptorSet(
        file: orderedNames.map(
          (name) => descriptor.FileDescriptorProto.fromBuffer(files[name]!),
        ),
      );
      final snapshot = const GrpcDescriptorLoader().load(
        Uint8List.fromList(set.writeToBuffer()),
      );
      return GrpcReflectionResult(
        services: List<String>.unmodifiable(services),
        snapshot: snapshot,
      );
    } on GrpcReflectionException {
      rethrow;
    } on GrpcError catch (error) {
      throw _grpcError(error, runtimeSecrets);
    } on Object {
      throw const GrpcReflectionException(
        category: GrpcReflectionFailureCategory.transportFailure,
        message: 'Reflection transport failed.',
      );
    } finally {
      if (!requests.isClosed) await requests.close();
      await iterator.cancel();
    }
  }

  Future<void> shutdown() async {
    if (_closed) return;
    _closed = true;
    if (!(_activeRequests?.isClosed ?? true)) {
      await _activeRequests?.close();
    }
    await _activeCall?.cancel();
    await _channel.shutdown();
  }

  GrpcReflectionException _protocolError(
    reflection.ErrorResponse error,
    List<String> runtimeSecrets,
  ) {
    final grpc = GrpcError.custom(error.errorCode, error.errorMessage);
    return _grpcError(grpc, runtimeSecrets);
  }

  GrpcReflectionException _grpcError(
    GrpcError error,
    List<String> runtimeSecrets,
  ) {
    final safeMessage =
        SecretMasker.redactStructured(
              error.message ?? 'Reflection failed.',
              runtimeSecrets: runtimeSecrets,
            )
            as String;
    final category = switch (error.code) {
      StatusCode.unimplemented =>
        GrpcReflectionFailureCategory.reflectionDisabled,
      StatusCode.permissionDenied =>
        GrpcReflectionFailureCategory.permissionDenied,
      StatusCode.unauthenticated =>
        GrpcReflectionFailureCategory.unauthenticated,
      StatusCode.deadlineExceeded =>
        GrpcReflectionFailureCategory.deadlineExceeded,
      StatusCode.cancelled => GrpcReflectionFailureCategory.cancelled,
      StatusCode.unavailable
          when RegExp(
            r'tls|certificate|handshake',
            caseSensitive: false,
          ).hasMatch(safeMessage) =>
        GrpcReflectionFailureCategory.tlsFailure,
      StatusCode.unavailable => GrpcReflectionFailureCategory.transportFailure,
      _ => GrpcReflectionFailureCategory.transportFailure,
    };
    return GrpcReflectionException(
      category: category,
      statusCode: error.code,
      message: safeMessage,
    );
  }
}

bool _equalBytes(List<int> left, List<int> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}
