import 'graphql_models.dart';

/// Lightweight lexical analysis deliberately keeps documents executable as
/// entered. It identifies operations without rewriting GraphQL source.
abstract final class GraphqlDocumentParser {
  static GraphqlDocumentAnalysis analyze(String source) {
    final errors = <String>[];
    final scrubbed = _withoutStringsAndComments(source, errors);
    final operations = <GraphqlOperation>[];
    final matcher = RegExp(
      r'\b(query|mutation|subscription)\b\s*([_A-Za-z][_0-9A-Za-z]*)?',
    );
    for (final match in matcher.allMatches(scrubbed)) {
      operations.add(
        GraphqlOperation(
          type: GraphqlOperationType.values.byName(match.group(1)!),
          name: match.group(2),
        ),
      );
    }
    if (operations.isEmpty && scrubbed.trimLeft().startsWith('{')) {
      operations.add(const GraphqlOperation(type: GraphqlOperationType.query));
    }
    if (operations.isEmpty && errors.isEmpty) {
      errors.add('No GraphQL operation was found.');
    }
    if (!_balanced(scrubbed, '{', '}')) {
      errors.add('Unbalanced selection braces.');
    }
    if (!_balanced(scrubbed, '(', ')')) {
      errors.add('Unbalanced variable parentheses.');
    }
    return GraphqlDocumentAnalysis(operations: operations, errors: errors);
  }

  static GraphqlOperation? select(
    GraphqlDocumentAnalysis analysis,
    String? name,
  ) {
    if (!analysis.isValid) {
      return null;
    }
    if (name != null) {
      return analysis.operations.where((op) => op.name == name).firstOrNull;
    }
    return analysis.operations.length == 1 ? analysis.operations.single : null;
  }

  static String _withoutStringsAndComments(String source, List<String> errors) {
    final out = StringBuffer();
    var quote = false;
    var escaped = false;
    var comment = false;
    for (final char in source.split('')) {
      if (comment) {
        if (char == '\n') {
          comment = false;
          out.write(char);
        } else {
          out.write(' ');
        }
        continue;
      }
      if (!quote && char == '#') {
        comment = true;
        out.write(' ');
        continue;
      }
      if (char == '"' && !escaped) {
        quote = !quote;
      }
      out.write(quote ? ' ' : char);
      escaped = char == '\\' && !escaped;
      if (char != '\\') escaped = false;
    }
    if (quote) {
      errors.add('Unterminated string literal.');
    }
    return out.toString();
  }

  static bool _balanced(String input, String open, String close) {
    var depth = 0;
    for (final char in input.split('')) {
      if (char == open) {
        depth++;
      }
      if (char == close) {
        depth--;
        if (depth < 0) {
          return false;
        }
      }
    }
    return depth == 0;
  }
}
