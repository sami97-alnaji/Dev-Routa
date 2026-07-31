import 'dart:convert';

import '../../../core/rest/curl_codec.dart';
import '../../../core/security/secret_masker.dart';
import '../domain/graphql_models.dart';

class GraphqlCurlImportResult {
  const GraphqlCurlImportResult({
    this.request,
    this.diagnostics = const <String>[],
  });

  final GraphqlRequest? request;
  final List<String> diagnostics;
  bool get isSuccess => request != null;
}

/// Converts the safe subset parsed by [CurlCodec] into a GraphQL request.
///
/// Sensitive imported headers are deliberately omitted: a pasted cURL command
/// must not turn its bearer token or cookie into a persisted GraphQL draft.
class GraphqlCurlCodec {
  GraphqlCurlCodec({CurlCodec? codec}) : _codec = codec ?? CurlCodec();

  final CurlCodec _codec;

  /// Produces a copy-safe cURL command. It never includes request credentials,
  /// endpoint query credentials, or values held under sensitive variable keys.
  String exportCommand(GraphqlRequest request) {
    final payload = <String, Object?>{
      'query': request.document,
      if (request.operationName != null) 'operationName': request.operationName,
      if (request.variables.isNotEmpty) 'variables': request.variables,
      if (request.extensions.isNotEmpty) 'extensions': request.extensions,
    };
    final safePayload = SecretMasker.redactStructured(payload);
    final headers = SecretMasker.redactHeaders(request.headers);
    final pieces = <String>[
      'curl',
      '-X',
      request.useGet ? 'GET' : 'POST',
      '-H',
      _quote('Accept: application/graphql-response+json, application/json'),
      if (!request.useGet) ...<String>[
        '-H',
        _quote('Content-Type: application/json'),
      ],
      for (final header in headers.entries) ...<String>[
        '-H',
        _quote('${header.key}: ${header.value}'),
      ],
    ];
    if (request.useGet) {
      final endpoint = Uri.parse(_safeEndpoint(Uri.parse(request.endpoint)));
      final query = <String, String>{
        for (final entry in (safePayload as Map).entries)
          entry.key.toString(): entry.value is String
              ? entry.value as String
              : jsonEncode(entry.value),
      };
      pieces.add(_quote(endpoint.replace(queryParameters: query).toString()));
    } else {
      pieces.addAll(<String>[
        '--data-raw',
        _quote(jsonEncode(safePayload)),
        _quote(_safeEndpoint(Uri.parse(request.endpoint))),
      ]);
    }
    return pieces.join(' ');
  }

  GraphqlCurlImportResult importCommand(String command) {
    final imported = _codec.importCommand(command);
    if (!imported.isSuccess || imported.request == null) {
      return GraphqlCurlImportResult(diagnostics: imported.diagnostics);
    }
    final source = imported.request!;
    final diagnostics = <String>[];
    final uri = Uri.tryParse(source.url);
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return const GraphqlCurlImportResult(
        diagnostics: <String>[
          'The cURL URL must be an HTTP or HTTPS endpoint.',
        ],
      );
    }
    final payload = _payload(
      source.body?.content,
      uri.queryParameters,
      diagnostics,
    );
    if (payload == null) {
      return GraphqlCurlImportResult(diagnostics: diagnostics);
    }
    final query = payload['query'];
    if (query is! String || query.trim().isEmpty) {
      diagnostics.add('The cURL body must contain a non-empty GraphQL query.');
      return GraphqlCurlImportResult(diagnostics: diagnostics);
    }
    final variables = _object(payload['variables'], 'variables', diagnostics);
    final extensions = _object(
      payload['extensions'],
      'extensions',
      diagnostics,
    );
    if (diagnostics.isNotEmpty) {
      return GraphqlCurlImportResult(diagnostics: diagnostics);
    }
    final headers = <String, String>{};
    for (final header in source.headers.where((item) => item.enabled)) {
      if (SecretMasker.redactHeaders(<String, String>{
            header.key: header.value,
          })[header.key] ==
          '[REDACTED]') {
        diagnostics.add(
          'Omitted sensitive ${header.key} header; configure secure authentication before executing.',
        );
        continue;
      }
      headers[header.key] = header.value;
    }
    return GraphqlCurlImportResult(
      request: GraphqlRequest(
        endpoint: _safeEndpoint(uri),
        document: query,
        operationName: payload['operationName']?.toString(),
        variables: variables,
        headers: headers,
        extensions: extensions,
        useGet: source.method.name == 'get',
      ),
      diagnostics: diagnostics,
    );
  }

  Map<String, Object?>? _payload(
    String? body,
    Map<String, String> query,
    List<String> diagnostics,
  ) {
    if (body != null && body.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map) {
          return decoded.map((key, value) => MapEntry(key.toString(), value));
        }
      } on FormatException {
        // Add the user-facing diagnostic below.
      }
      diagnostics.add('The GraphQL cURL body must be a JSON object.');
      return null;
    }
    if (query.isEmpty) return const <String, Object?>{};
    final result = <String, Object?>{};
    for (final entry in query.entries) {
      if (entry.key == 'variables' || entry.key == 'extensions') {
        try {
          result[entry.key] = jsonDecode(entry.value);
        } on FormatException {
          diagnostics.add('The ${entry.key} query parameter must be JSON.');
          return null;
        }
      } else {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  Map<String, Object?> _object(
    Object? value,
    String name,
    List<String> diagnostics,
  ) {
    if (value == null) return const <String, Object?>{};
    if (value is! Map) {
      diagnostics.add('GraphQL $name must be a JSON object.');
      return const <String, Object?>{};
    }
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  String _safeEndpoint(Uri uri) =>
      uri.replace(userInfo: '').toString().split('#').first.split('?').first;

  String _quote(String value) => "'${value.replaceAll("'", "'\\\"'\\\"'")}'";
}
