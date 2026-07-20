import 'dart:convert';
import 'dart:io';

import 'package:devroute_ai_studio/core/network/dio_request_execution_service.dart';
import 'package:devroute_ai_studio/core/storage/database_schema.dart';
import 'package:devroute_ai_studio/core/storage/local_workspace_repository.dart';
import 'package:devroute_ai_studio/features/requests/presentation/request_workflow_cubit.dart';
import 'package:devroute_ai_studio/shared/models/api_models.dart';
import 'package:devroute_ai_studio/shared/services/service_interfaces.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _Secrets implements SecureStorageService {
  final values = <String, String>{};
  @override
  Future<void> deleteSecret(String key) async => values.remove(key);
  @override
  Future<String?> readSecret(String key) async => values[key];
  @override
  Future<void> writeSecret(String key, String value) async =>
      values[key] = value;
}

void main() {
  test('Dio execution uses a deterministic local HTTP server', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final serverTask = server.first.then((incoming) async {
      final body = await utf8.decoder.bind(incoming).join();
      incoming.response.statusCode = 201;
      incoming.response.headers.contentType = ContentType.json;
      incoming.response.write(
        jsonEncode(<String, Object?>{
          'method': incoming.method,
          'query': incoming.uri.queryParameters,
          'header': incoming.headers.value('x-test'),
          'body': body,
        }),
      );
      await incoming.response.close();
    });
    final now = DateTime.now();
    final response = await DioRequestExecutionService().execute(
      ApiRequestModel(
        id: 'local',
        createdAt: now,
        updatedAt: now,
        name: 'Local',
        url: 'http://${server.address.address}:${server.port}/echo',
        method: HttpMethod.post,
        queryParams: const <RequestQueryParamModel>[
          RequestQueryParamModel(key: 'page', value: '1'),
        ],
        headers: const <RequestHeaderModel>[
          RequestHeaderModel(key: 'x-test', value: 'yes'),
        ],
        body: const RequestBodyModel(
          type: RequestBodyType.json,
          content: '{"ok":true}',
        ),
      ),
    );
    await serverTask;
    await server.close(force: true);
    expect(response.statusCode, 201);
    expect(response.body, contains('POST'));
    expect(response.body, contains('page'));
    expect(response.body, contains('yes'));
  });

  test(
    'API-key query and multipart metadata resolve without public endpoints',
    () async {
      final secrets = _Secrets();
      await secrets.writeSecret('api-key', 'query-secret');
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final task = server.first.then((incoming) async {
        final body = await incoming.fold<List<int>>(
          <int>[],
          (all, chunk) => all..addAll(chunk),
        );
        incoming.response.write(
          '${incoming.uri.queryParameters['key']}|${incoming.headers.contentType?.mimeType}|${utf8.decode(body).contains('field')}',
        );
        await incoming.response.close();
      });
      final now = DateTime.now();
      final response = await DioRequestExecutionService(secureStorage: secrets)
          .execute(
            ApiRequestModel(
              id: 'multipart',
              createdAt: now,
              updatedAt: now,
              name: 'Multipart',
              url: 'http://${server.address.address}:${server.port}/upload',
              method: HttpMethod.post,
              auth: const RequestAuthModel(
                type: AuthType.apiKeyQuery,
                apiKeyName: 'key',
                apiKeySecretRef: 'api-key',
              ),
              body: const RequestBodyModel(
                type: RequestBodyType.multipart,
                content: '{"field":"value"}',
              ),
            ),
          );
      await task;
      await server.close(force: true);
      expect(response.body, contains('query-secret|multipart/form-data|true'));
    },
  );

  test(
    'request workflow resolves plain and secret environment variables only at send time',
    () async {
      final secrets = _Secrets();
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final repository = LocalWorkspaceRepository(database, secrets);
      final workspace = await repository.createWorkspace('Local');
      final environment = await repository.createEnvironment(
        workspace.id,
        'Test',
        EnvironmentKind.development,
      );
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      await repository.saveEnvironmentVariable(
        environment.id,
        key: 'HOST',
        value: '${server.address.address}:${server.port}',
      );
      await repository.saveEnvironmentVariable(
        environment.id,
        key: 'TOKEN',
        value: 'runtime-secret',
        isSecret: true,
      );
      final task = server.first.then((incoming) async {
        incoming.response.write(incoming.headers.value('x-token'));
        await incoming.response.close();
      });
      final cubit = RequestWorkflowCubit(
        DioRequestExecutionService(secureStorage: secrets),
        repository,
      );
      cubit.updateUrl('http://{{HOST}}/environment');
      cubit.updateHeaders(const <RequestHeaderModel>[
        RequestHeaderModel(key: 'x-token', value: '{{TOKEN}}'),
      ]);
      await cubit.send(environmentId: environment.id);
      await task;
      await server.close(force: true);
      expect(cubit.state.response?.body, 'runtime-secret');
      expect(
        (await repository.history()).single.snapshot.toString(),
        isNot(contains('runtime-secret')),
      );
      await cubit.close();
      await database.close();
    },
  );
}
