import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/security/secret_masker.dart';
import '../../../core/storage/database_schema.dart'
    hide
        GrpcDescriptorSnapshot,
        GrpcDraft,
        GrpcInvocationHistory,
        GrpcSavedRequest,
        GrpcStoredStreamEvent;
import '../domain/grpc_persistence_models.dart';

/// Persistence is the sanitization boundary: every structured value is
/// redacted by key and by exact runtime-secret value before SQLite sees it.
class GrpcPersistenceRepository {
  GrpcPersistenceRepository(this._database, {Uuid ids = const Uuid()})
    : _ids = ids;

  final AppDatabase _database;
  final Uuid _ids;

  Future<GrpcDescriptorSnapshot> storeDescriptor({
    required String workspaceId,
    required String fingerprint,
    required GrpcDescriptorSourceType sourceType,
    required String displayName,
    required Uint8List descriptorBytes,
    required int fileCount,
    required int serviceCount,
    String? sourceIdentity,
    Iterable<String> runtimeSecrets = const <String>[],
  }) => _database.transaction(() async {
    await _requireWorkspace(workspaceId);
    if (descriptorBytes.isEmpty || descriptorBytes.length > 16 * 1024 * 1024) {
      throw const GrpcPersistenceFailure(
        'descriptorSize',
        'Descriptor bytes are outside the persisted limit.',
      );
    }
    final actual = sha256.convert(descriptorBytes).toString();
    if (actual != fingerprint) {
      throw const GrpcPersistenceFailure(
        'fingerprintMismatch',
        'Descriptor fingerprint does not match its bytes.',
      );
    }
    final existing = await _database
        .customSelect(
          'SELECT * FROM grpc_descriptor_snapshots WHERE workspace_id = ? AND fingerprint = ?',
          variables: <Variable<Object>>[
            Variable<String>(workspaceId),
            Variable<String>(fingerprint),
          ],
        )
        .getSingleOrNull();
    if (existing != null) {
      final bytes = existing.read<Uint8List>('descriptor_bytes');
      if (!_bytesEqual(bytes, descriptorBytes)) {
        throw const GrpcPersistenceFailure(
          'fingerprintConflict',
          'Conflicting descriptor bytes use the same fingerprint.',
        );
      }
      await touchDescriptor(existing.read<String>('id'));
      return _descriptorFromRow(existing);
    }
    final now = DateTime.now();
    final id = _ids.v4();
    await _database.customStatement(
      'INSERT INTO grpc_descriptor_snapshots (id, workspace_id, fingerprint, source_type, display_name, source_identity, descriptor_bytes, descriptor_byte_count, file_count, service_count, created_at, last_used_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      <Object?>[
        id,
        workspaceId,
        fingerprint,
        sourceType.name,
        _safeText(displayName, runtimeSecrets),
        sourceIdentity == null
            ? null
            : _safeText(sourceIdentity, runtimeSecrets),
        descriptorBytes,
        descriptorBytes.length,
        fileCount,
        serviceCount,
        _seconds(now),
        _seconds(now),
      ],
    );
    return GrpcDescriptorSnapshot(
      id: id,
      workspaceId: workspaceId,
      fingerprint: fingerprint,
      sourceType: sourceType,
      displayName: _safeText(displayName, runtimeSecrets),
      sourceIdentity: sourceIdentity == null
          ? null
          : _safeText(sourceIdentity, runtimeSecrets),
      descriptorBytes: descriptorBytes,
      fileCount: fileCount,
      serviceCount: serviceCount,
      createdAt: now,
      lastUsedAt: now,
    );
  });

  Future<GrpcDescriptorSnapshot?> descriptorById(String id) async {
    final row = await _database
        .customSelect(
          'SELECT * FROM grpc_descriptor_snapshots WHERE id = ?',
          variables: <Variable<Object>>[Variable<String>(id)],
        )
        .getSingleOrNull();
    return row == null ? null : _descriptorFromRow(row);
  }

  Future<List<GrpcDescriptorSnapshot>> descriptors(
    String workspaceId, {
    GrpcDescriptorSourceType? sourceType,
    String query = '',
  }) async {
    final rows = await _database
        .customSelect(
          '''SELECT * FROM grpc_descriptor_snapshots
      WHERE workspace_id = ?
      AND (? = '' OR source_type = ?)
      AND (display_name LIKE ? OR COALESCE(source_identity, '') LIKE ?)
      ORDER BY last_used_at DESC, id''',
          variables: <Variable<Object>>[
            Variable<String>(workspaceId),
            Variable<String>(sourceType?.name ?? ''),
            Variable<String>(sourceType?.name ?? ''),
            Variable<String>('%$query%'),
            Variable<String>('%$query%'),
          ],
        )
        .get();
    return rows.map(_descriptorFromRow).toList(growable: false);
  }

  Future<void> touchDescriptor(String id) => _database.customStatement(
    'UPDATE grpc_descriptor_snapshots SET last_used_at = ? WHERE id = ?',
    <Object?>[_seconds(DateTime.now()), id],
  );

  Future<void> deleteDescriptor(String id) async {
    final references = await _database
        .customSelect(
          '''SELECT
      (SELECT COUNT(*) FROM grpc_saved_requests WHERE descriptor_snapshot_id = ?) +
      (SELECT COUNT(*) FROM grpc_drafts WHERE descriptor_snapshot_id = ?) +
      (SELECT COUNT(*) FROM grpc_invocation_history WHERE descriptor_snapshot_id = ?) AS count''',
          variables: <Variable<Object>>[
            Variable<String>(id),
            Variable<String>(id),
            Variable<String>(id),
          ],
        )
        .getSingle();
    if (references.read<int>('count') != 0) {
      throw const GrpcPersistenceFailure(
        'descriptorReferenced',
        'Referenced descriptor snapshots cannot be deleted.',
      );
    }
    await _database.customStatement(
      'DELETE FROM grpc_descriptor_snapshots WHERE id = ?',
      <Object?>[id],
    );
  }

  Future<int> deleteStaleDescriptors(
    String workspaceId,
    DateTime cutoff,
  ) async {
    await _database.customStatement(
      '''DELETE FROM grpc_descriptor_snapshots
      WHERE workspace_id = ? AND last_used_at < ?
      AND NOT EXISTS (SELECT 1 FROM grpc_saved_requests WHERE descriptor_snapshot_id = grpc_descriptor_snapshots.id)
      AND NOT EXISTS (SELECT 1 FROM grpc_drafts WHERE descriptor_snapshot_id = grpc_descriptor_snapshots.id)
      AND NOT EXISTS (SELECT 1 FROM grpc_invocation_history WHERE descriptor_snapshot_id = grpc_descriptor_snapshots.id)''',
      <Object?>[workspaceId, _seconds(cutoff)],
    );
    return _changedRows();
  }

  Future<GrpcSavedRequest> saveRequest(
    GrpcSavedRequest request, {
    Iterable<String> runtimeSecrets = const <String>[],
    int? expectedRevision,
  }) => _database.transaction(() async {
    await _validateOwnership(
      request.workspaceId,
      request.collectionId,
      request.folderId,
    );
    await _validateDescriptorWorkspace(
      request.descriptorSnapshotId,
      request.workspaceId,
    );
    final existing = await requestById(request.id);
    if (expectedRevision != null && existing?.revision != expectedRevision) {
      throw const GrpcPersistenceFailure(
        'revisionConflict',
        'The saved request has a newer revision.',
      );
    }
    final now = DateTime.now();
    final revision = (existing?.revision ?? 0) + 1;
    await _database.customStatement(
      '''INSERT OR REPLACE INTO grpc_saved_requests
      (id, workspace_id, collection_id, folder_id, descriptor_snapshot_id, name,
       sort_order, service_full_name, method_name, method_path, invocation_kind,
       endpoint_json, request_json, metadata_json, certificate_references_json,
       revision, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      <Object?>[
        request.id,
        request.workspaceId,
        request.collectionId,
        request.folderId,
        request.descriptorSnapshotId,
        request.name.trim(),
        request.sortOrder,
        request.serviceFullName,
        request.methodName,
        request.methodPath,
        request.invocationKind.name,
        _safeJson(request.endpoint, runtimeSecrets),
        _safeJson(request.request, runtimeSecrets),
        _safeJson(request.metadata, runtimeSecrets),
        jsonEncode(request.certificateReferences),
        revision,
        _seconds(existing?.createdAt ?? now),
        _seconds(now),
      ],
    );
    return (await requestById(request.id))!;
  });

  Future<GrpcSavedRequest?> requestById(String id) async {
    final row = await _database
        .customSelect(
          'SELECT * FROM grpc_saved_requests WHERE id = ?',
          variables: <Variable<Object>>[Variable<String>(id)],
        )
        .getSingleOrNull();
    return row == null ? null : _requestFromRow(row);
  }

  Future<List<GrpcSavedRequest>> requests(
    String workspaceId, {
    String query = '',
    String? collectionId,
    String? folderId,
  }) async {
    final rows = await _database
        .customSelect(
          '''SELECT * FROM grpc_saved_requests WHERE workspace_id = ?
      AND (? = '' OR collection_id = ?)
      AND (? = '' OR folder_id = ?)
      AND (name LIKE ? OR service_full_name LIKE ? OR method_name LIKE ?)
      ORDER BY sort_order, name, id''',
          variables: <Variable<Object>>[
            Variable<String>(workspaceId),
            Variable<String>(collectionId ?? ''),
            Variable<String>(collectionId ?? ''),
            Variable<String>(folderId ?? ''),
            Variable<String>(folderId ?? ''),
            Variable<String>('%$query%'),
            Variable<String>('%$query%'),
            Variable<String>('%$query%'),
          ],
        )
        .get();
    return rows.map(_requestFromRow).toList(growable: false);
  }

  Future<GrpcSavedRequest> renameRequest(
    String id,
    String name, {
    required int expectedRevision,
  }) async {
    final source = await requestById(id);
    if (source == null) {
      throw const GrpcPersistenceFailure('notFound', 'Saved request missing.');
    }
    return saveRequest(
      _copyRequest(source, name: name),
      expectedRevision: expectedRevision,
    );
  }

  Future<GrpcSavedRequest> duplicateRequest(String id) async {
    final source = await requestById(id);
    if (source == null) {
      throw const GrpcPersistenceFailure('notFound', 'Saved request missing.');
    }
    final now = DateTime.now();
    return saveRequest(
      GrpcSavedRequest(
        id: _ids.v4(),
        workspaceId: source.workspaceId,
        collectionId: source.collectionId,
        folderId: source.folderId,
        descriptorSnapshotId: source.descriptorSnapshotId,
        name: '${source.name} Copy',
        sortOrder: source.sortOrder + 1,
        serviceFullName: source.serviceFullName,
        methodName: source.methodName,
        methodPath: source.methodPath,
        invocationKind: source.invocationKind,
        endpoint: source.endpoint,
        request: source.request,
        metadata: source.metadata,
        certificateReferences: source.certificateReferences,
        revision: 0,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> moveAndReorderRequests(
    List<GrpcSavedRequest> ordered, {
    String? collectionId,
    String? folderId,
  }) => _database.transaction(() async {
    if (ordered.isEmpty) return;
    await _validateOwnership(ordered.first.workspaceId, collectionId, folderId);
    for (var index = 0; index < ordered.length; index++) {
      final item = ordered[index];
      if (item.workspaceId != ordered.first.workspaceId) {
        throw const GrpcPersistenceFailure(
          'workspaceMismatch',
          'Reorder cannot cross workspaces.',
        );
      }
      await _database.customStatement(
        'UPDATE grpc_saved_requests SET collection_id = ?, folder_id = ?, sort_order = ?, revision = revision + 1, updated_at = ? WHERE id = ?',
        <Object?>[
          collectionId,
          folderId,
          index,
          _seconds(DateTime.now()),
          item.id,
        ],
      );
    }
  });

  Future<void> deleteRequest(String id) => _database.customStatement(
    'DELETE FROM grpc_saved_requests WHERE id = ?',
    <Object?>[id],
  );

  Future<GrpcDraft> openRequestAsDraft(String requestId) async {
    final request = await requestById(requestId);
    if (request == null) {
      throw const GrpcPersistenceFailure('notFound', 'Saved request missing.');
    }
    final now = DateTime.now();
    return saveDraft(
      GrpcDraft(
        id: _ids.v4(),
        workspaceId: request.workspaceId,
        sourceSavedRequestId: request.id,
        descriptorSnapshotId: request.descriptorSnapshotId,
        title: request.name,
        methodIdentity: <String, Object?>{
          'serviceFullName': request.serviceFullName,
          'methodName': request.methodName,
          'methodPath': request.methodPath,
          'invocationKind': request.invocationKind.name,
        },
        endpoint: request.endpoint,
        request: request.request,
        metadata: request.metadata,
        certificateReferences: request.certificateReferences,
        revision: 0,
        tabOrder: (await drafts(request.workspaceId)).length,
        dirty: false,
        createdAt: now,
        updatedAt: now,
        lastOpenedAt: now,
      ),
    );
  }

  Future<GrpcDraft> saveDraft(
    GrpcDraft draft, {
    Iterable<String> runtimeSecrets = const <String>[],
    int? expectedRevision,
  }) => _database.transaction(() async {
    await _requireWorkspace(draft.workspaceId);
    await _validateDescriptorWorkspace(
      draft.descriptorSnapshotId,
      draft.workspaceId,
    );
    final existing = await draftById(draft.id);
    if (expectedRevision != null && existing?.revision != expectedRevision) {
      throw const GrpcPersistenceFailure(
        'revisionConflict',
        'The draft has a newer revision.',
      );
    }
    final revision = (existing?.revision ?? 0) + 1;
    await _database.customStatement(
      '''INSERT OR REPLACE INTO grpc_drafts
      (id, workspace_id, source_saved_request_id, descriptor_snapshot_id, title,
       method_identity_json, endpoint_json, request_json, metadata_json,
       certificate_references_json, revision, tab_order, dirty, created_at,
       updated_at, last_opened_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      <Object?>[
        draft.id,
        draft.workspaceId,
        draft.sourceSavedRequestId,
        draft.descriptorSnapshotId,
        draft.title,
        _safeJson(draft.methodIdentity, runtimeSecrets),
        _safeJson(draft.endpoint, runtimeSecrets),
        _safeJson(draft.request, runtimeSecrets),
        _safeJson(draft.metadata, runtimeSecrets),
        jsonEncode(draft.certificateReferences),
        revision,
        draft.tabOrder,
        draft.dirty ? 1 : 0,
        _seconds(existing?.createdAt ?? draft.createdAt),
        _seconds(DateTime.now()),
        _seconds(draft.lastOpenedAt),
      ],
    );
    return (await draftById(draft.id))!;
  });

  Future<GrpcDraft?> draftById(String id) async {
    final row = await _database
        .customSelect(
          'SELECT * FROM grpc_drafts WHERE id = ?',
          variables: <Variable<Object>>[Variable<String>(id)],
        )
        .getSingleOrNull();
    return row == null ? null : _draftFromRow(row);
  }

  Future<List<GrpcDraft>> drafts(String workspaceId) async {
    final rows = await _database
        .customSelect(
          'SELECT * FROM grpc_drafts WHERE workspace_id = ? ORDER BY tab_order, id',
          variables: <Variable<Object>>[Variable<String>(workspaceId)],
        )
        .get();
    return rows.map(_draftFromRow).toList(growable: false);
  }

  Future<void> deleteDraft(String id) => _database.customStatement(
    'DELETE FROM grpc_drafts WHERE id = ?',
    <Object?>[id],
  );

  Future<void> recordHistory(
    GrpcInvocationHistory history, {
    Iterable<GrpcStoredStreamEvent> events = const <GrpcStoredStreamEvent>[],
    Iterable<String> runtimeSecrets = const <String>[],
    int maximumEvents = 500,
    int maximumRetainedRawBytes = 1024 * 1024,
  }) => _database.transaction(() async {
    await _requireWorkspace(history.workspaceId);
    await _validateDescriptorWorkspace(
      history.descriptorSnapshotId,
      history.workspaceId,
    );
    final existing = await historyById(history.id);
    if (existing != null) {
      throw const GrpcPersistenceFailure(
        'historyImmutable',
        'History rows are immutable.',
      );
    }
    await _insertHistory(history, runtimeSecrets);
    await _insertEvents(
      history.id,
      events,
      runtimeSecrets,
      maximumEvents,
      maximumRetainedRawBytes,
    );
  });

  Future<void> finalizeStreamingSession(
    String id, {
    required DateTime completedAt,
    required GrpcHistoryOutcome outcome,
    required String terminalState,
    int? statusCode,
    String? statusName,
    String? statusMessage,
    int droppedEventCount = 0,
    Iterable<String> runtimeSecrets = const <String>[],
  }) => _database.transaction(() async {
    final existing = await historyById(id);
    if (existing == null) {
      throw const GrpcPersistenceFailure(
        'notFound',
        'History session missing.',
      );
    }
    if (existing.isFinalized) {
      throw const GrpcPersistenceFailure(
        'alreadyFinalized',
        'Streaming history can be finalized exactly once.',
      );
    }
    await _database.customStatement(
      '''UPDATE grpc_invocation_history SET completed_at = ?,
      duration_microseconds = ?, outcome = ?, terminal_state = ?,
      status_code = ?, status_name = ?, status_message = ?,
      dropped_event_count = ? WHERE id = ? AND completed_at IS NULL''',
      <Object?>[
        _seconds(completedAt),
        completedAt.difference(existing.startedAt).inMicroseconds,
        outcome.name,
        terminalState,
        statusCode,
        statusName,
        statusMessage == null ? null : _safeText(statusMessage, runtimeSecrets),
        droppedEventCount,
        id,
      ],
    );
    if (await _changedRows() != 1) {
      throw const GrpcPersistenceFailure(
        'alreadyFinalized',
        'Streaming history can be finalized exactly once.',
      );
    }
  });

  Future<void> appendEvents(
    String historyId,
    Iterable<GrpcStoredStreamEvent> events, {
    Iterable<String> runtimeSecrets = const <String>[],
    int maximumEvents = 500,
    int maximumRetainedRawBytes = 1024 * 1024,
  }) => _database.transaction(() async {
    final history = await historyById(historyId);
    if (history == null) {
      throw const GrpcPersistenceFailure(
        'notFound',
        'History session missing.',
      );
    }
    if (history.isFinalized) {
      throw const GrpcPersistenceFailure(
        'historyFinalized',
        'Events cannot be appended after finalization.',
      );
    }
    await _insertEvents(
      historyId,
      events,
      runtimeSecrets,
      maximumEvents,
      maximumRetainedRawBytes,
    );
  });

  Future<GrpcInvocationHistory?> historyById(String id) async {
    final row = await _database
        .customSelect(
          'SELECT * FROM grpc_invocation_history WHERE id = ?',
          variables: <Variable<Object>>[Variable<String>(id)],
        )
        .getSingleOrNull();
    return row == null ? null : _historyFromRow(row);
  }

  Future<List<GrpcStoredStreamEvent>> events(String historyId) async {
    final rows = await _database
        .customSelect(
          'SELECT * FROM grpc_stored_stream_events WHERE session_history_id = ? ORDER BY sequence_number',
          variables: <Variable<Object>>[Variable<String>(historyId)],
        )
        .get();
    return rows.map(_eventFromRow).toList(growable: false);
  }

  Future<List<GrpcInvocationHistory>> history(
    String workspaceId, {
    GrpcHistoryFilter filter = const GrpcHistoryFilter(),
    int limit = 50,
    int offset = 0,
  }) async {
    if (limit < 1 || limit > 200 || offset < 0) {
      throw const GrpcPersistenceFailure(
        'pagination',
        'History pagination is outside bounds.',
      );
    }
    final rows = await _database
        .customSelect(
          '''SELECT * FROM grpc_invocation_history WHERE workspace_id = ?
      AND (? = '' OR invocation_kind = ?)
      AND (? = '' OR outcome = ?)
      AND (? = -1 OR status_code = ?)
      AND (? = '' OR saved_request_id = ?)
      AND (? = '' OR descriptor_snapshot_id = ?)
      AND created_at >= ?
      AND created_at <= ?
      AND (method_identity_json LIKE ? OR endpoint_json LIKE ?)
      ORDER BY created_at DESC, id DESC LIMIT ? OFFSET ?''',
          variables: <Variable<Object>>[
            Variable<String>(workspaceId),
            Variable<String>(filter.invocationKind?.name ?? ''),
            Variable<String>(filter.invocationKind?.name ?? ''),
            Variable<String>(filter.outcome?.name ?? ''),
            Variable<String>(filter.outcome?.name ?? ''),
            Variable<int>(filter.statusCode ?? -1),
            Variable<int>(filter.statusCode ?? -1),
            Variable<String>(filter.savedRequestId ?? ''),
            Variable<String>(filter.savedRequestId ?? ''),
            Variable<String>(filter.descriptorSnapshotId ?? ''),
            Variable<String>(filter.descriptorSnapshotId ?? ''),
            Variable<int>(filter.from == null ? 0 : _seconds(filter.from!)),
            Variable<int>(
              filter.to == null ? 0x7FFFFFFFFFFFFFFF : _seconds(filter.to!),
            ),
            Variable<String>('%${filter.query ?? ''}%'),
            Variable<String>('%${filter.query ?? ''}%'),
            Variable<int>(limit),
            Variable<int>(offset),
          ],
        )
        .get();
    return rows.map(_historyFromRow).toList(growable: false);
  }

  Future<GrpcDraft> replayHistory(String historyId) async {
    final source = await historyById(historyId);
    if (source == null) {
      throw const GrpcPersistenceFailure('notFound', 'History entry missing.');
    }
    final now = DateTime.now();
    return saveDraft(
      GrpcDraft(
        id: _ids.v4(),
        workspaceId: source.workspaceId,
        descriptorSnapshotId: source.descriptorSnapshotId,
        title: 'Replay ${source.methodIdentity['methodName'] ?? 'gRPC'}',
        methodIdentity: source.methodIdentity,
        endpoint: source.endpoint,
        request: source.request,
        metadata: source.requestMetadata,
        certificateReferences: const <String>[],
        revision: 0,
        tabOrder: (await drafts(source.workspaceId)).length,
        dirty: true,
        createdAt: now,
        updatedAt: now,
        lastOpenedAt: now,
      ),
    );
  }

  Future<void> applyHistoryRetention(
    String workspaceId,
    GrpcRetentionPolicy policy,
  ) => _database.transaction(() async {
    final cutoff = DateTime.now().subtract(policy.maximumAge);
    await _database.customStatement(
      'DELETE FROM grpc_invocation_history WHERE workspace_id = ? AND created_at < ?',
      <Object?>[workspaceId, _seconds(cutoff)],
    );
    await _database.customStatement(
      '''DELETE FROM grpc_invocation_history WHERE id IN (
      SELECT id FROM grpc_invocation_history WHERE workspace_id = ?
      ORDER BY created_at DESC, id DESC LIMIT -1 OFFSET ?)''',
      <Object?>[workspaceId, policy.maximumCount],
    );
    final rows = await _database
        .customSelect(
          '''SELECT h.id, COALESCE(SUM(e.raw_byte_count), 0) AS bytes
      FROM grpc_invocation_history h LEFT JOIN grpc_stored_stream_events e
      ON e.session_history_id = h.id WHERE h.workspace_id = ?
      GROUP BY h.id ORDER BY h.created_at DESC, h.id DESC''',
          variables: <Variable<Object>>[Variable<String>(workspaceId)],
        )
        .get();
    var retained = 0;
    for (final row in rows) {
      retained += row.read<int>('bytes');
      if (retained > policy.maximumRetainedBytes) {
        await _database.customStatement(
          'DELETE FROM grpc_invocation_history WHERE id = ?',
          <Object?>[row.read<String>('id')],
        );
      }
    }
  });

  Future<void> deleteHistory(String id) => _database.customStatement(
    'DELETE FROM grpc_invocation_history WHERE id = ?',
    <Object?>[id],
  );

  Future<void> clearHistory(String workspaceId) => _database.customStatement(
    'DELETE FROM grpc_invocation_history WHERE workspace_id = ?',
    <Object?>[workspaceId],
  );

  GrpcUnaryComparison compareUnary(
    GrpcInvocationHistory left,
    GrpcInvocationHistory right,
  ) {
    final changes = _compareJson(
      '',
      _comparisonMap(left),
      _comparisonMap(right),
    );
    return GrpcUnaryComparison(
      changes: changes,
      durationDeltaMicroseconds:
          (right.durationMicroseconds ?? 0) - (left.durationMicroseconds ?? 0),
      requestByteDelta: right.requestByteCount - left.requestByteCount,
      responseByteDelta: right.responseByteCount - left.responseByteCount,
    );
  }

  Future<GrpcStreamingComparison> compareStreaming(
    String leftId,
    String rightId, {
    int maximumComparedEvents = 500,
  }) async {
    final left = await historyById(leftId);
    final right = await historyById(rightId);
    if (left == null || right == null) {
      throw const GrpcPersistenceFailure(
        'notFound',
        'Streaming comparison entry missing.',
      );
    }
    final leftEvents = (await events(
      leftId,
    )).take(maximumComparedEvents).toList();
    final rightEvents = (await events(
      rightId,
    )).take(maximumComparedEvents).toList();
    final leftByKey = {
      for (final e in leftEvents) '${e.direction.name}:${e.sequenceNumber}': e,
    };
    final rightByKey = {
      for (final e in rightEvents) '${e.direction.name}:${e.sequenceNumber}': e,
    };
    final eventChanges = <GrpcComparisonChange>[];
    final onlyLeft = <int>[];
    final onlyRight = <int>[];
    for (final entry in leftByKey.entries) {
      final other = rightByKey[entry.key];
      if (other == null) {
        onlyLeft.add(entry.value.sequenceNumber);
      } else {
        eventChanges.addAll(
          _compareJson(
            'events.${entry.key}',
            _eventMap(entry.value),
            _eventMap(other),
          ),
        );
      }
    }
    for (final entry in rightByKey.entries) {
      if (!leftByKey.containsKey(entry.key)) {
        onlyRight.add(entry.value.sequenceNumber);
      }
    }
    return GrpcStreamingComparison(
      summaryChanges: _compareJson(
        'session',
        _comparisonMap(left),
        _comparisonMap(right),
      ),
      eventChanges: eventChanges,
      onlyInLeft: onlyLeft,
      onlyInRight: onlyRight,
      retentionWarning:
          left.droppedEventCount > 0 ||
          right.droppedEventCount > 0 ||
          leftEvents.length == maximumComparedEvents ||
          rightEvents.length == maximumComparedEvents,
    );
  }

  Future<void> _insertHistory(
    GrpcInvocationHistory history,
    Iterable<String> runtimeSecrets,
  ) => _database.customStatement(
    '''INSERT INTO grpc_invocation_history
    (id, workspace_id, saved_request_id, descriptor_snapshot_id, invocation_kind,
     started_at, completed_at, duration_microseconds, endpoint_json,
     method_identity_json, request_json, request_metadata_json, response_json,
     response_headers_json, response_trailers_json, status_code, status_name,
     status_message, request_byte_count, response_byte_count, outcome,
     diagnostic_category, dropped_event_count, terminal_state, created_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
    <Object?>[
      history.id,
      history.workspaceId,
      history.savedRequestId,
      history.descriptorSnapshotId,
      history.invocationKind.name,
      _seconds(history.startedAt),
      history.completedAt == null ? null : _seconds(history.completedAt!),
      history.durationMicroseconds,
      _safeJson(history.endpoint, runtimeSecrets),
      _safeJson(history.methodIdentity, runtimeSecrets),
      _safeJson(history.request, runtimeSecrets),
      _safeJson(history.requestMetadata, runtimeSecrets),
      history.response == null
          ? null
          : _safeJson(history.response!, runtimeSecrets),
      _safeJson(history.responseHeaders, runtimeSecrets),
      _safeJson(history.responseTrailers, runtimeSecrets),
      history.statusCode,
      history.statusName,
      history.statusMessage == null
          ? null
          : _safeText(history.statusMessage!, runtimeSecrets),
      history.requestByteCount,
      history.responseByteCount,
      history.outcome.name,
      history.diagnosticCategory == null
          ? null
          : _safeText(history.diagnosticCategory!, runtimeSecrets),
      history.droppedEventCount,
      history.terminalState,
      _seconds(history.createdAt),
    ],
  );

  Future<void> _insertEvents(
    String historyId,
    Iterable<GrpcStoredStreamEvent> source,
    Iterable<String> runtimeSecrets,
    int maximumEvents,
    int maximumRetainedRawBytes,
  ) async {
    final existing = await _database
        .customSelect(
          'SELECT COUNT(*) AS count, COALESCE(SUM(LENGTH(retained_raw_bytes)), 0) AS bytes FROM grpc_stored_stream_events WHERE session_history_id = ?',
          variables: <Variable<Object>>[Variable<String>(historyId)],
        )
        .getSingle();
    var count = existing.read<int>('count');
    var retainedBytes = existing.read<int>('bytes');
    for (final event in source) {
      if (count >= maximumEvents) break;
      final raw = event.retainedRawBytes;
      final retained =
          raw != null && raw.length + retainedBytes <= maximumRetainedRawBytes
          ? raw
          : null;
      await _database.customStatement(
        '''INSERT INTO grpc_stored_stream_events
        (id, session_history_id, sequence_number, direction, category, occurred_at,
         decoded_payload_json, raw_byte_count, retained_raw_bytes, status_code,
         status_text, decode_failure_category)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
        <Object?>[
          '$historyId:${event.id}',
          historyId,
          event.sequenceNumber,
          event.direction.name,
          event.category,
          _seconds(event.occurredAt),
          event.decodedPayload == null
              ? null
              : _safeJson(event.decodedPayload!, runtimeSecrets),
          event.rawByteCount,
          retained,
          event.statusCode,
          event.statusText == null
              ? null
              : _safeText(event.statusText!, runtimeSecrets),
          event.decodeFailureCategory,
        ],
      );
      count++;
      retainedBytes += retained?.length ?? 0;
    }
  }

  Future<void> _requireWorkspace(String workspaceId) async {
    final exists = await _database
        .customSelect(
          'SELECT 1 FROM workspaces WHERE id = ?',
          variables: <Variable<Object>>[Variable<String>(workspaceId)],
        )
        .getSingleOrNull();
    if (exists == null) {
      throw const GrpcPersistenceFailure(
        'workspaceMissing',
        'Workspace does not exist.',
      );
    }
  }

  Future<void> _validateDescriptorWorkspace(
    String? descriptorId,
    String workspaceId,
  ) async {
    if (descriptorId == null) return;
    final row = await _database
        .customSelect(
          'SELECT workspace_id FROM grpc_descriptor_snapshots WHERE id = ?',
          variables: <Variable<Object>>[Variable<String>(descriptorId)],
        )
        .getSingleOrNull();
    if (row == null || row.read<String>('workspace_id') != workspaceId) {
      throw const GrpcPersistenceFailure(
        'descriptorWorkspace',
        'Descriptor snapshot belongs to another workspace or is missing.',
      );
    }
  }

  Future<void> _validateOwnership(
    String workspaceId,
    String? collectionId,
    String? folderId,
  ) async {
    await _requireWorkspace(workspaceId);
    if (collectionId != null) {
      final collection = await _database
          .customSelect(
            'SELECT workspace_id FROM collections WHERE id = ?',
            variables: <Variable<Object>>[Variable<String>(collectionId)],
          )
          .getSingleOrNull();
      if (collection == null ||
          collection.read<String>('workspace_id') != workspaceId) {
        throw const GrpcPersistenceFailure(
          'collectionWorkspace',
          'Collection does not belong to the workspace.',
        );
      }
    }
    if (folderId != null) {
      final folder = await _database
          .customSelect(
            '''SELECT c.workspace_id, f.collection_id FROM folders f
        JOIN collections c ON c.id = f.collection_id WHERE f.id = ?''',
            variables: <Variable<Object>>[Variable<String>(folderId)],
          )
          .getSingleOrNull();
      if (folder == null ||
          folder.read<String>('workspace_id') != workspaceId ||
          (collectionId != null &&
              folder.read<String>('collection_id') != collectionId)) {
        throw const GrpcPersistenceFailure(
          'folderWorkspace',
          'Folder does not belong to the selected location.',
        );
      }
    }
  }

  String _safeJson(Object? value, Iterable<String> runtimeSecrets) =>
      jsonEncode(
        SecretMasker.redactStructured(value, runtimeSecrets: runtimeSecrets),
      );

  String _safeText(String value, Iterable<String> runtimeSecrets) =>
      SecretMasker.redactStructured(value, runtimeSecrets: runtimeSecrets)
          as String;

  Future<int> _changedRows() async =>
      (await _database.customSelect('SELECT changes() AS count').getSingle())
          .read<int>('count');

  int _seconds(DateTime value) => value.millisecondsSinceEpoch ~/ 1000;

  DateTime _date(int value) =>
      DateTime.fromMillisecondsSinceEpoch(value * 1000);

  Map<String, Object?> _jsonMap(String source) {
    final value = jsonDecode(source);
    if (value is! Map) {
      throw const GrpcPersistenceFailure(
        'malformedJson',
        'Persisted JSON is not an object.',
      );
    }
    return value.map((key, item) => MapEntry(key.toString(), item as Object?));
  }

  List<String> _stringList(String source) {
    final value = jsonDecode(source);
    if (value is! List || value.any((item) => item is! String)) {
      throw const GrpcPersistenceFailure(
        'malformedJson',
        'Persisted references are malformed.',
      );
    }
    return value.cast<String>();
  }

  GrpcDescriptorSnapshot _descriptorFromRow(QueryRow row) =>
      GrpcDescriptorSnapshot(
        id: row.read<String>('id'),
        workspaceId: row.read<String>('workspace_id'),
        fingerprint: row.read<String>('fingerprint'),
        sourceType: _enum(
          GrpcDescriptorSourceType.values,
          row.read<String>('source_type'),
          GrpcDescriptorSourceType.descriptorSet,
        ),
        displayName: row.read<String>('display_name'),
        sourceIdentity: row.readNullable<String>('source_identity'),
        descriptorBytes: row.read<Uint8List>('descriptor_bytes'),
        fileCount: row.read<int>('file_count'),
        serviceCount: row.read<int>('service_count'),
        createdAt: _date(row.read<int>('created_at')),
        lastUsedAt: _date(row.read<int>('last_used_at')),
      );

  GrpcSavedRequest _requestFromRow(QueryRow row) => GrpcSavedRequest(
    id: row.read<String>('id'),
    workspaceId: row.read<String>('workspace_id'),
    collectionId: row.readNullable<String>('collection_id'),
    folderId: row.readNullable<String>('folder_id'),
    descriptorSnapshotId: row.readNullable<String>('descriptor_snapshot_id'),
    name: row.read<String>('name'),
    sortOrder: row.read<int>('sort_order'),
    serviceFullName: row.read<String>('service_full_name'),
    methodName: row.read<String>('method_name'),
    methodPath: row.read<String>('method_path'),
    invocationKind: _enum(
      GrpcPersistedInvocationKind.values,
      row.read<String>('invocation_kind'),
      GrpcPersistedInvocationKind.unary,
    ),
    endpoint: _jsonMap(row.read<String>('endpoint_json')),
    request: _jsonMap(row.read<String>('request_json')),
    metadata: _jsonMap(row.read<String>('metadata_json')),
    certificateReferences: _stringList(
      row.read<String>('certificate_references_json'),
    ),
    revision: row.read<int>('revision'),
    createdAt: _date(row.read<int>('created_at')),
    updatedAt: _date(row.read<int>('updated_at')),
  );

  GrpcSavedRequest _copyRequest(GrpcSavedRequest source, {String? name}) =>
      GrpcSavedRequest(
        id: source.id,
        workspaceId: source.workspaceId,
        collectionId: source.collectionId,
        folderId: source.folderId,
        descriptorSnapshotId: source.descriptorSnapshotId,
        name: name ?? source.name,
        sortOrder: source.sortOrder,
        serviceFullName: source.serviceFullName,
        methodName: source.methodName,
        methodPath: source.methodPath,
        invocationKind: source.invocationKind,
        endpoint: source.endpoint,
        request: source.request,
        metadata: source.metadata,
        certificateReferences: source.certificateReferences,
        revision: source.revision,
        createdAt: source.createdAt,
        updatedAt: source.updatedAt,
      );

  GrpcDraft _draftFromRow(QueryRow row) => GrpcDraft(
    id: row.read<String>('id'),
    workspaceId: row.read<String>('workspace_id'),
    sourceSavedRequestId: row.readNullable<String>('source_saved_request_id'),
    descriptorSnapshotId: row.readNullable<String>('descriptor_snapshot_id'),
    title: row.read<String>('title'),
    methodIdentity: _jsonMap(row.read<String>('method_identity_json')),
    endpoint: _jsonMap(row.read<String>('endpoint_json')),
    request: _jsonMap(row.read<String>('request_json')),
    metadata: _jsonMap(row.read<String>('metadata_json')),
    certificateReferences: _stringList(
      row.read<String>('certificate_references_json'),
    ),
    revision: row.read<int>('revision'),
    tabOrder: row.read<int>('tab_order'),
    dirty: row.read<int>('dirty') != 0,
    createdAt: _date(row.read<int>('created_at')),
    updatedAt: _date(row.read<int>('updated_at')),
    lastOpenedAt: _date(row.read<int>('last_opened_at')),
  );

  GrpcInvocationHistory _historyFromRow(QueryRow row) => GrpcInvocationHistory(
    id: row.read<String>('id'),
    workspaceId: row.read<String>('workspace_id'),
    savedRequestId: row.readNullable<String>('saved_request_id'),
    descriptorSnapshotId: row.readNullable<String>('descriptor_snapshot_id'),
    invocationKind: _enum(
      GrpcPersistedInvocationKind.values,
      row.read<String>('invocation_kind'),
      GrpcPersistedInvocationKind.unary,
    ),
    startedAt: _date(row.read<int>('started_at')),
    completedAt: row.readNullable<int>('completed_at') == null
        ? null
        : _date(row.read<int>('completed_at')),
    durationMicroseconds: row.readNullable<int>('duration_microseconds'),
    endpoint: _jsonMap(row.read<String>('endpoint_json')),
    methodIdentity: _jsonMap(row.read<String>('method_identity_json')),
    request: _jsonMap(row.read<String>('request_json')),
    requestMetadata: _jsonMap(row.read<String>('request_metadata_json')),
    response: row.readNullable<String>('response_json') == null
        ? null
        : _jsonMap(row.read<String>('response_json')),
    responseHeaders: _jsonMap(row.read<String>('response_headers_json')),
    responseTrailers: _jsonMap(row.read<String>('response_trailers_json')),
    statusCode: row.readNullable<int>('status_code'),
    statusName: row.readNullable<String>('status_name'),
    statusMessage: row.readNullable<String>('status_message'),
    requestByteCount: row.read<int>('request_byte_count'),
    responseByteCount: row.read<int>('response_byte_count'),
    outcome: _enum(
      GrpcHistoryOutcome.values,
      row.read<String>('outcome'),
      GrpcHistoryOutcome.transportFailure,
    ),
    diagnosticCategory: row.readNullable<String>('diagnostic_category'),
    droppedEventCount: row.read<int>('dropped_event_count'),
    terminalState: row.read<String>('terminal_state'),
    createdAt: _date(row.read<int>('created_at')),
  );

  GrpcStoredStreamEvent _eventFromRow(QueryRow row) => GrpcStoredStreamEvent(
    id: row.read<String>('id'),
    sessionHistoryId: row.read<String>('session_history_id'),
    sequenceNumber: row.read<int>('sequence_number'),
    direction: _enum(
      GrpcStoredEventDirection.values,
      row.read<String>('direction'),
      GrpcStoredEventDirection.system,
    ),
    category: row.read<String>('category'),
    occurredAt: _date(row.read<int>('occurred_at')),
    decodedPayload: row.readNullable<String>('decoded_payload_json') == null
        ? null
        : _jsonMap(row.read<String>('decoded_payload_json')),
    rawByteCount: row.read<int>('raw_byte_count'),
    retainedRawBytes: row.readNullable<Uint8List>('retained_raw_bytes'),
    statusCode: row.readNullable<int>('status_code'),
    statusText: row.readNullable<String>('status_text'),
    decodeFailureCategory: row.readNullable<String>('decode_failure_category'),
  );

  T _enum<T extends Enum>(List<T> values, String name, T fallback) =>
      values.where((value) => value.name == name).firstOrNull ?? fallback;

  Map<String, Object?> _comparisonMap(GrpcInvocationHistory value) => {
    'endpoint': value.endpoint,
    'method': value.methodIdentity,
    'invocationKind': value.invocationKind.name,
    'request': value.request,
    'requestMetadata': value.requestMetadata,
    'response': value.response,
    'headers': value.responseHeaders,
    'trailers': value.responseTrailers,
    'statusCode': value.statusCode,
    'statusName': value.statusName,
    'outcome': value.outcome.name,
    'descriptorSnapshotId': value.descriptorSnapshotId,
  };

  Map<String, Object?> _eventMap(GrpcStoredStreamEvent value) => {
    'category': value.category,
    'payload': value.decodedPayload,
    'rawByteCount': value.rawByteCount,
    'statusCode': value.statusCode,
    'statusText': value.statusText,
  };

  List<GrpcComparisonChange> _compareJson(
    String path,
    Object? before,
    Object? after,
  ) {
    if (before is Map && after is Map) {
      final changes = <GrpcComparisonChange>[];
      final keys = <String>{
        ...before.keys.map((key) => key.toString()),
        ...after.keys.map((key) => key.toString()),
      }.toList()..sort();
      for (final key in keys) {
        final child = path.isEmpty ? key : '$path.$key';
        if (!before.containsKey(key)) {
          changes.add(
            GrpcComparisonChange(path: child, kind: 'added', after: after[key]),
          );
        } else if (!after.containsKey(key)) {
          changes.add(
            GrpcComparisonChange(
              path: child,
              kind: 'removed',
              before: before[key],
            ),
          );
        } else {
          changes.addAll(_compareJson(child, before[key], after[key]));
        }
      }
      return changes;
    }
    if (before is List && after is List) {
      final changes = <GrpcComparisonChange>[];
      final length = before.length > after.length
          ? before.length
          : after.length;
      for (var index = 0; index < length; index++) {
        final child = '$path[$index]';
        if (index >= before.length) {
          changes.add(
            GrpcComparisonChange(
              path: child,
              kind: 'added',
              after: after[index],
            ),
          );
        } else if (index >= after.length) {
          changes.add(
            GrpcComparisonChange(
              path: child,
              kind: 'removed',
              before: before[index],
            ),
          );
        } else {
          changes.addAll(_compareJson(child, before[index], after[index]));
        }
      }
      return changes;
    }
    if (before.runtimeType != after.runtimeType) {
      return <GrpcComparisonChange>[
        GrpcComparisonChange(
          path: path,
          kind: 'typeChanged',
          before: before,
          after: after,
        ),
      ];
    }
    return before == after
        ? const <GrpcComparisonChange>[]
        : <GrpcComparisonChange>[
            GrpcComparisonChange(
              path: path,
              kind: 'changed',
              before: before,
              after: after,
            ),
          ];
  }

  bool _bytesEqual(Uint8List left, Uint8List right) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) return false;
    }
    return true;
  }
}
