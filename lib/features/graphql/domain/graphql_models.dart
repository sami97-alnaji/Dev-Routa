import 'dart:convert';

enum GraphqlOperationType { query, mutation, subscription }

class GraphqlOperation {
  const GraphqlOperation({required this.type, this.name});
  final GraphqlOperationType type;
  final String? name;
  String get label => '${type.name}${name == null ? '' : ' $name'}';
}

class GraphqlDocumentAnalysis {
  const GraphqlDocumentAnalysis({
    required this.operations,
    required this.errors,
  });
  final List<GraphqlOperation> operations;
  final List<String> errors;
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
