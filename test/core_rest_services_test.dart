import 'package:devroute_ai_studio/core/rest/bug_report_service.dart';
import 'package:devroute_ai_studio/core/rest/curl_codec.dart';
import 'package:devroute_ai_studio/core/rest/request_safety_service.dart';
import 'package:devroute_ai_studio/core/rest/token_candidate_service.dart';
import 'package:devroute_ai_studio/core/rest/variable_resolution_service.dart';
import 'package:devroute_ai_studio/core/security/secret_masker.dart';
import 'package:devroute_ai_studio/shared/models/api_models.dart';
import 'package:flutter_test/flutter_test.dart';

ApiRequestModel request({
  String url = 'https://api.example.test/{{version}}',
  HttpMethod method = HttpMethod.get,
  List<RequestHeaderModel> headers = const <RequestHeaderModel>[],
  RequestBodyModel? body,
}) {
  final now = DateTime(2026);
  return ApiRequestModel(
    id: 'request-1',
    createdAt: now,
    updatedAt: now,
    name: 'Request',
    url: url,
    method: method,
    headers: headers,
    body: body,
  );
}

void main() {
  group('variable resolution', () {
    test('uses runtime precedence and expands nested variables', () {
      final result = VariableResolutionService().resolve(
        '{{url}}',
        defaults: {'host': 'example.test', 'url': 'https://{{host}}/v1'},
        runtime: {'host': 'localhost'},
      );
      expect(result.value, 'https://localhost/v1');
      expect(result.isValid, isTrue);
    });

    test('reports unresolved values and cycles', () {
      final missing = VariableResolutionService().resolve('{{missing}}');
      final cycle = VariableResolutionService().resolve(
        '{{a}}',
        environment: {'a': '{{b}}', 'b': '{{a}}'},
      );
      expect(missing.unresolved, ['missing']);
      expect(cycle.cycles, isNotEmpty);
    });
  });

  test('request validation rejects malformed JSON and unsafe URL', () {
    final result = RequestSafetyService().validate(
      request(
        url: 'not-a-url',
        body: const RequestBodyModel(type: RequestBodyType.json, content: '{'),
      ),
    );
    expect(result.errors, hasLength(2));
  });

  test('production safety requires destructive confirmation', () {
    expect(
      RequestSafetyService().needsProductionConfirmation(
        environment: EnvironmentKind.production,
        method: HttpMethod.delete,
        strictMode: false,
      ),
      isTrue,
    );
    expect(
      RequestSafetyService().needsProductionConfirmation(
        environment: EnvironmentKind.production,
        method: HttpMethod.post,
        strictMode: true,
      ),
      isTrue,
    );
    expect(
      RequestSafetyService().needsProductionConfirmation(
        environment: EnvironmentKind.staging,
        method: HttpMethod.delete,
        strictMode: true,
      ),
      isFalse,
    );
  });

  test('cURL import parses without executing and export masks secrets', () {
    final parsed = CurlCodec().importCommand(
      "curl -X POST -H 'Authorization: Bearer secret' --data-raw '{\"ok\":true}' https://api.example.test/items",
    );
    expect(parsed.diagnostics, isEmpty);
    expect(parsed.request!.method, HttpMethod.post);
    expect(CurlCodec().export(parsed.request!), contains('[REDACTED]'));
  });

  test('token candidates are masked and nested paths are preserved', () {
    final candidates = TokenCandidateService().find(
      '{"data":{"access_token":"abcdef"}}',
    );
    expect(candidates.single.jsonPath, 'data.access_token');
    expect(candidates.single.maskedValue, isNot(contains('abcdef')));
    expect(
      TokenCandidateService().extract('{"data":{"access_token":"abcdef"}}'),
      <String, String>{'data.access_token': 'abcdef'},
    );
  });

  test('bug reports redact authorization values', () {
    final report = BugReportService().create(
      request: request(
        headers: const [
          RequestHeaderModel(key: 'Authorization', value: 'Bearer private'),
        ],
      ),
      response: ApiResponseModel(
        statusCode: 401,
        statusMessage: 'Unauthorized',
        headers: const {},
        body: 'nope',
        durationMs: 5,
        sizeBytes: 4,
        timestamp: DateTime(2026),
      ),
      environmentName: 'Production',
    );
    expect(report, contains('[REDACTED]'));
    expect(report, isNot(contains('Bearer private')));
  });

  test('secret masker redacts nested secret and refresh-token JSON keys', () {
    final value = SecretMasker.redactText(
      '{"outer":[{"SeCrEt":"private-value","refresh_token":"refresh-value"}]}',
    );
    expect(value, isNot(contains('private-value')));
    expect(value, isNot(contains('refresh-value')));
    expect(value, contains('[REDACTED]'));
    expect(
      SecretMasker.redactHeaders(<String, String>{'X-Secret': 'private'}),
      <String, String>{'X-Secret': '[REDACTED]'},
    );
  });
}
