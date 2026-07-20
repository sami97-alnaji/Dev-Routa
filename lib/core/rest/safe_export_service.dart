import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../shared/models/api_models.dart';
import '../security/secret_masker.dart';

class SafeExportService {
  SafeExportService({Future<Directory> Function()? directoryProvider})
    : _directoryProvider =
          directoryProvider ?? getApplicationDocumentsDirectory;
  final Future<Directory> Function() _directoryProvider;

  Future<File> exportResponse(
    ApiResponseModel response, {
    Set<String> sensitiveValues = const <String>{},
  }) async {
    final directory = Directory(
      path.join((await _directoryProvider()).path, 'DevRoute', 'exports'),
    );
    await directory.create(recursive: true);
    final file = File(
      path.join(
        directory.path,
        'response-${DateTime.now().millisecondsSinceEpoch}.json',
      ),
    );
    final body = _redactKnown(response.body, sensitiveValues);
    final payload = <String, Object?>{
      'status': response.statusCode,
      'statusMessage': response.statusMessage,
      'headers': SecretMasker.redactHeaders(response.headers),
      'cookies': response.cookies.map((_) => '[REDACTED]').toList(),
      'body': SecretMasker.redactText(body),
      'durationMs': response.durationMs,
      'sizeBytes': response.sizeBytes,
      'timestamp': response.timestamp.toIso8601String(),
      'truncated': response.isTruncated,
      'error': response.error,
      'errorCategory': response.errorCategory,
    };
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
      flush: true,
    );
    return file;
  }

  String sanitizedText(String value, Set<String> sensitiveValues) =>
      SecretMasker.redactText(_redactKnown(value, sensitiveValues));

  String _redactKnown(String source, Set<String> values) {
    var result = source;
    for (final value in values.where((item) => item.isNotEmpty)) {
      result = result.replaceAll(value, '[REDACTED]');
    }
    return result;
  }
}
