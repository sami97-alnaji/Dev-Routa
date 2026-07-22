import 'package:devroute_ai_studio/core/storage/database_schema.dart'
    hide GraphqlDraft;
import 'package:devroute_ai_studio/features/graphql/data/graphql_repository.dart';
import 'package:devroute_ai_studio/features/graphql/data/graphql_http_service.dart';
import 'package:devroute_ai_studio/features/graphql/application/graphql_execution_service.dart';
import 'package:devroute_ai_studio/features/graphql/domain/graphql_models.dart';
import 'package:devroute_ai_studio/features/graphql/presentation/graphql_workflow_cubit.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'GraphQL tabs autosave full drafts and restore independent active state',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final repository = GraphqlRepository(database);
      final execution = GraphqlExecutionService(
        GraphqlHttpService(),
        repository,
      );
      final first = GraphqlWorkflowCubit(
        repository,
        execution,
        workspaceId: 'workspace',
      );
      first.updateEndpoint('http://127.0.0.1/graphql');
      first.updateDocument('query One { one }');
      first.updateVariables(<String, Object?>{'page': 1});
      first.updateExtensions(<String, Object?>{'trace': true});
      first.newDraft(
        request: const GraphqlRequest(
          endpoint: 'http://127.0.0.1/graphql',
          document: 'query Two { two }',
        ),
      );
      first.renameActive('Two');
      await Future<void>.delayed(Duration.zero);

      final restored = GraphqlWorkflowCubit(
        repository,
        execution,
        workspaceId: 'workspace',
      );
      await restored.restoreDrafts();
      expect(restored.state.tabs, hasLength(2));
      expect(restored.state.active.title, 'Two');
      restored.selectTab(0);
      expect(restored.state.active.request.variables, <String, Object?>{
        'page': 1,
      });
      expect(restored.state.active.request.extensions, <String, Object?>{
        'trace': true,
      });

      final saved = await restored.saveActive(forceNew: true);
      expect(restored.state.active.savedRequestId, saved.id);
      expect(restored.state.active.isDirty, isFalse);
      await restored.closeActive(discardChanges: true);
      expect(restored.state.tabs, hasLength(1));
      await first.close();
      await restored.close();
      await database.close();
    },
  );

  test(
    'GraphQL tab close guards dirty tabs and closes the requested tab',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final repository = GraphqlRepository(database);
      final execution = GraphqlExecutionService(
        GraphqlHttpService(),
        repository,
      );
      final cubit = GraphqlWorkflowCubit(
        repository,
        execution,
        workspaceId: 'workspace',
      );

      cubit.updateDocument('query One { one }');
      cubit.newDraft(
        request: const GraphqlRequest(
          endpoint: 'http://127.0.0.1/graphql',
          document: 'query Two { two }',
        ),
      );
      cubit.renameActive('Two');

      final firstId = cubit.state.tabs.first.id;
      await cubit.closeTab(firstId, discardChanges: false);
      expect(cubit.state.tabs, hasLength(2));

      await cubit.closeTab(firstId, discardChanges: true);
      expect(cubit.state.tabs, hasLength(1));
      expect(cubit.state.active.title, 'Two');

      await cubit.close();
      await database.close();
    },
  );

  test(
    'GraphQL saved requests update and reorder through the workflow cubit',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final repository = GraphqlRepository(database);
      final execution = GraphqlExecutionService(
        GraphqlHttpService(),
        repository,
      );
      final first = await repository.saveRequest(
        workspaceId: 'workspace',
        name: 'First',
        collectionId: 'collection-a',
        request: const GraphqlRequest(
          endpoint: 'http://127.0.0.1/graphql',
          document: 'query First { first }',
        ),
      );
      final second = await repository.saveRequest(
        workspaceId: 'workspace',
        name: 'Second',
        request: const GraphqlRequest(
          endpoint: 'http://127.0.0.1/graphql',
          document: 'query Second { second }',
        ),
      );

      final cubit = GraphqlWorkflowCubit(
        repository,
        execution,
        workspaceId: 'workspace',
      );
      await cubit.refreshSavedRequests();
      await cubit.renameSavedRequest(first.id, 'Renamed first');
      await cubit.reorderSavedRequest(second.id, 0);
      await cubit.moveSavedRequest(
        first.id,
        collectionId: 'collection-b',
        folderId: 'folder-b',
      );

      expect((await repository.requestById(second.id))!.sortOrder, 0);
      expect((await repository.requestById(first.id))!.name, 'Renamed first');
      final moved = await repository.requestById(first.id);
      expect(moved!.collectionId, 'collection-b');
      expect(moved.folderId, 'folder-b');
      expect(moved.sortOrder, 0);

      await cubit.close();
      await database.close();
    },
  );

  test(
    'opening a saved request is clean, deduplicated, and tracks a baseline',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final repository = GraphqlRepository(database);
      final execution = GraphqlExecutionService(
        GraphqlHttpService(),
        repository,
      );
      final saved = await repository.saveRequest(
        workspaceId: 'workspace',
        name: 'Users',
        request: const GraphqlRequest(
          endpoint: 'http://127.0.0.1/graphql',
          document: 'query Users { users { id } }',
          variables: <String, Object?>{'page': 1, 'limit': 10},
        ),
      );
      final cubit = GraphqlWorkflowCubit(
        repository,
        execution,
        workspaceId: 'workspace',
      );

      cubit.openSavedRequest(saved);
      expect(cubit.state.active.isDirty, isFalse);
      cubit.updateVariables(<String, Object?>{'limit': 10, 'page': 1});
      expect(cubit.state.active.isDirty, isFalse);
      cubit.updateDocument('query Users { users { id name } }');
      expect(cubit.state.active.isDirty, isTrue);
      cubit.updateDocument(saved.request.document);
      expect(cubit.state.active.isDirty, isFalse);
      cubit.openSavedRequest(saved);
      expect(
        cubit.state.tabs.where((tab) => tab.savedRequestId == saved.id),
        hasLength(1),
      );

      await cubit.close();
      await database.close();
    },
  );
}
