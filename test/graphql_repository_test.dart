import 'package:devroute_ai_studio/core/storage/database_schema.dart';
import 'package:devroute_ai_studio/features/graphql/data/graphql_repository.dart';
import 'package:devroute_ai_studio/features/graphql/domain/graphql_models.dart';
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
}
