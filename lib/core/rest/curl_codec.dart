import '../../shared/models/api_models.dart';
import '../security/secret_masker.dart';

class CurlImportResult {
  const CurlImportResult({this.request, this.diagnostics = const <String>[]});
  final ApiRequestModel? request;
  final List<String> diagnostics;
  bool get isSuccess => request != null && diagnostics.isEmpty;
}

/// Parses a deliberately small, documented cURL subset; it never starts a
/// process or evaluates shell syntax.
class CurlCodec {
  CurlImportResult importCommand(String command) {
    final tokens = _tokenize(
      command.replaceAll('\\\n', ' ').replaceAll('^\n', ' '),
    );
    if (tokens.isEmpty || tokens.first.toLowerCase() != 'curl') {
      return const CurlImportResult(
        diagnostics: <String>['The input must start with curl.'],
      );
    }
    var method = HttpMethod.get;
    String? url;
    String? body;
    final headers = <RequestHeaderModel>[];
    final diagnostics = <String>[];
    for (var index = 1; index < tokens.length; index++) {
      final token = tokens[index];
      String? next() => ++index < tokens.length ? tokens[index] : null;
      if (token == '-X' || token == '--request') {
        final value = next()?.toLowerCase();
        final match = HttpMethod.values.where((item) => item.name == value);
        if (match.isEmpty) {
          diagnostics.add('Unsupported HTTP method: $value');
        } else {
          method = match.first;
        }
      } else if (token == '-H' || token == '--header') {
        final value = next();
        final split = value?.indexOf(':') ?? -1;
        if (split <= 0) {
          diagnostics.add('Invalid header syntax.');
        } else {
          final name = value!.substring(0, split).trim();
          final headerValue = value.substring(split + 1).trim();
          headers.add(
            RequestHeaderModel(
              key: name,
              value: headerValue,
              isSecret:
                  SecretMasker.redactHeaders(<String, String>{
                    name: headerValue,
                  })[name] ==
                  '[REDACTED]',
            ),
          );
        }
      } else if (token == '-d' || token == '--data' || token == '--data-raw') {
        body = next();
        if (method == HttpMethod.get) {
          method = HttpMethod.post;
        }
      } else if (token == '-u' || token == '--user') {
        final value = next();
        if (value == null || !value.contains(':')) {
          diagnostics.add('Invalid basic-auth syntax.');
        }
      } else if (token.startsWith('-')) {
        diagnostics.add('Unsupported cURL flag: $token');
      } else {
        url ??= token;
      }
    }
    if (url == null) {
      diagnostics.add('No URL was found.');
    }
    if (diagnostics.isNotEmpty || url == null) {
      return CurlImportResult(diagnostics: diagnostics);
    }
    final now = DateTime.now();
    return CurlImportResult(
      request: ApiRequestModel(
        id: 'imported',
        createdAt: now,
        updatedAt: now,
        name: 'Imported cURL',
        url: url,
        method: method,
        headers: headers,
        body: body == null
            ? null
            : RequestBodyModel(type: RequestBodyType.rawText, content: body),
      ),
    );
  }

  String export(ApiRequestModel request, {bool includeSecrets = false}) {
    final pieces = <String>['curl', '-X', request.method.name.toUpperCase()];
    for (final header in request.headers.where((item) => item.enabled)) {
      final value = header.isSecret && !includeSecrets
          ? '[REDACTED]'
          : header.value;
      pieces.addAll(<String>['-H', _quote('${header.key}: $value')]);
    }
    final body = request.body;
    if (body != null &&
        body.type != RequestBodyType.none &&
        body.content.isNotEmpty) {
      pieces.addAll(<String>['--data-raw', _quote(body.content)]);
    }
    pieces.add(_quote(request.url));
    return pieces.join(' ');
  }

  List<String> _tokenize(String input) {
    final result = <String>[];
    final buffer = StringBuffer();
    String? quote;
    for (var index = 0; index < input.length; index++) {
      final char = input[index];
      // In POSIX single quotes a backslash is literal. Preserving it is
      // essential for JSON produced by the GraphQL cURL exporter.
      if (char == '\\' && quote != "'" && index + 1 < input.length) {
        buffer.write(input[++index]);
        continue;
      }
      if ((char == '"' || char == "'") && (quote == null || quote == char)) {
        quote = quote == null ? char : null;
        continue;
      }
      if (char.trim().isEmpty && quote == null) {
        if (buffer.isNotEmpty) {
          result.add(buffer.toString());
          buffer.clear();
        }
      } else {
        buffer.write(char);
      }
    }
    if (quote != null) {
      return const <String>[];
    }
    if (buffer.isNotEmpty) {
      result.add(buffer.toString());
    }
    return result;
  }

  String _quote(String value) => "'${value.replaceAll("'", "'\\\"'\\\"'")}'";
}
