import 'dart:async';
import 'dart:typed_data';

import 'package:grpc/grpc.dart';

import '../../../core/security/secret_masker.dart';
import '../domain/grpc_descriptor_models.dart';
import '../domain/grpc_streaming_models.dart';

class GrpcStreamingTransport {
  GrpcStreamingTransport.forChannel(this._channel)
    : _client = _RawStreamingClient(_channel);

  factory GrpcStreamingTransport.connect({
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
    return GrpcStreamingTransport.forChannel(
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
  final _RawStreamingClient _client;
  final Set<GrpcStreamingSession> _sessions = <GrpcStreamingSession>{};
  bool _closed = false;

  GrpcStreamingSession startServerStreaming({
    required GrpcMethodDescriptor method,
    required Uint8List requestBytes,
    Map<String, String> metadata = const <String, String>{},
    Duration? deadline,
    Iterable<String> runtimeSecrets = const <String>[],
    int maximumRetainedEvents = 500,
    int maximumRetainedBytes = 4 * 1024 * 1024,
    int maximumSingleMessageBytes = 1024 * 1024,
  }) {
    _ensureOpen();
    _requireKind(method, GrpcStreamingKind.serverStreaming);
    final response = _client.streaming(
      method.path,
      Stream<Uint8List>.value(requestBytes),
      CallOptions(metadata: metadata, timeout: deadline),
    );
    final session = _session(
      response,
      runtimeSecrets,
      maximumRetainedEvents,
      maximumRetainedBytes,
      maximumSingleMessageBytes,
      0,
      null,
    );
    session.recordSent(requestBytes);
    return session;
  }

  GrpcStreamingSession startClientStreaming({
    required GrpcMethodDescriptor method,
    Map<String, String> metadata = const <String, String>{},
    Duration? deadline,
    Iterable<String> runtimeSecrets = const <String>[],
    int maximumRetainedEvents = 500,
    int maximumRetainedBytes = 4 * 1024 * 1024,
    int maximumSingleMessageBytes = 1024 * 1024,
    int maximumQueuedOutboundMessages = 32,
  }) {
    _ensureOpen();
    _requireKind(method, GrpcStreamingKind.clientStreaming);
    return _startWritable(
      method,
      metadata,
      deadline,
      runtimeSecrets,
      maximumRetainedEvents,
      maximumRetainedBytes,
      maximumSingleMessageBytes,
      maximumQueuedOutboundMessages,
      singleResponse: true,
    );
  }

  GrpcStreamingSession startBidirectionalStreaming({
    required GrpcMethodDescriptor method,
    Map<String, String> metadata = const <String, String>{},
    Duration? deadline,
    Iterable<String> runtimeSecrets = const <String>[],
    int maximumRetainedEvents = 500,
    int maximumRetainedBytes = 4 * 1024 * 1024,
    int maximumSingleMessageBytes = 1024 * 1024,
    int maximumQueuedOutboundMessages = 32,
  }) {
    _ensureOpen();
    _requireKind(method, GrpcStreamingKind.bidirectionalStreaming);
    return _startWritable(
      method,
      metadata,
      deadline,
      runtimeSecrets,
      maximumRetainedEvents,
      maximumRetainedBytes,
      maximumSingleMessageBytes,
      maximumQueuedOutboundMessages,
      singleResponse: false,
    );
  }

  GrpcStreamingSession _startWritable(
    GrpcMethodDescriptor method,
    Map<String, String> metadata,
    Duration? deadline,
    Iterable<String> runtimeSecrets,
    int maximumRetainedEvents,
    int maximumRetainedBytes,
    int maximumSingleMessageBytes,
    int maximumQueuedOutboundMessages, {
    required bool singleResponse,
  }) {
    final requests = StreamController<Uint8List>();
    final response = _client.streaming(
      method.path,
      requests.stream,
      CallOptions(metadata: metadata, timeout: deadline),
    );
    return _session(
      response,
      runtimeSecrets,
      maximumRetainedEvents,
      maximumRetainedBytes,
      maximumSingleMessageBytes,
      maximumQueuedOutboundMessages,
      requests,
      singleResponse: singleResponse,
    );
  }

  GrpcStreamingSession _session(
    ResponseStream<Uint8List> response,
    Iterable<String> runtimeSecrets,
    int maximumRetainedEvents,
    int maximumRetainedBytes,
    int maximumSingleMessageBytes,
    int maximumQueuedOutboundMessages,
    StreamController<Uint8List>? requests, {
    bool singleResponse = false,
  }) {
    late final GrpcStreamingSession session;
    session = GrpcStreamingSession._(
      response: response,
      requests: requests,
      runtimeSecrets: runtimeSecrets.toList(),
      maximumRetainedEvents: maximumRetainedEvents,
      maximumRetainedBytes: maximumRetainedBytes,
      maximumSingleMessageBytes: maximumSingleMessageBytes,
      maximumQueuedOutboundMessages: maximumQueuedOutboundMessages,
      singleResponse: singleResponse,
      onClosed: () => _sessions.remove(session),
    );
    _sessions.add(session);
    session.start();
    return session;
  }

  Future<void> shutdown() async {
    if (_closed) return;
    _closed = true;
    await Future.wait(_sessions.toList().map((session) => session.close()));
    _sessions.clear();
    await _channel.shutdown();
  }

  void _ensureOpen() {
    if (_closed) throw StateError('The gRPC streaming transport is closed.');
  }

  void _requireKind(GrpcMethodDescriptor method, GrpcStreamingKind expected) {
    if (method.streamingKind != expected) {
      throw ArgumentError.value(
        method.streamingKind,
        'method',
        'Expected ${expected.name} method.',
      );
    }
  }
}

class GrpcStreamingSession {
  GrpcStreamingSession._({
    required ResponseStream<Uint8List> response,
    required StreamController<Uint8List>? requests,
    required List<String> runtimeSecrets,
    required this.maximumRetainedEvents,
    required this.maximumRetainedBytes,
    required this.maximumSingleMessageBytes,
    required this.maximumQueuedOutboundMessages,
    required bool singleResponse,
    required void Function() onClosed,
  }) : _response = response,
       _requests = requests,
       _runtimeSecrets = runtimeSecrets,
       _singleResponse = singleResponse,
       _onClosed = onClosed,
       sessionId = Object().hashCode.toRadixString(16);

  final String sessionId;
  final int maximumRetainedEvents;
  final int maximumRetainedBytes;
  final int maximumSingleMessageBytes;
  final int maximumQueuedOutboundMessages;
  final ResponseStream<Uint8List> _response;
  final StreamController<Uint8List>? _requests;
  final List<String> _runtimeSecrets;
  final bool _singleResponse;
  final void Function() _onClosed;
  final StreamController<GrpcStreamEvent> _events =
      StreamController<GrpcStreamEvent>.broadcast();
  final Completer<GrpcStreamingResult> _result =
      Completer<GrpcStreamingResult>();
  final List<GrpcStreamEvent> _timeline = <GrpcStreamEvent>[];

  StreamSubscription<Uint8List>? _subscription;
  GrpcStreamingSessionState _state = GrpcStreamingSessionState.connecting;
  int _generation = 0;
  int _sequence = 0;
  int _retainedBytes = 0;
  int _queuedOutbound = 0;
  int droppedEventCount = 0;
  Uint8List? _singleMessage;
  Map<String, String> _headers = const <String, String>{};
  Map<String, String> _trailers = const <String, String>{};

  GrpcStreamingSessionState get state => _state;
  Stream<GrpcStreamEvent> get events => _events.stream;
  Future<GrpcStreamingResult> get result => _result.future;
  List<GrpcStreamEvent> get timeline =>
      List<GrpcStreamEvent>.unmodifiable(_timeline);

  void start() {
    final generation = _generation;
    _state = GrpcStreamingSessionState.active;
    unawaited(_captureHeaders(generation));
    _subscription = _response.listen(
      (bytes) => _receive(bytes, generation),
      onError: (Object error, StackTrace stackTrace) =>
          _fail(error, stackTrace, generation),
      onDone: () => _complete(generation),
      cancelOnError: true,
    );
  }

  void send(Uint8List bytes) {
    if (_requests == null) {
      throw StateError('This session does not accept client messages.');
    }
    if (_state != GrpcStreamingSessionState.active) {
      throw StateError('The client stream is not active.');
    }
    if (bytes.length > maximumSingleMessageBytes) {
      throw StateError('Outbound message exceeds the byte limit.');
    }
    if (_queuedOutbound >= maximumQueuedOutboundMessages) {
      throw StateError('Outbound message queue is full.');
    }
    _queuedOutbound++;
    _requests.add(Uint8List.fromList(bytes));
    recordSent(bytes);
    scheduleMicrotask(() {
      if (_queuedOutbound > 0) _queuedOutbound--;
    });
  }

  void recordSent(Uint8List bytes) {
    _append(
      GrpcStreamEvent(
        sequence: _sequence++,
        direction: GrpcStreamEventDirection.sent,
        category: GrpcStreamEventCategory.message,
        timestamp: DateTime.now().toUtc(),
        bytes: Uint8List.fromList(bytes),
      ),
    );
  }

  Future<void> completeClientStream() async {
    if (_requests == null) {
      throw StateError('This session has no client stream.');
    }
    if (_state == GrpcStreamingSessionState.clientHalfClosed) return;
    if (_state != GrpcStreamingSessionState.active) {
      throw StateError('The client stream is not active.');
    }
    _state = GrpcStreamingSessionState.clientHalfClosed;
    await _requests.close();
  }

  Future<void> cancel() async {
    if (_isTerminal) return;
    _state = GrpcStreamingSessionState.cancelling;
    _generation++;
    await _requests?.close();
    await _response.cancel();
    await _subscription?.cancel();
    _state = GrpcStreamingSessionState.cancelled;
    _terminal(StatusCode.cancelled, 'CANCELLED', 'Cancelled by user.');
  }

  Future<void> close() async {
    if (!_isTerminal) await cancel();
    _generation++;
    await _subscription?.cancel();
    if (!(_requests?.isClosed ?? true)) await _requests?.close();
    _runtimeSecrets.clear();
    if (!_events.isClosed) await _events.close();
    _state = GrpcStreamingSessionState.closed;
    _onClosed();
  }

  bool get _isTerminal => <GrpcStreamingSessionState>{
    GrpcStreamingSessionState.serverCompleted,
    GrpcStreamingSessionState.cancelled,
    GrpcStreamingSessionState.failed,
    GrpcStreamingSessionState.closed,
  }.contains(_state);

  Future<void> _captureHeaders(int generation) async {
    try {
      final headers = await _response.headers;
      if (!_valid(generation)) return;
      _headers = _sanitize(headers);
      _append(
        GrpcStreamEvent(
          sequence: _sequence++,
          direction: GrpcStreamEventDirection.system,
          category: GrpcStreamEventCategory.headers,
          timestamp: DateTime.now().toUtc(),
          metadata: _headers,
        ),
      );
    } on Object {
      // The response listener owns terminal error mapping.
    }
  }

  void _receive(Uint8List bytes, int generation) {
    if (!_valid(generation)) return;
    if (bytes.length > maximumSingleMessageBytes) {
      unawaited(cancel());
      return;
    }
    final copy = Uint8List.fromList(bytes);
    if (_singleResponse && _singleMessage != null) {
      _fail(
        GrpcError.unimplemented('More than one response received'),
        StackTrace.current,
        generation,
      );
      return;
    }
    _singleMessage = copy;
    _append(
      GrpcStreamEvent(
        sequence: _sequence++,
        direction: GrpcStreamEventDirection.received,
        category: GrpcStreamEventCategory.message,
        timestamp: DateTime.now().toUtc(),
        bytes: copy,
      ),
    );
  }

  Future<void> _complete(int generation) async {
    if (!_valid(generation)) return;
    try {
      _trailers = _sanitize(await _response.trailers);
    } on Object {
      _trailers = const <String, String>{};
    }
    if (!_valid(generation)) return;
    _append(
      GrpcStreamEvent(
        sequence: _sequence++,
        direction: GrpcStreamEventDirection.system,
        category: GrpcStreamEventCategory.trailers,
        timestamp: DateTime.now().toUtc(),
        metadata: _trailers,
      ),
    );
    _append(
      GrpcStreamEvent(
        sequence: _sequence++,
        direction: GrpcStreamEventDirection.system,
        category: GrpcStreamEventCategory.status,
        timestamp: DateTime.now().toUtc(),
        statusCode: StatusCode.ok,
        safeMessage: 'OK',
      ),
      terminal: true,
    );
    _state = GrpcStreamingSessionState.serverCompleted;
    if (!_result.isCompleted) {
      if (_singleResponse && _singleMessage == null) {
        _result.completeError(
          const GrpcStreamingException(
            statusCode: StatusCode.unimplemented,
            statusName: 'UNIMPLEMENTED',
            message: 'No response received.',
            trailers: <String, String>{},
          ),
        );
      } else {
        _result.complete(
          GrpcStreamingResult(
            message: _singleMessage ?? Uint8List(0),
            headers: _headers,
            trailers: _trailers,
          ),
        );
      }
    }
    _runtimeSecrets.clear();
  }

  void _fail(Object error, StackTrace stackTrace, int generation) {
    if (!_valid(generation)) return;
    _state = GrpcStreamingSessionState.failed;
    final grpcError = error is GrpcError ? error : GrpcError.unknown();
    final exception = GrpcStreamingException(
      statusCode: grpcError.code,
      statusName: StatusCode.name(grpcError.code) ?? 'UNKNOWN',
      message:
          SecretMasker.redactStructured(
                grpcError.message ?? 'gRPC stream failed.',
                runtimeSecrets: _runtimeSecrets,
              )
              as String,
      trailers: _sanitize(grpcError.trailers ?? const <String, String>{}),
    );
    _terminal(exception.statusCode, exception.statusName, exception.message);
    if (!_result.isCompleted) _result.completeError(exception, stackTrace);
    _runtimeSecrets.clear();
  }

  void _terminal(int code, String name, String message) {
    _append(
      GrpcStreamEvent(
        sequence: _sequence++,
        direction: GrpcStreamEventDirection.system,
        category: GrpcStreamEventCategory.status,
        timestamp: DateTime.now().toUtc(),
        statusCode: code,
        safeMessage: '$name: $message',
      ),
      terminal: true,
    );
    if (!_result.isCompleted && code == StatusCode.cancelled) {
      _result.completeError(
        GrpcStreamingException(
          statusCode: code,
          statusName: name,
          message: message,
          trailers: _trailers,
        ),
      );
    }
  }

  void _append(GrpcStreamEvent event, {bool terminal = false}) {
    if (_events.isClosed || (_isTerminal && !terminal)) return;
    _timeline.add(event);
    _retainedBytes += event.retainedBytes;
    while (_timeline.length > maximumRetainedEvents ||
        _retainedBytes > maximumRetainedBytes) {
      final removable = _timeline.indexWhere(
        (item) => item.category != GrpcStreamEventCategory.status,
      );
      if (removable < 0) break;
      final removed = _timeline.removeAt(removable);
      _retainedBytes -= removed.retainedBytes;
      droppedEventCount++;
    }
    _events.add(event);
  }

  bool _valid(int generation) => generation == _generation && !_isTerminal;

  Map<String, String> _sanitize(Map<String, String> metadata) =>
      Map<String, String>.unmodifiable(
        SecretMasker.redactHeaders(metadata).map(
          (key, value) => MapEntry(
            key,
            SecretMasker.redactStructured(
                  value,
                  runtimeSecrets: _runtimeSecrets,
                )
                as String,
          ),
        ),
      );
}

class _RawStreamingClient extends Client {
  _RawStreamingClient(super.channel);

  ResponseStream<Uint8List> streaming(
    String path,
    Stream<Uint8List> requests,
    CallOptions options,
  ) => $createStreamingCall(
    ClientMethod<Uint8List, Uint8List>(
      path,
      (value) => value,
      Uint8List.fromList,
    ),
    requests,
    options: options,
  );
}
