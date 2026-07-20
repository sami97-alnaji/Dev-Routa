import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/security/secret_masker.dart';
import '../domain/graphql_document_parser.dart';
import '../domain/graphql_models.dart';

class GraphqlHttpService {
  GraphqlHttpService({Dio? dio}) : _dio = dio ?? Dio();
  final Dio _dio;
  final Map<String, CancelToken> _cancellations = <String, CancelToken>{};

  Future<GraphqlResponse> execute(String id, GraphqlRequest request) async {
    final analysis = GraphqlDocumentParser.analyze(request.document);
    final operation = GraphqlDocumentParser.select(
      analysis,
      request.operationName,
    );
    if (!analysis.isValid) {
      throw ArgumentError(analysis.errors.join('\n'));
    }
    if (operation == null) {
      throw ArgumentError('Select an operation before execution.');
    }
    if (request.useGet && operation.type != GraphqlOperationType.query) {
      throw ArgumentError('Only GraphQL queries may use GET.');
    }
    final token = CancelToken();
    _cancellations[id] = token;
    final stopwatch = Stopwatch()..start();
    try {
      final payload = <String, Object?>{
        'query': request.document,
        if (request.operationName != null)
          'operationName': request.operationName,
        if (request.variables.isNotEmpty) 'variables': request.variables,
      };
      final response = await _dio.request<Object?>(
        request.endpoint,
        data: request.useGet ? null : payload,
        queryParameters: request.useGet
            ? <String, Object?>{
                for (final e in payload.entries)
                  e.key: e.value is String ? e.value : jsonEncode(e.value),
              }
            : null,
        options: Options(
          method: request.useGet ? 'GET' : 'POST',
          headers: <String, String>{
            'accept': 'application/graphql-response+json, application/json',
            'content-type': 'application/json',
            ...request.headers,
          },
          responseType: ResponseType.plain,
        ),
        cancelToken: token,
      );
      final raw = response.data?.toString() ?? '';
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        throw const FormatException('GraphQL response root must be an object.');
      }
      return GraphqlResponse(
        statusCode: response.statusCode,
        data: decoded['data'],
        errors: (decoded['errors'] as List?)?.cast<Object?>() ?? const [],
        extensions: decoded['extensions'],
        duration: stopwatch.elapsed,
        sizeBytes: utf8.encode(raw).length,
        headers: SecretMasker.redactHeaders(
          response.headers.map.map((k, v) => MapEntry(k, v.join(','))),
        ),
      );
    } finally {
      stopwatch.stop();
      _cancellations.remove(id);
    }
  }

  void cancel(String id) =>
      _cancellations.remove(id)?.cancel('GraphQL operation cancelled');
}
