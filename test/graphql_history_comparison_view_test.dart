import 'dart:convert';

import 'package:devroute_ai_studio/features/graphql/data/graphql_repository.dart';
import 'package:devroute_ai_studio/features/graphql/domain/graphql_history_comparison.dart';
import 'package:devroute_ai_studio/features/graphql/domain/graphql_models.dart';
import 'package:devroute_ai_studio/features/graphql/presentation/graphql_history_comparison_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

GraphqlHistoryEntry _entry({
  required String id,
  required Map<String, Object?> summary,
}) => GraphqlHistoryEntry(
  id: id,
  draftId: null,
  workspaceId: 'workspace-1',
  operationType: GraphqlOperationType.query,
  summary: summary,
  createdAt: DateTime.utc(2026, 7, 21, id == 'before' ? 8 : 9),
);

void main() {
  final before = _entry(
    id: 'before',
    summary: <String, Object?>{
      'statusCode': 200,
      'data': <String, Object?>{
        'user': <String, Object?>{'id': 1, 'name': 'Before'},
      },
      'headers': <String, Object?>{'x-version': '1'},
      'removed': 'legacy',
    },
  );

  final after = _entry(
    id: 'after',
    summary: <String, Object?>{
      'statusCode': 201,
      'data': <String, Object?>{
        'user': <String, Object?>{'id': 1, 'name': 'After'},
      },
      'headers': <String, Object?>{'x-version': '1'},
      'added': 'new',
    },
  );

  test('exports deterministic safe comparison JSON', () {
    final encoded = GraphqlHistoryComparisonService.exportJson(before, after);
    final decoded = jsonDecode(encoded) as Map<String, Object?>;

    expect(decoded['format'], 'devroute.graphql-history-comparison');
    expect(decoded['version'], 1);
    expect(decoded['changes'], isA<List<Object?>>());
    expect((decoded['changes'] as List<Object?>), hasLength(4));
    expect(encoded, contains(r'$.data.user.name'));
  });

  testWidgets('filters, searches, and swaps comparison results', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1000,
            height: 700,
            child: GraphqlHistoryComparisonView(before: before, after: after),
          ),
        ),
      ),
    );

    expect(find.text('All (4)'), findsOneWidget);
    expect(find.text('Added (1)'), findsOneWidget);
    expect(find.text('Removed (1)'), findsOneWidget);
    expect(find.text('Changed (2)'), findsOneWidget);

    await tester.tap(find.byKey(const Key('graphql-comparison-filter-added')));
    await tester.pump();

    expect(find.text(r'$.added'), findsOneWidget);
    expect(find.text(r'$.statusCode'), findsNothing);

    await tester.tap(
      find.byKey(const Key('graphql-comparison-filter-changed')),
    );
    await tester.pump();

    expect(find.text(r'$.statusCode'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(r'$.data.user.name'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text(r'$.data.user.name'), findsOneWidget);
    expect(find.text(r'$.added'), findsNothing);

    await tester.enterText(
      find.byKey(const Key('graphql-history-comparison-search')),
      'name',
    );
    await tester.pump();

    await tester.scrollUntilVisible(
      find.text(r'$.data.user.name'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text(r'$.data.user.name'), findsOneWidget);
    expect(find.text(r'$.statusCode'), findsNothing);

    final beforeIdentity = find.byKey(
      const Key('graphql-history-identity-before'),
    );
    expect(
      find.descendant(
        of: beforeIdentity,
        matching: find.text('query · before'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('graphql-history-comparison-swap')));
    await tester.pump();

    expect(
      find.descendant(of: beforeIdentity, matching: find.text('query · after')),
      findsOneWidget,
    );
  });
}
