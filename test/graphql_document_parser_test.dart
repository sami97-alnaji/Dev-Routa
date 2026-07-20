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

  test(
    'AST analysis preserves fragments, directives, variables and locations',
    () {
      const source = r'''
    query GetUser($id: ID!) @client {
      user(id: $id) { ...UserFields }
    }
    fragment UserFields on User @defer { id name }
    ''';
      final analysis = GraphqlDocumentParser.analyze(source);
      expect(analysis.isValid, isTrue);
      expect(analysis.hasFragments, isTrue);
      expect(analysis.hasDirectives, isTrue);
      expect(analysis.operations.single.variableNames, <String>['id']);
      expect(analysis.operations.single.location?.line, 1);
      expect(analysis.normalizedDocument, contains('fragment UserFields'));
    },
  );

  test(
    'AST analysis rejects duplicate names and multiple anonymous operations',
    () {
      final duplicate = GraphqlDocumentParser.analyze('''
      query Same { one }
      mutation Same { two }
    ''');
      expect(duplicate.errors.single, contains('Duplicate operation name'));

      final anonymous = GraphqlDocumentParser.analyze('''
      { one }
      { two }
    ''');
      expect(anonymous.errors.single, contains('Only one anonymous operation'));
    },
  );

  test('operation selection blocks ambiguity and selects by name', () {
    final analysis = GraphqlDocumentParser.analyze('''
      query First { one }
      query Second { two }
    ''');
    expect(GraphqlDocumentParser.select(analysis, null), isNull);
    expect(GraphqlDocumentParser.select(analysis, 'Second')?.name, 'Second');
    expect(GraphqlDocumentParser.select(analysis, 'Missing'), isNull);
  });
}
