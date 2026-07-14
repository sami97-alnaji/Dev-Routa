import '../../shared/models/api_models.dart';
import '../security/secret_masker.dart';

class BugReportService {
  String create({
    required ApiRequestModel request,
    required ApiResponseModel response,
    required String environmentName,
    String? title,
  }) {
    final safeHeaders = SecretMasker.redactHeaders({
      for (final header in request.headers.where((header) => header.enabled))
        header.key: header.value,
    });
    final body = request.body?.content ?? '';
    final safeBody = body.length > 2048
        ? '${body.substring(0, 2048)}\n[truncated]'
        : body;
    final responseBody = response.body.length > 4096
        ? '${response.body.substring(0, 4096)}\n[truncated]'
        : response.body;
    return '''# ${title?.trim().isNotEmpty == true ? title!.trim() : 'DevRoute API issue'}

- Timestamp: ${response.timestamp.toIso8601String()}
- Environment: $environmentName
- Request: ${request.method.name.toUpperCase()} ${_maskUrl(request.url)}
- Response: ${response.statusCode ?? 'No response'} ${response.statusMessage ?? ''}
- Timing: ${response.durationMs} ms
- Size: ${response.sizeBytes} bytes
- Error category: ${response.errorCategory ?? 'None'}

## Masked request headers
```text
$safeHeaders
```

## Safe request body
```text
$safeBody
```

## Safe response excerpt
```text
${response.error ?? responseBody}
```

## Reproduction steps
1. Select the $environmentName environment.
2. Run the request shown above.
3. Observe the reported response or error.
''';
  }

  String _maskUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return value;
    return uri
        .replace(
          queryParameters: {
            for (final entry in uri.queryParameters.entries)
              entry.key:
                  SecretMasker.redactHeaders(<String, String>{
                    entry.key: entry.value,
                  })[entry.key] ??
                  entry.value,
          },
        )
        .toString();
  }
}
