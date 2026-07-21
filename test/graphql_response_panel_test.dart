import 'package:devroute_ai_studio/features/graphql/domain/graphql_models.dart';
import 'package:devroute_ai_studio/features/graphql/presentation/graphql_response_panel.dart';
import 'package:devroute_ai_studio/features/graphql/presentation/graphql_workflow_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final response = GraphqlResponse(
    statusCode: 200,
    data: const <String, Object?>{
      'user': <String, Object?>{'id': 1, 'name': 'Sami'},
    },
    errors: const <GraphqlResponseError>[
      GraphqlResponseError(
        message: 'Partial field failure',
        locations: <GraphqlErrorLocation>[
          GraphqlErrorLocation(line: 3, column: 5),
        ],
        path: <GraphqlErrorPathSegment>[
          GraphqlErrorPathSegment(value: 'user'),
          GraphqlErrorPathSegment(value: 'email'),
        ],
        extensions: <String, Object?>{'code': 'PARTIAL'},
      ),
    ],
    extensions: const <String, Object?>{'traceId': 'trace-1'},
    duration: const Duration(milliseconds: 120),
    sizeBytes: 2048,
    headers: const <String, String>{
      'content-type': 'application/json',
      'set-cookie': '[masked]',
    },
    completion: GraphqlCompletionCategory.partialSuccess,
    rawPreview: '{"data":{"user":{"id":1,"name":"Sami"}}}',
    truncated: true,
  );

  Widget subject() => MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 1000,
        height: 700,
        child: GraphqlResponsePanel(
          execution: GraphqlTabExecution(
            phase: GraphqlExecutionPhase.partialSuccess,
            id: 'execution-1',
            response: response,
            duration: const Duration(milliseconds: 120),
          ),
        ),
      ),
    ),
  );

  testWidgets('shows focused response views and observed diagnostics', (
    tester,
  ) async {
    await tester.pumpWidget(subject());

    expect(find.text('HTTP 200'), findsOneWidget);
    expect(find.text('partialSuccess'), findsOneWidget);
    expect(find.byKey(const Key('graphql-response-truncated')), findsOneWidget);
    expect(find.textContaining('"name": "Sami"'), findsOneWidget);

    await tester.tap(find.byKey(const Key('graphql-response-tab-errors')));
    await tester.pump();
    expect(find.textContaining('Partial field failure'), findsOneWidget);
    expect(find.textContaining('"line": 3'), findsOneWidget);
    expect(find.textContaining('"code": "PARTIAL"'), findsOneWidget);

    await tester.tap(find.byKey(const Key('graphql-response-tab-extensions')));
    await tester.pump();
    expect(find.textContaining('"traceId": "trace-1"'), findsOneWidget);

    await tester.tap(find.byKey(const Key('graphql-response-tab-headers')));
    await tester.pump();
    expect(find.textContaining('"set-cookie": "[masked]"'), findsOneWidget);

    await tester.tap(find.byKey(const Key('graphql-response-tab-diagnostics')));
    await tester.pump();
    expect(
      find.textContaining(
        'Partial data and GraphQL errors were returned together.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Path: user.email'), findsOneWidget);
  });

  testWidgets('searches only the selected safe response view', (tester) async {
    await tester.pumpWidget(subject());

    await tester.enterText(
      find.byKey(const Key('graphql-response-search')),
      'not-present',
    );
    await tester.pump();

    expect(find.text('No matches in data.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('graphql-response-search')),
      'Sami',
    );
    await tester.pump();

    expect(find.textContaining('"name": "Sami"'), findsOneWidget);
  });

  testWidgets('renders typed failure without a response', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            height: 600,
            child: GraphqlResponsePanel(
              execution: GraphqlTabExecution(
                phase: GraphqlExecutionPhase.transportFailure,
                id: 'failure-1',
                failure: GraphqlFailure(
                  GraphqlFailureCategory.timeout,
                  'Request timed out.',
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('"category": "timeout"'), findsOneWidget);
    expect(find.textContaining('Request timed out.'), findsOneWidget);
  });
}
