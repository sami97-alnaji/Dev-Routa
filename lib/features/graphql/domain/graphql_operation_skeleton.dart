import 'graphql_schema_models.dart';

class GraphqlOperationSkeleton {
  const GraphqlOperationSkeleton._();

  static String generate({
    required GraphqlSchemaType root,
    required GraphqlSchemaField field,
    required String operationType,
    String operationName = 'GeneratedOperation',
    Iterable<String>? selectedFields,
  }) {
    final arguments = <String>[];
    final variables = <String>[];
    for (final argument in field.args) {
      final variableName = _safeName(argument.name);
      final required = argument.type.endsWith('!');
      variables.add('\$$variableName: ${argument.type}');
      arguments.add('${argument.name}: \$$variableName');
      if (!required) variables.removeLast();
    }
    final argumentText = arguments.isEmpty ? '' : '(${arguments.join(', ')})';
    final selection = selectedFields == null
        ? _minimalSelection(field.type)
        : ' { ${selectedFields.join(' ')} }';
    final variableText = variables.isEmpty ? '' : '(${variables.join(', ')})';
    return '$operationType $operationName$variableText { ${field.name}$argumentText$selection }';
  }

  static String _minimalSelection(String type) {
    final normalized = type
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('!', '');
    if (const {
      'String',
      'Int',
      'Float',
      'Boolean',
      'ID',
    }.contains(normalized)) {
      return '';
    }
    return ' { __typename }';
  }

  static String _safeName(String value) =>
      value.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_');
}
