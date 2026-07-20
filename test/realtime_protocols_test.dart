import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:devroute_ai_studio/core/ai/consent_ai_service.dart';
import 'package:devroute_ai_studio/core/diagnostics/developer_diagnostics.dart';
import 'package:devroute_ai_studio/core/diagnostics/history_comparison_service.dart';
import 'package:devroute_ai_studio/core/security/secret_masker.dart';
import 'package:devroute_ai_studio/features/realtime/domain/realtime_models.dart';
import 'package:devroute_ai_studio/features/realtime/domain/sse_parser.dart';
import 'package:devroute_ai_studio/features/realtime/domain/stream_decoders.dart';
import 'package:devroute_ai_studio/shared/models/api_models.dart';

void main() {
  group('SSE parser', () {
    test(
      'preserves fields across arbitrary line chunks and handles comments',
      () {
        final parser = SseParser();
        expect(parser.addText(': heartbeat\n'), isEmpty);
        expect(parser.addText('event: up'), isEmpty);
        expect(
          parser.addText('date\nid: 9\nretry: 1200\ndata: first\n'),
          isEmpty,
        );
        final events = parser.addText('data: second\n\n');

        expect(events, hasLength(1));
        expect(events.single.event, 'update');
        expect(events.single.id, '9');
        expect(events.single.retry, 1200);
        expect(events.single.data, 'first\nsecond');
        expect(events.single.comment, 'heartbeat');
      },
    );
    test('reports malformed retry fields as diagnostics', () {
      final parser = SseParser();
      final events = parser.addText('retry: later\n\n');
      expect(events.single.diagnostic, contains('Malformed SSE retry'));
    });
  });

  test(
    'NDJSON decoder retains incomplete data and reports malformed records',
    () {
      final decoder = NdjsonDecoder();
      expect(decoder.addText('{"id":1}\n{"id"'), hasLength(1));
      final records = decoder.addText(':2}\nnot-json\n');
      expect(records.map((item) => item.isValid), <bool>[true, false]);
    },
  );

  test('reconnect policy is bounded with exponential backoff', () {
    const policy = ReconnectPolicy(
      initialDelay: Duration(milliseconds: 100),
      maxDelay: Duration(milliseconds: 450),
    );
    expect(policy.delayFor(0), const Duration(milliseconds: 100));
    expect(policy.delayFor(2), const Duration(milliseconds: 400));
    expect(policy.delayFor(4), const Duration(milliseconds: 450));
  });

  test('incremental UTF-8 decoder preserves split multibyte characters', () {
    final decoder = IncrementalUtf8Decoder();
    final bytes = 'مرحبا'.codeUnits;
    final encoded = utf8.encode('مرحبا');
    expect(bytes, isNotEmpty);
    final first = decoder.add(encoded.sublist(0, 1));
    final second = decoder.add(encoded.sublist(1));
    expect('$first$second${decoder.close()}', 'مرحبا');
  });

  test('comparison is JSON-aware with text fallback', () {
    final changes = HistoryComparisonService.compareJsonText(
      '{"status":200,"body":{"ok":true}}',
      '{"status":201,"body":{"ok":false}}',
    );
    expect(
      changes.map((item) => item.path),
      containsAll([r'$.status', r'$.body.ok']),
    );
    expect(
      HistoryComparisonService.compareJsonText('a', 'b').single.path,
      r'$',
    );
  });

  test('secret masking and AI consent cannot include data until consent', () {
    expect(
      SecretMasker.redactText('Authorization: top-secret'),
      contains('[REDACTED]'),
    );
    final blocked = ConsentAiService.preview(
      options: const AiConsentOptions(),
      source: <String, Object?>{'body': 'password=secret'},
    );
    expect(blocked.payload['consent'], isFalse);
    final allowed = ConsentAiService.preview(
      options: const AiConsentOptions(granted: true, includeBodies: true),
      source: <String, Object?>{'body': 'password=secret'},
    );
    expect(allowed.payload['body'], contains('[REDACTED]'));
  });

  test('AI analysis requires consent and honors cancellation', () async {
    await expectLater(
      ConsentAiService.analyze(
        options: const AiConsentOptions(),
        source: const <String, Object?>{},
        provider: FakeAiProvider(),
      ),
      throwsStateError,
    );
    final token = AiCancellationToken()..cancel();
    await expectLater(
      ConsentAiService.analyze(
        options: const AiConsentOptions(granted: true),
        source: const <String, Object?>{},
        provider: FakeAiProvider(),
        cancellationToken: token,
      ),
      throwsStateError,
    );
  });

  test('diagnostics separate observed facts from suggestions', () {
    final request = ApiRequestModel(
      id: 'r',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      name: 'r',
      url: 'https://{{host}}/v1',
      method: HttpMethod.get,
    );
    final diagnostics = DeveloperDiagnostics.forRequest(
      request,
      ApiResponseModel(
        statusCode: 500,
        statusMessage: 'Server error',
        headers: const <String, String>{},
        body: '',
        durationMs: 4000,
        sizeBytes: 0,
        timestamp: DateTime(2026),
      ),
    );
    expect(
      diagnostics.any((item) => item.kind == DiagnosticKind.observed),
      isTrue,
    );
    expect(
      diagnostics.any((item) => item.kind == DiagnosticKind.suggestion),
      isTrue,
    );
  });
}
