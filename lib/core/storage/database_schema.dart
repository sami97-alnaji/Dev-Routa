import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

part 'database_schema.g.dart';

// Phase 1 schema draft. Sensitive values are stored by secure-storage reference only.
class Workspaces extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get productionStrictMode =>
      boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

class Collections extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {id};
}

class Folders extends Table {
  TextColumn get id => text()();
  TextColumn get collectionId => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get parentFolderId => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class Requests extends Table {
  TextColumn get id => text()();
  TextColumn get collectionId => text().nullable()();
  TextColumn get folderId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get method => text()();
  TextColumn get url => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get payloadJson => text().withDefault(const Constant('{}'))();
  @override
  Set<Column> get primaryKey => {id};
}

class RequestHeaders extends Table {
  TextColumn get id => text()();
  TextColumn get requestId => text()();
  TextColumn get name => text()();
  TextColumn get valueOrSecretRef => text()();
  BoolColumn get isSecret => boolean().withDefault(const Constant(false))();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  @override
  Set<Column> get primaryKey => {id};
}

class RequestQueryParams extends Table {
  TextColumn get id => text()();
  TextColumn get requestId => text()();
  TextColumn get name => text()();
  TextColumn get value => text()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  @override
  Set<Column> get primaryKey => {id};
}

class RequestBodies extends Table {
  TextColumn get id => text()();
  TextColumn get requestId => text()();
  TextColumn get type => text()();
  TextColumn get contentOrSecretRef => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class Environments extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get workspaceId => text().nullable()();
  TextColumn get kind => text().withDefault(const Constant('custom'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

class EnvironmentVariables extends Table {
  TextColumn get id => text()();
  TextColumn get environmentId => text()();
  TextColumn get name => text()();
  TextColumn get valueOrSecretRef => text()();
  BoolColumn get isSecret => boolean().withDefault(const Constant(false))();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {id};
}

class RequestHistory extends Table {
  TextColumn get id => text()();
  TextColumn get requestId => text()();
  TextColumn get responseSnapshotId => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get snapshotJson => text().withDefault(const Constant('{}'))();
  @override
  Set<Column> get primaryKey => {id};
}

class ResponseSnapshots extends Table {
  TextColumn get id => text()();
  TextColumn get requestId => text()();
  IntColumn get statusCode => integer().nullable()();
  TextColumn get bodyPreview => text()();
  IntColumn get durationMs => integer()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class WebSocketSessions extends Table {
  TextColumn get id => text()();
  TextColumn get url => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class AiAnalyses extends Table {
  TextColumn get id => text()();
  TextColumn get responseSnapshotId => text()();
  TextColumn get summary => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

/// Persisted, non-secret configuration for WebSocket, SSE and HTTP streams.
/// Values which can contain credentials are represented as secure-storage
/// references inside `payloadJson`, never as secret material.
class RealtimeConfigurations extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text()();
  TextColumn get protocol => text()();
  TextColumn get name => text()();
  TextColumn get url => text()();
  TextColumn get payloadJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class RealtimeDrafts extends Table {
  TextColumn get id => text()();
  TextColumn get configurationId => text().nullable()();
  TextColumn get workspaceId => text()();
  TextColumn get protocol => text()();
  TextColumn get title => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

/// Sanitized session summaries only. Raw binary payloads are deliberately not
/// retained, and all event bodies have already passed through SecretMasker.
class RealtimeHistory extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text()();
  TextColumn get configurationId => text().nullable()();
  TextColumn get protocol => text()();
  TextColumn get status => text()();
  TextColumn get collectionId => text().nullable()();
  TextColumn get requestId => text().nullable()();
  TextColumn get environmentId => text().nullable()();
  TextColumn get failureCategory => text().nullable()();
  TextColumn get summaryJson => text()();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  TextColumn get tagsJson => text().withDefault(const Constant('[]'))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class AiPreferences extends Table {
  TextColumn get id => text()();
  BoolColumn get consentGranted =>
      boolean().withDefault(const Constant(false))();
  TextColumn get providerName => text().nullable()();
  TextColumn get providerModel => text().nullable()();
  TextColumn get providerEndpoint => text().nullable()();
  BoolColumn get includeBodies =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get includeHeaders =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get includeHistory =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get includeEvents =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class RequestDrafts extends Table {
  TextColumn get id => text()();
  TextColumn get requestId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class WorkspaceSettings extends Table {
  TextColumn get workspaceId => text()();
  IntColumn get historyRetentionDays =>
      integer().withDefault(const Constant(30))();
  IntColumn get historyMaximumCount =>
      integer().withDefault(const Constant(1000))();
  IntColumn get responsePreviewBytes =>
      integer().withDefault(const Constant(1048576))();
  BoolColumn get productionStrictMode =>
      boolean().withDefault(const Constant(true))();
  IntColumn get realtimeRetentionDays =>
      integer().withDefault(const Constant(30))();
  IntColumn get realtimeMaximumCount =>
      integer().withDefault(const Constant(500))();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {workspaceId};
}

/// GraphQL documents and history persist only sanitized payload metadata.
/// Secret values remain secure-storage references owned by the caller.
class GraphqlDrafts extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text()();
  TextColumn get title => text()();
  TextColumn get endpoint => text()();
  TextColumn get document => text()();
  TextColumn get operationName => text().nullable()();
  TextColumn get variablesJson => text().withDefault(const Constant('{}'))();
  TextColumn get headersJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class GraphqlHistory extends Table {
  TextColumn get id => text()();
  TextColumn get draftId => text().nullable()();
  TextColumn get workspaceId => text()();
  TextColumn get operationType => text()();
  TextColumn get summaryJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class GraphqlSavedRequests extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text()();
  TextColumn get collectionId => text().nullable()();
  TextColumn get folderId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get payloadJson => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class GraphqlSchemaSnapshots extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text()();
  TextColumn get endpointFingerprint => text()();
  TextColumn get schemaHash => text()();
  TextColumn get snapshotJson => text()();
  DateTimeColumn get fetchedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class GrpcDescriptorSnapshots extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId =>
      text().references(Workspaces, #id, onDelete: KeyAction.cascade)();
  TextColumn get fingerprint => text()();
  TextColumn get sourceType => text()();
  TextColumn get displayName => text()();
  TextColumn get sourceIdentity => text().nullable()();
  BlobColumn get descriptorBytes => blob()();
  IntColumn get descriptorByteCount => integer()();
  IntColumn get fileCount => integer()();
  IntColumn get serviceCount => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastUsedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class GrpcSavedRequests extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId =>
      text().references(Workspaces, #id, onDelete: KeyAction.cascade)();
  TextColumn get collectionId => text().nullable()();
  TextColumn get folderId => text().nullable()();
  TextColumn get descriptorSnapshotId => text().nullable().references(
    GrpcDescriptorSnapshots,
    #id,
    onDelete: KeyAction.restrict,
  )();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get serviceFullName => text()();
  TextColumn get methodName => text()();
  TextColumn get methodPath => text()();
  TextColumn get invocationKind => text()();
  TextColumn get endpointJson => text()();
  TextColumn get requestJson => text()();
  TextColumn get metadataJson => text()();
  TextColumn get certificateReferencesJson =>
      text().withDefault(const Constant('[]'))();
  IntColumn get revision => integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class GrpcDrafts extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId =>
      text().references(Workspaces, #id, onDelete: KeyAction.cascade)();
  TextColumn get sourceSavedRequestId => text().nullable().references(
    GrpcSavedRequests,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get descriptorSnapshotId => text().nullable().references(
    GrpcDescriptorSnapshots,
    #id,
    onDelete: KeyAction.restrict,
  )();
  TextColumn get title => text()();
  TextColumn get methodIdentityJson => text()();
  TextColumn get endpointJson => text()();
  TextColumn get requestJson => text()();
  TextColumn get metadataJson => text()();
  TextColumn get certificateReferencesJson =>
      text().withDefault(const Constant('[]'))();
  IntColumn get revision => integer().withDefault(const Constant(1))();
  IntColumn get tabOrder => integer().withDefault(const Constant(0))();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastOpenedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class GrpcInvocationHistory extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId =>
      text().references(Workspaces, #id, onDelete: KeyAction.cascade)();
  TextColumn get savedRequestId => text().nullable().references(
    GrpcSavedRequests,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get descriptorSnapshotId => text().nullable().references(
    GrpcDescriptorSnapshots,
    #id,
    onDelete: KeyAction.restrict,
  )();
  TextColumn get invocationKind => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get durationMicroseconds => integer().nullable()();
  TextColumn get endpointJson => text()();
  TextColumn get methodIdentityJson => text()();
  TextColumn get requestJson => text()();
  TextColumn get requestMetadataJson => text()();
  TextColumn get responseJson => text().nullable()();
  TextColumn get responseHeadersJson => text()();
  TextColumn get responseTrailersJson => text()();
  IntColumn get statusCode => integer().nullable()();
  TextColumn get statusName => text().nullable()();
  TextColumn get statusMessage => text().nullable()();
  IntColumn get requestByteCount => integer().withDefault(const Constant(0))();
  IntColumn get responseByteCount => integer().withDefault(const Constant(0))();
  TextColumn get outcome => text()();
  TextColumn get diagnosticCategory => text().nullable()();
  IntColumn get droppedEventCount => integer().withDefault(const Constant(0))();
  TextColumn get terminalState => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class GrpcStoredStreamEvents extends Table {
  TextColumn get id => text()();
  TextColumn get sessionHistoryId => text().references(
    GrpcInvocationHistory,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get sequenceNumber => integer()();
  TextColumn get direction => text()();
  TextColumn get category => text()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get decodedPayloadJson => text().nullable()();
  IntColumn get rawByteCount => integer().withDefault(const Constant(0))();
  BlobColumn get retainedRawBytes => blob().nullable()();
  IntColumn get statusCode => integer().nullable()();
  TextColumn get statusText => text().nullable()();
  TextColumn get decodeFailureCategory => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: <Type>[
    Workspaces,
    Collections,
    Folders,
    Requests,
    RequestHeaders,
    RequestQueryParams,
    RequestBodies,
    Environments,
    EnvironmentVariables,
    RequestHistory,
    ResponseSnapshots,
    WebSocketSessions,
    AiAnalyses,
    RequestDrafts,
    RealtimeConfigurations,
    RealtimeDrafts,
    RealtimeHistory,
    AiPreferences,
    WorkspaceSettings,
    GraphqlDrafts,
    GraphqlHistory,
    GraphqlSavedRequests,
    GraphqlSchemaSnapshots,
    GrpcDescriptorSnapshots,
    GrpcSavedRequests,
    GrpcDrafts,
    GrpcInvocationHistory,
    GrpcStoredStreamEvents,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(workspaces, workspaces.sortOrder);
        await m.addColumn(workspaces, workspaces.productionStrictMode);
        await m.addColumn(collections, collections.sortOrder);
        await m.addColumn(folders, folders.sortOrder);
        await m.addColumn(requests, requests.sortOrder);
        await m.addColumn(requests, requests.payloadJson);
        await m.addColumn(requestHeaders, requestHeaders.enabled);
        await m.addColumn(requestQueryParams, requestQueryParams.enabled);
        await m.addColumn(environments, environments.workspaceId);
        await m.addColumn(environments, environments.kind);
        await m.addColumn(environments, environments.isActive);
        await m.addColumn(requestHistory, requestHistory.snapshotJson);
        await m.createTable(requestDrafts);
      }
      if (from < 3) {
        await m.createTable(realtimeConfigurations);
        await m.createTable(realtimeDrafts);
        await m.createTable(realtimeHistory);
        await m.createTable(aiPreferences);
      }
      if (from < 4) {
        await m.addColumn(folders, folders.parentFolderId);
        await m.addColumn(environmentVariables, environmentVariables.enabled);
        await m.addColumn(environmentVariables, environmentVariables.sortOrder);
        await m.createTable(workspaceSettings);
      }
      if (from < 5) {
        if (from >= 3) {
          await m.addColumn(realtimeHistory, realtimeHistory.collectionId);
          await m.addColumn(realtimeHistory, realtimeHistory.requestId);
          await m.addColumn(realtimeHistory, realtimeHistory.environmentId);
          await m.addColumn(realtimeHistory, realtimeHistory.failureCategory);
          await m.addColumn(aiPreferences, aiPreferences.providerModel);
          await m.addColumn(aiPreferences, aiPreferences.providerEndpoint);
        }
        if (from >= 4) {
          await m.addColumn(
            workspaceSettings,
            workspaceSettings.realtimeRetentionDays,
          );
          await m.addColumn(
            workspaceSettings,
            workspaceSettings.realtimeMaximumCount,
          );
        }
      }
      if (from < 6) {
        await m.createTable(graphqlDrafts);
        await m.createTable(graphqlHistory);
      }
      if (from < 7) {
        await m.createTable(grpcDescriptorSnapshots);
        await m.createTable(grpcSavedRequests);
        await m.createTable(grpcDrafts);
        await m.createTable(grpcInvocationHistory);
        await m.createTable(grpcStoredStreamEvents);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      // These additive tables were introduced after schema version 6 was
      // already published. IF NOT EXISTS upgrades existing v6 databases
      // without resetting or rewriting their data.
      await customStatement(
        '''CREATE TABLE IF NOT EXISTS graphql_saved_requests (
        id TEXT PRIMARY KEY NOT NULL, workspace_id TEXT NOT NULL,
        collection_id TEXT, folder_id TEXT, name TEXT NOT NULL,
        payload_json TEXT NOT NULL, sort_order INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)''',
      );
      await customStatement(
        '''CREATE TABLE IF NOT EXISTS graphql_schema_snapshots (
        id TEXT PRIMARY KEY NOT NULL, workspace_id TEXT NOT NULL,
        endpoint_fingerprint TEXT NOT NULL, schema_hash TEXT NOT NULL,
        snapshot_json TEXT NOT NULL, fetched_at INTEGER NOT NULL)''',
      );
      await customStatement(
        'CREATE UNIQUE INDEX IF NOT EXISTS grpc_descriptor_workspace_fingerprint ON grpc_descriptor_snapshots(workspace_id, fingerprint)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS grpc_descriptor_workspace_source ON grpc_descriptor_snapshots(workspace_id, source_type, display_name)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS grpc_saved_location_order ON grpc_saved_requests(workspace_id, collection_id, folder_id, sort_order)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS grpc_draft_workspace_order ON grpc_drafts(workspace_id, tab_order)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS grpc_history_filters ON grpc_invocation_history(workspace_id, invocation_kind, outcome, created_at)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS grpc_history_method ON grpc_invocation_history(workspace_id, method_identity_json, created_at)',
      );
      await customStatement(
        'CREATE UNIQUE INDEX IF NOT EXISTS grpc_stream_event_sequence ON grpc_stored_stream_events(session_history_id, sequence_number)',
      );
    },
  );

  static QueryExecutor _openConnection() => LazyDatabase(() async {
    final directory = await getApplicationSupportDirectory();
    await directory.create(recursive: true);
    return NativeDatabase(File(path.join(directory.path, 'devroute.sqlite')));
  });
}
