import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../core/security/secret_masker.dart';
import '../data/graphql_repository.dart';
import '../domain/graphql_models.dart';

/// Writes GraphQL artifacts only after structurally redacting secrets.
class GraphqlSafeExportService {
  GraphqlSafeExportService({Future<Directory> Function()? directoryProvider})
    : _directoryProvider =
          directoryProvider ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _directoryProvider;

  Future<File> exportRequest(GraphqlRequest request) =>
      _write('graphql-request', _requestPayload(request));

  Future<File> exportResponse(
    GraphqlResponse response, {
    Set<String> runtimeSecrets = const <String>{},
  }) => _write('graphql-response', _responsePayload(response), runtimeSecrets);

  Future<File> exportHistory(
    GraphqlHistoryEntry entry, {
    Set<String> runtimeSecrets = const <String>{},
  }) => _write('graphql-history', <String, Object?>{
    'id': entry.id,
    'operationType': entry.operationType.name,
    'createdAt': entry.createdAt.toIso8601String(),
    'summary': _historySummary(entry.summary),
  }, runtimeSecrets);

  String requestJson(GraphqlRequest request) =>
      _encode(_requestPayload(request));

  String responseJson(
    GraphqlResponse response, {
    Set<String> runtimeSecrets = const <String>{},
  }) => _encode(_responsePayload(response), runtimeSecrets);

  String historyJson(
    GraphqlHistoryEntry entry, {
    Set<String> runtimeSecrets = const <String>{},
  }) => _encode(<String, Object?>{
    'id': entry.id,
    'operationType': entry.operationType.name,
    'createdAt': entry.createdAt.toIso8601String(),
    'summary': _historySummary(entry.summary),
  }, runtimeSecrets);

  Future<File> _write(
    String prefix,
    Map<String, Object?> payload, [
    Set<String> runtimeSecrets = const <String>{},
  ]) async {
    final directory = Directory(
      path.join((await _directoryProvider()).path, 'DevRoute', 'exports'),
    );
    await directory.create(recursive: true);
    final file = File(
      path.join(
        directory.path,
        '$prefix-${DateTime.now().millisecondsSinceEpoch}.json',
      ),
    );
    await file.writeAsString(_encode(payload, runtimeSecrets), flush: true);
    return file;
  }

  String _encode(
    Map<String, Object?> payload, [
    Set<String> runtimeSecrets = const <String>{},
  ]) => const JsonEncoder.withIndent('  ').convert(
    SecretMasker.redactStructured(payload, runtimeSecrets: runtimeSecrets),
  );

  Map<String, Object?> _requestPayload(
    GraphqlRequest request,
  ) => <String, Object?>{
    'endpoint': _safeEndpoint(request.endpoint),
    'document': request.document,
    if (request.operationName != null) 'operationName': request.operationName,
    'variables': request.variables,
    'headers': SecretMasker.redactHeaders(request.headers),
    'extensions': request.extensions,
    'useGet': request.useGet,
    'auth': <String, Object?>{'type': request.auth.type.name},
  };

  Map<String, Object?> _responsePayload(GraphqlResponse response) =>
      <String, Object?>{
        'statusCode': response.statusCode,
        'data': response.data,
        'errors': response.errors.map((item) => item.toJson()).toList(),
        'extensions': response.extensions,
        'headers': SecretMasker.redactHeaders(response.headers),
        'durationMs': response.duration.inMilliseconds,
        'sizeBytes': response.sizeBytes,
        'completion': response.completion.name,
        'rawPreview': response.rawPreview,
        'truncated': response.truncated,
      };

  Map<String, Object?> _historySummary(Map<String, Object?> summary) {
    final result = Map<String, Object?>.of(summary);
    final request = summary['request'];
    if (request is Map) {
      final safeRequest = request.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      final endpoint = safeRequest['endpoint'];
      if (endpoint is String) safeRequest['endpoint'] = _safeEndpoint(endpoint);
      result['request'] = safeRequest;
    }
    return result;
  }

  String _safeEndpoint(String value) {
    final uri = Uri.tryParse(value);
    return uri == null
        ? value.split('?').first.split('#').first
        : uri
              .replace(userInfo: '')
              .toString()
              .split('#')
              .first
              .split('?')
              .first;
  }
}
