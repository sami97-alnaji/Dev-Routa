import 'package:gql/ast.dart';
import 'package:gql/language.dart' as language;
import 'package:source_span/source_span.dart';

import 'graphql_models.dart';

/// AST-backed GraphQL document analysis. The original source is never changed;
/// the optional normalized document is only a presentation aid.
abstract final class GraphqlDocumentParser {
  static GraphqlDocumentAnalysis analyze(String source) {
    try {
      final document = language.parseString(source);
      final definitions = document.definitions;
      final operations = <GraphqlOperation>[];
      final errors = <String>[];
      final names = <String>{};
      var anonymousCount = 0;
      var hasFragments = false;
      var hasDirectives = false;

      for (final definition in definitions) {
        if (definition is FragmentDefinitionNode) {
          hasFragments = true;
          hasDirectives = hasDirectives || definition.directives.isNotEmpty;
          continue;
        }
        if (definition is! OperationDefinitionNode) continue;
        final name = definition.name?.value;
        if (name == null) {
          anonymousCount++;
        } else if (!names.add(name)) {
          errors.add('Duplicate operation name "$name".');
        }
        final variables = definition.variableDefinitions
            .map((variable) => variable.variable.name.value)
            .toList(growable: false);
        final directives =
            definition.directives.isNotEmpty ||
            _containsDirective(definition.selectionSet);
        hasDirectives = hasDirectives || directives;
        operations.add(
          GraphqlOperation(
            type: GraphqlOperationType.values.byName(definition.type.name),
            name: name,
            location: _location(definition.span ?? definition.name?.span),
            variableNames: variables,
            hasFragments: hasFragments,
            hasDirectives: directives,
          ),
        );
      }
      if (anonymousCount > 1) {
        errors.add('Only one anonymous operation is allowed.');
      }
      if (operations.isEmpty && errors.isEmpty) {
        errors.add('No GraphQL operation was found.');
      }
      return GraphqlDocumentAnalysis(
        operations: operations,
        errors: errors,
        normalizedDocument: language.printNode(document),
        hasFragments: hasFragments,
        hasDirectives: hasDirectives,
      );
    } on SourceSpanException catch (error) {
      final span = error.span;
      final location = span == null
          ? ''
          : ' at ${span.start.line + 1}:${span.start.column + 1}';
      return GraphqlDocumentAnalysis(
        operations: const <GraphqlOperation>[],
        errors: <String>['GraphQL syntax error$location: ${error.message}'],
      );
    } catch (error) {
      return GraphqlDocumentAnalysis(
        operations: const <GraphqlOperation>[],
        errors: <String>['GraphQL syntax error: $error'],
      );
    }
  }

  static GraphqlOperation? select(
    GraphqlDocumentAnalysis analysis,
    String? name,
  ) {
    if (!analysis.isValid) return null;
    if (name != null) {
      return analysis.operations.where((op) => op.name == name).firstOrNull;
    }
    return analysis.operations.length == 1 ? analysis.operations.single : null;
  }

  static GraphqlSourceLocation? _location(FileSpan? span) => span == null
      ? null
      : GraphqlSourceLocation(
          line: span.start.line + 1,
          column: span.start.column + 1,
        );

  static bool _containsDirective(SelectionSetNode set) {
    for (final selection in set.selections) {
      if (selection is FieldNode) {
        if (selection.directives.isNotEmpty ||
            (selection.selectionSet != null &&
                _containsDirective(selection.selectionSet!))) {
          return true;
        }
      } else if (selection is FragmentSpreadNode &&
          selection.directives.isNotEmpty) {
        return true;
      } else if (selection is InlineFragmentNode &&
          (selection.directives.isNotEmpty ||
              _containsDirective(selection.selectionSet))) {
        return true;
      }
    }
    return false;
  }
}
