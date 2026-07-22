import 'package:devroute_ai_studio/app.dart';
import 'package:devroute_ai_studio/core/storage/database_schema.dart';
import 'package:devroute_ai_studio/features/graphql/application/graphql_execution_service.dart';
import 'package:devroute_ai_studio/features/graphql/data/graphql_repository.dart';
import 'package:devroute_ai_studio/features/graphql/domain/graphql_models.dart';
import 'package:devroute_ai_studio/features/graphql/presentation/graphql_workflow_cubit.dart';
import 'package:devroute_ai_studio/features/workspace/presentation/workspace_cubit.dart';
import 'package:drift/native.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<AppDatabase> openGraphql(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await tester.pumpWidget(DevRouteApp(database: database));
    await tester.pumpAndSettle();
    await tester.tap(find.text('GraphQL').last);
    await tester.pumpAndSettle();
    expect(find.text('Endpoint'), findsOneWidget);
    return database;
  }

  Future<void> makeDirty(WidgetTester tester) async {
    await tester.enterText(
      find.widgetWithText(TextField, 'Endpoint'),
      'http://127.0.0.1/graphql',
    );
    await tester.pump();
  }

  Future<void> saveCurrentAs(WidgetTester tester, String name) async {
    final saveAsNew = find.widgetWithText(OutlinedButton, 'Save as new');
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -700),
    );
    await tester.pumpAndSettle();
    await tester.tap(saveAsNew);
    await tester.pumpAndSettle();
    final field = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(field, name);
    await tester.pump();
    final save = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(FilledButton, 'Save'),
    );
    expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
    await tester.tap(save);
    await tester.pumpAndSettle();
  }

  Future<void> openActions(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Saved request actions').first);
    await tester.pumpAndSettle();
  }

  GraphqlWorkflowCubit workflow(WidgetTester tester) =>
      BlocProvider.of<GraphqlWorkflowCubit>(
        tester.element(find.text('GraphQL Studio')),
      );

  testWidgets('dirty GraphQL tab close offers cancel and keeps the tab', (
    tester,
  ) async {
    await openGraphql(tester, const Size(800, 600));
    await makeDirty(tester);
    await tester.tap(find.byTooltip('Close GraphQL tab'));
    await tester.pumpAndSettle();

    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Discard'), findsOneWidget);
    final cancel = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.text('Cancel'),
    );
    expect(cancel, findsOneWidget);
    await tester.tap(cancel);
    await tester.pumpAndSettle();
    expect(find.byType(InputChip), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('saving a new dirty tab asks for a non-empty name before close', (
    tester,
  ) async {
    await openGraphql(tester, const Size(1440, 900));
    await makeDirty(tester);
    await tester.tap(find.byTooltip('Close GraphQL tab'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Save GraphQL request'), findsOneWidget);
    final save = find.widgetWithText(FilledButton, 'Save');
    expect(tester.widget<FilledButton>(save).onPressed, isNull);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Cancel'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(InputChip), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'GraphQL dirty exit guard names the source and stays on request',
    (tester) async {
      await openGraphql(tester, const Size(390, 844));
      await makeDirty(tester);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('Unsaved changes'), findsOneWidget);
      expect(
        find.text('There are unsaved changes in GraphQL.'),
        findsOneWidget,
      );
      expect(find.text('Stay'), findsOneWidget);
      expect(find.text('Discard and exit'), findsOneWidget);
      await tester.tap(find.text('Stay'));
      await tester.pumpAndSettle();
      expect(find.text('Endpoint'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('saved request popup renames a linked clean tab', (tester) async {
    final database = await openGraphql(tester, const Size(1440, 900));
    await makeDirty(tester);
    await saveCurrentAs(tester, 'Get User');
    final rows = await database
        .customSelect('SELECT name FROM graphql_saved_requests')
        .get();
    expect(rows, hasLength(1));
    expect(find.text('Get User'), findsWidgets);
    await openActions(tester);
    await tester.tap(find.text('Rename').last);
    await tester.pumpAndSettle();

    final nameField = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    expect(tester.widget<TextField>(nameField).controller!.text, 'Get User');
    await tester.enterText(nameField, 'Get User Details');
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Save'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Get User Details'), findsWidgets);
    expect(find.textContaining('* Get User Details'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('saved request delete keeps its linked tab as a dirty draft', (
    tester,
  ) async {
    await openGraphql(tester, const Size(1440, 900));
    await makeDirty(tester);
    await saveCurrentAs(tester, 'Delete me');
    await tester.enterText(
      find.widgetWithText(TextField, 'Endpoint'),
      'http://127.0.0.1/graphql/changed',
    );
    await tester.pump();
    expect(find.text('Delete me'), findsWidgets);
    await openActions(tester);
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(find.text('Delete saved request and keep draft?'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Delete and keep draft'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, 700),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Saved request actions'), findsNothing);
    final draftChip = tester.widget<InputChip>(find.byType(InputChip).first);
    expect((draftChip.label as Text).data, startsWith('* '));
    expect(tester.takeException(), isNull);
  });

  testWidgets('saved request delete detaches a linked clean tab', (
    tester,
  ) async {
    final database = await openGraphql(tester, const Size(1440, 900));
    final cubit = workflow(tester);
    cubit.updateEndpoint('http://127.0.0.1/graphql');
    cubit.updateDocument('query User { user { id } }');
    cubit.updateVariables(<String, Object?>{'id': '42'});
    cubit.updateHeaders(<String, String>{'x-client': 'widget-test'});
    await tester.pumpAndSettle();
    await saveCurrentAs(tester, 'Clean linked request');
    final before = cubit.state.active;
    expect(before.isDirty, isFalse);
    expect(before.savedRequestId, isNotNull);

    await openActions(tester);
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Cancel'),
      ),
    );
    await tester.pumpAndSettle();
    expect(cubit.state.active.savedRequestId, before.savedRequestId);
    expect(
      await database
          .customSelect('SELECT id FROM graphql_saved_requests')
          .get(),
      hasLength(1),
    );

    await openActions(tester);
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(find.text('Delete saved request?'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Delete'),
      ),
    );
    await tester.pumpAndSettle();

    final detached = cubit.state.active;
    expect(detached.savedRequestId, isNull);
    expect(detached.isDirty, isTrue);
    expect(detached.request.endpoint, before.request.endpoint);
    expect(detached.request.document, before.request.document);
    expect(detached.request.variables, before.request.variables);
    expect(detached.request.headers, before.request.headers);
    expect(
      await database
          .customSelect('SELECT id FROM graphql_saved_requests')
          .get(),
      isEmpty,
    );
    expect(find.byType(InputChip), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('saved request popup moves a request into a collection', (
    tester,
  ) async {
    final database = await openGraphql(tester, const Size(1440, 900));
    await makeDirty(tester);
    await saveCurrentAs(tester, 'Move me');
    final workspace = await database
        .customSelect('SELECT id FROM workspaces LIMIT 1')
        .getSingle();
    await database.customStatement(
      '''INSERT INTO collections (id, workspace_id, name, created_at, updated_at, sort_order)
         VALUES (?, ?, ?, unixepoch(), unixepoch(), 0)''',
      <Object?>['graphql-test-collection', workspace.read<String>('id'), 'API'],
    );
    await BlocProvider.of<WorkspaceCubit>(
      tester.element(find.text('GraphQL Studio')),
    ).load();
    await tester.pumpAndSettle();
    await openActions(tester);
    await tester.tap(find.text('Move').last);
    await tester.pumpAndSettle();
    expect(find.text('Move saved request'), findsOneWidget);
    await tester.tap(find.text('API'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Collection root'));
    await tester.pumpAndSettle();

    final moved = await database
        .customSelect(
          'SELECT collection_id, folder_id FROM graphql_saved_requests',
        )
        .getSingle();
    expect(moved.read<String?>('collection_id'), 'graphql-test-collection');
    expect(moved.read<String?>('folder_id'), isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('saved request popup reorders sibling requests', (tester) async {
    final database = await openGraphql(tester, const Size(1440, 900));
    await makeDirty(tester);
    await saveCurrentAs(tester, 'First request');
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, 700),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ActionChip, '+'));
    await tester.pumpAndSettle();
    await makeDirty(tester);
    await saveCurrentAs(tester, 'Second request');
    final cubit = workflow(tester);
    final repository = RepositoryProvider.of<GraphqlRepository>(
      tester.element(find.text('GraphQL Studio')),
    );
    await repository.saveRequest(
      workspaceId: cubit.workspaceId,
      name: 'Third request',
      request: const GraphqlRequest(
        endpoint: 'http://127.0.0.1/graphql',
        document: 'query Third { third }',
      ),
    );
    final otherFolder = await repository.saveRequest(
      workspaceId: cubit.workspaceId,
      name: 'Other folder request',
      collectionId: 'other-collection',
      folderId: 'other-folder',
      request: const GraphqlRequest(
        endpoint: 'http://127.0.0.1/graphql',
        document: 'query Other { other }',
      ),
    );
    await cubit.refreshSavedRequests();
    await tester.pumpAndSettle();
    final before = cubit.state.savedRequests
        .where(
          (request) => request.collectionId == null && request.folderId == null,
        )
        .map((request) => request.name)
        .toList();
    final linkedTabIds = cubit.state.tabs
        .map((tab) => tab.savedRequestId)
        .toList();
    await openActions(tester);
    await tester.tap(find.text('Move down').last);
    await tester.pumpAndSettle();
    final after = cubit.state.savedRequests
        .where(
          (request) => request.collectionId == null && request.folderId == null,
        )
        .map((request) => request.name)
        .toList();
    final persisted = await database.customSelect(
      '''SELECT name, sort_order FROM graphql_saved_requests
             WHERE collection_id IS NULL AND folder_id IS NULL
             ORDER BY sort_order''',
    ).get();

    expect(after, isNot(before));
    expect(persisted.map((row) => row.read<int>('sort_order')).toList(), <int>[
      0,
      1,
      2,
    ]);
    expect((await repository.requestById(otherFolder.id))!.sortOrder, 0);
    expect(
      cubit.state.tabs.map((tab) => tab.savedRequestId).toList(),
      linkedTabIds,
    );

    final reloaded = GraphqlWorkflowCubit(
      repository,
      RepositoryProvider.of<GraphqlExecutionService>(
        tester.element(find.text('GraphQL Studio')),
      ),
      workspaceId: cubit.workspaceId,
    );
    await reloaded.restoreDrafts();
    expect(
      reloaded.state.savedRequests
          .where(
            (request) =>
                request.collectionId == null && request.folderId == null,
          )
          .map((request) => request.name)
          .toList(),
      after,
    );
    await reloaded.close();
    expect(tester.takeException(), isNull);
  });
}
