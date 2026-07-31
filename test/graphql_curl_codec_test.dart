import 'package:devroute_ai_studio/features/graphql/application/graphql_curl_codec.dart';
import 'package:devroute_ai_studio/features/graphql/domain/graphql_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GraphQL cURL import creates an isolated safe request', () {
    final result = GraphqlCurlCodec().importCommand(r'''curl -X POST \
      -H 'Authorization: Bearer live-token' \
      -H 'X-Client: DevRoute' \
      --data-raw '{"query":"query GetUser($id: ID!) { user(id: $id) { id } }","operationName":"GetUser","variables":{"id":"42"}}' \
      https://api.example.test/graphql?api_key=must-not-persist''');

    expect(result.isSuccess, isTrue);
    expect(result.request!.endpoint, 'https://api.example.test/graphql');
    expect(result.request!.document, contains(r'$id'));
    expect(result.request!.operationName, 'GetUser');
    expect(result.request!.variables, <String, Object?>{'id': '42'});
    expect(result.request!.headers, <String, String>{'X-Client': 'DevRoute'});
    expect(result.diagnostics.join(), contains('Authorization'));
    expect(result.diagnostics.join(), isNot(contains('live-token')));
  });

  test('GraphQL cURL import rejects a body without a GraphQL document', () {
    final result = GraphqlCurlCodec().importCommand(
      "curl --data-raw '{\"variables\":{}}' https://api.example.test/graphql",
    );

    expect(result.isSuccess, isFalse);
    expect(result.request, isNull);
    expect(result.diagnostics, contains(contains('non-empty GraphQL query')));
  });

  test('GraphQL cURL POST round-trip preserves supported request fields', () {
    const request = GraphqlRequest(
      endpoint: 'https://api.example.test/graphql?token=not-exported',
      document: 'query Viewer(\$id: ID!) { viewer(id: \$id) { id name } }',
      operationName: 'Viewer',
      variables: <String, Object?>{'id': '42', 'password': 'not-exported'},
      headers: <String, String>{
        'X-Client': 'DevRoute',
        'Authorization': 'Bearer not-exported',
      },
      extensions: <String, Object?>{'trace': true},
    );
    final codec = GraphqlCurlCodec();
    final command = codec.exportCommand(request);
    final result = codec.importCommand(command);

    expect(command, isNot(contains('not-exported')));
    expect(result.isSuccess, isTrue);
    expect(result.request!.endpoint, 'https://api.example.test/graphql');
    expect(result.request!.document, request.document);
    expect(result.request!.operationName, 'Viewer');
    expect(result.request!.variables, <String, Object?>{
      'id': '42',
      'password': '[REDACTED]',
    });
    expect(result.request!.extensions, <String, Object?>{'trace': true});
    expect(result.request!.headers['X-Client'], 'DevRoute');
  });

  test('GraphQL cURL GET round-trip preserves encoded parameters', () {
    const request = GraphqlRequest(
      endpoint: 'https://api.example.test/graphql',
      document: 'query {\n  viewer { id }\n}',
      variables: <String, Object?>{},
      useGet: true,
    );
    final codec = GraphqlCurlCodec();
    final result = codec.importCommand(codec.exportCommand(request));

    expect(result.isSuccess, isTrue);
    expect(result.request!.useGet, isTrue);
    expect(result.request!.document, request.document);
    expect(result.request!.variables, isEmpty);
  });

  test('GraphQL cURL import rejects malformed and unsupported commands', () {
    final malformed = GraphqlCurlCodec().importCommand('curl --compressed');
    final missingUrl = GraphqlCurlCodec().importCommand(
      "curl --data-raw '{\"query\":\"query { viewer { id } }\"}'",
    );

    expect(malformed.isSuccess, isFalse);
    expect(malformed.diagnostics, contains(contains('Unsupported cURL flag')));
    expect(missingUrl.isSuccess, isFalse);
    expect(missingUrl.diagnostics, contains('No URL was found.'));
  });
}
