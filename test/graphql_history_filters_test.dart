import 'package:devroute_ai_studio/core/storage/database_schema.dart'
    hide GraphqlDraft;
import 'package:devroute_ai_studio/features/graphql/application/graphql_execution_service.dart';
import 'package:devroute_ai_studio/features/graphql/data/graphql_http_service.dart';
import 'package:devroute_ai_studio/features/graphql/data/graphql_repository.dart';
import 'package:devroute_ai_studio/features/graphql/domain/graphql_models.dart';
import 'package:devroute_ai_studio/features/graphql/presentation/graphql_workflow_cubit.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

GraphqlResponse _response(GraphqlCompletionCategory completion) =>
    GraphqlResponse(
      statusCode: 200,
      data: completion == GraphqlCompletionCategory.success
          ? <String, Object?>{'ok': true}
          : null,
      errors: completion == GraphqlCompletionCategory.graphqlFailure
          ? const <GraphqlResponseError>[
              GraphqlResponseError(message: 'bad query'),
            ]
          : const <GraphqlResponseError>[],
      extensions: null,
      duration: Duration.zero,
      sizeBytes: 0,
      headers: const <String, String>{},
      completion: completion,
    );

void main() {
  test('history filters compose and survive refresh and deletion', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = GraphqlRepository(database);
    final requests = <GraphqlRequest>[
      const GraphqlRequest(
        endpoint: 'https://one.example/graphql?token=hidden',
        document: 'query One { one }',
      ),
      const GraphqlRequest(
        endpoint: 'https://two.example/graphql',
        document: 'mutation Two { two }',
      ),
      const GraphqlRequest(
        endpoint: 'https://one.example/graphql?token=hidden',
        document: 'query Three { three }',
      ),
    ];
    await repository.record(
      workspaceId: 'workspace',
      type: GraphqlOperationType.query,
      response: _response(GraphqlCompletionCategory.success),
      request: requests[0],
    );
    await repository.record(
      workspaceId: 'workspace',
      type: GraphqlOperationType.mutation,
      response: _response(GraphqlCompletionCategory.graphqlFailure),
      request: requests[1],
    );
    await repository.record(
      workspaceId: 'workspace',
      type: GraphqlOperationType.query,
      response: _response(GraphqlCompletionCategory.httpFailure),
      request: requests[2],
    );
    final cubit = GraphqlWorkflowCubit(
      repository,
      GraphqlExecutionService(GraphqlHttpService(), repository),
      workspaceId: 'workspace',
    );
    await cubit.refreshHistory();
    expect(cubit.state.availableHistoryEndpoints, hasLength(2));
    cubit.setHistoryOutcomeFilter(GraphqlHistoryOutcomeFilter.transportFailure);
    cubit.setHistoryOperationTypeFilter(GraphqlOperationType.query);
    cubit.setHistoryEndpointFilter(
      cubit.state.availableHistoryEndpoints.firstWhere(
        (value) => value.contains('one.example'),
      ),
    );
    cubit.setHistoryQuery('three');
    expect(cubit.state.history, hasLength(1));
    expect(
      cubit.state.history.single.operationType,
      GraphqlOperationType.query,
    );
    await cubit.refreshHistory();
    expect(cubit.state.history, hasLength(1));
    await cubit.deleteHistory(cubit.state.history.single.id);
    expect(cubit.state.history, isEmpty);
    expect(cubit.state.historyEndpointFilter, isNotNull);
    cubit.clearHistoryFilters();
    expect(cubit.state.hasActiveHistoryFilters, isFalse);
    expect(cubit.state.history, hasLength(2));
    await cubit.close();
    await database.close();
  });
}
