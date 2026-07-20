import 'dart:typed_data';

import '../../../shared/models/api_models.dart';

enum RealtimeProtocolType { webSocket, sse, httpStream }

enum HttpStreamMode { raw, lines, ndjson }

enum RealtimeConnectionStatus {
  idle,
  connecting,
  connected,
  reconnecting,
  completed,
  disconnected,
  failed,
  cancelled,
}

enum RealtimeMessageDirection { inbound, outbound, system }

enum RealtimePayloadType {
  text,
  json,
  binary,
  event,
  chunk,
  ndjson,
  diagnostic,
}

class ReconnectPolicy {
  const ReconnectPolicy({
    this.enabled = false,
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 15),
  });
  final bool enabled;
  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;
  Duration delayFor(int attempt) {
    final milliseconds =
        initialDelay.inMilliseconds * (1 << attempt.clamp(0, 10));
    return Duration(
      milliseconds: milliseconds
          .clamp(initialDelay.inMilliseconds, maxDelay.inMilliseconds)
          .toInt(),
    );
  }
}

class RealtimeSessionConfig {
  const RealtimeSessionConfig({
    required this.id,
    required this.protocol,
    required this.url,
    this.name = 'Untitled realtime request',
    this.workspaceId,
    this.method = HttpMethod.get,
    this.headers = const <RequestHeaderModel>[],
    this.queryParams = const <RequestQueryParamModel>[],
    this.body,
    this.auth = const RequestAuthModel(),
    this.subprotocols = const <String>[],
    this.connectionTimeout = const Duration(seconds: 15),
    this.reconnectPolicy = const ReconnectPolicy(),
    this.lastEventId,
    this.maxEvents = 500,
    this.streamMode = HttpStreamMode.raw,
    this.collectionId,
    this.requestId,
    this.environmentId,
    this.productionEnvironment = false,
  });
  final String id;
  final RealtimeProtocolType protocol;
  final String url;
  final String name;
  final String? workspaceId;
  final HttpMethod method;
  final List<RequestHeaderModel> headers;
  final List<RequestQueryParamModel> queryParams;
  final RequestBodyModel? body;
  final RequestAuthModel auth;
  final List<String> subprotocols;
  final Duration connectionTimeout;
  final ReconnectPolicy reconnectPolicy;
  final String? lastEventId;
  final int maxEvents;
  final HttpStreamMode streamMode;
  final String? collectionId;
  final String? requestId;
  final String? environmentId;
  final bool productionEnvironment;

  RealtimeSessionConfig copyWith({
    String? url,
    RealtimeProtocolType? protocol,
    String? name,
    String? lastEventId,
    HttpMethod? method,
    List<RequestHeaderModel>? headers,
    List<RequestQueryParamModel>? queryParams,
    RequestBodyModel? body,
    RequestAuthModel? auth,
    List<String>? subprotocols,
    Duration? connectionTimeout,
    ReconnectPolicy? reconnectPolicy,
    int? maxEvents,
    HttpStreamMode? streamMode,
    String? collectionId,
    String? requestId,
    String? environmentId,
    bool? productionEnvironment,
    String? workspaceId,
  }) => RealtimeSessionConfig(
    id: id,
    protocol: protocol ?? this.protocol,
    url: url ?? this.url,
    name: name ?? this.name,
    workspaceId: workspaceId ?? this.workspaceId,
    method: method ?? this.method,
    headers: headers ?? this.headers,
    queryParams: queryParams ?? this.queryParams,
    body: body ?? this.body,
    auth: auth ?? this.auth,
    subprotocols: subprotocols ?? this.subprotocols,
    connectionTimeout: connectionTimeout ?? this.connectionTimeout,
    reconnectPolicy: reconnectPolicy ?? this.reconnectPolicy,
    lastEventId: lastEventId ?? this.lastEventId,
    maxEvents: maxEvents ?? this.maxEvents,
    streamMode: streamMode ?? this.streamMode,
    collectionId: collectionId ?? this.collectionId,
    requestId: requestId ?? this.requestId,
    environmentId: environmentId ?? this.environmentId,
    productionEnvironment: productionEnvironment ?? this.productionEnvironment,
  );
}

class RealtimeMessage {
  const RealtimeMessage({
    required this.sequence,
    required this.direction,
    required this.payloadType,
    required this.timestamp,
    required this.content,
    this.bytes,
    this.eventName,
    this.eventId,
    this.retry,
  });
  final int sequence;
  final RealtimeMessageDirection direction;
  final RealtimePayloadType payloadType;
  final DateTime timestamp;
  final String content;
  final Uint8List? bytes;
  final String? eventName;
  final String? eventId;
  final int? retry;
  int get sizeBytes => bytes?.length ?? content.length;
}

class RealtimeFailure {
  const RealtimeFailure(this.category, this.message, {this.code});
  final String category;
  final String message;
  final int? code;
}

class RealtimeMetrics {
  const RealtimeMetrics({
    this.startedAt,
    this.endedAt,
    this.bytesIn = 0,
    this.bytesOut = 0,
    this.reconnectAttempts = 0,
  });
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int bytesIn;
  final int bytesOut;
  final int reconnectAttempts;
  Duration? get duration => startedAt == null
      ? null
      : (endedAt ?? DateTime.now()).difference(startedAt!);
  RealtimeMetrics copyWith({
    DateTime? startedAt,
    DateTime? endedAt,
    int? bytesIn,
    int? bytesOut,
    int? reconnectAttempts,
  }) => RealtimeMetrics(
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt ?? this.endedAt,
    bytesIn: bytesIn ?? this.bytesIn,
    bytesOut: bytesOut ?? this.bytesOut,
    reconnectAttempts: reconnectAttempts ?? this.reconnectAttempts,
  );
}

class RealtimeSessionState {
  const RealtimeSessionState({
    this.status = RealtimeConnectionStatus.idle,
    this.config,
    this.messages = const <RealtimeMessage>[],
    this.metrics = const RealtimeMetrics(),
    this.failure,
    this.isDirty = false,
    this.droppedMessages = 0,
  });
  final RealtimeConnectionStatus status;
  final RealtimeSessionConfig? config;
  final List<RealtimeMessage> messages;
  final RealtimeMetrics metrics;
  final RealtimeFailure? failure;
  final bool isDirty;
  final int droppedMessages;
  bool get canSend =>
      status == RealtimeConnectionStatus.connected &&
      config?.protocol == RealtimeProtocolType.webSocket;
  RealtimeSessionState copyWith({
    RealtimeConnectionStatus? status,
    RealtimeSessionConfig? config,
    List<RealtimeMessage>? messages,
    RealtimeMetrics? metrics,
    RealtimeFailure? failure,
    bool clearFailure = false,
    bool? isDirty,
    int? droppedMessages,
  }) => RealtimeSessionState(
    status: status ?? this.status,
    config: config ?? this.config,
    messages: messages ?? this.messages,
    metrics: metrics ?? this.metrics,
    failure: clearFailure ? null : (failure ?? this.failure),
    isDirty: isDirty ?? this.isDirty,
    droppedMessages: droppedMessages ?? this.droppedMessages,
  );
}

class RealtimeSessionSnapshot {
  const RealtimeSessionSnapshot({required this.config, required this.state});
  final RealtimeSessionConfig config;
  final RealtimeSessionState state;
}
