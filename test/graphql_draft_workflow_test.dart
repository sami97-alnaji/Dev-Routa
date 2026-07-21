import 'package:devroute_ai_studio/core/storage/database_schema.dart'
    hide GraphqlDraft;
import 'package:devroute_ai_studio/features/graphql/data/graphql_repository.dart';
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
      final first = GraphqlWorkflowCubit(repository, workspaceId: 'workspace');
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
}
