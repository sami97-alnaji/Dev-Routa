import 'dart:io';

import 'package:devroute_ai_studio/features/graphql/application/graphql_safe_export_service.dart';
import 'package:devroute_ai_studio/features/graphql/data/graphql_repository.dart';
import 'package:devroute_ai_studio/features/graphql/domain/graphql_models.dart';
import 'package:devroute_ai_studio/shared/models/api_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'GraphQL request response and history exports redact all secret forms',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'devroute-graphql-export-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final service = GraphqlSafeExportService(
        directoryProvider: () async => directory,
      );
      const runtimeSecret = 'runtime-secret-value';
      final request = const GraphqlRequest(
        endpoint:
            'https://user:pass@api.example.test/graphql?token=query-token',
        document: 'query Viewer { viewer { id } }',
        headers: <String, String>{
          'Authorization': 'Bearer header-secret',
          'X-Client': 'DevRoute',
        },
        variables: <String, Object?>{'password': 'variable-secret'},
        auth: RequestAuthModel(
          type: AuthType.bearer,
          tokenSecretRef: 'secure/graphql/viewer',
        ),
      );
      final response = GraphqlResponse(
        statusCode: 200,
        data: const <String, Object?>{
          'echo': runtimeSecret,
          'access_token': 'response-token',
        },
        errors: const <GraphqlResponseError>[
          GraphqlResponseError(message: 'cookie=session-cookie'),
        ],
        extensions: const <String, Object?>{'secret': 'extension-secret'},
        duration: const Duration(milliseconds: 12),
        sizeBytes: 30,
        headers: const <String, String>{'set-cookie': 'session-cookie'},
        rawPreview: '{"echo":"runtime-secret-value"}',
      );
      final history = GraphqlHistoryEntry(
        id: 'history',
        draftId: 'draft',
        workspaceId: 'workspace',
        operationType: GraphqlOperationType.query,
        summary: const <String, Object?>{
          'request': <String, Object?>{
            'endpoint': 'https://api.example.test/graphql?token=query-token',
            'headers': <String, String>{
              'Authorization': 'Bearer header-secret',
            },
          },
          'data': <String, String>{'echo': runtimeSecret},
        },
        createdAt: DateTime(2026),
      );

      final files = await Future.wait(<Future<File>>[
        service.exportRequest(request),
        service.exportResponse(
          response,
          runtimeSecrets: const <String>{runtimeSecret},
        ),
        service.exportHistory(
          history,
          runtimeSecrets: const <String>{runtimeSecret},
        ),
      ]);
      final joined = (await Future.wait(
        files.map((file) => file.readAsString()),
      )).join();

      for (final secret in <String>[
        'header-secret',
        'variable-secret',
        'query-token',
        'runtime-secret-value',
        'response-token',
        'session-cookie',
        'extension-secret',
      ]) {
        expect(joined, isNot(contains(secret)));
      }
      expect(joined, contains('[REDACTED]'));
      expect(joined, contains('https://api.example.test/graphql'));
      expect(joined, contains('X-Client'));
    },
  );

  test(
    'GraphQL export JSON is deterministic and removes endpoint credentials',
    () {
      const request = GraphqlRequest(
        endpoint: 'https://user:pass@api.example.test/graphql?api_key=hidden',
        document: 'query Viewer { viewer { id } }',
        variables: <String, Object?>{'token': 'hidden'},
      );
      final service = GraphqlSafeExportService();

      final first = service.requestJson(request);
      final second = service.requestJson(request);

      expect(first, second);
      expect(first, contains('https://api.example.test/graphql'));
      expect(first, isNot(contains('user:pass')));
      expect(first, isNot(contains('hidden')));
    },
  );
}
