import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../shared/models/api_models.dart';
import '../../shared/services/service_interfaces.dart';
import '../security/secret_masker.dart';

class DioRequestExecutionService implements RequestExecutionService {
  DioRequestExecutionService({Dio? client, SecureStorageService? secureStorage})
    : _client = client ?? Dio(),
      _secureStorage = secureStorage;

  final Dio _client;
  final SecureStorageService? _secureStorage;
  CancelToken? _activeCancelToken;

  bool get isExecuting => _activeCancelToken != null;

  void cancel() {
    _activeCancelToken?.cancel('Cancelled by the user.');
  }

  @override
  Future<ApiResponseModel> execute(
    ApiRequestModel request, {
    int previewLimitBytes = 1024 * 1024,
  }) async {
    final stopwatch = Stopwatch()..start();
    final cancelToken = CancelToken();
    _activeCancelToken = cancelToken;
    try {
      _client.options.connectTimeout = Duration(
        milliseconds: request.settings.connectTimeoutMs,
      );
      final response = await _client.request<dynamic>(
        request.url,
        data: await _bodyFor(request),
        queryParameters: await _queryFor(request),
        cancelToken: cancelToken,
        options: Options(
          method: request.method.name.toUpperCase(),
          headers: await _headersFor(request),
          contentType:
              request.body?.contentType ?? _contentType(request.body?.type),
          validateStatus: (_) => true,
          sendTimeout: Duration(milliseconds: request.settings.sendTimeoutMs),
          receiveTimeout: Duration(
            milliseconds: request.settings.receiveTimeoutMs,
          ),
          followRedirects: request.settings.followRedirects,
          maxRedirects: request.settings.maxRedirects,
        ),
      );
      stopwatch.stop();
      final fullBody = _bodyToString(response.data);
      final limit = previewLimitBytes.clamp(1024, 16 * 1024 * 1024);
      final truncated = fullBody.length > limit;
      final body = truncated ? fullBody.substring(0, limit) : fullBody;
      final headers = response.headers.map.map(
        (key, values) => MapEntry(key, values.join(', ')),
      );
      return ApiResponseModel(
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        headers: SecretMasker.redactHeaders(headers),
        body: body,
        durationMs: stopwatch.elapsedMilliseconds,
        sizeBytes: utf8.encode(fullBody).length,
        timestamp: DateTime.now(),
        cookies: response.headers.map['set-cookie'] ?? const <String>[],
        isTruncated: truncated,
      );
    } on DioException catch (error) {
      stopwatch.stop();
      return ApiResponseModel(
        statusCode: error.response?.statusCode,
        statusMessage: error.response?.statusMessage,
        headers: const <String, String>{},
        body: '',
        durationMs: stopwatch.elapsedMilliseconds,
        sizeBytes: 0,
        timestamp: DateTime.now(),
        error: _safeMessage(error),
        errorCategory: _category(error),
      );
    } finally {
      if (identical(_activeCancelToken, cancelToken)) {
        _activeCancelToken = null;
      }
    }
  }

  Future<Map<String, String>> _headersFor(ApiRequestModel request) async {
    final headers = <String, String>{};
    for (final header in request.headers.where((item) => item.enabled)) {
      headers[header.key] = await _secretOrValue(
        header.value,
        header.secretRef,
        header.isSecret,
      );
    }
    switch (request.auth.type) {
      case AuthType.bearer:
        headers['Authorization'] =
            'Bearer ${await _secretOrValue('', request.auth.tokenSecretRef, true)}';
      case AuthType.basic:
        final password = await _secretOrValue(
          '',
          request.auth.passwordSecretRef,
          true,
        );
        headers['Authorization'] =
            'Basic ${base64Encode(utf8.encode('${request.auth.username}:$password'))}';
      case AuthType.apiKeyHeader:
        headers[request.auth.apiKeyName] = await _secretOrValue(
          '',
          request.auth.apiKeySecretRef,
          true,
        );
      case AuthType.none:
      case AuthType.apiKeyQuery:
        break;
    }
    return headers;
  }

  Future<Map<String, String>> _queryFor(ApiRequestModel request) async {
    final query = <String, String>{
      for (final param in request.queryParams.where((item) => item.enabled))
        param.key: param.value,
    };
    if (request.auth.type == AuthType.apiKeyQuery &&
        request.auth.apiKeyName.isNotEmpty) {
      query[request.auth.apiKeyName] = await _secretOrValue(
        '',
        request.auth.apiKeySecretRef,
        true,
      );
    }
    return query;
  }

  Future<dynamic> _bodyFor(ApiRequestModel request) async {
    final body = request.body;
    if (body == null || body.type == RequestBodyType.none) {
      return null;
    }
    if (body.type == RequestBodyType.json) {
      return jsonDecode(body.content);
    }
    if (body.type == RequestBodyType.urlEncoded) {
      return Uri.splitQueryString(body.content);
    }
    if (body.type == RequestBodyType.formData ||
        body.type == RequestBodyType.multipart) {
      final fields = _bodyFields(body.content);
      if (body.filePath != null && body.filePath!.isNotEmpty) {
        fields['file'] = await MultipartFile.fromFile(body.filePath!);
      }
      return FormData.fromMap(fields);
    }
    if (body.type == RequestBodyType.binary) {
      final filePath = body.filePath ?? body.content;
      return File(filePath).readAsBytes();
    }
    return body.content;
  }

  Map<String, dynamic> _bodyFields(String content) {
    try {
      final decoded = jsonDecode(content);
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } on FormatException {
      // Fall through to key=value parsing.
    }
    return <String, dynamic>{
      for (final line in const LineSplitter().convert(content))
        if (line.contains('='))
          line.substring(0, line.indexOf('=')).trim(): line
              .substring(line.indexOf('=') + 1)
              .trim(),
    };
  }

  Future<String> _secretOrValue(
    String value,
    String? reference,
    bool isSecret,
  ) async {
    if (!isSecret) return value;
    if (reference == null || _secureStorage == null) return value;
    return await _secureStorage.readSecret(reference) ?? '';
  }

  String _bodyToString(dynamic value) => value is String
      ? value
      : const JsonEncoder.withIndent('  ').convert(value);

  String? _contentType(RequestBodyType? type) => switch (type) {
    RequestBodyType.json => Headers.jsonContentType,
    RequestBodyType.xml => 'application/xml',
    RequestBodyType.html => 'text/html',
    RequestBodyType.urlEncoded => Headers.formUrlEncodedContentType,
    RequestBodyType.formData ||
    RequestBodyType.multipart => 'multipart/form-data',
    RequestBodyType.binary => 'application/octet-stream',
    RequestBodyType.rawText => 'text/plain',
    _ => null,
  };

  String _category(DioException error) => switch (error.type) {
    DioExceptionType.cancel => 'cancelled',
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => 'timeout',
    DioExceptionType.badCertificate => 'tls',
    DioExceptionType.connectionError => 'network',
    DioExceptionType.badResponse => 'http',
    _ => 'unknown',
  };

  String _safeMessage(DioException error) => switch (_category(error)) {
    'cancelled' => 'The request was cancelled.',
    'timeout' => 'The request timed out.',
    'tls' => 'The TLS certificate could not be verified.',
    'network' => 'A network connection could not be established.',
    'http' => 'The server returned an invalid response.',
    _ => 'The request could not be completed.',
  };
}
