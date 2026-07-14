import 'dart:convert';

import 'package:dio/dio.dart';

import '../../shared/models/api_models.dart';
import '../../shared/services/service_interfaces.dart';

class DioRequestExecutionService implements RequestExecutionService {
  DioRequestExecutionService({Dio? client}) : _client = client ?? Dio();

  final Dio _client;

  @override
  Future<ApiResponseModel> execute(ApiRequestModel request) async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await _client.request<dynamic>(
        request.url,
        data: _bodyFor(request),
        queryParameters: _queryFor(request),
        options: Options(
          method: request.method.name.toUpperCase(),
          headers: _headersFor(request),
          validateStatus: (_) => true,
        ),
      );
      stopwatch.stop();
      final body = response.data is String
          ? response.data as String
          : const JsonEncoder.withIndent('  ').convert(response.data);
      final headers = response.headers.map.map(
        (key, values) => MapEntry(key, values.join(', ')),
      );
      return ApiResponseModel(
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        headers: headers,
        body: body,
        durationMs: stopwatch.elapsedMilliseconds,
        sizeBytes: utf8.encode(body).length,
        timestamp: DateTime.now(),
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
        error: _redact(error.message ?? 'The request could not be completed.'),
      );
    }
  }

  Map<String, String> _headersFor(ApiRequestModel request) => {
    for (final header in request.headers.where((header) => header.enabled))
      header.key: header.value,
  };

  Map<String, String> _queryFor(ApiRequestModel request) => {
    for (final param in request.queryParams.where((param) => param.enabled))
      param.key: param.value,
  };

  dynamic _bodyFor(ApiRequestModel request) {
    final body = request.body;
    if (body == null || body.type == RequestBodyType.none) return null;
    if (body.type == RequestBodyType.json) return jsonDecode(body.content);
    return body.content;
  }

  String _redact(String message) => message.replaceAll(
    RegExp(
      r'(authorization|api[-_ ]?key|token|password)\s*[:=]\s*[^\s,]+',
      caseSensitive: false,
    ),
    r'$1: [REDACTED]',
  );
}
