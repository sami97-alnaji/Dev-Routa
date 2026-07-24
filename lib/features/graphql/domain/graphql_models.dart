import 'dart:convert';

import '../../../shared/models/api_models.dart';

enum GraphqlFailureCategory {
  validation,
  unresolvedVariable,
  missingSecret,
  cancelled,
  timeout,
  network,
  tls,
  http,
  malformedResponse,
  graphql,
  protocol,
  authConflict,
  introspectionDenied,
  unknown,
}

enum GraphqlCompletionCategory {
  success,
  partialSuccess,
  graphqlFailure,
  httpFailure,
}

class GraphqlFailure implements Exception {
  const GraphqlFailure(this.category, this.message, {this.cause});
  final GraphqlFailureCategory category;
  final String message;
  final Object? cause;
  @override
  String toString() => 'GraphQL ${category.name}: $message';
}

class GraphqlErrorLocation {
  const GraphqlErrorLocation({required this.line, required this.column});
  final int line;
  final int column;
  Map<String, int> toJson() => <String, int>{'line': line, 'column': column};
}

class GraphqlErrorPathSegment {
  const GraphqlErrorPathSegment({required this.value});
  final Object? value;
  Object? toJson() => value;
}

class GraphqlResponseError {
  const GraphqlResponseError({
    required this.message,
    this.locations = const <GraphqlErrorLocation>[],
    this.path = const <GraphqlErrorPathSegment>[],
    this.extensions = const <String, Object?>{},
  });
  final String message;
  final List<GraphqlErrorLocation> locations;
  final List<GraphqlErrorPathSegment> path;
  final Map<String, Object?> extensions;
  Map<String, Object?> toJson() => <String, Object?>{
    'message': message,
    if (locations.isNotEmpty)
      'locations': locations.map((item) => item.toJson()).toList(),
    if (path.isNotEmpty) 'path': path.map((item) => item.toJson()).toList(),
    if (extensions.isNotEmpty) 'extensions': extensions,
  };

  factory GraphqlResponseError.fromJson(Object? value) {
    final map = value is Map ? value : const <Object?, Object?>{};
    final locations = (map['locations'] as List? ?? const <Object?>[])
        .whereType<Map>()
        .map(
          (item) => GraphqlErrorLocation(
            line: (item['line'] as num?)?.toInt() ?? 0,
            column: (item['column'] as num?)?.toInt() ?? 0,
          ),
        )
        .toList(growable: false);
    return GraphqlResponseError(
      message: map['message']?.toString() ?? 'Unknown GraphQL error',
      locations: locations,
      path: (map['path'] as List? ?? const <Object?>[])
          .map((item) => GraphqlErrorPathSegment(value: item))
          .toList(growable: false),
      extensions:
          (map['extensions'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), value),
          ) ??
          const <String, Object?>{},
    );
  }
}

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
    this.extensions = const <String, Object?>{},
    this.auth = const RequestAuthModel(),
    this.settings = const RequestSettingsModel(),
  });
  final String endpoint;
  final String document;
  final String? operationName;
  final Map<String, Object?> variables;
  final Map<String, String> headers;
  final bool useGet;
  final Map<String, Object?> extensions;
  final RequestAuthModel auth;
  final RequestSettingsModel settings;
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
    this.completion = GraphqlCompletionCategory.success,
    this.rawPreview = '',
    this.truncated = false,
  });
  final int? statusCode;
  final Object? data;
  final List<GraphqlResponseError> errors;
  final Object? extensions;
  final Duration duration;
  final int sizeBytes;
  final Map<String, String> headers;
  final GraphqlCompletionCategory completion;
  final String rawPreview;
  final bool truncated;
  bool get hasPartialData => data != null && errors.isNotEmpty;
  bool get hasGraphqlErrors => errors.isNotEmpty;
  String get safeJson => jsonEncode(<String, Object?>{
    if (data != null) 'data': data,
    if (errors.isNotEmpty)
      'errors': errors.map((item) => item.toJson()).toList(),
    if (extensions != null) 'extensions': extensions,
  });
}

/// Produces a bounded preview without splitting a UTF-8 code point.
GraphqlPreview boundedGraphqlPreview(String value, {int maxBytes = 65536}) {
  final bytes = utf8.encode(value);
  if (bytes.length <= maxBytes) {
    return GraphqlPreview(value: value, truncated: false);
  }
  var end = maxBytes;
  while (end > 0) {
    try {
      return GraphqlPreview(
        value: utf8.decode(bytes.sublist(0, end)),
        truncated: true,
      );
    } on FormatException {
      end--;
    }
  }
  return const GraphqlPreview(value: '', truncated: true);
}

class GraphqlPreview {
  const GraphqlPreview({required this.value, required this.truncated});
  final String value;
  final bool truncated;
}
