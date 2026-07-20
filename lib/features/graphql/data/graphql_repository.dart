import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/security/secret_masker.dart';
import '../../../core/storage/database_schema.dart';
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
    final now = DateTime.now();
    final requestId = id ?? _ids.v4();
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
        now.millisecondsSinceEpoch ~/ 1000,
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
  });
}
