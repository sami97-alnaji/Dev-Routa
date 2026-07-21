import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/security/secret_masker.dart';
import '../../../core/storage/database_schema.dart';
import '../../../shared/models/api_models.dart';
import '../../../shared/services/service_interfaces.dart';
import '../domain/graphql_models.dart';

class GraphqlDraft {
  const GraphqlDraft({
    required this.id,
    required this.workspaceId,
    required this.title,
    required this.request,
    required this.updatedAt,
    this.savedRequestId,
    this.environmentId,
    this.sortOrder = 0,
    this.isActive = false,
    this.isDirty = true,
  });
  final String id;
  final String workspaceId;
  final String title;
  final GraphqlRequest request;
  final DateTime updatedAt;
  final String? savedRequestId;
  final String? environmentId;
  final int sortOrder;
  final bool isActive;
  final bool isDirty;
}

class GraphqlSavedRequest {
  const GraphqlSavedRequest({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.request,
    this.collectionId,
    this.folderId,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });
  final String id;
  final String workspaceId;
  final String name;
  final GraphqlRequest request;
  final String? collectionId;
  final String? folderId;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class GraphqlHistoryEntry {
  const GraphqlHistoryEntry({
    required this.id,
    required this.draftId,
    required this.workspaceId,
    required this.operationType,
    required this.summary,
    required this.createdAt,
  });
  final String id;
  final String? draftId;
  final String workspaceId;
  final GraphqlOperationType operationType;
  final Map<String, Object?> summary;
  final DateTime createdAt;
}

class GraphqlRepository {
  GraphqlRepository(this._database, {SecureStorageService? secureStorage})
    : _secureStorage = secureStorage;
  final AppDatabase _database;
  final SecureStorageService? _secureStorage;
  static const _ids = Uuid();

  Future<Map<String, String>> executionEnvironment(String environmentId) async {
    final rows = await _database
        .customSelect(
          'SELECT name, value_or_secret_ref, is_secret, enabled FROM environment_variables WHERE environment_id = ? ORDER BY sort_order, name',
          variables: <Variable>[Variable.withString(environmentId)],
        )
        .get();
    final values = <String, String>{};
    for (final row in rows) {
      if (!row.read<bool>('enabled')) continue;
      final key = row.read<String>('name');
      if (!row.read<bool>('is_secret')) {
        values[key] = row.read<String>('value_or_secret_ref');
        continue;
      }
      final reference = row.read<String>('value_or_secret_ref');
      final value = await _secureStorage?.readSecret(reference);
      if (value == null || value.isEmpty) {
        throw StateError('Missing secure environment reference for $key.');
      }
      values[key] = value;
    }
    return values;
  }

  Future<GraphqlDraft> saveDraft({
    String? id,
    required String workspaceId,
    required String title,
    required GraphqlRequest request,
    String? savedRequestId,
    String? environmentId,
    int sortOrder = 0,
    bool isActive = false,
    bool isDirty = true,
  }) async {
    final draft = GraphqlDraft(
      id: id ?? _ids.v4(),
      workspaceId: workspaceId,
      title: title,
      request: request,
      updatedAt: DateTime.now(),
      savedRequestId: savedRequestId,
      environmentId: environmentId,
      sortOrder: sortOrder,
      isActive: isActive,
      isDirty: isDirty,
    );
    await _database.customStatement(
      'INSERT OR REPLACE INTO graphql_drafts (id, workspace_id, title, endpoint, document, operation_name, variables_json, headers_json, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      <Object?>[
        draft.id,
        workspaceId,
        title,
        request.endpoint,
        request.document,
        request.operationName,
        jsonEncode(request.variables),
        _draftPayload(draft),
        draft.updatedAt.millisecondsSinceEpoch ~/ 1000,
      ],
    );
    return draft;
  }

  Future<List<GraphqlDraft>> drafts(String workspaceId) async =>
      (await _database
              .customSelect(
                'SELECT * FROM graphql_drafts WHERE workspace_id = ? ORDER BY updated_at DESC',
                variables: <Variable>[Variable.withString(workspaceId)],
              )
              .get())
          .map(_draftFromRow)
          .toList();

  Future<void> deleteDraft(String id) => _database.customStatement(
    'DELETE FROM graphql_drafts WHERE id = ?',
    <Object?>[id],
  );

  Future<void> record({
    String? draftId,
    required String workspaceId,
    required GraphqlOperationType type,
    required GraphqlResponse response,
    GraphqlRequest? request,
    String? operationName,
  }) => _database.customStatement(
    'INSERT INTO graphql_history (id, draft_id, workspace_id, operation_type, summary_json, created_at) VALUES (?, ?, ?, ?, ?, ?)',
    <Object?>[
      _ids.v4(),
      draftId,
      workspaceId,
      type.name,
      SecretMasker.redactText(
        jsonEncode(<String, Object?>{
          'request': request == null
              ? null
              : <String, Object?>{
                  'endpoint': request.endpoint,
                  'document': request.document,
                  'operationName': operationName ?? request.operationName,
                  'variables': request.variables,
                  'extensions': request.extensions,
                  'headers': SecretMasker.redactHeaders(request.headers),
                  'useGet': request.useGet,
                  'authType': request.auth.type.name,
                  'environmentId': null,
                },
          'statusCode': response.statusCode,
          'completion': response.completion.name,
          'data': response.data,
          'errors': response.errors.map((item) => item.toJson()).toList(),
          'extensions': response.extensions,
          'headers': response.headers,
          'durationMs': response.duration.inMilliseconds,
          'sizeBytes': response.sizeBytes,
          'rawPreview': response.rawPreview,
          'truncated': response.truncated,
        }),
      ),
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
    ],
  );

  Future<List<GraphqlHistoryEntry>> history(
    String workspaceId, {
    String query = '',
    GraphqlOperationType? operationType,
  }) async {
    final rows = await _database
        .customSelect(
          'SELECT * FROM graphql_history WHERE workspace_id = ? ORDER BY created_at DESC',
          variables: <Variable>[Variable.withString(workspaceId)],
        )
        .get();
    final normalized = query.trim().toLowerCase();
    return rows
        .map(
          (row) => GraphqlHistoryEntry(
            id: row.read<String>('id'),
            draftId: row.read<String?>('draft_id'),
            workspaceId: row.read<String>('workspace_id'),
            operationType: GraphqlOperationType.values.byName(
              row.read<String>('operation_type'),
            ),
            summary: _jsonMap(row.read<String>('summary_json')),
            createdAt: row.read<DateTime>('created_at'),
          ),
        )
        .where(
          (entry) =>
              (operationType == null || entry.operationType == operationType) &&
              (normalized.isEmpty ||
                  jsonEncode(entry.summary).toLowerCase().contains(normalized)),
        )
        .toList(growable: false);
  }

  Future<void> deleteHistory(String id) => _database.customStatement(
    'DELETE FROM graphql_history WHERE id = ?',
    <Object?>[id],
  );

  Future<void> clearHistory({String? workspaceId}) => workspaceId == null
      ? _database.customStatement('DELETE FROM graphql_history')
      : _database.customStatement(
          'DELETE FROM graphql_history WHERE workspace_id = ?',
          <Object?>[workspaceId],
        );

  Future<void> applyHistoryRetention({
    required String workspaceId,
    int maximumCount = 1000,
    Duration maximumAge = const Duration(days: 30),
  }) async {
    final cutoff = DateTime.now().subtract(maximumAge);
    await _database.customStatement(
      'DELETE FROM graphql_history WHERE workspace_id = ? AND created_at < ?',
      <Object?>[workspaceId, cutoff.millisecondsSinceEpoch ~/ 1000],
    );
    await _database.customStatement(
      '''DELETE FROM graphql_history WHERE workspace_id = ? AND id NOT IN
         (SELECT id FROM graphql_history WHERE workspace_id = ? ORDER BY created_at DESC LIMIT ?)''',
      <Object?>[workspaceId, workspaceId, maximumCount],
    );
  }

  String _draftPayload(GraphqlDraft draft) => jsonEncode(<String, Object?>{
    'headers': draft.request.headers,
    'extensions': draft.request.extensions,
    'auth': _authJson(draft.request.auth),
    'settings': _settingsJson(draft.request.settings),
    'savedRequestId': draft.savedRequestId,
    'environmentId': draft.environmentId,
    'sortOrder': draft.sortOrder,
    'isActive': draft.isActive,
    'isDirty': draft.isDirty,
  });

  GraphqlDraft _draftFromRow(QueryRow row) {
    final payload = _jsonMap(row.read<String>('headers_json'));
    // v6 foundations stored a plain header map. Treat that shape as a safe
    // legacy draft while the envelope carries all tab state for new saves.
    final headers = payload['headers'] is Map
        ? _stringMap(payload['headers'])
        : _stringMap(payload);
    return GraphqlDraft(
      id: row.read<String>('id'),
      workspaceId: row.read<String>('workspace_id'),
      title: row.read<String>('title'),
      updatedAt: row.read<DateTime>('updated_at'),
      savedRequestId: payload['savedRequestId']?.toString(),
      environmentId: payload['environmentId']?.toString(),
      sortOrder: (payload['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: payload['isActive'] == true,
      isDirty: payload['isDirty'] != false,
      request: GraphqlRequest(
        endpoint: row.read<String>('endpoint'),
        document: row.read<String>('document'),
        operationName: row.read<String?>('operation_name'),
        variables: _jsonMap(row.read<String>('variables_json')),
        headers: headers,
        extensions: _jsonMap(payload['extensions']),
        auth: _authFromJson(payload['auth']),
        settings: _settingsFromJson(payload['settings']),
      ),
    );
  }

  Future<GraphqlSavedRequest> saveRequest({
    String? id,
    required String workspaceId,
    required String name,
    required GraphqlRequest request,
    String? collectionId,
    String? folderId,
    int sortOrder = 0,
  }) async {
    final now = DateTime.fromMillisecondsSinceEpoch(
      DateTime.now().millisecondsSinceEpoch ~/ 1000 * 1000,
    );
    final requestId = id ?? _ids.v4();
    final existing = id == null ? null : await requestById(id);
    await _database.customStatement(
      'INSERT OR REPLACE INTO graphql_saved_requests (id, workspace_id, collection_id, folder_id, name, payload_json, sort_order, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      <Object?>[
        requestId,
        workspaceId,
        collectionId,
        folderId,
        name,
        _requestJson(request),
        sortOrder,
        (existing?.createdAt ?? now).millisecondsSinceEpoch ~/ 1000,
        now.millisecondsSinceEpoch ~/ 1000,
      ],
    );
    return GraphqlSavedRequest(
      id: requestId,
      workspaceId: workspaceId,
      name: name,
      request: request,
      collectionId: collectionId,
      folderId: folderId,
      sortOrder: sortOrder,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<List<GraphqlSavedRequest>> requests(String workspaceId) async {
    final rows = await _database
        .customSelect(
          'SELECT * FROM graphql_saved_requests WHERE workspace_id = ? ORDER BY sort_order, updated_at DESC',
          variables: <Variable>[Variable.withString(workspaceId)],
        )
        .get();
    return rows.map(_savedFromRow).toList(growable: false);
  }

  Future<GraphqlSavedRequest?> requestById(String id) async {
    final row = await _database
        .customSelect(
          'SELECT * FROM graphql_saved_requests WHERE id = ? LIMIT 1',
          variables: <Variable>[Variable.withString(id)],
        )
        .getSingleOrNull();
    return row == null ? null : _savedFromRow(row);
  }

  Future<GraphqlSavedRequest> renameRequest(String id, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('A saved GraphQL request needs a name.');
    }
    await _database.customStatement(
      'UPDATE graphql_saved_requests SET name = ?, updated_at = ? WHERE id = ?',
      <Object?>[trimmed, DateTime.now().millisecondsSinceEpoch ~/ 1000, id],
    );
    final saved = await requestById(id);
    if (saved == null) {
      throw StateError('Saved GraphQL request $id was not found.');
    }
    return saved;
  }

  Future<GraphqlSavedRequest> duplicateRequest(
    String id, {
    String? name,
  }) async {
    final original = await requestById(id);
    if (original == null) {
      throw StateError('Saved GraphQL request $id was not found.');
    }
    return saveRequest(
      workspaceId: original.workspaceId,
      name: name?.trim().isNotEmpty == true
          ? name!.trim()
          : '${original.name} copy',
      request: original.request,
      collectionId: original.collectionId,
      folderId: original.folderId,
      sortOrder: original.sortOrder + 1,
    );
  }

  Future<List<GraphqlSavedRequest>> searchRequests(
    String workspaceId,
    String query,
  ) async {
    final escaped = query
        .trim()
        .replaceAll(r'%', r'\%')
        .replaceAll(r'_', r'\_');
    if (escaped.isEmpty) return requests(workspaceId);
    final rows = await _database
        .customSelect(
          '''SELECT * FROM graphql_saved_requests
             WHERE workspace_id = ? AND (name LIKE ? ESCAPE '\\' OR payload_json LIKE ? ESCAPE '\\')
             ORDER BY sort_order, updated_at DESC''',
          variables: <Variable>[
            Variable.withString(workspaceId),
            Variable.withString('%$escaped%'),
            Variable.withString('%$escaped%'),
          ],
        )
        .get();
    return rows.map(_savedFromRow).toList(growable: false);
  }

  Future<void> reorderRequests(
    String workspaceId,
    List<String> orderedIds,
  ) async {
    await _database.transaction(() async {
      for (var index = 0; index < orderedIds.length; index++) {
        await _database.customStatement(
          'UPDATE graphql_saved_requests SET sort_order = ?, updated_at = ? WHERE id = ? AND workspace_id = ?',
          <Object?>[
            index,
            DateTime.now().millisecondsSinceEpoch ~/ 1000,
            orderedIds[index],
            workspaceId,
          ],
        );
      }
    });
  }

  Future<void> deleteRequest(String id) => _database.customStatement(
    'DELETE FROM graphql_saved_requests WHERE id = ?',
    <Object?>[id],
  );

  Future<void> moveRequest(
    String id, {
    String? collectionId,
    String? folderId,
    int? sortOrder,
  }) => _database.customStatement(
    'UPDATE graphql_saved_requests SET collection_id = ?, folder_id = ?, sort_order = ?, updated_at = ? WHERE id = ?',
    <Object?>[
      collectionId,
      folderId,
      sortOrder ?? 0,
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      id,
    ],
  );

  GraphqlSavedRequest _savedFromRow(QueryRow row) {
    final payload = jsonDecode(row.read<String>('payload_json')) as Map;
    return GraphqlSavedRequest(
      id: row.read<String>('id'),
      workspaceId: row.read<String>('workspace_id'),
      name: row.read<String>('name'),
      collectionId: row.read<String?>('collection_id'),
      folderId: row.read<String?>('folder_id'),
      sortOrder: row.read<int>('sort_order'),
      createdAt: row.read<DateTime>('created_at'),
      updatedAt: row.read<DateTime>('updated_at'),
      request: GraphqlRequest(
        endpoint: payload['endpoint'] as String? ?? '',
        document: payload['document'] as String? ?? '',
        operationName: payload['operationName'] as String?,
        variables: (payload['variables'] as Map? ?? const <Object?, Object?>{})
            .map((k, v) => MapEntry(k.toString(), v)),
        headers: (payload['headers'] as Map? ?? const <Object?, Object?>{}).map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        ),
        useGet: payload['useGet'] == true,
        extensions:
            (payload['extensions'] as Map? ?? const <Object?, Object?>{}).map(
              (k, v) => MapEntry(k.toString(), v),
            ),
        auth: _authFromJson(payload['auth']),
        settings: _settingsFromJson(payload['settings']),
      ),
    );
  }

  String _requestJson(GraphqlRequest request) => jsonEncode(<String, Object?>{
    'endpoint': request.endpoint,
    'document': request.document,
    'operationName': request.operationName,
    'variables': request.variables,
    'headers': request.headers,
    'useGet': request.useGet,
    'extensions': request.extensions,
    'auth': _authJson(request.auth),
    'settings': _settingsJson(request.settings),
  });

  Map<String, Object?> _authJson(RequestAuthModel auth) => <String, Object?>{
    'type': auth.type.name,
    'username': auth.username,
    'passwordSecretRef': auth.passwordSecretRef,
    'tokenSecretRef': auth.tokenSecretRef,
    'apiKeyName': auth.apiKeyName,
    'apiKeySecretRef': auth.apiKeySecretRef,
  };

  Map<String, Object?> _settingsJson(RequestSettingsModel settings) =>
      <String, Object?>{
        'connectTimeoutMs': settings.connectTimeoutMs,
        'sendTimeoutMs': settings.sendTimeoutMs,
        'receiveTimeoutMs': settings.receiveTimeoutMs,
        'followRedirects': settings.followRedirects,
        'maxRedirects': settings.maxRedirects,
        'verifyCertificates': settings.verifyCertificates,
      };

  Map<String, Object?> _jsonMap(Object? value) {
    if (value is String) {
      try {
        return _jsonMap(jsonDecode(value));
      } on FormatException {
        return const <String, Object?>{};
      }
    }
    if (value is! Map) return const <String, Object?>{};
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  Map<String, String> _stringMap(Object? value) =>
      _jsonMap(value).map((key, item) => MapEntry(key, item.toString()));

  RequestAuthModel _authFromJson(Object? value) {
    final json = value is Map ? value : const <Object?, Object?>{};
    return RequestAuthModel(
      type: AuthType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => AuthType.none,
      ),
      username: json['username']?.toString() ?? '',
      passwordSecretRef: json['passwordSecretRef']?.toString(),
      tokenSecretRef: json['tokenSecretRef']?.toString(),
      apiKeyName: json['apiKeyName']?.toString() ?? '',
      apiKeySecretRef: json['apiKeySecretRef']?.toString(),
    );
  }

  RequestSettingsModel _settingsFromJson(Object? value) {
    final json = value is Map ? value : const <Object?, Object?>{};
    return RequestSettingsModel(
      connectTimeoutMs: (json['connectTimeoutMs'] as num?)?.toInt() ?? 15000,
      sendTimeoutMs: (json['sendTimeoutMs'] as num?)?.toInt() ?? 30000,
      receiveTimeoutMs: (json['receiveTimeoutMs'] as num?)?.toInt() ?? 30000,
      followRedirects: json['followRedirects'] != false,
      maxRedirects: (json['maxRedirects'] as num?)?.toInt() ?? 5,
      verifyCertificates: json['verifyCertificates'] != false,
    );
  }
}
