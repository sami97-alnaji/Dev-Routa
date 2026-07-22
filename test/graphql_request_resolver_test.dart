import 'package:devroute_ai_studio/core/storage/database_schema.dart'
    hide GraphqlDraft;
import 'package:devroute_ai_studio/features/graphql/application/graphql_request_resolver.dart';
import 'package:devroute_ai_studio/features/graphql/data/graphql_repository.dart';
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
    'resolver resolves nested values and keeps raw request unchanged',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final raw = GraphqlRequest(
        endpoint: 'wss://{{host}}/graphql',
        document: 'subscription Tick { tick }',
        headers: const <String, String>{'x-env': '{{host}}'},
        variables: const <String, Object?>{
          'nested': <String, Object?>{'value': '{{host}}'},
        },
        extensions: const <String, Object?>{'trace': '{{host}}'},
        auth: const RequestAuthModel(
          type: AuthType.bearer,
          tokenSecretRef: 'token-ref',
        ),
      );
      await database.customStatement(
        'INSERT INTO environment_variables (id, environment_id, name, value_or_secret_ref, is_secret, enabled, sort_order) VALUES (?, ?, ?, ?, ?, ?, ?)',
        <Object?>['host-id', 'env', 'host', 'example.test', 0, 1, 0],
      );
      final resolver = GraphqlRequestResolver(
        GraphqlRepository(
          database,
          secureStorage: _Secrets(<String, String>{
            'token-ref': 'super-secret',
          }),
        ),
        secureStorage: _Secrets(<String, String>{'token-ref': 'super-secret'}),
      );
      final resolved = await resolver.resolve(
        raw,
        environmentId: 'env',
        connectionInitPayload: const <String, Object?>{
          'nested': <String, Object?>{'host': '{{host}}'},
        },
      );
      expect(resolved.request.endpoint, 'wss://example.test/graphql');
      expect(resolved.request.headers['Authorization'], 'Bearer super-secret');
      expect(resolved.request.variables['nested'], <String, Object?>{
        'value': 'example.test',
      });
      expect(
        resolved.connectionInitPayload['headers'],
        containsPair('Authorization', 'Bearer super-secret'),
      );
      expect(resolved.runtimeSecrets, contains('super-secret'));
      expect(raw.endpoint, 'wss://{{host}}/graphql');
      expect(raw.auth.tokenSecretRef, 'token-ref');
      await database.close();
    },
  );

  test(
    'resolver fails safely for missing secret and unresolved variable',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final resolver = GraphqlRequestResolver(
        GraphqlRepository(database),
        secureStorage: _Secrets(<String, String>{}),
      );
      expect(
        () => resolver.resolve(
          const GraphqlRequest(
            endpoint: 'wss://{{missing}}/graphql',
            document: 'subscription Tick { tick }',
          ),
        ),
        throwsA(isA<GraphqlFailure>()),
      );
      expect(
        () => resolver.resolve(
          const GraphqlRequest(
            endpoint: 'wss://localhost/graphql',
            document: 'subscription Tick { tick }',
            auth: RequestAuthModel(
              type: AuthType.bearer,
              tokenSecretRef: 'missing',
            ),
          ),
        ),
        throwsA(isA<GraphqlFailure>()),
      );
      await database.close();
    },
  );
}
