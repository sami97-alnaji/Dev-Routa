import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../domain/graphql_models.dart';

class GraphqlSubscriptionEvent {
  const GraphqlSubscriptionEvent({
    required this.data,
    required this.receivedAt,
    this.errors = const <GraphqlResponseError>[],
    this.extensions,
  });
  final Object? data;
  final DateTime receivedAt;
  final List<GraphqlResponseError> errors;
  final Object? extensions;
}

class GraphqlSubscriptionConnection {
  GraphqlSubscriptionConnection._(this._socket, this.events);
  final WebSocket _socket;
  final Stream<GraphqlSubscriptionEvent> events;
  bool _closed = false;

  void stop() {
    if (_closed) return;
    _socket.add(jsonEncode(<String, Object?>{'id': '1', 'type': 'complete'}));
  }

  Future<void> disconnect() async {
    if (_closed) return;
    _closed = true;
    await _socket.close(WebSocketStatus.normalClosure, 'Client disconnected');
  }
}

class GraphqlSubscriptionTransport {
  GraphqlSubscriptionTransport({
    Future<WebSocket> Function(String, {Iterable<String>? protocols})?
    connector,
  }) : _connector = connector ?? _connect;
  final Future<WebSocket> Function(String, {Iterable<String>? protocols})
  _connector;

  Future<GraphqlSubscriptionConnection> connect({
    required String endpoint,
    required String document,
    String? operationName,
    Map<String, Object?> variables = const <String, Object?>{},
    Map<String, Object?> connectionParams = const <String, Object?>{},
    Duration ackTimeout = const Duration(seconds: 5),
  }) async {
    final uri = Uri.tryParse(endpoint);
    if (uri == null ||
        (uri.scheme != 'ws' && uri.scheme != 'wss') ||
        uri.host.isEmpty) {
      throw const GraphqlFailure(
        GraphqlFailureCategory.validation,
        'The GraphQL subscription endpoint must be a valid WS or WSS URL.',
      );
    }
    final socket = await _connector(
      endpoint,
      protocols: const <String>['graphql-transport-ws'],
    );
    final controller = StreamController<GraphqlSubscriptionEvent>();
    final ack = Completer<void>();
    late final StreamSubscription<dynamic> subscription;
    subscription = socket.listen(
      (message) {
        if (message is! String) return;
        final decoded = jsonDecode(message);
        if (decoded is! Map) {
          controller.addError(
            const GraphqlFailure(
              GraphqlFailureCategory.protocol,
              'Protocol message must be an object.',
            ),
          );
          return;
        }
        switch (decoded['type']) {
          case 'connection_ack':
            if (!ack.isCompleted) ack.complete();
          case 'ping':
            socket.add(
              jsonEncode(<String, Object?>{
                'type': 'pong',
                'payload': decoded['payload'],
              }),
            );
          case 'pong':
            break;
          case 'next':
            final payload = decoded['payload'];
            if (payload is! Map) {
              controller.addError(
                const GraphqlFailure(
                  GraphqlFailureCategory.protocol,
                  'next payload must be an object.',
                ),
              );
              return;
            }
            controller.add(
              GraphqlSubscriptionEvent(
                data: payload['data'],
                errors: (payload['errors'] as List? ?? const <Object?>[])
                    .map(GraphqlResponseError.fromJson)
                    .toList(growable: false),
                extensions: payload['extensions'],
                receivedAt: DateTime.now(),
              ),
            );
          case 'error':
            controller.addError(
              GraphqlFailure(
                GraphqlFailureCategory.graphql,
                (decoded['payload'] as Map?)?['message']?.toString() ??
                    'Subscription failed.',
              ),
            );
          case 'complete':
            controller.close();
          default:
            controller.addError(
              GraphqlFailure(
                GraphqlFailureCategory.protocol,
                'Unsupported protocol message: ${decoded['type']}.',
              ),
            );
        }
      },
      onError: controller.addError,
      onDone: () {
        if (!ack.isCompleted) {
          ack.completeError(
            const GraphqlFailure(
              GraphqlFailureCategory.protocol,
              'Socket closed before connection_ack.',
            ),
          );
        }
        if (!controller.isClosed) controller.close();
      },
    );
    socket.add(
      jsonEncode(<String, Object?>{
        'type': 'connection_init',
        if (connectionParams.isNotEmpty) 'payload': connectionParams,
      }),
    );
    try {
      await ack.future.timeout(ackTimeout);
      socket.add(
        jsonEncode(<String, Object?>{
          'id': '1',
          'type': 'subscribe',
          'payload': <String, Object?>{
            'query': document,
            // ignore: use_null_aware_elements
            if (operationName != null) 'operationName': operationName,
            if (variables.isNotEmpty) 'variables': variables,
          },
        }),
      );
      return GraphqlSubscriptionConnection._(socket, controller.stream);
    } catch (error) {
      await subscription.cancel();
      await socket.close(
        WebSocketStatus.protocolError,
        'GraphQL transport handshake failed',
      );
      if (error is GraphqlFailure) rethrow;
      throw GraphqlFailure(
        GraphqlFailureCategory.protocol,
        'Subscription handshake timed out.',
        cause: error,
      );
    }
  }

  static Future<WebSocket> _connect(
    String url, {
    Iterable<String>? protocols,
  }) async {
    final WebSocket socket = await WebSocket.connect(url, protocols: protocols);
    return socket;
  }
}
