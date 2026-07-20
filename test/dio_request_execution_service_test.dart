import 'dart:async';
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
  @override
  Future<void> deleteSecret(String key) async {}

  @override
  Future<String?> readSecret(String key) async => null;

  @override
  Future<void> writeSecret(String key, String value) async {}
}

ApiRequestModel _request(String id, String url) {
  final now = DateTime.now();
  return ApiRequestModel(
    id: id,
    createdAt: now,
    updatedAt: now,
    name: id,
    url: url,
    method: HttpMethod.get,
  );
}

Future<ApiResponseModel> _executeText(
  String body, {
  required int previewLimitBytes,
}) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  final served = Completer<void>();
  unawaited(
    server.listen((request) async {
      request.response.headers.contentType = ContentType.text;
      request.response.write(body);
      await request.response.close();
      served.complete();
    }).asFuture<void>(),
  );
  final response = await DioRequestExecutionService().execute(
    _request('preview', 'http://${server.address.address}:${server.port}/'),
    previewLimitBytes: previewLimitBytes,
  );
  await served.future;
  await server.close(force: true);
  return response;
}

void main() {
  test('response preview keeps ASCII below its byte limit', () async {
    final response = await _executeText('abc', previewLimitBytes: 3);
    expect(response.body, 'abc');
    expect(response.sizeBytes, 3);
    expect(response.isTruncated, isFalse);
  });

  test('response preview truncates ASCII at its byte limit', () async {
    final response = await _executeText('abcdef', previewLimitBytes: 4);
    expect(response.body, 'abcd');
    expect(response.sizeBytes, 6);
    expect(response.isTruncated, isTrue);
  });

  test('response preview does not split Arabic UTF-8 code points', () async {
    final response = await _executeText('مرحبا', previewLimitBytes: 5);
    expect(response.body, 'مر');
    expect(response.sizeBytes, utf8.encode('مرحبا').length);
    expect(response.isTruncated, isTrue);
  });

  test(
    'response preview keeps emoji valid when a byte limit cuts after it',
    () async {
      final response = await _executeText('a😀b', previewLimitBytes: 5);
      expect(response.body, 'a😀');
      expect(utf8.decode(utf8.encode(response.body)), response.body);
      expect(response.sizeBytes, utf8.encode('a😀b').length);
      expect(response.isTruncated, isTrue);
    },
  );

  test(
    'concurrent REST operations cancel independently and clean up',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final received = <String>{};
      final bothReceived = Completer<void>();
      final release = Completer<void>();
      unawaited(
        server.listen((request) async {
          received.add(request.uri.path);
          if (received.length == 2 && !bothReceived.isCompleted) {
            bothReceived.complete();
          }
          await release.future;
          try {
            request.response.write(request.uri.path);
            await request.response.close();
          } on HttpException {
            // The cancelled client can close its connection before the reply.
          }
        }).asFuture<void>(),
      );
      final service = DioRequestExecutionService();
      final base = 'http://${server.address.address}:${server.port}';
      final operationA = service.execute(
        _request('a', '$base/a'),
        operationId: 'tab-a',
      );
      final operationB = service.execute(
        _request('b', '$base/b'),
        operationId: 'tab-b',
      );
      await bothReceived.future;
      expect(service.activeOperationCount, 2);

      service.cancel('tab-a');
      service.cancel('tab-a');
      release.complete();
      final responseA = await operationA;
      final responseB = await operationB;

      expect(responseA.errorCategory, 'cancelled');
      expect(responseB.body, '/b');
      expect(service.activeOperationCount, 0);
      service.cancel('tab-b');
      await server.close(force: true);
    },
  );

  test(
    'disposing the service cancels every remaining REST operation',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final received = Completer<void>();
      unawaited(
        server.listen((request) async {
          received.complete();
          await Future<void>.delayed(const Duration(seconds: 5));
        }).asFuture<void>(),
      );
      final service = DioRequestExecutionService();
      final operation = service.execute(
        _request('dispose', 'http://${server.address.address}:${server.port}/'),
        operationId: 'dispose-tab',
      );
      await received.future;
      service.dispose();
      final response = await operation;
      expect(response.errorCategory, 'cancelled');
      expect(service.activeOperationCount, 0);
      await server.close(force: true);
    },
  );

  test(
    'closing one request tab cancels only its own active operation',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final paths = <String>{};
      final bothReceived = Completer<void>();
      final release = Completer<void>();
      unawaited(
        server.listen((request) async {
          paths.add(request.uri.path);
          if (paths.length == 2 && !bothReceived.isCompleted) {
            bothReceived.complete();
          }
          await release.future;
          try {
            request.response.write(request.uri.path);
            await request.response.close();
          } on HttpException {
            // The matching tab can close before its response is written.
          }
        }).asFuture<void>(),
      );
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final repository = LocalWorkspaceRepository(database, _Secrets());
      final cubit = RequestWorkflowCubit(
        DioRequestExecutionService(),
        repository,
      );
      final base = 'http://${server.address.address}:${server.port}';

      cubit.updateUrl('$base/a');
      final tabA = cubit.state.request.id;
      final sendA = cubit.send();
      while (!paths.contains('/a')) {
        await Future<void>.delayed(Duration.zero);
      }
      cubit.newRequest();
      cubit.updateUrl('$base/b');
      final tabB = cubit.state.request.id;
      final sendB = cubit.send();
      await bothReceived.future;

      cubit.selectTab(0);
      expect(cubit.state.request.id, tabA);
      await cubit.closeActive(discardChanges: true);
      release.complete();
      await Future.wait<void>(<Future<void>>[sendA, sendB]);

      expect(cubit.state.responses.containsKey(tabA), isFalse);
      expect(cubit.state.responses[tabB]?.body, '/b');
      await cubit.close();
      await database.close();
      await server.close(force: true);
    },
  );
}
