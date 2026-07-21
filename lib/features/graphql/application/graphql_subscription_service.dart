import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/graphql_subscription_transport.dart';
import '../domain/graphql_document_parser.dart';
import '../domain/graphql_models.dart';

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
  GraphqlSubscriptionService({GraphqlSubscriptionTransport? transport})
    : _transport = transport ?? GraphqlSubscriptionTransport();
  final GraphqlSubscriptionTransport _transport;
  final Map<String, GraphqlSubscriptionConnection> _connections =
      <String, GraphqlSubscriptionConnection>{};

  Future<GraphqlSubscriptionConnection> connect({
    required String tabId,
    required GraphqlRequest request,
    Map<String, Object?> connectionParams = const <String, Object?>{},
    Duration ackTimeout = const Duration(seconds: 5),
  }) async {
    final analysis = GraphqlDocumentParser.analyze(request.document);
    final operation = GraphqlDocumentParser.select(
      analysis,
      request.operationName,
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

    await disconnect(tabId);
    final connection = await _transport.connect(
      endpoint: request.endpoint,
      document: request.document,
      operationName: request.operationName,
      variables: request.variables,
      connectionParams: connectionParams,
      ackTimeout: ackTimeout,
    );
    _connections[tabId] = connection;
    return connection;
  }

  Future<void> disconnect(String tabId) async {
    final connection = _connections.remove(tabId);
    await connection?.disconnect();
  }

  void stop(String tabId) => _connections[tabId]?.stop();

  Future<void> dispose() async {
    final ids = _connections.keys.toList(growable: false);
    for (final id in ids) {
      await disconnect(id);
    }
  }
}

class _GraphqlSubscriptionContext {
  const _GraphqlSubscriptionContext({
    required this.request,
    required this.connectionParams,
    required this.ackTimeout,
    required this.reconnectPolicy,
  });

  final GraphqlRequest request;
  final Map<String, Object?> connectionParams;
  final Duration ackTimeout;
  final GraphqlReconnectPolicy reconnectPolicy;
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

  static const int _maximumEvents = 500;

  Future<void> connect(
    String tabId,
    GraphqlRequest request, {
    Map<String, Object?> connectionParams = const <String, Object?>{},
    Duration ackTimeout = const Duration(seconds: 5),
    GraphqlReconnectPolicy reconnectPolicy = const GraphqlReconnectPolicy(),
  }) async {
    _contexts[tabId] = _GraphqlSubscriptionContext(
      request: request,
      connectionParams: Map<String, Object?>.unmodifiable(connectionParams),
      ackTimeout: ackTimeout,
      reconnectPolicy: reconnectPolicy,
    );
    _intentionalDisconnects.remove(tabId);
    _handlingTermination.remove(tabId);
    _reconnectTimers.remove(tabId)?.cancel();
    await _listeners.remove(tabId)?.cancel();
    await _service.disconnect(tabId);
    await _connectAttempt(tabId, reconnectAttempts: 0, reconnecting: false);
  }

  Future<void> reconnect(String tabId) async {
    if (!_contexts.containsKey(tabId)) return;
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
    if (context == null ||
        _intentionalDisconnects.contains(tabId) ||
        isClosed) {
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
        connectionParams: context.connectionParams,
        ackTimeout: context.ackTimeout,
      );
      if (_intentionalDisconnects.contains(tabId) || isClosed) {
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
        (event) => _addEvent(tabId, event),
        onError: (Object error) => unawaited(_handleTermination(tabId, error)),
        onDone: () => unawaited(_handleTermination(tabId, null)),
      );
    } on Object catch (error) {
      await _handleTermination(tabId, error);
    }
  }

  Future<void> _handleTermination(String tabId, Object? error) async {
    if (isClosed || _intentionalDisconnects.contains(tabId)) return;
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

  void _addEvent(String tabId, GraphqlSubscriptionEvent event) {
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
    await _service.dispose();
    return super.close();
  }
}
