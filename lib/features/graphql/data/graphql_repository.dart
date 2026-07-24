import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/security/secret_masker.dart';
import '../../../core/storage/database_schema.dart';
import '../../../shared/models/api_models.dart';
import '../../../shared/services/service_interfaces.dart';
import '../domain/graphql_models.dart';
import '../domain/graphql_schema_models.dart' as schema;

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
    this.baselineFingerprint,
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

  /// Stable snapshot of all request fields that participate in dirty state.
  final String? baselineFingerprint;

  static String fingerprint(GraphqlRequest request, String? environmentId) =>
      jsonEncode(
        _canonical(<String, Object?>{
          'endpoint': request.endpoint,
          'document': request.document,
          'operationName': request.operationName,
          'variables': request.variables,
          'headers': request.headers,
          'extensions': request.extensions,
          'useGet': request.useGet,
          'environmentId': environmentId,
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
        }),
      );

  static Object? _canonical(Object? value) {
    if (value is Map) {
      final entries =
          value.entries
              .map(
                (entry) =>
                    MapEntry(entry.key.toString(), _canonical(entry.value)),
              )
              .toList()
            ..sort((a, b) => a.key.compareTo(b.key));
      return Map<String, Object?>.fromEntries(entries);
    }
    if (value is Iterable) return value.map(_canonical).toList(growable: false);
    return value;
  }
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

  /// The persisted summary deliberately has no endpoint query or fragment, so
  /// filter values and the UI cannot reveal query-string credentials.
  String get endpoint =>
      (summary['request'] as Map?)?['endpoint']?.toString() ?? '';
  String? get completionName => summary['completion']?.toString();
  GraphqlCompletionCategory? get completion => switch (completionName) {
    'success' => GraphqlCompletionCategory.success,
    'partialSuccess' => GraphqlCompletionCategory.partialSuccess,
    'graphqlFailure' => GraphqlCompletionCategory.graphqlFailure,
    'httpFailure' => GraphqlCompletionCategory.httpFailure,
    _ => null,
  };

  GraphqlHistoryOutcome get outcome {
    if (completionName == 'cancelled' ||
        summary['failureCategory'] == GraphqlFailureCategory.cancelled.name) {
      return GraphqlHistoryOutcome.cancelled;
    }
    return switch (completion) {
      GraphqlCompletionCategory.success => GraphqlHistoryOutcome.success,
      GraphqlCompletionCategory.partialSuccess ||
      GraphqlCompletionCategory.graphqlFailure =>
        GraphqlHistoryOutcome.graphqlError,
      GraphqlCompletionCategory.httpFailure =>
        GraphqlHistoryOutcome.transportFailure,
      null => GraphqlHistoryOutcome.unknown,
    };
  }
}

enum GraphqlHistoryOutcome {
  success,
  graphqlError,
  transportFailure,
  cancelled,
  unknown,
}

class GraphqlStoredSchemaSnapshot {
  const GraphqlStoredSchemaSnapshot({
    required this.id,
    required this.workspaceId,
    required this.endpointFingerprint,
    required this.snapshot,
    required this.createdAt,
  });
  final String id;
  final String workspaceId;
  final String endpointFingerprint;
  final schema.GraphqlSchemaSnapshot snapshot;
  final DateTime createdAt;
}

class GraphqlRepository {
  GraphqlRepository(this._database, {SecureStorageService? secureStorage})
    : _secureStorage = secureStorage;
  final AppDatabase _database;
  final SecureStorageService? _secureStorage;
  static const _ids = Uuid();

  Future<GraphqlStoredSchemaSnapshot> saveSchemaSnapshot({
    required String workspaceId,
    required String endpoint,
    required schema.GraphqlSchemaSnapshot snapshot,
  }) async {
    final fingerprint = sha256.convert(utf8.encode(endpoint)).toString();
    final existing = await _database
        .customSelect(
          'SELECT * FROM graphql_schema_snapshots WHERE workspace_id = ? AND endpoint_fingerprint = ? AND schema_hash = ? LIMIT 1',
          variables: <Variable>[
            Variable.withString(workspaceId),
            Variable.withString(fingerprint),
            Variable.withString(snapshot.hash),
          ],
        )
        .getSingleOrNull();
    if (existing != null) return _schemaFromRow(existing);
    final id = _ids.v4();
    final now = DateTime.now();
    await _database.customStatement(
      'INSERT INTO graphql_schema_snapshots (id, workspace_id, endpoint_fingerprint, schema_hash, snapshot_json, fetched_at) VALUES (?, ?, ?, ?, ?, ?)',
      <Object?>[
        id,
        workspaceId,
        fingerprint,
        snapshot.hash,
        snapshot.safeJson,
        now.millisecondsSinceEpoch ~/ 1000,
      ],
    );
    return GraphqlStoredSchemaSnapshot(
      id: id,
      workspaceId: workspaceId,
      endpointFingerprint: fingerprint,
      snapshot: snapshot,
      createdAt: now,
    );
  }

  Future<List<GraphqlStoredSchemaSnapshot>> schemaSnapshots(
    String workspaceId,
  ) async =>
      (await _database
              .customSelect(
                'SELECT * FROM graphql_schema_snapshots WHERE workspace_id = ? ORDER BY fetched_at DESC',
                variables: <Variable>[Variable.withString(workspaceId)],
              )
              .get())
          .map(_schemaFromRow)
          .toList(growable: false);

  Future<void> deleteSchemaSnapshot(String id) => _database.customStatement(
    'DELETE FROM graphql_schema_snapshots WHERE id = ?',
    <Object?>[id],
  );

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

  Future<Set<String>> executionEnvironmentSecretValues(
    String environmentId,
  ) async {
    final rows = await _database
        .customSelect(
          'SELECT name, value_or_secret_ref FROM environment_variables WHERE environment_id = ? AND is_secret = ? AND enabled = ?',
          variables: <Variable>[
            Variable.withString(environmentId),
            Variable.withBool(true),
            Variable.withBool(true),
          ],
        )
        .get();
    final values = <String>{};
    for (final row in rows) {
      final value = await _secureStorage?.readSecret(
        row.read<String>('value_or_secret_ref'),
      );
      if (value == null || value.isEmpty) {
        throw StateError(
          'Missing secure environment reference for ${row.read<String>('name')}.',
        );
      }
      values.add(value);
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
    String? baselineFingerprint,
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
      baselineFingerprint:
          baselineFingerprint ??
          GraphqlDraft.fingerprint(request, environmentId),
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
          'request': _historyRequest(request, operationName),
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

  Future<void> recordFailure({
    String? draftId,
    required String workspaceId,
    required GraphqlOperationType type,
    required GraphqlFailure failure,
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
          'request': _historyRequest(request, operationName),
          'completion': failure.category == GraphqlFailureCategory.cancelled
              ? 'cancelled'
              : 'httpFailure',
          'failureCategory': failure.category.name,
          'errors': <Map<String, String>>[
            <String, String>{'message': failure.message},
          ],
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

  Map<String, Object?>? _historyRequest(
    GraphqlRequest? request,
    String? operationName,
  ) => request == null
      ? null
      : <String, Object?>{
          'endpoint': _safeHistoryEndpoint(request.endpoint),
          'document': request.document,
          'operationName': operationName ?? request.operationName,
          'variables': request.variables,
          'extensions': request.extensions,
          'headers': SecretMasker.redactHeaders(request.headers),
          'useGet': request.useGet,
          'authType': request.auth.type.name,
          'environmentId': null,
        };

  String _safeHistoryEndpoint(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return value.split('?').first.split('#').first;
    return uri.replace(userInfo: '', query: null, fragment: null).toString();
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
    'baselineFingerprint': draft.baselineFingerprint,
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
      baselineFingerprint: payload['baselineFingerprint']?.toString(),
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
    int? sortOrder,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const FormatException('A saved GraphQL request needs a name.');
    }
    final now = DateTime.fromMillisecondsSinceEpoch(
      DateTime.now().millisecondsSinceEpoch ~/ 1000 * 1000,
    );
    final requestId = id ?? _ids.v4();
    final existing = id == null ? null : await requestById(id);
    final targetCollectionId = collectionId ?? existing?.collectionId;
    final targetFolderId = folderId ?? existing?.folderId;
    await _ensureNameAvailable(
      workspaceId: workspaceId,
      name: trimmedName,
      collectionId: targetCollectionId,
      folderId: targetFolderId,
      excludingId: id,
    );
    await _database.customStatement(
      'INSERT OR REPLACE INTO graphql_saved_requests (id, workspace_id, collection_id, folder_id, name, payload_json, sort_order, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      <Object?>[
        requestId,
        workspaceId,
        targetCollectionId,
        targetFolderId,
        trimmedName,
        _requestJson(request),
        sortOrder ?? existing?.sortOrder ?? 0,
        (existing?.createdAt ?? now).millisecondsSinceEpoch ~/ 1000,
        now.millisecondsSinceEpoch ~/ 1000,
      ],
    );
    return GraphqlSavedRequest(
      id: requestId,
      workspaceId: workspaceId,
      name: trimmedName,
      request: request,
      collectionId: targetCollectionId,
      folderId: targetFolderId,
      sortOrder: sortOrder ?? existing?.sortOrder ?? 0,
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
    final existing = await requestById(id);
    if (existing == null) {
      throw StateError('Saved GraphQL request $id was not found.');
    }
    await _ensureNameAvailable(
      workspaceId: existing.workspaceId,
      name: trimmed,
      collectionId: existing.collectionId,
      folderId: existing.folderId,
      excludingId: id,
    );
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
    final copyName = await _nextCopyName(original);
    return saveRequest(
      workspaceId: original.workspaceId,
      name: name?.trim().isNotEmpty == true ? name!.trim() : copyName,
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

  /// Reorders only siblings in the request's own collection/folder location.
  Future<void> reorderRequest(String id, int destinationIndex) async {
    final source = await requestById(id);
    if (source == null) {
      throw StateError('Saved GraphQL request $id was not found.');
    }
    final siblings = (await requests(source.workspaceId))
        .where(
          (item) =>
              item.collectionId == source.collectionId &&
              item.folderId == source.folderId,
        )
        .toList();
    final current = siblings.indexWhere((item) => item.id == id);
    if (current < 0) return;
    final item = siblings.removeAt(current);
    siblings.insert(destinationIndex.clamp(0, siblings.length), item);
    await _writeSequentialOrder(siblings);
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
    bool clearCollection = false,
    bool clearFolder = false,
  }) async {
    final source = await requestById(id);
    if (source == null) {
      throw StateError('Saved GraphQL request $id was not found.');
    }
    final targetCollectionId = clearCollection
        ? null
        : collectionId ?? source.collectionId;
    final targetFolderId = clearFolder || clearCollection
        ? null
        : folderId ?? source.folderId;
    await _database.transaction(() async {
      final targetSiblings = (await requests(source.workspaceId))
          .where(
            (item) =>
                item.id != id &&
                item.collectionId == targetCollectionId &&
                item.folderId == targetFolderId,
          )
          .toList();
      await _database.customStatement(
        'UPDATE graphql_saved_requests SET collection_id = ?, folder_id = ?, sort_order = ?, updated_at = ? WHERE id = ?',
        <Object?>[
          targetCollectionId,
          targetFolderId,
          targetSiblings.length,
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
          id,
        ],
      );
      final sourceSiblings = (await requests(source.workspaceId))
          .where(
            (item) =>
                item.id != id &&
                item.collectionId == source.collectionId &&
                item.folderId == source.folderId,
          )
          .toList();
      await _writeSequentialOrder(sourceSiblings);
    });
  }

  Future<void> _writeSequentialOrder(List<GraphqlSavedRequest> items) async {
    await _database.transaction(() async {
      for (var index = 0; index < items.length; index++) {
        await _database.customStatement(
          'UPDATE graphql_saved_requests SET sort_order = ?, updated_at = ? WHERE id = ?',
          <Object?>[
            index,
            DateTime.now().millisecondsSinceEpoch ~/ 1000,
            items[index].id,
          ],
        );
      }
    });
  }

  Future<void> _ensureNameAvailable({
    required String workspaceId,
    required String name,
    required String? collectionId,
    required String? folderId,
    String? excludingId,
  }) async {
    final conflict = (await requests(workspaceId)).any(
      (item) =>
          item.id != excludingId &&
          item.name.toLowerCase() == name.toLowerCase() &&
          item.collectionId == collectionId &&
          item.folderId == folderId,
    );
    if (conflict) {
      throw FormatException(
        'A saved GraphQL request named "$name" already exists in this location.',
      );
    }
  }

  Future<String> _nextCopyName(GraphqlSavedRequest original) async {
    final existing = await requests(original.workspaceId);
    final names = existing
        .where(
          (item) =>
              item.collectionId == original.collectionId &&
              item.folderId == original.folderId,
        )
        .map((item) => item.name.toLowerCase())
        .toSet();
    var candidate = '${original.name} copy';
    var number = 2;
    while (names.contains(candidate.toLowerCase())) {
      candidate = '${original.name} copy $number';
      number++;
    }
    return candidate;
  }

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

  GraphqlStoredSchemaSnapshot _schemaFromRow(QueryRow row) {
    final payload = jsonDecode(row.read<String>('snapshot_json')) as Map;
    final types = (payload['types'] as List? ?? const <Object?>[])
        .whereType<Map>()
        .map(_schemaTypeFromJson)
        .toList(growable: false);
    return GraphqlStoredSchemaSnapshot(
      id: row.read<String>('id'),
      workspaceId: row.read<String>('workspace_id'),
      endpointFingerprint: row.read<String>('endpoint_fingerprint'),
      createdAt: row.read<DateTime>('fetched_at'),
      snapshot: schema.GraphqlSchemaSnapshot(
        hash: row.read<String>('schema_hash'),
        fetchedAt: row.read<DateTime>('fetched_at'),
        queryRoot: payload['queryRoot']?.toString(),
        mutationRoot: payload['mutationRoot']?.toString(),
        subscriptionRoot: payload['subscriptionRoot']?.toString(),
        types: types,
      ),
    );
  }

  schema.GraphqlSchemaType _schemaTypeFromJson(Map value) =>
      schema.GraphqlSchemaType(
        name: value['name']?.toString() ?? '',
        kind: value['kind']?.toString() ?? '',
        description: value['description']?.toString(),
        fields: (value['fields'] as List? ?? const <Object?>[])
            .whereType<Map>()
            .map(_schemaFieldFromJson)
            .toList(growable: false),
        enumValues: (value['enumValues'] as List? ?? const <Object?>[])
            .map((item) => item.toString())
            .toList(growable: false),
        interfaces: (value['interfaces'] as List? ?? const <Object?>[])
            .map((item) => item.toString())
            .toList(growable: false),
      );

  schema.GraphqlSchemaField _schemaFieldFromJson(Map value) =>
      schema.GraphqlSchemaField(
        name: value['name']?.toString() ?? '',
        type: value['type']?.toString() ?? 'Unknown',
        description: value['description']?.toString(),
        args: (value['args'] as List? ?? const <Object?>[])
            .whereType<Map>()
            .map(_schemaArgumentFromJson)
            .toList(growable: false),
        isDeprecated: value['isDeprecated'] == true,
        deprecationReason: value['deprecationReason']?.toString(),
      );

  schema.GraphqlSchemaArgument _schemaArgumentFromJson(Map value) =>
      schema.GraphqlSchemaArgument(
        name: value['name']?.toString() ?? '',
        type: value['type']?.toString() ?? 'Unknown',
        description: value['description']?.toString(),
        defaultValue: value['defaultValue'],
      );

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
