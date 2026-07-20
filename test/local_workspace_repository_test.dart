import 'package:devroute_ai_studio/core/storage/database_schema.dart';
import 'package:devroute_ai_studio/core/storage/local_workspace_repository.dart';
import 'package:devroute_ai_studio/shared/models/api_models.dart';
import 'package:devroute_ai_studio/shared/services/service_interfaces.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class MemorySecrets implements SecureStorageService {
  final values = <String, String>{};
  final deleted = <String>[];
  @override
  Future<void> deleteSecret(String key) async {
    deleted.add(key);
    values.remove(key);
  }

  @override
  Future<String?> readSecret(String key) async => values[key];
  @override
  Future<void> writeSecret(String key, String value) async {
    values[key] = value;
  }
}

void main() {
  late AppDatabase database;
  late LocalWorkspaceRepository repository;
  late MemorySecrets secrets;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    secrets = MemorySecrets();
    repository = LocalWorkspaceRepository(database, secrets);
  });
  tearDown(() async => database.close());

  test(
    'collection, folder, request, draft, move, duplicate, search and cascade persist',
    () async {
      final workspace = await repository.createWorkspace('Team API');
      final collection = await repository.createCollection(
        workspace.id,
        'Auth',
      );
      final target = await repository.createCollection(workspace.id, 'Users');
      final folder = await repository.createFolder(collection.id, 'Tokens');
      final child = await repository.createFolder(
        collection.id,
        'Refresh',
        parentFolderId: folder.id,
      );
      expect(child.parentFolderId, folder.id);

      final now = DateTime.now();
      final request = ApiRequestModel(
        id: 'request-1',
        createdAt: now,
        updatedAt: now,
        name: 'Login',
        url: 'https://example.test/login',
        method: HttpMethod.post,
        collectionId: collection.id,
        folderId: folder.id,
        headers: const <RequestHeaderModel>[
          RequestHeaderModel(
            key: 'Authorization',
            value: 'top-secret',
            isSecret: true,
          ),
        ],
        queryParams: const <RequestQueryParamModel>[
          RequestQueryParamModel(key: 'verbose', value: 'true'),
        ],
        body: const RequestBodyModel(
          type: RequestBodyType.json,
          content: '{"user":"sam"}',
        ),
        settings: const RequestSettingsModel(receiveTimeoutMs: 4321),
      );
      await repository.saveRequest(request);
      await repository.saveDraft(request);
      final loaded = (await repository.savedRequests(
        workspace.id,
        search: 'login',
      )).single;
      expect(loaded.body?.content, contains('sam'));
      expect(loaded.settings.receiveTimeoutMs, 4321);
      expect(loaded.headers.single.value, isEmpty);
      expect(
        await repository.readSecret(loaded.headers.single.secretRef!),
        'top-secret',
      );
      expect((await repository.drafts()).single.id, request.id);

      final duplicate = await repository.duplicateRequest(request.id);
      expect((await repository.savedRequests(workspace.id)).length, 2);
      expect(
        duplicate.headers.single.secretRef,
        isNot(loaded.headers.single.secretRef),
      );
      await repository.moveRequest(duplicate.id, collectionId: target.id);
      expect(
        (await repository.savedRequests(
          workspace.id,
          collectionId: target.id,
        )).single.id,
        duplicate.id,
      );

      await repository.deleteCollection(collection.id);
      expect(await repository.requestById(request.id), isNull);
      expect(secrets.deleted, contains(loaded.headers.single.secretRef));
      expect(await repository.requestById(duplicate.id), isNotNull);
    },
  );

  test(
    'environment variables keep secrets outside SQLite and clean them safely',
    () async {
      final workspace = await repository.createWorkspace('API');
      final environment = await repository.createEnvironment(
        workspace.id,
        'Production',
        EnvironmentKind.production,
      );
      final variable = await repository.saveEnvironmentVariable(
        environment.id,
        key: 'TOKEN',
        value: 'secret-value',
        isSecret: true,
      );
      final rows = await repository.environmentVariables(environment.id);
      expect(rows.single.value, isEmpty);
      expect(await repository.readSecret(variable.secretRef!), 'secret-value');
      await repository.saveEnvironmentVariable(
        environment.id,
        id: variable.id,
        key: 'TOKEN',
        value: '',
        isSecret: true,
        enabled: false,
      );
      expect(
        (await repository.environmentVariables(environment.id)).single.enabled,
        isFalse,
      );
      await repository.deleteEnvironment(environment.id);
      expect(secrets.values, isEmpty);
    },
  );

  test(
    'history snapshots are redacted, replayable, filterable and retained',
    () async {
      final workspace = await repository.createWorkspace('API');
      final collection = await repository.createCollection(
        workspace.id,
        'Core',
      );
      final now = DateTime.now();
      final request = ApiRequestModel(
        id: 'r',
        createdAt: now,
        updatedAt: now,
        name: 'Health',
        url: 'https://example.test/health',
        method: HttpMethod.get,
        collectionId: collection.id,
        headers: const <RequestHeaderModel>[
          RequestHeaderModel(key: 'Authorization', value: 'secret'),
        ],
      );
      await repository.saveRequest(request);
      await repository.recordHistory(
        request,
        ApiResponseModel(
          statusCode: 200,
          statusMessage: 'OK',
          headers: const <String, String>{
            'set-cookie': 'private',
            'content-type': 'application/json',
          },
          body: '{"password":"private"}',
          durationMs: 12,
          sizeBytes: 22,
          timestamp: now,
          cookies: const <String>['private'],
        ),
      );
      final history = await repository.history(search: 'health', method: 'get');
      expect(history, hasLength(1));
      expect(jsonText(history.single.snapshot), isNot(contains('private')));
      final replay = await repository.replayHistory(history.single.id);
      expect(replay?.id, isNot(request.id));
      expect(replay?.name, contains('replay'));
      await repository.applyHistoryRetention(
        const WorkspaceSettingsModel(historyMaximumCount: 1),
      );
      expect(await repository.history(), hasLength(1));
      await repository.clearHistory();
      expect(await repository.history(), isEmpty);
    },
  );
}

String jsonText(Object? value) => value.toString();
