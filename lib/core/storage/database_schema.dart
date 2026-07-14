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
  @override
  Set<Column> get primaryKey => {id};
}

class Collections extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class Folders extends Table {
  TextColumn get id => text()();
  TextColumn get collectionId => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
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
  @override
  Set<Column> get primaryKey => {id};
}

class RequestHeaders extends Table {
  TextColumn get id => text()();
  TextColumn get requestId => text()();
  TextColumn get name => text()();
  TextColumn get valueOrSecretRef => text()();
  BoolColumn get isSecret => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

class RequestQueryParams extends Table {
  TextColumn get id => text()();
  TextColumn get requestId => text()();
  TextColumn get name => text()();
  TextColumn get value => text()();
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
  @override
  Set<Column> get primaryKey => {id};
}

class EnvironmentVariables extends Table {
  TextColumn get id => text()();
  TextColumn get environmentId => text()();
  TextColumn get name => text()();
  TextColumn get valueOrSecretRef => text()();
  BoolColumn get isSecret => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

class RequestHistory extends Table {
  TextColumn get id => text()();
  TextColumn get requestId => text()();
  TextColumn get responseSnapshotId => text()();
  DateTimeColumn get createdAt => dateTime()();
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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() => LazyDatabase(() async {
    final directory = await getApplicationSupportDirectory();
    await directory.create(recursive: true);
    return NativeDatabase(File(path.join(directory.path, 'devroute.sqlite')));
  });
}
