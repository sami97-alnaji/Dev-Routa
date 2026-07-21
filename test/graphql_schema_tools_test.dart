import 'package:devroute_ai_studio/features/graphql/domain/graphql_schema_models.dart';
import 'package:devroute_ai_studio/features/graphql/domain/graphql_operation_skeleton.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _schema({bool extra = false}) => <String, Object?>{
  'data': <String, Object?>{
    '__schema': <String, Object?>{
      'queryType': <String, Object?>{'name': 'Query'},
      'types': <Object?>[
        <String, Object?>{
          'name': 'Query',
          'kind': 'OBJECT',
          'fields': <Object?>[
            <String, Object?>{
              'name': 'user',
              'type': <String, Object?>{
                'kind': 'NON_NULL',
                'ofType': <String, Object?>{'kind': 'SCALAR', 'name': 'UserId'},
              },
            },
            if (extra)
              <String, Object?>{
                'name': 'health',
                'type': <String, Object?>{'kind': 'SCALAR', 'name': 'String'},
              },
          ],
        },
      ],
    },
  },
};

void main() {
  test('schema parsing produces stable hashes and wrapped types', () {
    final first = GraphqlSchemaTools.parse(_schema());
    final second = GraphqlSchemaTools.parse(_schema());
    expect(first.hash, second.hash);
    expect(first.queryRoot, 'Query');
    expect(first.types.single.fields.single.type, 'UserId!');
  });

  test('schema comparison reports additive changes conservatively', () {
    final diff = GraphqlSchemaTools.compare(
      GraphqlSchemaTools.parse(_schema()),
      GraphqlSchemaTools.parse(_schema(extra: true)),
    );
    expect(diff.addedFields, contains('Query.health'));
    expect(diff.classification, 'Non-breaking candidate');
  });

  test('operation skeleton preserves required arguments and selection', () {
    const root = GraphqlSchemaType(name: 'Query', kind: 'OBJECT');
    const field = GraphqlSchemaField(
      name: 'user',
      type: 'User',
      args: <GraphqlSchemaArgument>[
        GraphqlSchemaArgument(name: 'id', type: 'ID!'),
      ],
    );
    expect(
      GraphqlOperationSkeleton.generate(
        root: root,
        field: field,
        operationType: 'query',
        operationName: 'GetUser',
      ),
      'query GetUser(\$id: ID!) { user(id: \$id) { __typename } }',
    );
  });
}
