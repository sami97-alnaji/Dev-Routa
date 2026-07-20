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
}
