import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/security/secret_masker.dart';
import '../../../core/storage/database_schema.dart';
import '../../../shared/models/api_models.dart';
import '../domain/graphql_models.dart';

class GraphqlDraft {
  const GraphqlDraft({
    required this.id,
    required this.workspaceId,
    required this.title,
    required this.request,
    required this.updatedAt,
  });
  final String id;
  final String workspaceId;
  final String title;
  final GraphqlRequest request;
  final DateTime updatedAt;
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

class GraphqlRepository {
  GraphqlRepository(this._database);
  final AppDatabase _database;
  static const _ids = Uuid();

  Future<GraphqlDraft> saveDraft({
    String? id,
    required String workspaceId,
    required String title,
    required GraphqlRequest request,
  }) async {
    final draft = GraphqlDraft(
      id: id ?? _ids.v4(),
      workspaceId: workspaceId,
      title: title,
      request: request,
      updatedAt: DateTime.now(),
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
        _safeJson(request.variables),
        _safeJson(request.headers),
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
          .map(
            (r) => GraphqlDraft(
              id: r.read<String>('id'),
              workspaceId: workspaceId,
              title: r.read<String>('title'),
              updatedAt: r.read<DateTime>('updated_at'),
              request: GraphqlRequest(
                endpoint: r.read<String>('endpoint'),
                document: r.read<String>('document'),
                operationName: r.read<String?>('operation_name'),
                variables: (jsonDecode(r.read<String>('variables_json')) as Map)
                    .cast<String, Object?>(),
                headers: (jsonDecode(r.read<String>('headers_json')) as Map)
                    .map((k, v) => MapEntry(k.toString(), v.toString())),
              ),
            ),
          )
          .toList();

  Future<void> record({
    String? draftId,
    required String workspaceId,
    required GraphqlOperationType type,
    required GraphqlResponse response,
  }) => _database.customStatement(
    'INSERT INTO graphql_history (id, draft_id, workspace_id, operation_type, summary_json, created_at) VALUES (?, ?, ?, ?, ?, ?)',
    <Object?>[
      _ids.v4(),
      draftId,
      workspaceId,
      type.name,
      SecretMasker.redactText(response.safeJson),
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
    ],
  );

  String _safeJson(Object value) => SecretMasker.redactText(jsonEncode(value));

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
  });

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
