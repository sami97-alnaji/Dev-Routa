import 'dart:convert';

import 'package:devroute_ai_studio/core/storage/database_schema.dart'
    hide GraphqlSavedRequest;
import 'package:devroute_ai_studio/features/graphql/data/graphql_repository.dart';
import 'package:devroute_ai_studio/features/graphql/domain/graphql_models.dart';
import 'package:devroute_ai_studio/shared/models/api_models.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late GraphqlRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = GraphqlRepository(database);
  });
  tearDown(() => database.close());

  test('saved GraphQL requests round-trip and can move/delete', () async {
    final saved = await repository.saveRequest(
      workspaceId: 'workspace',
      name: 'Users',
      collectionId: 'collection-a',
      request: const GraphqlRequest(
        endpoint: 'http://127.0.0.1/graphql',
        document: 'query Users { users { id } }',
        operationName: 'Users',
        variables: <String, Object?>{'limit': 10},
      ),
    );
    expect(
      (await repository.requests('workspace')).single.request.document,
      contains('users'),
    );
    await repository.moveRequest(
      saved.id,
      collectionId: 'collection-b',
      folderId: 'folder',
    );
    expect(
      (await repository.requests('workspace')).single.collectionId,
      'collection-b',
    );
    await repository.deleteRequest(saved.id);
    expect(await repository.requests('workspace'), isEmpty);
  });

  test(
    'saved requests preserve executable references and support CRUD tools',
    () async {
      final first = await repository.saveRequest(
        workspaceId: 'workspace',
        name: 'Users',
        request: const GraphqlRequest(
          endpoint: 'http://127.0.0.1/graphql',
          document: 'query Users { users { id } }',
          operationName: 'Users',
          extensions: <String, Object?>{
            'persistedQuery': <String, Object?>{'v': 1},
          },
          auth: RequestAuthModel(
            type: AuthType.bearer,
            tokenSecretRef: 'secure/graphql/users-token',
          ),
          settings: RequestSettingsModel(receiveTimeoutMs: 42000),
        ),
      );
      final renamed = await repository.renameRequest(first.id, 'All users');
      expect(renamed.name, 'All users');
      final copy = await repository.duplicateRequest(first.id);
      expect(copy.id, isNot(first.id));
      expect(copy.request.auth.tokenSecretRef, 'secure/graphql/users-token');
      expect(copy.request.extensions['persistedQuery'], isA<Map>());
      expect(copy.request.settings.receiveTimeoutMs, 42000);
      expect(
        await repository.searchRequests('workspace', 'All'),
        contains(predicate<GraphqlSavedRequest>((item) => item.id == first.id)),
      );
      await repository.reorderRequests('workspace', <String>[
        copy.id,
        first.id,
      ]);
      expect((await repository.requests('workspace')).first.id, copy.id);
      await repository.saveRequest(
        id: first.id,
        workspaceId: 'workspace',
        name: 'Updated users',
        request: first.request,
      );
      expect(
        (await repository.requestById(first.id))!.createdAt,
        first.createdAt,
      );
    },
  );

  test('GraphQL history is sanitized, searchable, and retained', () async {
    final response = GraphqlResponse(
      statusCode: 200,
      data: const <String, Object?>{'ok': true},
      errors: const <GraphqlResponseError>[],
      extensions: const <String, Object?>{'trace': 'local'},
      duration: const Duration(milliseconds: 12),
      sizeBytes: 20,
      headers: const <String, String>{'set-cookie': '[REDACTED]'},
      rawPreview: '{"ok":true}',
    );
    await repository.record(
      workspaceId: 'workspace',
      type: GraphqlOperationType.query,
      response: response,
      request: const GraphqlRequest(
        endpoint: 'http://127.0.0.1/graphql',
        document: 'query Users { users }',
        headers: <String, String>{'Authorization': 'Bearer secret'},
      ),
    );
    final entries = await repository.history('workspace', query: 'users');
    expect(entries, hasLength(1));
    expect(
      jsonEncode(entries.single.summary),
      isNot(contains('Bearer secret')),
    );
    await repository.applyHistoryRetention(
      workspaceId: 'workspace',
      maximumCount: 0,
    );
    expect(await repository.history('workspace'), isEmpty);
  });
}
