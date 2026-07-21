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
    this.error,
  });
  final GraphqlSubscriptionPhase phase;
  final List<GraphqlTimelineEvent> events;
  final int droppedEvents;
  final GraphqlFailure? error;
  bool get isActive => phase == GraphqlSubscriptionPhase.active;
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
        analysis.errors.join('\n'),
      );
    }
    if (operation.type != GraphqlOperationType.subscription) {
      throw const GraphqlFailure(
        GraphqlFailureCategory.validation,
        'Only subscription operations may use the WebSocket transport.',
      );
    }
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

class GraphqlSubscriptionCubit
    extends Cubit<Map<String, GraphqlSubscriptionTabState>> {
  GraphqlSubscriptionCubit(this._service)
    : super(const <String, GraphqlSubscriptionTabState>{});
  final GraphqlSubscriptionService _service;
  final Map<String, StreamSubscription<GraphqlSubscriptionEvent>> _listeners =
      <String, StreamSubscription<GraphqlSubscriptionEvent>>{};
  static const int _maximumEvents = 500;

  Future<void> connect(String tabId, GraphqlRequest request) async {
    _set(
      tabId,
      const GraphqlSubscriptionTabState(
        phase: GraphqlSubscriptionPhase.connecting,
      ),
    );
    try {
      final connection = await _service.connect(tabId: tabId, request: request);
      _set(
        tabId,
        const GraphqlSubscriptionTabState(
          phase: GraphqlSubscriptionPhase.active,
        ),
      );
      _listeners[tabId] = connection.events.listen(
        (event) => _addEvent(tabId, event),
        onError: (Object error) {
          _set(
            tabId,
            GraphqlSubscriptionTabState(
              phase: GraphqlSubscriptionPhase.failed,
              error: error is GraphqlFailure
                  ? error
                  : GraphqlFailure(
                      GraphqlFailureCategory.protocol,
                      error.toString(),
                    ),
            ),
          );
        },
        onDone: () => _set(
          tabId,
          GraphqlSubscriptionTabState(
            phase: GraphqlSubscriptionPhase.completed,
            events: state[tabId]?.events ?? const <GraphqlTimelineEvent>[],
          ),
        ),
      );
    } on GraphqlFailure catch (error) {
      _set(
        tabId,
        GraphqlSubscriptionTabState(
          phase: GraphqlSubscriptionPhase.failed,
          error: error,
        ),
      );
    }
  }

  Future<void> disconnect(String tabId) async {
    _set(tabId, _copy(tabId, phase: GraphqlSubscriptionPhase.stopping));
    await _listeners.remove(tabId)?.cancel();
    await _service.disconnect(tabId);
    _set(tabId, _copy(tabId, phase: GraphqlSubscriptionPhase.disconnected));
  }

  void stop(String tabId) => _service.stop(tabId);

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
    GraphqlFailure? error,
  }) {
    final current = state[tabId] ?? const GraphqlSubscriptionTabState();
    return GraphqlSubscriptionTabState(
      phase: phase ?? current.phase,
      events: events ?? current.events,
      droppedEvents: droppedEvents ?? current.droppedEvents,
      error: error ?? current.error,
    );
  }

  void _set(String tabId, GraphqlSubscriptionTabState value) {
    emit(<String, GraphqlSubscriptionTabState>{...state, tabId: value});
  }

  @override
  Future<void> close() async {
    for (final listener in _listeners.values) {
      await listener.cancel();
    }
    _listeners.clear();
    await _service.dispose();
    return super.close();
  }
}
