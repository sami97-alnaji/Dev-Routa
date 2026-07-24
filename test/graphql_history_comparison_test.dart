import 'package:devroute_ai_studio/features/graphql/data/graphql_repository.dart';
import 'package:devroute_ai_studio/features/graphql/domain/graphql_history_comparison.dart';
import 'package:devroute_ai_studio/features/graphql/domain/graphql_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('history comparison returns JSON-aware paths and filters', () {
    final before = GraphqlHistoryEntry(
      id: 'a',
      draftId: null,
      workspaceId: 'workspace',
      operationType: GraphqlOperationType.query,
      summary: const <String, Object?>{
        'statusCode': 200,
        'data': {'count': 1},
      },
      createdAt: DateTime(2026),
    );
    final after = GraphqlHistoryEntry(
      id: 'b',
      draftId: null,
      workspaceId: 'workspace',
      operationType: GraphqlOperationType.query,
      summary: const <String, Object?>{
        'statusCode': 500,
        'data': {'count': 2},
      },
      createdAt: DateTime(2026),
    );
    final comparison = GraphqlHistoryComparisonService.compare(before, after);
    expect(
      comparison.changes.map((item) => item.path),
      contains(r'$.statusCode'),
    );
    expect(
      comparison.changes.map((item) => item.path),
      contains(r'$.data.count'),
    );
    expect(comparison.changed, hasLength(2));
  });
}
