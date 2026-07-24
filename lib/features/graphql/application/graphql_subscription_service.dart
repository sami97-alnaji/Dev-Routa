import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/security/secret_masker.dart';
import '../data/graphql_subscription_transport.dart';
import '../domain/graphql_document_parser.dart';
import '../domain/graphql_models.dart';
import 'graphql_request_resolver.dart';

enum GraphqlSubscriptionPhase {
  idle,
  resolving,
  connecting,
  awaitingAck,
  subscribing,
  active,
  reconnecting,
  stopping,
  completed,
  disconnected,
  failed,
  cancelled,
  disposed,
}

class GraphqlReconnectPolicy {
  const GraphqlReconnectPolicy({
    this.enabled = false,
    this.resubscribe = false,
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 8),
  }) : assert(maxAttempts >= 0);

  final bool enabled;
  final bool resubscribe;
  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;

  bool get canAutomaticallyResubscribe =>
      enabled && resubscribe && maxAttempts > 0;

  Duration delayForAttempt(int attempt) {
    var milliseconds = initialDelay.inMilliseconds;
    final maximum = maxDelay.inMilliseconds;
    for (var index = 1; index < attempt; index++) {
      if (milliseconds >= maximum) break;
      milliseconds *= 2;
    }
    if (milliseconds > maximum) milliseconds = maximum;
    return Duration(milliseconds: milliseconds);
  }
}

class GraphqlTimelineEvent {
  const GraphqlTimelineEvent({
    required this.sequence,
    required this.receivedAt,
    required this.data,
    this.errors = const <GraphqlResponseError>[],
    this.extensions,
  });
  final int sequence;
  final DateTime receivedAt;
  final Object? data;
  final List<GraphqlResponseError> errors;
  final Object? extensions;
}

class GraphqlSubscriptionTabState {
  const GraphqlSubscriptionTabState({
    this.phase = GraphqlSubscriptionPhase.idle,
    this.events = const <GraphqlTimelineEvent>[],
    this.droppedEvents = 0,
    this.reconnectAttempts = 0,
    this.connectedAt,
    this.error,
  });
  final GraphqlSubscriptionPhase phase;
  final List<GraphqlTimelineEvent> events;
  final int droppedEvents;
  final int reconnectAttempts;
  final DateTime? connectedAt;
  final GraphqlFailure? error;

  bool get isActive => switch (phase) {
    GraphqlSubscriptionPhase.connecting ||
    GraphqlSubscriptionPhase.awaitingAck ||
    GraphqlSubscriptionPhase.subscribing ||
    GraphqlSubscriptionPhase.active ||
    GraphqlSubscriptionPhase.reconnecting ||
    GraphqlSubscriptionPhase.stopping => true,
    _ => false,
  };
}

class GraphqlSubscriptionService {
  GraphqlSubscriptionService({
    GraphqlSubscriptionTransport? transport,
    GraphqlRequestResolver? resolver,
  }) : _transport = transport ?? GraphqlSubscriptionTransport(),
       _resolver = resolver;
  final GraphqlSubscriptionTransport _transport;
  final GraphqlRequestResolver? _resolver;
  final Map<String, GraphqlSubscriptionConnection> _connections =
      <String, GraphqlSubscriptionConnection>{};
  final Map<String, Set<String>> _runtimeSecrets = <String, Set<String>>{};

  int runtimeSecretCount(String tabId) => _runtimeSecrets[tabId]?.length ?? 0;

  Future<GraphqlSubscriptionConnection> connect({
    required String tabId,
    required GraphqlRequest request,
    String? environmentId,
    Map<String, Object?> connectionParams = const <String, Object?>{},
    Duration ackTimeout = const Duration(seconds: 5),
  }) async {
    await disconnect(tabId);
    final resolved = _resolver == null
        ? null
        : await _resolver.resolve(
            request,
            environmentId: environmentId,
            connectionInitPayload: connectionParams,
          );
    final runtimeRequest = resolved?.request ?? request;
    final runtimeConnectionParams =
        resolved?.connectionInitPayload ?? connectionParams;
    final analysis = GraphqlDocumentParser.analyze(runtimeRequest.document);
    final operation = GraphqlDocumentParser.select(
      analysis,
      runtimeRequest.operationName,
    );
    if (!analysis.isValid || operation == null) {
      throw GraphqlFailure(
        GraphqlFailureCategory.validation,
        analysis.errors.isEmpty
            ? 'Select a subscription operation before connecting.'
            : analysis.errors.join('\n'),
      );
    }
    if (operation.type != GraphqlOperationType.subscription) {
      throw const GraphqlFailure(
        GraphqlFailureCategory.validation,
        'Only subscription operations may use the WebSocket transport.',
      );
    }

    final connection = await _transport.connect(
      endpoint: runtimeRequest.endpoint,
      document: runtimeRequest.document,
      operationName: runtimeRequest.operationName,
      variables: runtimeRequest.variables,
      connectionParams: runtimeConnectionParams,
      ackTimeout: ackTimeout,
    );
    final secrets = <String>{...?resolved?.runtimeSecrets};
    _runtimeSecrets[tabId] = secrets;
    final scopedConnection = connection.mapEvents(
      (event) => GraphqlSubscriptionEvent(
        data: SecretMasker.redactStructured(
          event.data,
          runtimeSecrets: secrets,
        ),
        errors: event.errors
            .map(
              (error) => GraphqlResponseError.fromJson(
                SecretMasker.redactStructured(
                  error.toJson(),
                  runtimeSecrets: secrets,
                ),
              ),
            )
            .toList(growable: false),
        extensions: SecretMasker.redactStructured(
          event.extensions,
          runtimeSecrets: secrets,
        ),
        receivedAt: event.receivedAt,
      ),
      onDisconnect: () async => _clearRuntimeSecrets(tabId, secrets),
    );
    _connections[tabId] = scopedConnection;
    return scopedConnection;
  }

  Future<void> disconnect(String tabId) async {
    final connection = _connections.remove(tabId);
    final secrets = _runtimeSecrets.remove(tabId);
    try {
      await connection?.disconnect();
    } finally {
      secrets?.clear();
    }
  }

  void stop(String tabId) => _connections[tabId]?.stop();

  Future<void> dispose() async {
    final ids = _connections.keys.toList(growable: false);
    for (final id in ids) {
      await disconnect(id);
    }
    for (final secrets in _runtimeSecrets.values) {
      secrets.clear();
    }
    _runtimeSecrets.clear();
  }

  Future<void> _clearRuntimeSecrets(String tabId, Set<String> expected) async {
    if (identical(_runtimeSecrets[tabId], expected)) {
      _runtimeSecrets.remove(tabId);
    }
    expected.clear();
  }
}

class _GraphqlSubscriptionContext {
  const _GraphqlSubscriptionContext({
    required this.request,
    required this.environmentId,
    required this.connectionParams,
    required this.ackTimeout,
    required this.reconnectPolicy,
    required this.generation,
  });

  final GraphqlRequest request;
  final String? environmentId;
  final Map<String, Object?> connectionParams;
  final Duration ackTimeout;
  final GraphqlReconnectPolicy reconnectPolicy;
  final int generation;

  _GraphqlSubscriptionContext nextGeneration(int value) =>
      _GraphqlSubscriptionContext(
        request: request,
        environmentId: environmentId,
        connectionParams: connectionParams,
        ackTimeout: ackTimeout,
        reconnectPolicy: reconnectPolicy,
        generation: value,
      );
}

class GraphqlSubscriptionCubit
    extends Cubit<Map<String, GraphqlSubscriptionTabState>> {
  GraphqlSubscriptionCubit(this._service)
    : super(const <String, GraphqlSubscriptionTabState>{});

  final GraphqlSubscriptionService _service;
  final Map<String, StreamSubscription<GraphqlSubscriptionEvent>> _listeners =
      <String, StreamSubscription<GraphqlSubscriptionEvent>>{};
  final Map<String, _GraphqlSubscriptionContext> _contexts =
      <String, _GraphqlSubscriptionContext>{};
  final Map<String, Timer> _reconnectTimers = <String, Timer>{};
  final Set<String> _intentionalDisconnects = <String>{};
  final Set<String> _handlingTermination = <String>{};
  final Map<String, int> _sessionGenerations = <String, int>{};

  static const int _maximumEvents = 500;

  Future<void> connect(
    String tabId,
    GraphqlRequest request, {
    String? environmentId,
    Map<String, Object?> connectionParams = const <String, Object?>{},
    Duration ackTimeout = const Duration(seconds: 5),
    GraphqlReconnectPolicy reconnectPolicy = const GraphqlReconnectPolicy(),
  }) async {
    final generation = _nextGeneration(tabId);
    _contexts[tabId] = _GraphqlSubscriptionContext(
      request: request,
      environmentId: environmentId,
      connectionParams: Map<String, Object?>.unmodifiable(connectionParams),
      ackTimeout: ackTimeout,
      reconnectPolicy: reconnectPolicy,
      generation: generation,
    );
    _intentionalDisconnects.remove(tabId);
    _handlingTermination.remove(tabId);
    _reconnectTimers.remove(tabId)?.cancel();
    await _listeners.remove(tabId)?.cancel();
    await _service.disconnect(tabId);
    await _connectAttempt(tabId, reconnectAttempts: 0, reconnecting: false);
  }

  Future<void> reconnect(String tabId) async {
    final context = _contexts[tabId];
    if (context == null) return;
    _contexts[tabId] = context.nextGeneration(_nextGeneration(tabId));
    _intentionalDisconnects.remove(tabId);
    _handlingTermination.remove(tabId);
    _reconnectTimers.remove(tabId)?.cancel();
    await _listeners.remove(tabId)?.cancel();
    await _service.disconnect(tabId);
    await _connectAttempt(
      tabId,
      reconnectAttempts: state[tabId]?.reconnectAttempts ?? 0,
      reconnecting: true,
    );
  }

  Future<void> _connectAttempt(
    String tabId, {
    required int reconnectAttempts,
    required bool reconnecting,
  }) async {
    final context = _contexts[tabId];
    if (context == null || !_isCurrent(tabId, context.generation) || isClosed) {
      return;
    }

    final current = state[tabId] ?? const GraphqlSubscriptionTabState();
    _set(
      tabId,
      GraphqlSubscriptionTabState(
        phase: reconnecting
            ? GraphqlSubscriptionPhase.reconnecting
            : GraphqlSubscriptionPhase.connecting,
        events: current.events,
        droppedEvents: current.droppedEvents,
        reconnectAttempts: reconnectAttempts,
        error: current.error,
      ),
    );

    try {
      final connection = await _service.connect(
        tabId: tabId,
        request: context.request,
        environmentId: context.environmentId,
        connectionParams: context.connectionParams,
        ackTimeout: context.ackTimeout,
      );
      if (!_isCurrent(tabId, context.generation) || isClosed) {
        await _service.disconnect(tabId);
        return;
      }

      _handlingTermination.remove(tabId);
      final active = state[tabId] ?? const GraphqlSubscriptionTabState();
      _set(
        tabId,
        GraphqlSubscriptionTabState(
          phase: GraphqlSubscriptionPhase.active,
          events: active.events,
          droppedEvents: active.droppedEvents,
          reconnectAttempts: reconnectAttempts,
          connectedAt: DateTime.now(),
        ),
      );
      _listeners[tabId] = connection.events.listen(
        (event) => _addEvent(tabId, event, context.generation),
        onError: (Object error) =>
            unawaited(_handleTermination(tabId, error, context.generation)),
        onDone: () =>
            unawaited(_handleTermination(tabId, null, context.generation)),
      );
    } on Object catch (error) {
      await _handleTermination(tabId, error, context.generation);
    }
  }

  Future<void> _handleTermination(
    String tabId,
    Object? error,
    int generation,
  ) async {
    if (isClosed || !_isCurrent(tabId, generation)) return;
    if (!_handlingTermination.add(tabId)) return;

    final current = state[tabId] ?? const GraphqlSubscriptionTabState();
    if (current.phase == GraphqlSubscriptionPhase.stopping) {
      await _listeners.remove(tabId)?.cancel();
      await _service.disconnect(tabId);
      _set(
        tabId,
        GraphqlSubscriptionTabState(
          phase: GraphqlSubscriptionPhase.completed,
          events: current.events,
          droppedEvents: current.droppedEvents,
          reconnectAttempts: current.reconnectAttempts,
          connectedAt: current.connectedAt,
        ),
      );
      _handlingTermination.remove(tabId);
      return;
    }

    await _listeners.remove(tabId)?.cancel();
    await _service.disconnect(tabId);

    final context = _contexts[tabId];
    final failure = error == null
        ? null
        : error is GraphqlFailure
        ? error
        : GraphqlFailure(
            GraphqlFailureCategory.protocol,
            error.toString(),
            cause: error,
          );

    if (context != null &&
        context.reconnectPolicy.canAutomaticallyResubscribe &&
        current.reconnectAttempts < context.reconnectPolicy.maxAttempts) {
      final nextAttempt = current.reconnectAttempts + 1;
      final delay = context.reconnectPolicy.delayForAttempt(nextAttempt);
      _set(
        tabId,
        GraphqlSubscriptionTabState(
          phase: GraphqlSubscriptionPhase.reconnecting,
          events: current.events,
          droppedEvents: current.droppedEvents,
          reconnectAttempts: nextAttempt,
          connectedAt: current.connectedAt,
          error: failure,
        ),
      );
      _reconnectTimers.remove(tabId)?.cancel();
      _reconnectTimers[tabId] = Timer(delay, () {
        _reconnectTimers.remove(tabId);
        _handlingTermination.remove(tabId);
        if (!_isCurrent(tabId, generation)) return;
        unawaited(
          _connectAttempt(
            tabId,
            reconnectAttempts: nextAttempt,
            reconnecting: true,
          ),
        );
      });
      return;
    }

    _set(
      tabId,
      GraphqlSubscriptionTabState(
        phase: failure == null
            ? GraphqlSubscriptionPhase.completed
            : GraphqlSubscriptionPhase.failed,
        events: current.events,
        droppedEvents: current.droppedEvents,
        reconnectAttempts: current.reconnectAttempts,
        connectedAt: current.connectedAt,
        error: failure,
      ),
    );
    _handlingTermination.remove(tabId);
  }

  Future<void> disconnect(String tabId) async {
    _nextGeneration(tabId);
    _intentionalDisconnects.add(tabId);
    _reconnectTimers.remove(tabId)?.cancel();
    _handlingTermination.remove(tabId);
    _set(tabId, _copy(tabId, phase: GraphqlSubscriptionPhase.stopping));
    await _listeners.remove(tabId)?.cancel();
    await _service.disconnect(tabId);
    _set(tabId, _copy(tabId, phase: GraphqlSubscriptionPhase.disconnected));
  }

  void stop(String tabId) {
    _reconnectTimers.remove(tabId)?.cancel();
    _set(tabId, _copy(tabId, phase: GraphqlSubscriptionPhase.stopping));
    _service.stop(tabId);
  }

  void clear(String tabId) => _set(
    tabId,
    _copy(tabId, events: const <GraphqlTimelineEvent>[], droppedEvents: 0),
  );

  void _addEvent(String tabId, GraphqlSubscriptionEvent event, int generation) {
    if (!_isCurrent(tabId, generation)) return;
    final previous = state[tabId] ?? const GraphqlSubscriptionTabState();
    final events = <GraphqlTimelineEvent>[
      ...previous.events,
      GraphqlTimelineEvent(
        sequence: previous.events.length + previous.droppedEvents + 1,
        receivedAt: event.receivedAt,
        data: event.data,
        errors: event.errors,
        extensions: event.extensions,
      ),
    ];
    final dropped = events.length > _maximumEvents
        ? previous.droppedEvents + 1
        : previous.droppedEvents;
    if (events.length > _maximumEvents) events.removeAt(0);
    _set(tabId, _copy(tabId, events: events, droppedEvents: dropped));
  }

  GraphqlSubscriptionTabState _copy(
    String tabId, {
    GraphqlSubscriptionPhase? phase,
    List<GraphqlTimelineEvent>? events,
    int? droppedEvents,
    int? reconnectAttempts,
    DateTime? connectedAt,
    GraphqlFailure? error,
  }) {
    final current = state[tabId] ?? const GraphqlSubscriptionTabState();
    return GraphqlSubscriptionTabState(
      phase: phase ?? current.phase,
      events: events ?? current.events,
      droppedEvents: droppedEvents ?? current.droppedEvents,
      reconnectAttempts: reconnectAttempts ?? current.reconnectAttempts,
      connectedAt: connectedAt ?? current.connectedAt,
      error: error ?? current.error,
    );
  }

  void _set(String tabId, GraphqlSubscriptionTabState value) {
    if (isClosed) return;
    emit(<String, GraphqlSubscriptionTabState>{...state, tabId: value});
  }

  int _nextGeneration(String tabId) {
    final value = (_sessionGenerations[tabId] ?? 0) + 1;
    _sessionGenerations[tabId] = value;
    return value;
  }

  bool _isCurrent(String tabId, int generation) =>
      !_intentionalDisconnects.contains(tabId) &&
      _sessionGenerations[tabId] == generation;

  @override
  Future<void> close() async {
    _intentionalDisconnects.addAll(_contexts.keys);
    for (final timer in _reconnectTimers.values) {
      timer.cancel();
    }
    _reconnectTimers.clear();
    for (final listener in _listeners.values) {
      await listener.cancel();
    }
    _listeners.clear();
    _contexts.clear();
    _handlingTermination.clear();
    _sessionGenerations.clear();
    await _service.dispose();
    return super.close();
  }
}
