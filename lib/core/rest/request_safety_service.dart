import 'dart:convert';

import '../../shared/models/api_models.dart';

class RequestValidationResult {
  const RequestValidationResult(this.errors);
  final List<String> errors;
  bool get isValid => errors.isEmpty;
}

class RequestSafetyService {
  RequestValidationResult validate(ApiRequestModel request) {
    final errors = <String>[];
    final uri = Uri.tryParse(request.url.trim());
    if (uri == null ||
        !(uri.isScheme('http') || uri.isScheme('https')) ||
        uri.host.isEmpty) {
      errors.add('Enter a complete HTTP or HTTPS URL.');
    }
    for (final header in request.headers.where((item) => item.enabled)) {
      if (header.key.trim().isEmpty) {
        errors.add('A header name cannot be empty.');
      }
    }
    if (request.body?.type == RequestBodyType.json) {
      try {
        // Dio parses JSON after this validation; malformed JSON gets a clear UI error.
        jsonDecode(request.body!.content);
      } catch (_) {
        errors.add('The JSON request body is invalid.');
      }
    }
    if (!request.settings.verifyCertificates && uri?.scheme == 'https') {
      errors.add(
        'Certificate verification may only be disabled after an explicit confirmation.',
      );
    }
    return RequestValidationResult(errors);
  }

  bool needsProductionConfirmation({
    required EnvironmentKind environment,
    required HttpMethod method,
    required bool strictMode,
  }) =>
      environment == EnvironmentKind.production &&
      (method == HttpMethod.delete ||
          (strictMode &&
              const <HttpMethod>{
                HttpMethod.post,
                HttpMethod.put,
                HttpMethod.patch,
              }.contains(method)));
}
