import 'dart:io';

import 'package:devroute_ai_studio/core/rest/safe_export_service.dart';
import 'package:devroute_ai_studio/shared/models/api_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('safe response export removes known and named secrets', () async {
    final directory = await Directory.systemTemp.createTemp('devroute-export-');
    final service = SafeExportService(directoryProvider: () async => directory);
    final file = await service.exportResponse(
      ApiResponseModel(
        statusCode: 200,
        statusMessage: 'OK',
        headers: const <String, String>{'Authorization': 'header-secret'},
        body: '{"echo":"runtime-secret","password":"named-secret"}',
        durationMs: 1,
        sizeBytes: 10,
        timestamp: DateTime(2026),
        cookies: const <String>['cookie-secret'],
      ),
      sensitiveValues: const <String>{'runtime-secret'},
    );
    final exported = await file.readAsString();
    expect(exported, isNot(contains('runtime-secret')));
    expect(exported, isNot(contains('named-secret')));
    expect(exported, isNot(contains('header-secret')));
    expect(exported, isNot(contains('cookie-secret')));
    expect(exported, contains('[REDACTED]'));
    await directory.delete(recursive: true);
  });
}
