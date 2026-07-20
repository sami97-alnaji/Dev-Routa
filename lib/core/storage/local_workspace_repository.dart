import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../shared/models/api_models.dart';
import '../../shared/services/service_interfaces.dart';
import '../security/secret_masker.dart';
import 'database_schema.dart';

class LocalWorkspaceRepository {
  LocalWorkspaceRepository(this._database, this._secureStorage);
  final AppDatabase _database;
  final SecureStorageService _secureStorage;
  static const _ids = Uuid();

  Future<void> _execute(
    String sql, [
    List<Object?> values = const <Object?>[],
  ]) => _database.customStatement(
    sql,
    values
        .map(
          (value) =>
              value is DateTime ? value.millisecondsSinceEpoch ~/ 1000 : value,
        )
        .toList(),
  );

  Future<void> saveSecret(String reference, String value) =>
      _secureStorage.writeSecret(reference, value);
  Future<String?> readSecret(String reference) =>
      _secureStorage.readSecret(reference);

  Future<List<WorkspaceModel>> workspaces() async {
    final rows = await _database
        .customSelect('SELECT * FROM workspaces ORDER BY sort_order, name')
        .get();
    return rows
        .map(
          (row) => WorkspaceModel(
            id: row.read<String>('id'),
            name: row.read<String>('name'),
            createdAt: row.read<DateTime>('created_at'),
            updatedAt: row.read<DateTime>('updated_at'),
          ),
        )
        .toList();
  }

  Future<WorkspaceModel> createWorkspace(String name) async {
    final now = DateTime.now();
    final model = WorkspaceModel(
      id: _ids.v4(),
      name: name.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await _execute(
      'INSERT INTO workspaces (id, name, created_at, updated_at, sort_order, production_strict_mode) VALUES (?, ?, ?, ?, ?, ?)',
      <Object?>[
        model.id,
        model.name,
        now,
        now,
        now.microsecondsSinceEpoch,
        true,
      ],
    );
    await updateWorkspaceSettings(model.id, const WorkspaceSettingsModel());
    return model;
  }

  Future<void> renameWorkspace(String id, String name) => _execute(
    'UPDATE workspaces SET name = ?, updated_at = ? WHERE id = ?',
    <Object?>[name.trim(), DateTime.now(), id],
  );

  Future<void> deleteWorkspace(String id) async {
    final requests = await savedRequests(id);
    final environmentsForWorkspace = await environments(id);
    for (final request in requests) {
      await deleteRequest(request.id);
    }
    for (final environment in environmentsForWorkspace) {
      await deleteEnvironment(environment.id);
    }
    await _database.transaction(() async {
      await _execute(
        'DELETE FROM request_history WHERE request_id NOT IN (SELECT id FROM requests)',
      );
      await _execute(
        'DELETE FROM realtime_history WHERE workspace_id = ?',
        <Object?>[id],
      );
      await _execute(
        'DELETE FROM realtime_drafts WHERE workspace_id = ?',
        <Object?>[id],
      );
      await _execute(
        'DELETE FROM realtime_configurations WHERE workspace_id = ?',
        <Object?>[id],
      );
      await _execute(
        'DELETE FROM folders WHERE collection_id IN (SELECT id FROM collections WHERE workspace_id = ?)',
        <Object?>[id],
      );
      await _execute(
        'DELETE FROM collections WHERE workspace_id = ?',
        <Object?>[id],
      );
      await _execute(
        'DELETE FROM workspace_settings WHERE workspace_id = ?',
        <Object?>[id],
      );
      await _execute('DELETE FROM workspaces WHERE id = ?', <Object?>[id]);
    });
  }

  Future<WorkspaceSettingsModel> workspaceSettings(String workspaceId) async {
    final row = await _database
        .customSelect(
          'SELECT * FROM workspace_settings WHERE workspace_id = ?',
          variables: <Variable>[Variable.withString(workspaceId)],
        )
        .getSingleOrNull();
    if (row == null) {
      const defaults = WorkspaceSettingsModel();
      await updateWorkspaceSettings(workspaceId, defaults);
      return defaults;
    }
    return WorkspaceSettingsModel(
      historyRetentionDays: row.read<int>('history_retention_days'),
      historyMaximumCount: row.read<int>('history_maximum_count'),
      responsePreviewBytes: row.read<int>('response_preview_bytes'),
      productionStrictMode: row.read<bool>('production_strict_mode'),
    );
  }

  Future<void> updateWorkspaceSettings(
    String workspaceId,
    WorkspaceSettingsModel settings,
  ) async {
    await _execute(
      'INSERT OR REPLACE INTO workspace_settings (workspace_id, history_retention_days, history_maximum_count, response_preview_bytes, production_strict_mode, updated_at) VALUES (?, ?, ?, ?, ?, ?)',
      <Object?>[
        workspaceId,
        settings.historyRetentionDays,
        settings.historyMaximumCount,
        settings.responsePreviewBytes,
        settings.productionStrictMode,
        DateTime.now(),
      ],
    );
    await _execute(
      'UPDATE workspaces SET production_strict_mode = ? WHERE id = ?',
      <Object?>[settings.productionStrictMode, workspaceId],
    );
  }

  Future<List<CollectionModel>> collections(
    String workspaceId, {
    String search = '',
  }) async {
    final rows = await _database
        .customSelect(
          'SELECT * FROM collections WHERE workspace_id = ? AND name LIKE ? ORDER BY sort_order, name',
          variables: <Variable>[
            Variable.withString(workspaceId),
            Variable.withString('%${search.trim()}%'),
          ],
        )
        .get();
    return rows
        .map(
          (row) => CollectionModel(
            id: row.read<String>('id'),
            workspaceId: workspaceId,
            name: row.read<String>('name'),
            createdAt: row.read<DateTime>('created_at'),
            updatedAt: row.read<DateTime>('updated_at'),
          ),
        )
        .toList();
  }

  Future<CollectionModel> createCollection(
    String workspaceId,
    String name,
  ) async {
    final now = DateTime.now();
    final model = CollectionModel(
      id: _ids.v4(),
      workspaceId: workspaceId,
      name: name.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await _execute(
      'INSERT INTO collections (id, workspace_id, name, created_at, updated_at, sort_order) VALUES (?, ?, ?, ?, ?, ?)',
      <Object?>[
        model.id,
        workspaceId,
        model.name,
        now,
        now,
        now.microsecondsSinceEpoch,
      ],
    );
    return model;
  }

  Future<void> renameCollection(String id, String name) => _execute(
    'UPDATE collections SET name = ?, updated_at = ? WHERE id = ?',
    <Object?>[name.trim(), DateTime.now(), id],
  );
  Future<void> moveCollection(String id, String workspaceId) => _execute(
    'UPDATE collections SET workspace_id = ?, updated_at = ? WHERE id = ?',
    <Object?>[workspaceId, DateTime.now(), id],
  );
  Future<void> reorderCollection(String id, int order) => _execute(
    'UPDATE collections SET sort_order = ?, updated_at = ? WHERE id = ?',
    <Object?>[order, DateTime.now(), id],
  );

  Future<CollectionModel> duplicateCollection(String id) async {
    final row = await _database
        .customSelect(
          'SELECT * FROM collections WHERE id = ?',
          variables: <Variable>[Variable.withString(id)],
        )
        .getSingle();
    final copy = await createCollection(
      row.read<String>('workspace_id'),
      '${row.read<String>('name')} copy',
    );
    final folderCopies = <String, String>{};
    for (final folder in await folders(id)) {
      final created = await createFolder(copy.id, folder.name);
      folderCopies[folder.id] = created.id;
    }
    for (final request in await savedRequests(
      row.read<String>('workspace_id'),
      collectionId: id,
    )) {
      await duplicateRequest(
        request.id,
        collectionId: copy.id,
        folderId: request.folderId == null
            ? null
            : folderCopies[request.folderId],
      );
    }
    return copy;
  }

  Future<void> deleteCollection(String id) async {
    final row = await _database
        .customSelect(
          'SELECT workspace_id FROM collections WHERE id = ?',
          variables: <Variable>[Variable.withString(id)],
        )
        .getSingleOrNull();
    if (row != null) {
      for (final request in await savedRequests(
        row.read<String>('workspace_id'),
        collectionId: id,
      )) {
        await deleteRequest(request.id);
      }
    }
    await _database.transaction(() async {
      await _execute('DELETE FROM folders WHERE collection_id = ?', <Object?>[
        id,
      ]);
      await _execute('DELETE FROM collections WHERE id = ?', <Object?>[id]);
    });
  }

  Future<List<FolderModel>> folders(String collectionId) async {
    final rows = await _database
        .customSelect(
          'SELECT * FROM folders WHERE collection_id = ? ORDER BY sort_order, name',
          variables: <Variable>[Variable.withString(collectionId)],
        )
        .get();
    return rows
        .map(
          (row) => FolderModel(
            id: row.read<String>('id'),
            collectionId: collectionId,
            name: row.read<String>('name'),
            parentFolderId: row.readNullable<String>('parent_folder_id'),
            createdAt: row.read<DateTime>('created_at'),
            updatedAt: row.read<DateTime>('updated_at'),
          ),
        )
        .toList();
  }

  Future<FolderModel> createFolder(
    String collectionId,
    String name, {
    String? parentFolderId,
  }) async {
    if (parentFolderId != null) {
      final parent = await _database
          .customSelect(
            'SELECT collection_id, parent_folder_id FROM folders WHERE id = ?',
            variables: <Variable>[Variable.withString(parentFolderId)],
          )
          .getSingleOrNull();
      if (parent == null ||
          parent.read<String>('collection_id') != collectionId ||
          parent.readNullable<String>('parent_folder_id') != null) {
        throw ArgumentError(
          'Folders support one nesting level inside the same collection.',
        );
      }
    }
    final now = DateTime.now();
    final model = FolderModel(
      id: _ids.v4(),
      collectionId: collectionId,
      name: name.trim(),
      parentFolderId: parentFolderId,
      createdAt: now,
      updatedAt: now,
    );
    await _execute(
      'INSERT INTO folders (id, collection_id, name, created_at, updated_at, sort_order, parent_folder_id) VALUES (?, ?, ?, ?, ?, ?, ?)',
      <Object?>[
        model.id,
        collectionId,
        model.name,
        now,
        now,
        now.microsecondsSinceEpoch,
        parentFolderId,
      ],
    );
    return model;
  }

  Future<void> renameFolder(String id, String name) => _execute(
    'UPDATE folders SET name = ?, updated_at = ? WHERE id = ?',
    <Object?>[name.trim(), DateTime.now(), id],
  );
  Future<void> reorderFolder(String id, int order) => _execute(
    'UPDATE folders SET sort_order = ?, updated_at = ? WHERE id = ?',
    <Object?>[order, DateTime.now(), id],
  );
  Future<void> moveFolder(
    String id,
    String collectionId, {
    String? parentFolderId,
  }) => _execute(
    'UPDATE folders SET collection_id = ?, parent_folder_id = ?, updated_at = ? WHERE id = ?',
    <Object?>[collectionId, parentFolderId, DateTime.now(), id],
  );
  Future<void> deleteFolder(String id) async {
    await _database.transaction(() async {
      await _execute(
        'UPDATE requests SET folder_id = NULL WHERE folder_id = ?',
        <Object?>[id],
      );
      await _execute(
        'UPDATE folders SET parent_folder_id = NULL WHERE parent_folder_id = ?',
        <Object?>[id],
      );
      await _execute('DELETE FROM folders WHERE id = ?', <Object?>[id]);
    });
  }

  Future<List<EnvironmentModel>> environments(String workspaceId) async {
    final rows = await _database
        .customSelect(
          'SELECT * FROM environments WHERE workspace_id = ? ORDER BY is_active DESC, name',
          variables: <Variable>[Variable.withString(workspaceId)],
        )
        .get();
    return rows
        .map(
          (row) => EnvironmentModel(
            id: row.read<String>('id'),
            workspaceId: workspaceId,
            name: row.read<String>('name'),
            kind: EnvironmentKind.values.byName(row.read<String>('kind')),
            isActive: row.read<bool>('is_active'),
            createdAt: row.read<DateTime>('created_at'),
            updatedAt: row.read<DateTime>('updated_at'),
          ),
        )
        .toList();
  }

  Future<EnvironmentModel> createEnvironment(
    String workspaceId,
    String name,
    EnvironmentKind kind,
  ) async {
    final now = DateTime.now();
    final model = EnvironmentModel(
      id: _ids.v4(),
      workspaceId: workspaceId,
      name: name.trim(),
      kind: kind,
      createdAt: now,
      updatedAt: now,
    );
    await _execute(
      'INSERT INTO environments (id, name, created_at, updated_at, workspace_id, kind, is_active) VALUES (?, ?, ?, ?, ?, ?, ?)',
      <Object?>[model.id, model.name, now, now, workspaceId, kind.name, false],
    );
    return model;
  }

  Future<void> renameEnvironment(String id, String name) => _execute(
    'UPDATE environments SET name = ?, updated_at = ? WHERE id = ?',
    <Object?>[name.trim(), DateTime.now(), id],
  );
  Future<void> setActiveEnvironment(
    String workspaceId,
    String id,
  ) async => _database.transaction(() async {
    await _execute(
      'UPDATE environments SET is_active = 0 WHERE workspace_id = ?',
      <Object?>[workspaceId],
    );
    await _execute(
      'UPDATE environments SET is_active = 1 WHERE id = ? AND workspace_id = ?',
      <Object?>[id, workspaceId],
    );
  });

  Future<EnvironmentModel> duplicateEnvironment(String id) async {
    final row = await _database
        .customSelect(
          'SELECT * FROM environments WHERE id = ?',
          variables: <Variable>[Variable.withString(id)],
        )
        .getSingle();
    final copy = await createEnvironment(
      row.read<String>('workspace_id'),
      '${row.read<String>('name')} copy',
      EnvironmentKind.values.byName(row.read<String>('kind')),
    );
    for (final variable in await environmentVariables(id)) {
      final value = variable.isSecret && variable.secretRef != null
          ? await _secureStorage.readSecret(variable.secretRef!) ?? ''
          : variable.value;
      await saveEnvironmentVariable(
        copy.id,
        key: variable.key,
        value: value,
        isSecret: variable.isSecret,
        enabled: variable.enabled,
      );
    }
    return copy;
  }

  Future<List<EnvironmentVariableModel>> environmentVariables(
    String environmentId,
  ) async {
    final rows = await _database
        .customSelect(
          'SELECT * FROM environment_variables WHERE environment_id = ? ORDER BY sort_order, name',
          variables: <Variable>[Variable.withString(environmentId)],
        )
        .get();
    return rows
        .map(
          (row) => EnvironmentVariableModel(
            id: row.read<String>('id'),
            environmentId: environmentId,
            key: row.read<String>('name'),
            value: row.read<bool>('is_secret')
                ? ''
                : row.read<String>('value_or_secret_ref'),
            isSecret: row.read<bool>('is_secret'),
            secretRef: row.read<bool>('is_secret')
                ? row.read<String>('value_or_secret_ref')
                : null,
            enabled: row.read<bool>('enabled'),
            sortOrder: row.read<int>('sort_order'),
          ),
        )
        .toList();
  }

  Future<({Map<String, String> values, Set<String> secretKeys})>
  executionEnvironment(String environmentId) async {
    final values = <String, String>{};
    final secretKeys = <String>{};
    for (final variable in await environmentVariables(environmentId)) {
      if (!variable.enabled) continue;
      if (variable.isSecret && variable.secretRef != null) {
        values[variable.key] =
            await _secureStorage.readSecret(variable.secretRef!) ?? '';
        secretKeys.add(variable.key);
      } else {
        values[variable.key] = variable.value;
      }
    }
    return (values: values, secretKeys: secretKeys);
  }

  Future<EnvironmentVariableModel> saveEnvironmentVariable(
    String environmentId, {
    String? id,
    required String key,
    required String value,
    bool isSecret = false,
    bool enabled = true,
    int? sortOrder,
  }) async {
    final variableId = id ?? _ids.v4();
    final existing = id == null
        ? null
        : await _database
              .customSelect(
                'SELECT value_or_secret_ref, is_secret FROM environment_variables WHERE id = ?',
                variables: <Variable>[Variable.withString(id)],
              )
              .getSingleOrNull();
    var stored = value;
    String? secretRef;
    if (isSecret) {
      secretRef = existing?.read<bool>('is_secret') == true
          ? existing!.read<String>('value_or_secret_ref')
          : 'environment.$environmentId.$variableId';
      if (value.isNotEmpty) {
        await _secureStorage.writeSecret(secretRef, value);
      }
      stored = secretRef;
    } else if (existing?.read<bool>('is_secret') == true) {
      await _secureStorage.deleteSecret(
        existing!.read<String>('value_or_secret_ref'),
      );
    }
    final order = sortOrder ?? DateTime.now().microsecondsSinceEpoch;
    await _execute(
      'INSERT OR REPLACE INTO environment_variables (id, environment_id, name, value_or_secret_ref, is_secret, enabled, sort_order) VALUES (?, ?, ?, ?, ?, ?, ?)',
      <Object?>[
        variableId,
        environmentId,
        key.trim(),
        stored,
        isSecret,
        enabled,
        order,
      ],
    );
    return EnvironmentVariableModel(
      id: variableId,
      environmentId: environmentId,
      key: key.trim(),
      value: isSecret ? '' : value,
      isSecret: isSecret,
      secretRef: secretRef,
      enabled: enabled,
      sortOrder: order,
    );
  }

  Future<void> reorderEnvironmentVariable(String id, int order) => _execute(
    'UPDATE environment_variables SET sort_order = ? WHERE id = ?',
    <Object?>[order, id],
  );
  Future<void> deleteEnvironmentVariable(String id) async {
    final row = await _database
        .customSelect(
          'SELECT value_or_secret_ref, is_secret FROM environment_variables WHERE id = ?',
          variables: <Variable>[Variable.withString(id)],
        )
        .getSingleOrNull();
    await _execute('DELETE FROM environment_variables WHERE id = ?', <Object?>[
      id,
    ]);
    if (row?.read<bool>('is_secret') == true) {
      await _secureStorage.deleteSecret(
        row!.read<String>('value_or_secret_ref'),
      );
    }
  }

  Future<void> deleteEnvironment(String id) async {
    for (final variable in await environmentVariables(id)) {
      await deleteEnvironmentVariable(variable.id);
    }
    await _execute('DELETE FROM environments WHERE id = ?', <Object?>[id]);
  }

  Map<String, Object?> _requestPayload(ApiRequestModel request) =>
      <String, Object?>{
        'id': request.id,
        'name': request.name,
        'url': request.url,
        'method': request.method.name,
        'collectionId': request.collectionId,
        'folderId': request.folderId,
        'sortOrder': request.sortOrder,
        'createdAt': request.createdAt.toIso8601String(),
        'updatedAt': request.updatedAt.toIso8601String(),
        'headers': request.headers
            .map(
              (item) => <String, Object?>{
                'key': item.key,
                'value': item.isSecret ? '' : item.value,
                'enabled': item.enabled,
                'isSecret': item.isSecret,
                'secretRef': item.secretRef,
              },
            )
            .toList(),
        'query': request.queryParams
            .map(
              (item) => <String, Object?>{
                'key': item.key,
                'value': item.value,
                'enabled': item.enabled,
              },
            )
            .toList(),
        'body': request.body == null
            ? null
            : <String, Object?>{
                'type': request.body!.type.name,
                'content': request.body!.content,
                'contentType': request.body!.contentType,
                'filePath': request.body!.filePath,
              },
        'auth': <String, Object?>{
          'type': request.auth.type.name,
          'username': request.auth.username,
          'passwordSecretRef': request.auth.passwordSecretRef,
          'tokenSecretRef': request.auth.tokenSecretRef,
          'apiKeyName': request.auth.apiKeyName,
          'apiKeySecretRef': request.auth.apiKeySecretRef,
        },
        'settings': <String, Object?>{
          'connectTimeoutMs': request.settings.connectTimeoutMs,
          'sendTimeoutMs': request.settings.sendTimeoutMs,
          'receiveTimeoutMs': request.settings.receiveTimeoutMs,
          'followRedirects': request.settings.followRedirects,
          'maxRedirects': request.settings.maxRedirects,
          'verifyCertificates': request.settings.verifyCertificates,
        },
      };

  ApiRequestModel _requestFromPayload(Map<String, dynamic> data) {
    final headers = ((data['headers'] as List?) ?? const <Object>[]).map((raw) {
      final item = (raw as Map).cast<String, dynamic>();
      return RequestHeaderModel(
        key: item['key'] as String? ?? '',
        value: item['value'] as String? ?? '',
        enabled: item['enabled'] as bool? ?? true,
        isSecret: item['isSecret'] as bool? ?? false,
        secretRef: item['secretRef'] as String?,
      );
    }).toList();
    final query = ((data['query'] as List?) ?? const <Object>[]).map((raw) {
      final item = (raw as Map).cast<String, dynamic>();
      return RequestQueryParamModel(
        key: item['key'] as String? ?? '',
        value: item['value'] as String? ?? '',
        enabled: item['enabled'] as bool? ?? true,
      );
    }).toList();
    final bodyData = (data['body'] as Map?)?.cast<String, dynamic>();
    final authData =
        (data['auth'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final settingsData =
        (data['settings'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final now = DateTime.now();
    return ApiRequestModel(
      id: data['id'] as String? ?? _ids.v4(),
      name: data['name'] as String? ?? 'Untitled request',
      url: data['url'] as String? ?? '',
      method: HttpMethod.values.byName(data['method'] as String? ?? 'get'),
      collectionId: data['collectionId'] as String?,
      folderId: data['folderId'] as String?,
      sortOrder: data['sortOrder'] as int? ?? 0,
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? '') ?? now,
      updatedAt: DateTime.tryParse(data['updatedAt'] as String? ?? '') ?? now,
      headers: headers,
      queryParams: query,
      body: bodyData == null
          ? null
          : RequestBodyModel(
              type: RequestBodyType.values.byName(
                bodyData['type'] as String? ?? 'none',
              ),
              content: bodyData['content'] as String? ?? '',
              contentType: bodyData['contentType'] as String?,
              filePath: bodyData['filePath'] as String?,
            ),
      auth: RequestAuthModel(
        type: AuthType.values.byName(authData['type'] as String? ?? 'none'),
        username: authData['username'] as String? ?? '',
        passwordSecretRef: authData['passwordSecretRef'] as String?,
        tokenSecretRef: authData['tokenSecretRef'] as String?,
        apiKeyName: authData['apiKeyName'] as String? ?? '',
        apiKeySecretRef: authData['apiKeySecretRef'] as String?,
      ),
      settings: RequestSettingsModel(
        connectTimeoutMs: settingsData['connectTimeoutMs'] as int? ?? 15000,
        sendTimeoutMs: settingsData['sendTimeoutMs'] as int? ?? 30000,
        receiveTimeoutMs: settingsData['receiveTimeoutMs'] as int? ?? 30000,
        followRedirects: settingsData['followRedirects'] as bool? ?? true,
        maxRedirects: settingsData['maxRedirects'] as int? ?? 5,
        verifyCertificates: settingsData['verifyCertificates'] as bool? ?? true,
      ),
    );
  }

  Future<void> saveRequest(ApiRequestModel request) async {
    final previousRefs = await _requestSecretRefs(request.id);
    final headers = <RequestHeaderModel>[];
    for (final item in request.headers) {
      if (!item.isSecret) {
        headers.add(item);
        continue;
      }
      final reference =
          item.secretRef ?? 'request.${request.id}.header.${_ids.v4()}';
      if (item.value.isNotEmpty) {
        await _secureStorage.writeSecret(reference, item.value);
      }
      headers.add(
        RequestHeaderModel(
          key: item.key,
          value: '',
          enabled: item.enabled,
          isSecret: true,
          secretRef: reference,
        ),
      );
    }
    final safeRequest = ApiRequestModel(
      id: request.id,
      createdAt: request.createdAt,
      updatedAt: DateTime.now(),
      name: request.name,
      url: request.url,
      method: request.method,
      headers: headers,
      queryParams: request.queryParams,
      body: request.body,
      auth: request.auth,
      settings: request.settings,
      collectionId: request.collectionId,
      folderId: request.folderId,
      sortOrder: request.sortOrder,
    );
    await _database.transaction(() async {
      await _execute(
        'INSERT OR REPLACE INTO requests (id, collection_id, folder_id, name, method, url, created_at, updated_at, sort_order, payload_json) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        <Object?>[
          safeRequest.id,
          safeRequest.collectionId,
          safeRequest.folderId,
          safeRequest.name,
          safeRequest.method.name,
          safeRequest.url,
          safeRequest.createdAt,
          safeRequest.updatedAt,
          safeRequest.sortOrder,
          jsonEncode(_requestPayload(safeRequest)),
        ],
      );
      await _execute(
        'DELETE FROM request_headers WHERE request_id = ?',
        <Object?>[safeRequest.id],
      );
      await _execute(
        'DELETE FROM request_query_params WHERE request_id = ?',
        <Object?>[safeRequest.id],
      );
      await _execute(
        'DELETE FROM request_bodies WHERE request_id = ?',
        <Object?>[safeRequest.id],
      );
      for (final item in headers) {
        await _execute(
          'INSERT INTO request_headers (id, request_id, name, value_or_secret_ref, is_secret, enabled) VALUES (?, ?, ?, ?, ?, ?)',
          <Object?>[
            _ids.v4(),
            safeRequest.id,
            item.key,
            item.isSecret ? item.secretRef : item.value,
            item.isSecret,
            item.enabled,
          ],
        );
      }
      for (final item in safeRequest.queryParams) {
        await _execute(
          'INSERT INTO request_query_params (id, request_id, name, value, enabled) VALUES (?, ?, ?, ?, ?)',
          <Object?>[
            _ids.v4(),
            safeRequest.id,
            item.key,
            item.value,
            item.enabled,
          ],
        );
      }
      if (safeRequest.body != null) {
        await _execute(
          'INSERT INTO request_bodies (id, request_id, type, content_or_secret_ref) VALUES (?, ?, ?, ?)',
          <Object?>[
            _ids.v4(),
            safeRequest.id,
            safeRequest.body!.type.name,
            safeRequest.body!.content,
          ],
        );
      }
    });
    final retainedRefs = <String>{
      ...headers
          .where((item) => item.secretRef != null)
          .map((item) => item.secretRef!),
      ...<String?>[
        safeRequest.auth.passwordSecretRef,
        safeRequest.auth.tokenSecretRef,
        safeRequest.auth.apiKeySecretRef,
      ].whereType<String>(),
    };
    for (final reference in previousRefs.difference(retainedRefs)) {
      await _secureStorage.deleteSecret(reference);
    }
  }

  Future<List<ApiRequestModel>> savedRequests(
    String workspaceId, {
    String search = '',
    String? collectionId,
  }) async {
    final whereCollection = collectionId == null
        ? ''
        : ' AND r.collection_id = ?';
    final rows = await _database
        .customSelect(
          'SELECT r.payload_json FROM requests r JOIN collections c ON c.id = r.collection_id WHERE c.workspace_id = ? AND (r.name LIKE ? OR r.url LIKE ?)$whereCollection ORDER BY r.sort_order, r.name',
          variables: <Variable>[
            Variable.withString(workspaceId),
            Variable.withString('%${search.trim()}%'),
            Variable.withString('%${search.trim()}%'),
            if (collectionId != null) Variable.withString(collectionId),
          ],
        )
        .get();
    return rows
        .map(
          (row) => _requestFromPayload(
            jsonDecode(row.read<String>('payload_json'))
                as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<ApiRequestModel?> requestById(String id) async {
    final row = await _database
        .customSelect(
          'SELECT payload_json FROM requests WHERE id = ?',
          variables: <Variable>[Variable.withString(id)],
        )
        .getSingleOrNull();
    return row == null
        ? null
        : _requestFromPayload(
            jsonDecode(row.read<String>('payload_json'))
                as Map<String, dynamic>,
          );
  }

  Future<ApiRequestModel> duplicateRequest(
    String id, {
    String? collectionId,
    String? folderId,
  }) async {
    final source = await requestById(id);
    if (source == null) throw StateError('Request not found.');
    final now = DateTime.now();
    final copiedHeaders = <RequestHeaderModel>[];
    for (final header in source.headers) {
      if (header.isSecret && header.secretRef != null) {
        copiedHeaders.add(
          RequestHeaderModel(
            key: header.key,
            value: await _secureStorage.readSecret(header.secretRef!) ?? '',
            enabled: header.enabled,
            isSecret: true,
          ),
        );
      } else {
        copiedHeaders.add(header);
      }
    }
    Future<String?> copyAuthSecret(String? sourceRef, String suffix) async {
      if (sourceRef == null) return null;
      final newRef = 'request.${_ids.v4()}.auth.$suffix';
      await _secureStorage.writeSecret(
        newRef,
        await _secureStorage.readSecret(sourceRef) ?? '',
      );
      return newRef;
    }

    final copiedAuth = RequestAuthModel(
      type: source.auth.type,
      username: source.auth.username,
      passwordSecretRef: await copyAuthSecret(
        source.auth.passwordSecretRef,
        'basic',
      ),
      tokenSecretRef: await copyAuthSecret(
        source.auth.tokenSecretRef,
        'bearer',
      ),
      apiKeyName: source.auth.apiKeyName,
      apiKeySecretRef: await copyAuthSecret(
        source.auth.apiKeySecretRef,
        'apiKey',
      ),
    );
    final copy = ApiRequestModel(
      id: _ids.v4(),
      createdAt: now,
      updatedAt: now,
      name: '${source.name} copy',
      url: source.url,
      method: source.method,
      headers: copiedHeaders,
      queryParams: source.queryParams,
      body: source.body,
      auth: copiedAuth,
      settings: source.settings,
      collectionId: collectionId ?? source.collectionId,
      folderId: folderId ?? source.folderId,
      sortOrder: now.microsecondsSinceEpoch,
    );
    await saveRequest(copy);
    return copy;
  }

  Future<void> moveRequest(
    String id, {
    required String collectionId,
    String? folderId,
  }) async {
    final source = await requestById(id);
    if (source == null) return;
    await saveRequest(
      ApiRequestModel(
        id: source.id,
        createdAt: source.createdAt,
        updatedAt: DateTime.now(),
        name: source.name,
        url: source.url,
        method: source.method,
        headers: source.headers,
        queryParams: source.queryParams,
        body: source.body,
        auth: source.auth,
        settings: source.settings,
        collectionId: collectionId,
        folderId: folderId,
        sortOrder: source.sortOrder,
      ),
    );
  }

  Future<void> reorderRequest(String id, int order) => _execute(
    'UPDATE requests SET sort_order = ?, updated_at = ? WHERE id = ?',
    <Object?>[order, DateTime.now(), id],
  );

  Future<Set<String>> _requestSecretRefs(String id) async {
    final refs = <String>{};
    final request = await requestById(id);
    if (request != null) {
      refs.addAll(
        request.headers
            .where((item) => item.isSecret && item.secretRef != null)
            .map((item) => item.secretRef!),
      );
      for (final ref in <String?>[
        request.auth.passwordSecretRef,
        request.auth.tokenSecretRef,
        request.auth.apiKeySecretRef,
      ]) {
        if (ref != null) {
          refs.add(ref);
        }
      }
    }
    return refs;
  }

  Future<Set<String>> executionRequestSecrets(ApiRequestModel request) async {
    final values = <String>{};
    final references = <String>{
      ...request.headers
          .where((item) => item.isSecret && item.secretRef != null)
          .map((item) => item.secretRef!),
      ...<String?>[
        request.auth.passwordSecretRef,
        request.auth.tokenSecretRef,
        request.auth.apiKeySecretRef,
      ].whereType<String>(),
    };
    for (final reference in references) {
      final value = await _secureStorage.readSecret(reference);
      if (value != null && value.isNotEmpty) values.add(value);
    }
    return values;
  }

  Future<void> deleteRequest(String id) async {
    final refs = await _requestSecretRefs(id);
    await _database.transaction(() async {
      await _execute(
        'DELETE FROM request_headers WHERE request_id = ?',
        <Object?>[id],
      );
      await _execute(
        'DELETE FROM request_query_params WHERE request_id = ?',
        <Object?>[id],
      );
      await _execute(
        'DELETE FROM request_bodies WHERE request_id = ?',
        <Object?>[id],
      );
      await _execute(
        'DELETE FROM request_drafts WHERE request_id = ?',
        <Object?>[id],
      );
      await _execute('DELETE FROM requests WHERE id = ?', <Object?>[id]);
    });
    for (final ref in refs) {
      await _secureStorage.deleteSecret(ref);
    }
  }

  Future<void> saveDraft(ApiRequestModel request) => _execute(
    'INSERT OR REPLACE INTO request_drafts (id, request_id, title, payload_json, updated_at) VALUES (?, ?, ?, ?, ?)',
    <Object?>[
      'active-${request.id}',
      request.id,
      request.name,
      jsonEncode(_requestPayload(request)),
      DateTime.now(),
    ],
  );
  Future<List<ApiRequestModel>> drafts() async {
    final rows = await _database
        .customSelect(
          'SELECT payload_json FROM request_drafts ORDER BY updated_at',
        )
        .get();
    return rows
        .map(
          (row) => _requestFromPayload(
            jsonDecode(row.read<String>('payload_json'))
                as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> deleteDraft(String requestId) => _execute(
    'DELETE FROM request_drafts WHERE request_id = ?',
    <Object?>[requestId],
  );

  Future<void> recordHistory(
    ApiRequestModel request,
    ApiResponseModel response, {
    Set<String> sensitiveValues = const <String>{},
  }) async {
    final id = _ids.v4();
    final now = DateTime.now();
    final safeResponseHeaders = SecretMasker.redactHeaders(response.headers);
    var responseBody = response.body;
    for (final sensitive in sensitiveValues.where(
      (value) => value.isNotEmpty,
    )) {
      responseBody = responseBody.replaceAll(sensitive, '[REDACTED]');
    }
    final safeBody = SecretMasker.redactText(
      responseBody.length > 262144
          ? '${responseBody.substring(0, 262144)}\n[truncated]'
          : responseBody,
    );
    final snapshot = <String, Object?>{
      'request': _requestPayload(request),
      'method': request.method.name,
      'url': request.url,
      'requestHeaders': SecretMasker.redactHeaders(<String, String>{
        for (final item in request.headers)
          item.key: item.isSecret ? '[REDACTED]' : item.value,
      }),
      'status': response.statusCode,
      'statusMessage': response.statusMessage,
      'durationMs': response.durationMs,
      'sizeBytes': response.sizeBytes,
      'responseHeaders': safeResponseHeaders,
      'cookies': response.cookies.map((_) => '[REDACTED]').toList(),
      'body': safeBody,
      'error': response.error,
      'category': response.errorCategory,
      'truncated': response.isTruncated,
      'recordedAt': now.toIso8601String(),
    };
    await _database.transaction(() async {
      await _execute(
        'INSERT INTO response_snapshots (id, request_id, status_code, body_preview, duration_ms, created_at) VALUES (?, ?, ?, ?, ?, ?)',
        <Object?>[
          id,
          request.id,
          response.statusCode,
          safeBody,
          response.durationMs,
          now,
        ],
      );
      await _execute(
        'INSERT INTO request_history (id, request_id, response_snapshot_id, created_at, snapshot_json) VALUES (?, ?, ?, ?, ?)',
        <Object?>[id, request.id, id, now, jsonEncode(snapshot)],
      );
    });
  }

  Future<List<HistoryEntry>> history({
    String search = '',
    String? method,
    int? minimumStatus,
    String? failureCategory,
    DateTime? after,
  }) async {
    final rows = await _database
        .customSelect('SELECT * FROM request_history ORDER BY created_at DESC')
        .get();
    return rows
        .map((row) {
          final snapshot =
              jsonDecode(row.read<String>('snapshot_json'))
                  as Map<String, dynamic>;
          return HistoryEntry(
            id: row.read<String>('id'),
            requestId: row.read<String>('request_id'),
            createdAt: row.read<DateTime>('created_at'),
            method: snapshot['method'] as String? ?? 'get',
            url: snapshot['url'] as String? ?? '',
            status: snapshot['status'] as int?,
            durationMs: snapshot['durationMs'] as int? ?? 0,
            snapshot: snapshot,
          );
        })
        .where(
          (item) =>
              (search.isEmpty ||
                  jsonEncode(
                    item.snapshot,
                  ).toLowerCase().contains(search.toLowerCase())) &&
              (method == null || item.method == method) &&
              (minimumStatus == null || (item.status ?? 0) >= minimumStatus) &&
              (failureCategory == null ||
                  item.snapshot['category'] == failureCategory) &&
              (after == null || item.createdAt.isAfter(after)),
        )
        .toList();
  }

  Future<ApiRequestModel?> replayHistory(String historyId) async {
    final row = await _database
        .customSelect(
          'SELECT snapshot_json FROM request_history WHERE id = ?',
          variables: <Variable>[Variable.withString(historyId)],
        )
        .getSingleOrNull();
    if (row == null) return null;
    final snapshot =
        jsonDecode(row.read<String>('snapshot_json')) as Map<String, dynamic>;
    final requestData = (snapshot['request'] as Map?)?.cast<String, dynamic>();
    if (requestData == null) return null;
    requestData['id'] = _ids.v4();
    requestData['name'] = '${requestData['name'] ?? 'Request'} replay';
    requestData['updatedAt'] = DateTime.now().toIso8601String();
    return _requestFromPayload(requestData);
  }

  Future<void> deleteHistory(
    String id,
  ) async => _database.transaction(() async {
    await _execute(
      'DELETE FROM response_snapshots WHERE id = (SELECT response_snapshot_id FROM request_history WHERE id = ?)',
      <Object?>[id],
    );
    await _execute('DELETE FROM request_history WHERE id = ?', <Object?>[id]);
  });
  Future<void> clearHistory() async => _database.transaction(() async {
    await _execute('DELETE FROM request_history');
    await _execute('DELETE FROM response_snapshots');
  });
  Future<void> applyHistoryRetention(WorkspaceSettingsModel settings) async {
    final cutoff = DateTime.now().subtract(
      Duration(days: settings.historyRetentionDays),
    );
    await _execute(
      'DELETE FROM request_history WHERE created_at < ?',
      <Object?>[cutoff],
    );
    await _execute(
      'DELETE FROM request_history WHERE id IN (SELECT id FROM request_history ORDER BY created_at DESC LIMIT -1 OFFSET ?)',
      <Object?>[settings.historyMaximumCount],
    );
    await _execute(
      'DELETE FROM response_snapshots WHERE id NOT IN (SELECT response_snapshot_id FROM request_history)',
    );
  }
}

class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.requestId,
    required this.createdAt,
    required this.method,
    required this.url,
    required this.status,
    required this.durationMs,
    required this.snapshot,
  });
  final String id;
  final String requestId;
  final DateTime createdAt;
  final String method;
  final String url;
  final int? status;
  final int durationMs;
  final Map<String, dynamic> snapshot;
}
