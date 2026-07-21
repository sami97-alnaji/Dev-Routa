import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:devroute_ai_studio/features/graphql/data/graphql_subscription_transport.dart';
import 'package:devroute_ai_studio/features/graphql/application/graphql_subscription_service.dart';
import 'package:devroute_ai_studio/features/graphql/domain/graphql_models.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _waitUntil(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  final stopwatch = Stopwatch()..start();
  while (!condition()) {
    if (stopwatch.elapsed >= timeout) {
      throw TestFailure('Condition was not met before $timeout.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  late HttpServer server;
  late String endpoint;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    endpoint = 'ws://${server.address.host}:${server.port}/graphql';
    server.listen((request) async {
      final socket = await WebSocketTransformer.upgrade(request);
      socket.listen((message) {
        final value = jsonDecode(message as String) as Map;
        switch (value['type']) {
          case 'connection_init':
            socket.add(jsonEncode(<String, Object?>{'type': 'connection_ack'}));
          case 'subscribe':
            socket.add(
              jsonEncode(<String, Object?>{
                'id': '1',
                'type': 'next',
                'payload': <String, Object?>{
                  'data': <String, Object?>{'tick': 1},
                  'extensions': <String, Object?>{'local': true},
                },
              }),
            );
          case 'complete':
            socket.add(
              jsonEncode(<String, Object?>{'id': '1', 'type': 'complete'}),
            );
        }
      });
    });
  });

  tearDown(() async => server.close(force: true));

  test('graphql-transport-ws performs init, ack, subscribe and next', () async {
    final connection = await GraphqlSubscriptionTransport().connect(
      endpoint: endpoint,
      document: 'subscription Tick { tick }',
      connectionParams: const <String, Object?>{'token': '[masked]'},
    );
    final event = await connection.events.first;
    expect(event.data, <String, Object?>{'tick': 1});
    expect(event.extensions, <String, Object?>{'local': true});
    await connection.disconnect();
  });

  test('ack timeout closes the protocol with a typed failure', () async {
    final silent = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final silentEndpoint = 'ws://${silent.address.host}:${silent.port}/graphql';
    silent.listen((request) async {
      await WebSocketTransformer.upgrade(request);
    });
    addTearDown(() => silent.close(force: true));
    expect(
      () => GraphqlSubscriptionTransport().connect(
        endpoint: silentEndpoint,
        document: 'subscription Tick { tick }',
        ackTimeout: const Duration(milliseconds: 100),
      ),
      throwsA(isA<GraphqlFailure>()),
    );
  });

  test('subscription cubit owns tab state and bounded timeline', () async {
    final cubit = GraphqlSubscriptionCubit(
      GraphqlSubscriptionService(transport: GraphqlSubscriptionTransport()),
    );
    await cubit.connect(
      'tab-a',
      GraphqlRequest(
        endpoint: endpoint,
        document: 'subscription Tick { tick }',
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(cubit.state['tab-a']?.phase, GraphqlSubscriptionPhase.active);
    expect(cubit.state['tab-a']?.events, hasLength(1));
    expect(cubit.state.containsKey('tab-b'), isFalse);
    await cubit.disconnect('tab-a');
    expect(cubit.state['tab-a']?.phase, GraphqlSubscriptionPhase.disconnected);
    await cubit.close();
  });

  test('reconnects and resubscribes with bounded backoff per tab', () async {
    final reconnectServer = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      0,
    );
    final reconnectEndpoint =
        'ws://${reconnectServer.address.host}:${reconnectServer.port}/graphql';
    var connectionCount = 0;

    reconnectServer.listen((request) async {
      final socket = await WebSocketTransformer.upgrade(request);
      final connectionNumber = ++connectionCount;
      socket.listen((message) {
        final value = jsonDecode(message as String) as Map;
        switch (value['type']) {
          case 'connection_init':
            socket.add(jsonEncode(<String, Object?>{'type': 'connection_ack'}));
          case 'subscribe':
            if (connectionNumber == 1) {
              Timer(
                const Duration(milliseconds: 10),
                () => unawaited(
                  socket.close(WebSocketStatus.goingAway, 'Restart once'),
                ),
              );
            } else {
              socket.add(
                jsonEncode(<String, Object?>{
                  'id': '1',
                  'type': 'next',
                  'payload': <String, Object?>{
                    'data': <String, Object?>{'tick': connectionNumber},
                  },
                }),
              );
            }
        }
      });
    });
    addTearDown(() => reconnectServer.close(force: true));

    final cubit = GraphqlSubscriptionCubit(
      GraphqlSubscriptionService(transport: GraphqlSubscriptionTransport()),
    );
    await cubit.connect(
      'tab-reconnect',
      GraphqlRequest(
        endpoint: reconnectEndpoint,
        document: 'subscription Tick { tick }',
      ),
      reconnectPolicy: const GraphqlReconnectPolicy(
        enabled: true,
        resubscribe: true,
        maxAttempts: 2,
        initialDelay: Duration(milliseconds: 10),
        maxDelay: Duration(milliseconds: 20),
      ),
    );

    await _waitUntil(
      () => cubit.state['tab-reconnect']?.events.isNotEmpty ?? false,
    );

    expect(connectionCount, 2);
    expect(cubit.state['tab-reconnect']?.reconnectAttempts, 1);
    expect(cubit.state['tab-reconnect']?.events.single.data, <String, Object?>{
      'tick': 2,
    });

    await cubit.disconnect('tab-reconnect');
    await cubit.close();
  });

  test('does not reconnect when automatic resubscribe is disabled', () async {
    final closeServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final closeEndpoint =
        'ws://${closeServer.address.host}:${closeServer.port}/graphql';
    var connectionCount = 0;

    closeServer.listen((request) async {
      final socket = await WebSocketTransformer.upgrade(request);
      connectionCount++;
      socket.listen((message) {
        final value = jsonDecode(message as String) as Map;
        switch (value['type']) {
          case 'connection_init':
            socket.add(jsonEncode(<String, Object?>{'type': 'connection_ack'}));
          case 'subscribe':
            Timer(
              const Duration(milliseconds: 10),
              () => unawaited(
                socket.close(WebSocketStatus.goingAway, 'Do not resubscribe'),
              ),
            );
        }
      });
    });
    addTearDown(() => closeServer.close(force: true));

    final cubit = GraphqlSubscriptionCubit(
      GraphqlSubscriptionService(transport: GraphqlSubscriptionTransport()),
    );
    await cubit.connect(
      'tab-no-resubscribe',
      GraphqlRequest(
        endpoint: closeEndpoint,
        document: 'subscription Tick { tick }',
      ),
      reconnectPolicy: const GraphqlReconnectPolicy(
        enabled: true,
        resubscribe: false,
        maxAttempts: 3,
        initialDelay: Duration(milliseconds: 10),
      ),
    );

    await _waitUntil(
      () =>
          cubit.state['tab-no-resubscribe']?.phase ==
          GraphqlSubscriptionPhase.completed,
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(connectionCount, 1);
    expect(cubit.state['tab-no-resubscribe']?.reconnectAttempts, 0);

    await cubit.close();
  });
}
