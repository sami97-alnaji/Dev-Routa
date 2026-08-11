import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:devroute_ai_studio/core/storage/database_schema.dart'
    hide
        GrpcDescriptorSnapshot,
        GrpcDraft,
        GrpcInvocationHistory,
        GrpcSavedRequest,
        GrpcStoredStreamEvent;
import 'package:devroute_ai_studio/features/grpc/data/grpc_persistence_repository.dart';
import 'package:devroute_ai_studio/features/grpc/domain/grpc_persistence_models.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late GrpcPersistenceRepository repository;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.customSelect('SELECT 1').get();
    await _workspace(database, 'workspace');
    await _workspace(database, 'other-workspace');
    repository = GrpcPersistenceRepository(database);
  });

  tearDown(() => database.close());

  test(
    'descriptor insert, dedupe, isolation and reference protection',
    () async {
      final bytes = Uint8List.fromList(<int>[10, 3, 102, 111, 111]);
      final fingerprint = sha256.convert(bytes).toString();
      final first = await repository.storeDescriptor(
        workspaceId: 'workspace',
        fingerprint: fingerprint,
        sourceType: GrpcDescriptorSourceType.reflection,
        displayName: 'Service',
        descriptorBytes: bytes,
        fileCount: 1,
        serviceCount: 1,
      );
      final duplicate = await repository.storeDescriptor(
        workspaceId: 'workspace',
        fingerprint: fingerprint,
        sourceType: GrpcDescriptorSourceType.reflection,
        displayName: 'Service',
        descriptorBytes: bytes,
        fileCount: 1,
        serviceCount: 1,
      );
      expect(duplicate.id, first.id);
      expect(
        await repository.descriptors(
          'workspace',
          sourceType: GrpcDescriptorSourceType.reflection,
          query: 'Serv',
        ),
        hasLength(1),
      );
      expect(await repository.descriptors('other-workspace'), isEmpty);
      await expectLater(
        repository.storeDescriptor(
          workspaceId: 'workspace',
          fingerprint: fingerprint,
          sourceType: GrpcDescriptorSourceType.descriptorSet,
          displayName: 'Conflict',
          descriptorBytes: Uint8List.fromList(<int>[1, 2, 3]),
          fileCount: 1,
          serviceCount: 1,
        ),
        throwsA(_failure('fingerprintMismatch')),
      );

      final request = await repository.saveRequest(
        _request(descriptorSnapshotId: first.id),
      );
      expect(request.descriptorSnapshotId, first.id);
      await expectLater(
        repository.deleteDescriptor(first.id),
        throwsA(_failure('descriptorReferenced')),
      );
      await repository.deleteRequest(request.id);
      await repository.deleteDescriptor(first.id);
      expect(await repository.descriptorById(first.id), isNull);
    },
  );

  test('concurrent descriptor inserts converge on one snapshot', () async {
    final bytes = Uint8List.fromList(<int>[8, 1]);
    final fingerprint = sha256.convert(bytes).toString();
    final values = await Future.wait(
      List<Future<GrpcDescriptorSnapshot>>.generate(
        4,
        (_) => repository.storeDescriptor(
          workspaceId: 'workspace',
          fingerprint: fingerprint,
          sourceType: GrpcDescriptorSourceType.descriptorSet,
          displayName: 'Concurrent',
          descriptorBytes: bytes,
          fileCount: 1,
          serviceCount: 0,
        ),
      ),
    );
    expect(values.map((value) => value.id).toSet(), hasLength(1));
  });

  test('saved requests enforce ownership, revisions, move and copies', () async {
    await database.customStatement(
      "INSERT INTO collections (id, workspace_id, name, created_at, updated_at, sort_order) VALUES ('collection', 'workspace', 'Collection', 1, 1, 0)",
    );
    await database.customStatement(
      "INSERT INTO folders (id, collection_id, name, created_at, updated_at, sort_order) VALUES ('folder', 'collection', 'Folder', 1, 1, 0)",
    );
    final saved = await repository.saveRequest(
      _request(collectionId: 'collection', folderId: 'folder'),
    );
    expect(saved.revision, 1);
    final renamed = await repository.renameRequest(
      saved.id,
      'Renamed',
      expectedRevision: 1,
    );
    expect(renamed.revision, 2);
    await expectLater(
      repository.renameRequest(saved.id, 'Stale', expectedRevision: 1),
      throwsA(_failure('revisionConflict')),
    );
    final copy = await repository.duplicateRequest(saved.id);
    expect(copy.id, isNot(saved.id));
    expect(copy.name, contains('Copy'));
    await repository.moveAndReorderRequests(<GrpcSavedRequest>[copy, renamed]);
    final ordered = await repository.requests('workspace');
    expect(ordered.map((item) => item.id), <String>[copy.id, renamed.id]);
    await expectLater(
      repository.saveRequest(
        _request(
          id: 'invalid-location',
          collectionId: 'collection',
          folderId: 'folder',
          workspaceId: 'other-workspace',
        ),
      ),
      throwsA(_failure('collectionWorkspace')),
    );
  });

  test('drafts restore independently and reject stale autosaves', () async {
    final saved = await repository.saveRequest(_request());
    final draft = await repository.openRequestAsDraft(saved.id);
    expect(draft.sourceSavedRequestId, saved.id);
    expect(draft.dirty, isFalse);
    final autosaved = await repository.saveDraft(
      _draft(
        id: draft.id,
        sourceSavedRequestId: draft.sourceSavedRequestId,
        request: <String, Object?>{'message': 'independent'},
        revision: draft.revision,
      ),
      expectedRevision: draft.revision,
    );
    expect(autosaved.request['message'], 'independent');
    expect(
      (await repository.requestById(saved.id))!.request['message'],
      'hello',
    );
    await expectLater(
      repository.saveDraft(
        _draft(id: draft.id, revision: draft.revision),
        expectedRevision: draft.revision,
      ),
      throwsA(_failure('revisionConflict')),
    );
    expect(await repository.drafts('workspace'), hasLength(1));
    await repository.deleteDraft(draft.id);
    expect(await repository.drafts('workspace'), isEmpty);
  });

  test(
    'unary history supports filtering, replay and JSON comparison',
    () async {
      final left = _history(
        id: 'left',
        response: <String, Object?>{'value': 1, 'kept': true},
        requestByteCount: 10,
        responseByteCount: 20,
        durationMicroseconds: 100,
      );
      final right = _history(
        id: 'right',
        response: <String, Object?>{'value': 2, 'added': 'yes'},
        requestByteCount: 12,
        responseByteCount: 25,
        durationMicroseconds: 160,
      );
      await repository.recordHistory(left);
      await repository.recordHistory(right);
      final filtered = await repository.history(
        'workspace',
        filter: const GrpcHistoryFilter(
          invocationKind: GrpcPersistedInvocationKind.unary,
          outcome: GrpcHistoryOutcome.success,
          query: 'Echo',
        ),
        limit: 10,
      );
      expect(filtered, hasLength(2));
      final replay = await repository.replayHistory(left.id);
      expect(replay.id, isNot(left.id));
      expect(replay.methodIdentity['methodName'], 'Echo');
      final comparison = repository.compareUnary(left, right);
      expect(comparison.durationDeltaMicroseconds, 60);
      expect(
        comparison.changes.map((change) => change.path),
        containsAll(<String>[
          'response.value',
          'response.kept',
          'response.added',
        ]),
      );
    },
  );

  test(
    'stream history orders events, bounds retention and finalizes once',
    () async {
      final session = _history(
        id: 'stream',
        invocationKind: GrpcPersistedInvocationKind.bidirectionalStreaming,
        completedAt: null,
        durationMicroseconds: null,
        terminalState: 'active',
        finalized: false,
      );
      await repository.recordHistory(session);
      await repository.appendEvents(
        session.id,
        <GrpcStoredStreamEvent>[
          _event(0, direction: GrpcStoredEventDirection.sent),
          _event(1, direction: GrpcStoredEventDirection.received),
          _event(2, direction: GrpcStoredEventDirection.system),
        ],
        maximumEvents: 2,
        maximumRetainedRawBytes: 2,
      );
      expect(
        (await repository.events(
          session.id,
        )).map((event) => event.sequenceNumber),
        <int>[0, 1],
      );
      await repository.finalizeStreamingSession(
        session.id,
        completedAt: session.startedAt.add(const Duration(seconds: 1)),
        outcome: GrpcHistoryOutcome.cancelled,
        terminalState: 'cancelled',
      );
      await expectLater(
        repository.finalizeStreamingSession(
          session.id,
          completedAt: DateTime.now(),
          outcome: GrpcHistoryOutcome.success,
          terminalState: 'completed',
        ),
        throwsA(_failure('alreadyFinalized')),
      );
      await expectLater(
        repository.appendEvents(session.id, <GrpcStoredStreamEvent>[_event(3)]),
        throwsA(_failure('historyFinalized')),
      );
    },
  );

  test('stream comparison is deterministic and child events cascade', () async {
    final left = _history(
      id: 'stream-left',
      invocationKind: GrpcPersistedInvocationKind.serverStreaming,
      droppedEventCount: 1,
    );
    final right = _history(
      id: 'stream-right',
      invocationKind: GrpcPersistedInvocationKind.serverStreaming,
    );
    await repository.recordHistory(
      left,
      events: <GrpcStoredStreamEvent>[
        _event(
          0,
          direction: GrpcStoredEventDirection.received,
          payload: {'value': 1},
        ),
        _event(1, direction: GrpcStoredEventDirection.received),
      ],
    );
    await repository.recordHistory(
      right,
      events: <GrpcStoredStreamEvent>[
        _event(
          0,
          direction: GrpcStoredEventDirection.received,
          payload: {'value': 2},
        ),
        _event(2, direction: GrpcStoredEventDirection.received),
      ],
    );
    final comparison = await repository.compareStreaming(left.id, right.id);
    expect(comparison.retentionWarning, isTrue);
    expect(comparison.onlyInLeft, <int>[1]);
    expect(comparison.onlyInRight, <int>[2]);
    expect(comparison.eventChanges.single.path, contains('payload.value'));
    await repository.deleteHistory(left.id);
    expect(await repository.events(left.id), isEmpty);
  });

  test('retention is transactional by age, count and byte budget', () async {
    for (var index = 0; index < 4; index++) {
      final entry = _history(
        id: 'retention-$index',
        startedAt: DateTime.now().subtract(Duration(days: 10 - index)),
        createdAt: DateTime.now().subtract(Duration(days: 10 - index)),
      );
      await repository.recordHistory(
        entry,
        events: <GrpcStoredStreamEvent>[_event(0, retainedBytes: Uint8List(4))],
      );
    }
    await repository.applyHistoryRetention(
      'workspace',
      const GrpcRetentionPolicy(
        maximumAge: Duration(days: 30),
        maximumCount: 2,
        maximumRetainedBytes: 4,
      ),
    );
    expect(await repository.history('workspace'), hasLength(1));
  });

  test('exact runtime secrets never enter any persisted row', () async {
    const secret = 'z9Q-secret-value-7xP';
    final bytes = Uint8List.fromList(<int>[8, 1]);
    final descriptor = await repository.storeDescriptor(
      workspaceId: 'workspace',
      fingerprint: sha256.convert(bytes).toString(),
      sourceType: GrpcDescriptorSourceType.reflection,
      displayName: 'ordinary $secret',
      sourceIdentity: 'server-$secret',
      descriptorBytes: bytes,
      fileCount: 1,
      serviceCount: 1,
      runtimeSecrets: const <String>[secret],
    );
    final saved = await repository.saveRequest(
      _request(
        descriptorSnapshotId: descriptor.id,
        metadata: <String, Object?>{'ordinary': secret},
      ),
      runtimeSecrets: const <String>[secret],
    );
    await repository.saveDraft(
      _draft(
        sourceSavedRequestId: saved.id,
        request: <String, Object?>{
          'nested': <Object?>[secret],
        },
      ),
      runtimeSecrets: const <String>[secret],
    );
    await repository.recordHistory(
      _history(
        id: 'secret-history',
        request: <String, Object?>{'ordinary': secret},
        statusMessage: 'failure $secret',
      ),
      events: <GrpcStoredStreamEvent>[
        _event(0, payload: <String, Object?>{'ordinary': secret}),
      ],
      runtimeSecrets: const <String>[secret],
    );

    final serialized = StringBuffer();
    for (final table in <String>[
      'grpc_descriptor_snapshots',
      'grpc_saved_requests',
      'grpc_drafts',
      'grpc_invocation_history',
      'grpc_stored_stream_events',
    ]) {
      for (final row
          in await database.customSelect('SELECT * FROM $table').get()) {
        serialized.write(jsonEncode(row.data));
      }
    }
    expect(serialized.toString(), isNot(contains(secret)));
  });

  test(
    'exact runtime secret bytes never enter the SQLite database file',
    () async {
      const secret = 'raw-file-secret-Q7m4K2';
      await database.close();
      final directory = await Directory.systemTemp.createTemp(
        'devroute-grpc-secret-scan-',
      );
      final file = File(
        '${directory.path}${Platform.pathSeparator}grpc-secrets.sqlite',
      );
      final fileDatabase = AppDatabase.forTesting(NativeDatabase(file));
      await fileDatabase.customSelect('SELECT 1').get();
      await _workspace(fileDatabase, 'workspace');
      final fileRepository = GrpcPersistenceRepository(fileDatabase);
      final bytes = Uint8List.fromList(<int>[8, 1]);
      final descriptor = await fileRepository.storeDescriptor(
        workspaceId: 'workspace',
        fingerprint: sha256.convert(bytes).toString(),
        sourceType: GrpcDescriptorSourceType.reflection,
        displayName: 'descriptor $secret',
        sourceIdentity: 'endpoint $secret',
        descriptorBytes: bytes,
        fileCount: 1,
        serviceCount: 1,
        runtimeSecrets: const <String>[secret],
      );
      await fileRepository.saveRequest(
        _request(
          descriptorSnapshotId: descriptor.id,
          metadata: const <String, Object?>{
            'ordinary': secret,
            'nested': <Object?>[secret],
          },
        ),
        runtimeSecrets: const <String>[secret],
      );
      await fileRepository.recordHistory(
        _history(
          id: 'raw-secret-history',
          request: const <String, Object?>{'ordinary': secret},
          response: const <String, Object?>{
            'nested': <Object?>[secret],
          },
          statusMessage: 'status $secret',
        ),
        events: <GrpcStoredStreamEvent>[
          _event(
            0,
            payload: const <String, Object?>{
              'repeated': <Object?>[secret],
            },
          ),
        ],
        runtimeSecrets: const <String>[secret],
      );
      await fileDatabase.close();

      final databaseBytes = await file.readAsBytes();
      final secretBytes = utf8.encode(secret);
      expect(_containsBytes(databaseBytes, secretBytes), isFalse);
      await directory.delete(recursive: true);
    },
  );

  test('workspace deletion cascades only its gRPC data', () async {
    await repository.saveRequest(_request());
    await repository.saveRequest(
      _request(id: 'other-request', workspaceId: 'other-workspace'),
    );
    await database.customStatement(
      "DELETE FROM workspaces WHERE id = 'workspace'",
    );
    expect(await repository.requests('workspace'), isEmpty);
    expect(await repository.requests('other-workspace'), hasLength(1));
    expect(
      await database.customSelect('PRAGMA foreign_key_check').get(),
      isEmpty,
    );
  });

  test(
    'stale descriptor retention deletes only unreferenced snapshots',
    () async {
      final firstBytes = Uint8List.fromList(<int>[8, 1]);
      final secondBytes = Uint8List.fromList(<int>[8, 2]);
      final referenced = await repository.storeDescriptor(
        workspaceId: 'workspace',
        fingerprint: sha256.convert(firstBytes).toString(),
        sourceType: GrpcDescriptorSourceType.descriptorSet,
        displayName: 'Referenced',
        descriptorBytes: firstBytes,
        fileCount: 1,
        serviceCount: 1,
      );
      final unused = await repository.storeDescriptor(
        workspaceId: 'workspace',
        fingerprint: sha256.convert(secondBytes).toString(),
        sourceType: GrpcDescriptorSourceType.descriptorSet,
        displayName: 'Unused',
        descriptorBytes: secondBytes,
        fileCount: 1,
        serviceCount: 1,
      );
      await repository.saveRequest(
        _request(descriptorSnapshotId: referenced.id),
      );
      await database.customStatement(
        'UPDATE grpc_descriptor_snapshots SET last_used_at = 1',
      );
      await repository.deleteStaleDescriptors(
        'workspace',
        DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(await repository.descriptorById(referenced.id), isNotNull);
      expect(await repository.descriptorById(unused.id), isNull);
    },
  );

  test('malformed persisted draft JSON returns a typed failure', () async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await database.customStatement(
      '''INSERT INTO grpc_drafts
      (id, workspace_id, title, method_identity_json, endpoint_json,
       request_json, metadata_json, certificate_references_json, revision,
       tab_order, dirty, created_at, updated_at, last_opened_at)
      VALUES ('malformed', 'workspace', 'Malformed', '{}', '{}', '[]', '{}',
      '[]', 1, 0, 1, ?, ?, ?)''',
      <Object?>[now, now, now],
    );
    await expectLater(
      repository.draftById('malformed'),
      throwsA(_failure('malformedJson')),
    );
  });

  test('history pagination and explicit deletion remain bounded', () async {
    for (var index = 0; index < 3; index++) {
      await repository.recordHistory(_history(id: 'page-$index'));
    }
    expect(
      await repository.history('workspace', limit: 2, offset: 1),
      hasLength(2),
    );
    await expectLater(
      repository.history('workspace', limit: 201),
      throwsA(_failure('pagination')),
    );
    await repository.deleteHistory('page-0');
    expect(await repository.historyById('page-0'), isNull);
    await repository.clearHistory('workspace');
    expect(await repository.history('workspace'), isEmpty);
  });

  test('a conflicting event batch rolls back without partial rows', () async {
    final session = _history(
      id: 'atomic-stream',
      invocationKind: GrpcPersistedInvocationKind.clientStreaming,
      finalized: false,
      terminalState: 'active',
    );
    await repository.recordHistory(session);
    await expectLater(
      repository.appendEvents(session.id, <GrpcStoredStreamEvent>[
        _event(0),
        _event(0, payload: const <String, Object?>{'duplicate': true}),
      ]),
      throwsA(isA<Exception>()),
    );
    expect(await repository.events(session.id), isEmpty);
  });
}

Future<void> _workspace(
  AppDatabase database,
  String id,
) => database.customStatement(
  'INSERT INTO workspaces (id, name, created_at, updated_at, sort_order, production_strict_mode) VALUES (?, ?, 1, 1, 0, 0)',
  <Object?>[id, id],
);

GrpcSavedRequest _request({
  String id = 'saved',
  String workspaceId = 'workspace',
  String? collectionId,
  String? folderId,
  String? descriptorSnapshotId,
  Map<String, Object?>? metadata,
}) {
  final now = DateTime.now();
  return GrpcSavedRequest(
    id: id,
    workspaceId: workspaceId,
    collectionId: collectionId,
    folderId: folderId,
    descriptorSnapshotId: descriptorSnapshotId,
    name: 'Echo',
    sortOrder: 0,
    serviceFullName: 'test.EchoService',
    methodName: 'Echo',
    methodPath: '/test.EchoService/Echo',
    invocationKind: GrpcPersistedInvocationKind.unary,
    endpoint: const <String, Object?>{
      'hostTemplate': 'localhost',
      'port': 443,
      'plaintext': false,
    },
    request: const <String, Object?>{'message': 'hello'},
    metadata: metadata ?? const <String, Object?>{},
    certificateReferences: const <String>['secure-ref:ca'],
    revision: 0,
    createdAt: now,
    updatedAt: now,
  );
}

GrpcDraft _draft({
  String id = 'draft',
  String workspaceId = 'workspace',
  String? sourceSavedRequestId,
  Map<String, Object?>? request,
  int revision = 0,
}) {
  final now = DateTime.now();
  return GrpcDraft(
    id: id,
    workspaceId: workspaceId,
    sourceSavedRequestId: sourceSavedRequestId,
    title: 'Draft',
    methodIdentity: const <String, Object?>{
      'serviceFullName': 'test.EchoService',
      'methodName': 'Echo',
      'methodPath': '/test.EchoService/Echo',
      'invocationKind': 'unary',
    },
    endpoint: const <String, Object?>{'hostTemplate': 'localhost', 'port': 443},
    request: request ?? const <String, Object?>{'message': 'hello'},
    metadata: const <String, Object?>{},
    certificateReferences: const <String>['secure-ref:ca'],
    revision: revision,
    tabOrder: 0,
    dirty: true,
    createdAt: now,
    updatedAt: now,
    lastOpenedAt: now,
  );
}

GrpcInvocationHistory _history({
  required String id,
  GrpcPersistedInvocationKind invocationKind =
      GrpcPersistedInvocationKind.unary,
  DateTime? startedAt,
  DateTime? completedAt,
  DateTime? createdAt,
  int? durationMicroseconds = 100,
  Map<String, Object?>? request,
  Map<String, Object?>? response,
  String? statusMessage,
  int requestByteCount = 10,
  int responseByteCount = 20,
  int droppedEventCount = 0,
  String terminalState = 'completed',
  bool finalized = true,
}) {
  final start = startedAt ?? DateTime.now();
  return GrpcInvocationHistory(
    id: id,
    workspaceId: 'workspace',
    invocationKind: invocationKind,
    startedAt: start,
    completedAt: finalized
        ? completedAt ?? start.add(const Duration(milliseconds: 1))
        : null,
    durationMicroseconds: finalized ? durationMicroseconds : null,
    endpoint: const <String, Object?>{'host': 'localhost', 'port': 443},
    methodIdentity: const <String, Object?>{
      'serviceFullName': 'test.EchoService',
      'methodName': 'Echo',
      'methodPath': '/test.EchoService/Echo',
    },
    request: request ?? const <String, Object?>{'message': 'hello'},
    requestMetadata: const <String, Object?>{},
    response: response ?? const <String, Object?>{'message': 'hello'},
    responseHeaders: const <String, Object?>{},
    responseTrailers: const <String, Object?>{},
    statusCode: 0,
    statusName: 'OK',
    statusMessage: statusMessage,
    requestByteCount: requestByteCount,
    responseByteCount: responseByteCount,
    outcome: GrpcHistoryOutcome.success,
    droppedEventCount: droppedEventCount,
    terminalState: terminalState,
    createdAt: createdAt ?? start,
  );
}

GrpcStoredStreamEvent _event(
  int sequence, {
  GrpcStoredEventDirection direction = GrpcStoredEventDirection.received,
  Map<String, Object?>? payload,
  Uint8List? retainedBytes,
}) => GrpcStoredStreamEvent(
  id: 'event-${direction.name}-$sequence',
  sessionHistoryId: 'ignored-by-repository',
  sequenceNumber: sequence,
  direction: direction,
  category: 'message',
  occurredAt: DateTime.now(),
  decodedPayload: payload ?? <String, Object?>{'sequence': sequence},
  rawByteCount: retainedBytes?.length ?? 1,
  retainedRawBytes: retainedBytes ?? Uint8List.fromList(<int>[sequence]),
);

Matcher _failure(String category) => isA<GrpcPersistenceFailure>().having(
  (failure) => failure.category,
  'category',
  category,
);

bool _containsBytes(List<int> source, List<int> pattern) {
  if (pattern.isEmpty || source.length < pattern.length) return false;
  for (var start = 0; start <= source.length - pattern.length; start++) {
    var matches = true;
    for (var offset = 0; offset < pattern.length; offset++) {
      if (source[start + offset] != pattern[offset]) {
        matches = false;
        break;
      }
    }
    if (matches) return true;
  }
  return false;
}
