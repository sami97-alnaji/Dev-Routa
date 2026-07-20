import 'dart:convert';

enum GraphqlOperationType { query, mutation, subscription }

class GraphqlOperation {
  const GraphqlOperation({
    required this.type,
    this.name,
    this.location,
    this.variableNames = const <String>[],
    this.hasFragments = false,
    this.hasDirectives = false,
  });
  final GraphqlOperationType type;
  final String? name;
  final GraphqlSourceLocation? location;
  final List<String> variableNames;
  final bool hasFragments;
  final bool hasDirectives;
  String get label => '${type.name}${name == null ? '' : ' $name'}';
}

class GraphqlSourceLocation {
  const GraphqlSourceLocation({required this.line, required this.column});
  final int line;
  final int column;
  @override
  String toString() => '$line:$column';
}

class GraphqlDocumentAnalysis {
  const GraphqlDocumentAnalysis({
    required this.operations,
    required this.errors,
    this.normalizedDocument,
    this.hasFragments = false,
    this.hasDirectives = false,
  });
  final List<GraphqlOperation> operations;
  final List<String> errors;
  final String? normalizedDocument;
  final bool hasFragments;
  final bool hasDirectives;
  bool get isValid => errors.isEmpty && operations.isNotEmpty;
}

class GraphqlRequest {
  const GraphqlRequest({
    required this.endpoint,
    required this.document,
    this.operationName,
    this.variables = const <String, Object?>{},
    this.headers = const <String, String>{},
    this.useGet = false,
  });
  final String endpoint;
  final String document;
  final String? operationName;
  final Map<String, Object?> variables;
  final Map<String, String> headers;
  final bool useGet;
}

class GraphqlResponse {
  const GraphqlResponse({
    required this.statusCode,
    required this.data,
    required this.errors,
    required this.extensions,
    required this.duration,
    required this.sizeBytes,
    required this.headers,
  });
  final int? statusCode;
  final Object? data;
  final List<Object?> errors;
  final Object? extensions;
  final Duration duration;
  final int sizeBytes;
  final Map<String, String> headers;
  bool get hasPartialData => data != null && errors.isNotEmpty;
  String get safeJson => jsonEncode(<String, Object?>{
    if (data != null) 'data': data,
    if (errors.isNotEmpty) 'errors': errors,
    if (extensions != null) 'extensions': extensions,
  });
}
