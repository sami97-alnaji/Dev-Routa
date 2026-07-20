import 'package:devroute_ai_studio/features/graphql/domain/graphql_document_parser.dart';
import 'package:devroute_ai_studio/features/graphql/domain/graphql_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'GraphQL parser identifies named multi-operations and implicit queries',
    () {
      final analysis = GraphqlDocumentParser.analyze('''
      query GetUser { user { id } }
      mutation UpdateUser { updateUser { id } }
      subscription Changed { changes { id } }
    ''');
      expect(analysis.errors, isEmpty);
      expect(
        analysis.operations.map((item) => item.type),
        <GraphqlOperationType>[
          GraphqlOperationType.query,
          GraphqlOperationType.mutation,
          GraphqlOperationType.subscription,
        ],
      );
      expect(
        GraphqlDocumentParser.select(analysis, 'UpdateUser')?.type,
        GraphqlOperationType.mutation,
      );
      expect(
        GraphqlDocumentParser.analyze('{ __typename }').operations.single.type,
        GraphqlOperationType.query,
      );
    },
  );

  test(
    'GraphQL parser reports malformed documents without changing source',
    () {
      final analysis = GraphqlDocumentParser.analyze('query Broken { user(');
      expect(analysis.isValid, isFalse);
      expect(analysis.errors, isNotEmpty);
    },
  );
}
