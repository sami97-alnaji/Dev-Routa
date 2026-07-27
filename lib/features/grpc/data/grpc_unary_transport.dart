import 'dart:typed_data';

import 'package:grpc/grpc.dart';

import '../../../core/security/secret_masker.dart';
import '../domain/grpc_descriptor_models.dart';
import '../domain/grpc_unary_models.dart';

class GrpcUnaryCall {
  GrpcUnaryCall._(this.response, this._cancel);

  final Future<GrpcUnaryResponse> response;
  final Future<void> Function() _cancel;

  Future<void> cancel() => _cancel();
}

class GrpcUnaryTransport {
  GrpcUnaryTransport.forChannel(this._channel)
    : _client = _RawGrpcClient(_channel);

  factory GrpcUnaryTransport.connect({
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
    return GrpcUnaryTransport.forChannel(
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
  final _RawGrpcClient _client;
  bool _closed = false;

  GrpcUnaryCall invoke({
    required GrpcMethodDescriptor method,
    required Uint8List request,
    Map<String, String> metadata = const <String, String>{},
    Duration? deadline,
    Iterable<String> runtimeSecrets = const <String>[],
  }) {
    if (_closed) {
      throw StateError('The gRPC transport is closed.');
    }
    if (method.streamingKind != GrpcStreamingKind.unary) {
      throw ArgumentError.value(
        method.streamingKind,
        'method',
        'Only unary gRPC methods are supported.',
      );
    }

    final raw = _client.unary(
      method.path,
      request,
      CallOptions(metadata: metadata, timeout: deadline),
    );
    return GrpcUnaryCall._(
      _collect(raw, runtimeSecrets: runtimeSecrets),
      raw.cancel,
    );
  }

  Future<void> shutdown() async {
    if (_closed) return;
    _closed = true;
    await _channel.shutdown();
  }

  Future<GrpcUnaryResponse> _collect(
    ResponseFuture<Uint8List> call, {
    required Iterable<String> runtimeSecrets,
  }) async {
    try {
      final headers = await call.headers;
      final message = await call;
      final trailers = await call.trailers;
      return GrpcUnaryResponse(
        message: message,
        headers: _sanitizeMetadata(headers, runtimeSecrets),
        trailers: _sanitizeMetadata(trailers, runtimeSecrets),
      );
    } on GrpcError catch (error) {
      throw GrpcUnaryException(
        statusCode: error.code,
        statusName: StatusCode.name(error.code) ?? 'UNKNOWN',
        message:
            SecretMasker.redactStructured(
                  error.message ?? 'gRPC call failed.',
                  runtimeSecrets: runtimeSecrets,
                )
                as String,
        trailers: _sanitizeMetadata(
          error.trailers ?? const <String, String>{},
          runtimeSecrets,
        ),
      );
    }
  }

  Map<String, String> _sanitizeMetadata(
    Map<String, String> metadata,
    Iterable<String> runtimeSecrets,
  ) => Map<String, String>.unmodifiable(
    SecretMasker.redactHeaders(metadata).map(
      (key, value) => MapEntry(
        key,
        SecretMasker.redactStructured(value, runtimeSecrets: runtimeSecrets)
            as String,
      ),
    ),
  );
}

class _RawGrpcClient extends Client {
  _RawGrpcClient(super.channel);

  ResponseFuture<Uint8List> unary(
    String path,
    Uint8List request,
    CallOptions options,
  ) => $createUnaryCall(
    ClientMethod<Uint8List, Uint8List>(
      path,
      (value) => value,
      Uint8List.fromList,
    ),
    request,
    options: options,
  );
}
