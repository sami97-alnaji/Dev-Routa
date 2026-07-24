import 'dart:convert';
import 'dart:io';

import 'package:devroute_ai_studio/core/storage/database_schema.dart'
    hide GraphqlDraft;
import 'package:devroute_ai_studio/features/graphql/application/graphql_execution_service.dart';
import 'package:devroute_ai_studio/features/graphql/data/graphql_http_service.dart';
import 'package:devroute_ai_studio/features/graphql/data/graphql_repository.dart';
import 'package:devroute_ai_studio/features/graphql/domain/graphql_models.dart';
import 'package:devroute_ai_studio/features/graphql/presentation/graphql_workflow_cubit.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each tab has isolated execution state and sanitized history', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode(<String, Object?>{
          'data': {'ok': true},
        }),
      );
      await request.response.close();
    });
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = GraphqlRepository(database);
    final cubit = GraphqlWorkflowCubit(
      repository,
      GraphqlExecutionService(GraphqlHttpService(), repository),
      workspaceId: 'workspace',
    );
    cubit.updateEndpoint(
      'http://${server.address.host}:${server.port}/graphql',
    );
    cubit.updateDocument('query First { ok }');
    final firstId = cubit.state.active.id;
    cubit.newDraft();
    cubit.updateEndpoint(
      'http://${server.address.host}:${server.port}/graphql',
    );
    cubit.updateDocument('query Second { ok }');
    final secondId = cubit.state.active.id;

    await cubit.executeActive();
    expect(cubit.state.executionFor(secondId).response?.data, {'ok': true});
    expect(cubit.state.executionFor(firstId).phase, GraphqlExecutionPhase.idle);
    final rows = await database
        .customSelect('SELECT * FROM graphql_history')
        .get();
    expect(rows, hasLength(1));

    await cubit.close();
    await database.close();
    await server.close(force: true);
  });

  test(
    'execution blocks unresolved environment placeholders before transport',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final repository = GraphqlRepository(database);
      final service = GraphqlExecutionService(GraphqlHttpService(), repository);
      expect(
        () => service.execute(
          tabId: 'tab',
          workspaceId: 'workspace',
          request: const GraphqlRequest(
            endpoint: '{{missingEndpoint}}',
            document: 'query Missing { ok }',
          ),
        ),
        throwsA(
          isA<GraphqlFailure>().having(
            (failure) => failure.category,
            'category',
            GraphqlFailureCategory.unresolvedVariable,
          ),
        ),
      );
      await database.close();
    },
  );
}
