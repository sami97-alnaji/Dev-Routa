import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/security/secret_masker.dart';
import '../../../shared/models/api_models.dart';
import '../../../shared/services/service_interfaces.dart';
import '../domain/graphql_document_parser.dart';
import '../domain/graphql_models.dart';

class GraphqlHttpService {
  GraphqlHttpService({Dio? dio, SecureStorageService? secureStorage})
    : _dio = dio ?? Dio(),
      _secureStorage = secureStorage;
  final Dio _dio;
  final SecureStorageService? _secureStorage;
  final Map<String, CancelToken> _cancellations = <String, CancelToken>{};

  Future<GraphqlResponse> execute(String id, GraphqlRequest request) async {
    final analysis = GraphqlDocumentParser.analyze(request.document);
    final operation = GraphqlDocumentParser.select(
      analysis,
      request.operationName,
    );
    if (!analysis.isValid) {
      throw GraphqlFailure(
        GraphqlFailureCategory.validation,
        analysis.errors.join('\n'),
      );
    }
    if (operation == null) {
      throw const GraphqlFailure(
        GraphqlFailureCategory.validation,
        'Select an operation before execution.',
      );
    }
    if (request.useGet && operation.type != GraphqlOperationType.query) {
      throw const GraphqlFailure(
        GraphqlFailureCategory.validation,
        'Only GraphQL queries may use GET.',
      );
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
        if (request.extensions.isNotEmpty) 'extensions': request.extensions,
      };
      final headers = await _headersFor(request);
      final queryParameters = <String, Object?>{
        if (request.useGet)
          for (final entry in payload.entries)
            entry.key: entry.value is String
                ? entry.value
                : jsonEncode(entry.value),
      };
      if (request.auth.type == AuthType.apiKeyQuery) {
        queryParameters[request.auth.apiKeyName] = await _secret(
          request.auth.apiKeySecretRef,
        );
      }
      final response = await _dio.request<Object?>(
        request.endpoint,
        data: request.useGet ? null : payload,
        queryParameters:
            request.useGet || request.auth.type == AuthType.apiKeyQuery
            ? queryParameters
            : null,
        options: Options(
          method: request.useGet ? 'GET' : 'POST',
          headers: <String, String>{
            'accept': 'application/graphql-response+json, application/json',
            if (!request.useGet) 'content-type': 'application/json',
            ...headers,
          },
          responseType: ResponseType.plain,
          validateStatus: (_) => true,
        ),
        cancelToken: token,
      );
      final raw = switch (response.data) {
        String value => value,
        List<int> value => utf8.decode(value),
        null => '',
        final value => jsonEncode(value),
      };
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        throw const GraphqlFailure(
          GraphqlFailureCategory.malformedResponse,
          'GraphQL response root must be an object.',
        );
      }
      final responseErrors = (decoded['errors'] as List? ?? const <Object?>[])
          .map(GraphqlResponseError.fromJson)
          .toList(growable: false);
      return GraphqlResponse(
        statusCode: response.statusCode,
        data: decoded['data'],
        errors: responseErrors,
        extensions: decoded['extensions'],
        duration: stopwatch.elapsed,
        sizeBytes: utf8.encode(raw).length,
        headers: SecretMasker.redactHeaders(
          response.headers.map.map((k, v) => MapEntry(k, v.join(','))),
        ),
      );
    } on DioException catch (error) {
      throw GraphqlFailure(
        _failureCategory(error),
        _safeMessage(error),
        cause: error,
      );
    } on FormatException catch (error) {
      throw GraphqlFailure(
        GraphqlFailureCategory.malformedResponse,
        'Response was not valid JSON: ${error.message}',
        cause: error,
      );
    } finally {
      stopwatch.stop();
      _cancellations.remove(id);
    }
  }

  void cancel(String id) =>
      _cancellations.remove(id)?.cancel('GraphQL operation cancelled');

  Future<Map<String, String>> _headersFor(GraphqlRequest request) async {
    final headers = <String, String>{...request.headers};
    switch (request.auth.type) {
      case AuthType.bearer:
        headers['Authorization'] =
            'Bearer ${await _secret(request.auth.tokenSecretRef)}';
      case AuthType.basic:
        final password = await _secret(request.auth.passwordSecretRef);
        headers['Authorization'] =
            'Basic ${base64Encode(utf8.encode('${request.auth.username}:$password'))}';
      case AuthType.apiKeyHeader:
        headers[request.auth.apiKeyName] = await _secret(
          request.auth.apiKeySecretRef,
        );
      case AuthType.none:
      case AuthType.apiKeyQuery:
        break;
    }
    return headers;
  }

  Future<String> _secret(String? reference) async {
    if (reference == null || reference.isEmpty) {
      throw const GraphqlFailure(
        GraphqlFailureCategory.missingSecret,
        'A required secret reference is missing.',
      );
    }
    final value = await _secureStorage?.readSecret(reference);
    if (value == null || value.isEmpty) {
      throw const GraphqlFailure(
        GraphqlFailureCategory.missingSecret,
        'A required secret could not be resolved.',
      );
    }
    return value;
  }

  GraphqlFailureCategory _failureCategory(DioException error) =>
      switch (error.type) {
        DioExceptionType.cancel => GraphqlFailureCategory.cancelled,
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout => GraphqlFailureCategory.timeout,
        DioExceptionType.badCertificate => GraphqlFailureCategory.tls,
        DioExceptionType.connectionError => GraphqlFailureCategory.network,
        DioExceptionType.badResponse => GraphqlFailureCategory.http,
        _ => GraphqlFailureCategory.unknown,
      };

  String _safeMessage(DioException error) => switch (_failureCategory(error)) {
    GraphqlFailureCategory.cancelled => 'The GraphQL operation was cancelled.',
    GraphqlFailureCategory.timeout => 'The GraphQL operation timed out.',
    GraphqlFailureCategory.tls => 'TLS certificate verification failed.',
    GraphqlFailureCategory.network =>
      'The GraphQL endpoint could not be reached.',
    GraphqlFailureCategory.http =>
      'The GraphQL endpoint returned HTTP ${error.response?.statusCode}.',
    _ => 'The GraphQL operation failed.',
  };
}
