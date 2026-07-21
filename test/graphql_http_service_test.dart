import 'dart:convert';
import 'dart:io';

import 'package:devroute_ai_studio/features/graphql/data/graphql_http_service.dart';
import 'package:devroute_ai_studio/features/graphql/domain/graphql_models.dart';
import 'package:devroute_ai_studio/shared/models/api_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HttpServer server;
  late String endpoint;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    endpoint = 'http://${server.address.host}:${server.port}/graphql';
    server.listen((request) async {
      final body = await utf8.decoder.bind(request).join();
      final query = request.method == 'GET'
          ? request.uri.queryParameters['query'] ?? ''
          : (jsonDecode(body) as Map)['query'] as String;
      if (query.contains('HttpError')) {
        request.response.statusCode = 500;
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode(<String, Object?>{
            'errors': <Object?>[
              <String, Object?>{'message': 'Server failure'},
            ],
          }),
        );
        await request.response.close();
        return;
      }
      if (query.contains('NonJson')) {
        request.response.statusCode = 502;
        request.response.write('upstream unavailable');
        await request.response.close();
        return;
      }
      request.response.headers.contentType = ContentType.json;
      if (query.contains('Partial')) {
        request.response.write(
          jsonEncode(<String, Object?>{
            'data': <String, Object?>{'user': null},
            'errors': <Object?>[
              <String, Object?>{
                'message': 'Denied',
                'locations': [
                  <String, int>{'line': 2, 'column': 3},
                ],
                'path': ['user'],
                'extensions': <String, Object?>{'code': 'FORBIDDEN'},
              },
            ],
          }),
        );
      } else {
        request.response.write(
          jsonEncode(<String, Object?>{
            'data': <String, Object?>{'ok': true},
            'extensions': <String, Object?>{'trace': 'local'},
          }),
        );
      }
      await request.response.close();
    });
  });

  tearDown(() async => server.close(force: true));

  test('POST and GET carry GraphQL envelope and extensions', () async {
    final service = GraphqlHttpService();
    final post = await service.execute(
      'post',
      GraphqlRequest(
        endpoint: endpoint,
        document: 'query Get { ok }',
        variables: const <String, Object?>{'id': 1},
        extensions: const <String, Object?>{'persisted': false},
      ),
    );
    final get = await service.execute(
      'get',
      GraphqlRequest(
        endpoint: endpoint,
        document: 'query Get { ok }',
        useGet: true,
      ),
    );
    expect(post.data, <String, Object?>{'ok': true});
    expect(post.extensions, <String, Object?>{'trace': 'local'});
    expect(get.data, <String, Object?>{'ok': true});
  });

  test('GET mutation is rejected before network execution', () async {
    expect(
      () => GraphqlHttpService().execute(
        'mutation',
        GraphqlRequest(
          endpoint: endpoint,
          document: 'mutation Change { ok }',
          useGet: true,
        ),
      ),
      throwsA(
        isA<GraphqlFailure>().having(
          (failure) => failure.category,
          'category',
          GraphqlFailureCategory.validation,
        ),
      ),
    );
  });

  test('refuses insecure TLS configuration before network execution', () async {
    expect(
      () => GraphqlHttpService().execute(
        'insecure',
        GraphqlRequest(
          endpoint: endpoint,
          document: 'query Secure { ok }',
          settings: const RequestSettingsModel(verifyCertificates: false),
        ),
      ),
      throwsA(
        isA<GraphqlFailure>().having(
          (failure) => failure.category,
          'category',
          GraphqlFailureCategory.validation,
        ),
      ),
    );
  });

  test(
    'typed GraphQL errors preserve locations, paths and extensions',
    () async {
      final response = await GraphqlHttpService().execute(
        'partial',
        GraphqlRequest(endpoint: endpoint, document: 'query Partial { user }'),
      );
      expect(response.hasPartialData, isTrue);
      expect(response.errors.single.locations.single.line, 2);
      expect(response.errors.single.path.single.value, 'user');
      expect(response.errors.single.extensions['code'], 'FORBIDDEN');
    },
  );

  test('classifies HTTP GraphQL and non-JSON failures safely', () async {
    final graphqlFailure = await GraphqlHttpService().execute(
      'http-graphql',
      GraphqlRequest(endpoint: endpoint, document: 'query HttpError { ok }'),
    );
    expect(graphqlFailure.statusCode, 500);
    expect(graphqlFailure.completion, GraphqlCompletionCategory.httpFailure);
    expect(graphqlFailure.errors.single.message, 'Server failure');

    expect(
      () => GraphqlHttpService().execute(
        'http-non-json',
        GraphqlRequest(endpoint: endpoint, document: 'query NonJson { ok }'),
      ),
      throwsA(
        isA<GraphqlFailure>().having(
          (failure) => failure.category,
          'category',
          GraphqlFailureCategory.http,
        ),
      ),
    );
  });

  test('bounded preview preserves Unicode and byte size', () {
    final preview = boundedGraphqlPreview('مرحبا 😀 world', maxBytes: 10);
    expect(preview.truncated, isTrue);
    expect(() => utf8.encode(preview.value), returnsNormally);
    expect(preview.value, isNot(contains('�')));
  });
}
