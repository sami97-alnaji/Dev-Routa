import 'dart:async';

import '../../../core/security/secret_masker.dart';
import '../data/grpc_streaming_transport.dart';
import '../data/grpc_unary_transport.dart';
import '../domain/grpc_codec_models.dart';
import '../domain/grpc_descriptor_models.dart';
import '../domain/grpc_dynamic_invocation_models.dart';
import '../domain/grpc_streaming_models.dart';
import 'grpc_dynamic_message_codec.dart';

class GrpcDynamicInvocationService {
  const GrpcDynamicInvocationService({
    required this.codec,
    required this.unaryTransport,
    required this.streamingTransport,
  });

  final GrpcDynamicMessageCodec codec;
  final GrpcUnaryTransport unaryTransport;
  final GrpcStreamingTransport streamingTransport;

  Future<GrpcDynamicUnaryResult> invokeUnary({
    required GrpcMethodDescriptor method,
    required Object? input,
    Map<String, String> metadata = const <String, String>{},
    Duration? deadline,
    Iterable<String> runtimeSecrets = const <String>[],
  }) async {
    final secrets = runtimeSecrets.toList();
    try {
      final request = codec.encode(method.inputType, input);
      final response = await unaryTransport
          .invoke(
            method: method,
            request: request,
            metadata: metadata,
            deadline: deadline,
            runtimeSecrets: secrets,
          )
          .response;
      return GrpcDynamicUnaryResult(
        rawBytes: response.message,
        payload: SecretMasker.redactStructured(
          codec.decode(method.outputType, response.message),
          runtimeSecrets: secrets,
        ),
        headers: response.headers,
        trailers: response.trailers,
      );
    } finally {
      secrets.clear();
    }
  }

  GrpcDynamicStreamingSession startServerStreaming({
    required GrpcMethodDescriptor method,
    required Object? input,
    Map<String, String> metadata = const <String, String>{},
    Duration? deadline,
    Iterable<String> runtimeSecrets = const <String>[],
    int maximumRetainedEvents = 500,
    int maximumRetainedBytes = 4 * 1024 * 1024,
  }) {
    final secrets = runtimeSecrets.toList();
    final raw = streamingTransport.startServerStreaming(
      method: method,
      requestBytes: codec.encode(method.inputType, input),
      metadata: metadata,
      deadline: deadline,
      runtimeSecrets: secrets,
      maximumRetainedEvents: maximumRetainedEvents,
      maximumRetainedBytes: maximumRetainedBytes,
    );
    return GrpcDynamicStreamingSession._(
      raw: raw,
      codec: codec,
      method: method,
      runtimeSecrets: secrets,
    );
  }

  GrpcDynamicStreamingSession startClientStreaming({
    required GrpcMethodDescriptor method,
    Map<String, String> metadata = const <String, String>{},
    Duration? deadline,
    Iterable<String> runtimeSecrets = const <String>[],
    int maximumQueuedOutboundMessages = 32,
  }) {
    final secrets = runtimeSecrets.toList();
    final raw = streamingTransport.startClientStreaming(
      method: method,
      metadata: metadata,
      deadline: deadline,
      runtimeSecrets: secrets,
      maximumQueuedOutboundMessages: maximumQueuedOutboundMessages,
    );
    return GrpcDynamicStreamingSession._(
      raw: raw,
      codec: codec,
      method: method,
      runtimeSecrets: secrets,
    );
  }

  GrpcDynamicStreamingSession startBidirectionalStreaming({
    required GrpcMethodDescriptor method,
    Map<String, String> metadata = const <String, String>{},
    Duration? deadline,
    Iterable<String> runtimeSecrets = const <String>[],
    int maximumQueuedOutboundMessages = 32,
    int maximumRetainedEvents = 500,
    int maximumRetainedBytes = 4 * 1024 * 1024,
  }) {
    final secrets = runtimeSecrets.toList();
    final raw = streamingTransport.startBidirectionalStreaming(
      method: method,
      metadata: metadata,
      deadline: deadline,
      runtimeSecrets: secrets,
      maximumQueuedOutboundMessages: maximumQueuedOutboundMessages,
      maximumRetainedEvents: maximumRetainedEvents,
      maximumRetainedBytes: maximumRetainedBytes,
    );
    return GrpcDynamicStreamingSession._(
      raw: raw,
      codec: codec,
      method: method,
      runtimeSecrets: secrets,
    );
  }
}

class GrpcDynamicStreamingSession {
  GrpcDynamicStreamingSession._({
    required this.raw,
    required GrpcDynamicMessageCodec codec,
    required GrpcMethodDescriptor method,
    required List<String> runtimeSecrets,
  }) : _codec = codec,
       _method = method,
       _runtimeSecrets = runtimeSecrets {
    _subscription = raw.events.listen(_onRawEvent);
    unawaited(
      raw.result.then(
        (value) {
          if (!_result.isCompleted) {
            _result.complete(
              GrpcDynamicStreamingResult(
                rawBytes: value.message,
                payload: value.message.isEmpty
                    ? null
                    : _sanitize(
                        _codec.decode(_method.outputType, value.message),
                      ),
                headers: value.headers,
                trailers: value.trailers,
              ),
            );
          }
          _runtimeSecrets.clear();
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!_result.isCompleted) _result.completeError(error, stackTrace);
          _runtimeSecrets.clear();
        },
      ),
    );
  }

  final GrpcStreamingSession raw;
  final GrpcDynamicMessageCodec _codec;
  final GrpcMethodDescriptor _method;
  final List<String> _runtimeSecrets;
  final StreamController<GrpcDynamicStreamEvent> _events =
      StreamController<GrpcDynamicStreamEvent>.broadcast();
  final Completer<GrpcDynamicStreamingResult> _result =
      Completer<GrpcDynamicStreamingResult>();
  late final StreamSubscription<GrpcStreamEvent> _subscription;

  String get sessionId => raw.sessionId;
  GrpcStreamingSessionState get state => raw.state;
  Stream<GrpcDynamicStreamEvent> get events => _events.stream;
  Future<GrpcDynamicStreamingResult> get result => _result.future;

  void send(Object? input) {
    raw.send(_codec.encode(_method.inputType, input));
  }

  Future<void> completeClientStream() => raw.completeClientStream();
  Future<void> cancel() => raw.cancel();

  Future<void> close() async {
    await raw.close();
    await _subscription.cancel();
    _runtimeSecrets.clear();
    if (!_events.isClosed) await _events.close();
  }

  void _onRawEvent(GrpcStreamEvent event) {
    Object? payload;
    GrpcCodecException? failure;
    if (event.category == GrpcStreamEventCategory.message &&
        event.bytes != null) {
      final type = event.direction == GrpcStreamEventDirection.sent
          ? _method.inputType
          : _method.outputType;
      final root = event.direction == GrpcStreamEventDirection.sent
          ? 'request'
          : 'response';
      try {
        payload = _sanitize(_codec.decode(type, event.bytes!, rootPath: root));
      } on GrpcCodecException catch (error) {
        failure = error;
      }
    }
    _events.add(
      GrpcDynamicStreamEvent(
        raw: event,
        payload: payload,
        decodeFailure: failure,
      ),
    );
  }

  Object? _sanitize(Object? value) =>
      SecretMasker.redactStructured(value, runtimeSecrets: _runtimeSecrets);
}
