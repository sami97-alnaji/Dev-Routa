import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:devroute_ai_studio/core/storage/database_schema.dart'
    hide GraphqlDraft;
import 'package:devroute_ai_studio/features/graphql/application/graphql_request_resolver.dart';
import 'package:devroute_ai_studio/features/graphql/application/graphql_subscription_service.dart';
import 'package:devroute_ai_studio/features/graphql/data/graphql_repository.dart';
import 'package:devroute_ai_studio/features/graphql/data/graphql_subscription_transport.dart';
import 'package:devroute_ai_studio/features/graphql/domain/graphql_models.dart';
import 'package:devroute_ai_studio/shared/models/api_models.dart';
import 'package:devroute_ai_studio/shared/services/service_interfaces.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _Secrets implements SecureStorageService {
  _Secrets(this.values);

  final Map<String, String> values;

  @override
  Future<void> deleteSecret(String key) async => values.remove(key);

  @override
  Future<String?> readSecret(String key) async => values[key];

  @override
  Future<void> writeSecret(String key, String value) async =>
      values[key] = value;
}

void main() {
  test(
    'subscription resolves runtime-only values before the socket opens',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final secrets = _Secrets(<String, String>{
        'bearer-ref': 'runtime-bearer',
        'init-ref': 'runtime-init',
      });
      final repository = GraphqlRepository(database, secureStorage: secrets);
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final initMessage = Completer<Map<Object?, Object?>>();
      server.listen((request) async {
        final socket = await WebSocketTransformer.upgrade(request);
        socket.listen((message) {
          final decoded = jsonDecode(message as String) as Map;
          if (decoded['type'] == 'connection_init') {
            initMessage.complete(
              decoded.map((key, value) => MapEntry(key, value)),
            );
            socket.add(jsonEncode(<String, Object?>{'type': 'connection_ack'}));
          }
        });
      });
      addTearDown(() => server.close(force: true));

      await database.customStatement(
        'INSERT INTO environment_variables (id, environment_id, name, value_or_secret_ref, is_secret, enabled, sort_order) VALUES (?, ?, ?, ?, ?, ?, ?)',
        <Object?>[
          'host',
          'environment',
          'host',
          '${server.address.host}:${server.port}',
          0,
          1,
          0,
        ],
      );
      await database.customStatement(
        'INSERT INTO environment_variables (id, environment_id, name, value_or_secret_ref, is_secret, enabled, sort_order) VALUES (?, ?, ?, ?, ?, ?, ?)',
        <Object?>['init', 'environment', 'initToken', 'init-ref', 1, 1, 1],
      );

      final service = GraphqlSubscriptionService(
        resolver: GraphqlRequestResolver(repository, secureStorage: secrets),
      );
      final request = const GraphqlRequest(
        endpoint: 'ws://{{host}}/graphql',
        document: 'subscription Updates { update }',
        headers: <String, String>{'x-host': '{{host}}'},
        auth: RequestAuthModel(
          type: AuthType.bearer,
          tokenSecretRef: 'bearer-ref',
        ),
      );

      await service.connect(
        tabId: 'subscription-tab',
        request: request,
        environmentId: 'environment',
        connectionParams: const <String, Object?>{
          'nested': <String, Object?>{'token': '{{initToken}}'},
        },
      );
      final payload = (await initMessage.future)['payload'] as Map;
      final headers = payload['headers'] as Map;
      expect(headers['Authorization'], 'Bearer runtime-bearer');
      expect(headers['x-host'], '${server.address.host}:${server.port}');
      expect((payload['nested'] as Map)['token'], 'runtime-init');
      expect(request.endpoint, 'ws://{{host}}/graphql');
      expect(await repository.history('workspace'), isEmpty);

      await service.disconnect('subscription-tab');
      await service.dispose();
      await database.close();
    },
  );

  test(
    'resolution failures and resolved HTTP endpoints never open a socket',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final repository = GraphqlRepository(database);
      var socketAttempts = 0;
      final transport = GraphqlSubscriptionTransport(
        connector: (url, {protocols}) async {
          socketAttempts++;
          throw StateError('The connector should not be reached.');
        },
      );
      final service = GraphqlSubscriptionService(
        transport: transport,
        resolver: GraphqlRequestResolver(
          repository,
          secureStorage: _Secrets({}),
        ),
      );

      await expectLater(
        service.connect(
          tabId: 'missing-variable',
          request: const GraphqlRequest(
            endpoint: 'ws://{{missing}}/graphql',
            document: 'subscription Updates { update }',
          ),
        ),
        throwsA(
          isA<GraphqlFailure>().having(
            (failure) => failure.category,
            'category',
            GraphqlFailureCategory.unresolvedVariable,
          ),
        ),
      );
      await expectLater(
        service.connect(
          tabId: 'invalid-endpoint',
          request: const GraphqlRequest(
            endpoint: 'https://example.test/graphql',
            document: 'subscription Updates { update }',
          ),
        ),
        throwsA(
          isA<GraphqlFailure>().having(
            (failure) => failure.category,
            'category',
            GraphqlFailureCategory.validation,
          ),
        ),
      );
      expect(socketAttempts, 0);

      await service.dispose();
      await database.close();
    },
  );

  test('reflected runtime secrets are masked and cleared per tab', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final secrets = _Secrets(<String, String>{'bearer': 'runtime-bearer'});
    final repository = GraphqlRepository(database, secureStorage: secrets);
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      final socket = await WebSocketTransformer.upgrade(request);
      socket.listen((message) {
        final decoded = jsonDecode(message as String) as Map;
        switch (decoded['type']) {
          case 'connection_init':
            socket.add(jsonEncode(<String, Object?>{'type': 'connection_ack'}));
          case 'subscribe':
            socket.add(
              jsonEncode(<String, Object?>{
                'id': '1',
                'type': 'next',
                'payload': <String, Object?>{
                  'data': <String, Object?>{
                    'ordinary': 'runtime-bearer',
                    'nested': <Object?>['runtime-bearer'],
                  },
                  'errors': <Object?>[
                    <String, Object?>{
                      'message': 'runtime-bearer',
                      'extensions': <String, Object?>{
                        'ordinary': 'runtime-bearer',
                      },
                    },
                  ],
                  'extensions': <String, Object?>{'ordinary': 'runtime-bearer'},
                },
              }),
            );
        }
      });
    });
    addTearDown(() => server.close(force: true));

    final service = GraphqlSubscriptionService(
      resolver: GraphqlRequestResolver(repository, secureStorage: secrets),
    );
    final connection = await service.connect(
      tabId: 'tab',
      request: GraphqlRequest(
        endpoint: 'ws://${server.address.host}:${server.port}/graphql',
        document: 'subscription Updates { update }',
        auth: const RequestAuthModel(
          type: AuthType.bearer,
          tokenSecretRef: 'bearer',
        ),
      ),
    );
    final event = await connection.events.first;
    expect(event.data.toString(), isNot(contains('runtime-bearer')));
    expect(event.data.toString(), contains('[REDACTED]'));
    expect(event.errors.single.message, '[REDACTED]');
    expect(event.extensions.toString(), isNot(contains('runtime-bearer')));
    expect(service.runtimeSecretCount('tab'), 1);

    await service.disconnect('tab');
    expect(service.runtimeSecretCount('tab'), 0);
    await service.dispose();
    await database.close();
  });
}
