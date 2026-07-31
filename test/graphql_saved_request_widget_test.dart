import 'package:devroute_ai_studio/app.dart';
import 'package:devroute_ai_studio/core/storage/database_schema.dart';
import 'package:devroute_ai_studio/features/graphql/application/graphql_execution_service.dart';
import 'package:devroute_ai_studio/features/graphql/data/graphql_repository.dart';
import 'package:devroute_ai_studio/features/graphql/presentation/graphql_workflow_cubit.dart';
import 'package:devroute_ai_studio/features/workspace/presentation/workspace_cubit.dart';
import 'package:drift/native.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const responsiveViewports = <Size>[Size(800, 600), Size(390, 844)];

  Future<AppDatabase> openGraphql(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await tester.pumpWidget(DevRouteApp(database: database));
    await tester.pumpAndSettle();
    final graphqlNavigation = find.text('GraphQL');
    await tester.tap(
      graphqlNavigation.evaluate().isNotEmpty
          ? graphqlNavigation.last
          : find.byTooltip('GraphQL'),
    );
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
    await tester.drag(find.byType(ListView).first, const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(saveAsNew, findsOneWidget);
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

  Future<void> openActions(WidgetTester tester, {String? requestName}) async {
    Finder actions = find.byTooltip('Saved request actions');
    await tester.drag(find.byType(ListView).first, const Offset(0, -1200));
    await tester.pumpAndSettle();
    if (requestName != null) {
      final requestTile = find.byWidgetPredicate(
        (widget) =>
            widget is ListTile &&
            widget.title is Text &&
            (widget.title as Text).data == requestName,
      );
      expect(requestTile, findsOneWidget);
      actions = find.descendant(
        of: requestTile,
        matching: find.byTooltip('Saved request actions'),
      );
    }
    expect(actions, findsWidgets);
    final action = actions.first;
    await tester.ensureVisible(action);
    await tester.pumpAndSettle();
    await tester.tap(action);
    await tester.pumpAndSettle();
  }

  Future<void> openNewDraft(WidgetTester tester) async {
    final newDraft = find.widgetWithText(ActionChip, '+');
    await tester.drag(find.byType(ListView).first, const Offset(0, 700));
    await tester.pumpAndSettle();
    expect(newDraft, findsOneWidget);
    await tester.tap(newDraft);
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

  for (final size in const <Size>[
    Size(390, 844),
    Size(600, 800),
    Size(800, 600),
    Size(1024, 700),
  ]) {
    testWidgets('dirty GraphQL close and naming dialogs fit at $size', (
      tester,
    ) async {
      await openGraphql(tester, size);
      await makeDirty(tester);
      await tester.tap(find.byTooltip('Close GraphQL tab'));
      await tester.pumpAndSettle();

      final closeDialog = find.byType(AlertDialog);
      expect(
        find.descendant(of: closeDialog, matching: find.text('Cancel')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: closeDialog, matching: find.text('Discard')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: closeDialog, matching: find.text('Save')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      await tester.tap(
        find.descendant(of: closeDialog, matching: find.text('Save')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Save GraphQL request'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Cancel'),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

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

  for (final viewport in responsiveViewports) {
    final viewportLabel =
        '${viewport.width.toInt()}x${viewport.height.toInt()}';

    testWidgets(
      'saved request popup renames a linked clean tab at $viewportLabel',
      (tester) async {
        final database = await openGraphql(tester, viewport);
        final cubit = workflow(tester);
        await makeDirty(tester);
        await saveCurrentAs(tester, 'Get User');
        await openActions(tester);
        await tester.tap(find.text('Rename').last);
        await tester.pumpAndSettle();

        expect(find.text('Rename saved request'), findsOneWidget);
        final nameField = find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        );
        await tester.enterText(nameField, '');
        await tester.pump();
        final save = find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(FilledButton, 'Save'),
        );
        expect(tester.widget<FilledButton>(save).onPressed, isNull);
        await tester.enterText(nameField, 'Get User Details');
        await tester.pump();
        await tester.tap(save);
        await tester.pumpAndSettle();

        expect(find.text('Get User Details'), findsWidgets);
        expect(cubit.state.active.title, 'Get User Details');
        expect(
          (await database
                  .customSelect('SELECT name FROM graphql_saved_requests')
                  .getSingle())
              .read<String>('name'),
          'Get User Details',
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'saved request delete keeps a clean linked tab as a dirty draft at $viewportLabel',
      (tester) async {
        final database = await openGraphql(tester, viewport);
        final cubit = workflow(tester);
        await makeDirty(tester);
        await saveCurrentAs(tester, 'Clean linked request');
        final before = cubit.state.active;
        expect(before.isDirty, isFalse);
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
        expect(detached.request, before.request);
        expect(
          await database
              .customSelect('SELECT id FROM graphql_saved_requests')
              .get(),
          isEmpty,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'saved request delete retains dirty linked-tab content at $viewportLabel',
      (tester) async {
        final database = await openGraphql(tester, viewport);
        final cubit = workflow(tester);
        await makeDirty(tester);
        await saveCurrentAs(tester, 'Dirty linked request');
        await tester.enterText(
          find.widgetWithText(TextField, 'Endpoint'),
          'http://127.0.0.1/graphql/changed',
        );
        await tester.pumpAndSettle();
        await openActions(tester);
        await tester.tap(find.text('Delete').last);
        await tester.pumpAndSettle();

        expect(
          find.text('Delete saved request and keep draft?'),
          findsOneWidget,
        );
        expect(
          find.text(
            'Unsaved edits will remain in an independent draft. The tab will not close.',
          ),
          findsOneWidget,
        );
        await tester.tap(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.widgetWithText(
              FilledButton,
              'Delete and keep draft',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(cubit.state.active.savedRequestId, isNull);
        expect(cubit.state.active.isDirty, isTrue);
        expect(
          cubit.state.active.request.endpoint,
          'http://127.0.0.1/graphql/changed',
        );
        expect(
          await database
              .customSelect('SELECT id FROM graphql_saved_requests')
              .get(),
          isEmpty,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'saved request popup moves through a folder and workspace root at $viewportLabel',
      (tester) async {
        final database = await openGraphql(tester, viewport);
        await makeDirty(tester);
        await saveCurrentAs(tester, 'Move me');
        final workspace = await database
            .customSelect('SELECT id FROM workspaces LIMIT 1')
            .getSingle();
        await database.customStatement(
          '''INSERT INTO collections (id, workspace_id, name, created_at, updated_at, sort_order)
          VALUES (?, ?, ?, unixepoch(), unixepoch(), 0)''',
          <Object?>[
            'graphql-test-collection',
            workspace.read<String>('id'),
            'API',
          ],
        );
        await database.customStatement(
          '''INSERT INTO folders (id, collection_id, name, created_at, updated_at, sort_order)
          VALUES (?, ?, ?, unixepoch(), unixepoch(), 0)''',
          <Object?>['graphql-test-folder', 'graphql-test-collection', 'Users'],
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
        expect(find.text('Choose folder'), findsOneWidget);
        await tester.tap(find.text('Users'));
        await tester.pumpAndSettle();
        var moved = await database
            .customSelect(
              'SELECT collection_id, folder_id FROM graphql_saved_requests',
            )
            .getSingle();
        expect(moved.read<String?>('collection_id'), 'graphql-test-collection');
        expect(moved.read<String?>('folder_id'), 'graphql-test-folder');

        await openActions(tester);
        await tester.tap(find.text('Move').last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Workspace root (unfiled)'));
        await tester.pumpAndSettle();
        moved = await database
            .customSelect(
              'SELECT collection_id, folder_id FROM graphql_saved_requests',
            )
            .getSingle();
        expect(moved.read<String?>('collection_id'), isNull);
        expect(moved.read<String?>('folder_id'), isNull);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'saved request popup reorders with move up and down at $viewportLabel',
      (tester) async {
        final database = await openGraphql(tester, viewport);
        await makeDirty(tester);
        await saveCurrentAs(tester, 'First request');
        await openNewDraft(tester);
        await makeDirty(tester);
        await saveCurrentAs(tester, 'Second request');
        await openNewDraft(tester);
        await makeDirty(tester);
        await saveCurrentAs(tester, 'Third request');
        final cubit = workflow(tester);
        final repository = RepositoryProvider.of<GraphqlRepository>(
          tester.element(find.text('GraphQL Studio')),
        );
        final executionService = RepositoryProvider.of<GraphqlExecutionService>(
          tester.element(find.text('GraphQL Studio')),
        );

        final before = cubit.state.savedRequests
            .map((request) => request.name)
            .toList();
        final movingRequest = before.first;
        await openActions(tester, requestName: movingRequest);
        await tester.tap(find.text('Move down').last);
        await tester.pumpAndSettle();
        final afterDown = cubit.state.savedRequests
            .map((request) => request.name)
            .toList();
        expect(afterDown, isNot(before));
        await openActions(tester, requestName: movingRequest);
        await tester.tap(find.text('Move up').last);
        await tester.pumpAndSettle();
        final after = cubit.state.savedRequests
            .map((request) => request.name)
            .toList();
        expect(after, before);
        expect(
          (await database
                  .customSelect(
                    'SELECT sort_order FROM graphql_saved_requests ORDER BY sort_order',
                  )
                  .get())
              .map((row) => row.read<int>('sort_order'))
              .toList(),
          <int>[0, 1, 2],
        );

        final reloaded = GraphqlWorkflowCubit(
          repository,
          executionService,
          workspaceId: cubit.workspaceId,
        );
        await reloaded.restoreDrafts();
        expect(
          reloaded.state.savedRequests.map((request) => request.name).toList(),
          after,
        );
        await reloaded.close();
        expect(tester.takeException(), isNull);
      },
    );
  }
}
