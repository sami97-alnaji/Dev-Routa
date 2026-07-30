import 'package:devroute_ai_studio/app.dart';
import 'package:devroute_ai_studio/core/storage/database_schema.dart'
    hide GraphqlDraft;
import 'package:devroute_ai_studio/features/graphql/data/graphql_repository.dart';
import 'package:devroute_ai_studio/features/graphql/domain/graphql_models.dart';
import 'package:devroute_ai_studio/features/graphql/presentation/graphql_workflow_cubit.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

GraphqlResponse _response(GraphqlCompletionCategory completion) =>
    GraphqlResponse(
      statusCode: 200,
      data: completion == GraphqlCompletionCategory.success
          ? <String, Object?>{'ok': true}
          : null,
      errors: completion == GraphqlCompletionCategory.success
          ? const <GraphqlResponseError>[]
          : const <GraphqlResponseError>[
              GraphqlResponseError(message: 'GraphQL response error'),
            ],
      extensions: null,
      duration: Duration.zero,
      sizeBytes: 0,
      headers: const <String, String>{},
      completion: completion,
    );

void main() {
  for (final size in const <Size>[Size(800, 600), Size(390, 844)]) {
    testWidgets('history filters work from the screen at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = GraphqlRepository(database);

      await tester.pumpWidget(DevRouteApp(database: database));
      await tester.pumpAndSettle();
      await tester.tap(find.text('GraphQL').last);
      await tester.pumpAndSettle();
      final cubit = BlocProvider.of<GraphqlWorkflowCubit>(
        tester.element(find.text('GraphQL Studio')),
      );
      await repository.record(
        workspaceId: cubit.workspaceId,
        type: GraphqlOperationType.query,
        response: _response(GraphqlCompletionCategory.success),
        request: const GraphqlRequest(
          endpoint: 'https://one.example/graphql?token=visible-token',
          document: 'query One { one }',
        ),
      );
      await repository.record(
        workspaceId: cubit.workspaceId,
        type: GraphqlOperationType.mutation,
        response: _response(GraphqlCompletionCategory.graphqlFailure),
        request: const GraphqlRequest(
          endpoint: 'https://two.example/graphql',
          document: 'mutation Two { two }',
        ),
      );
      await cubit.refreshHistory();
      await tester.pumpAndSettle();
      await tester.drag(find.text('GraphQL Studio'), const Offset(0, -1200));
      await tester.pumpAndSettle();
      final outcomeFilter = find.byKey(
        const Key('graphql-history-outcome-filter'),
      );
      await tester.ensureVisible(outcomeFilter);
      await tester.pumpAndSettle();
      await tester.tap(outcomeFilter);
      await tester.pumpAndSettle();
      await tester.tap(find.text('GraphQL error').last);
      await tester.pumpAndSettle();

      expect(find.text('Showing 1 of 2'), findsOneWidget);
      expect(find.text('visible-token'), findsNothing);
      expect(
        find.byKey(const Key('graphql-history-clear-filters')),
        findsOneWidget,
      );

      final clearFilters = find.byKey(
        const Key('graphql-history-clear-filters'),
      );
      await tester.ensureVisible(clearFilters);
      await tester.pumpAndSettle();
      await tester.tap(clearFilters);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Showing 2 of 2'));
      await tester.pumpAndSettle();
      expect(find.text('Showing 2 of 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
