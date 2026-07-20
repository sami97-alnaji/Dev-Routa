import 'dart:io';

import 'package:devroute_ai_studio/core/storage/database_schema.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  for (final version in <int>[1, 2, 3, 4]) {
    test('schema version $version upgrades to version 6 without reset', () async {
      final directory = await Directory.systemTemp.createTemp(
        'devroute-migration-',
      );
      final file = File(
        '${directory.path}${Platform.pathSeparator}database.sqlite',
      );
      final raw = sqlite.sqlite3.open(file.path);
      _createLegacySchema(raw, version);
      raw.execute(
        "INSERT INTO folders (id, collection_id, name, created_at, updated_at${version >= 2 ? ', sort_order' : ''}) VALUES ('folder', 'collection', 'Kept', 1, 1${version >= 2 ? ', 0' : ''})",
      );
      raw.execute(
        "INSERT INTO environment_variables (id, environment_id, name, value_or_secret_ref, is_secret) VALUES ('variable', 'environment', 'HOST', 'localhost', 0)",
      );
      raw.execute('PRAGMA user_version = $version');
      raw.close();

      final database = AppDatabase.forTesting(NativeDatabase(file));
      await database
          .customSelect('SELECT parent_folder_id FROM folders LIMIT 0')
          .get();
      await database
          .customSelect('SELECT endpoint, document FROM graphql_drafts LIMIT 0')
          .get();
      await database
          .customSelect(
            'SELECT workspace_id, payload_json FROM graphql_saved_requests LIMIT 0',
          )
          .get();
      await database
          .customSelect(
            'SELECT schema_hash, snapshot_json FROM graphql_schema_snapshots LIMIT 0',
          )
          .get();
      await database
          .customSelect(
            'SELECT collection_id, request_id, environment_id, failure_category FROM realtime_history LIMIT 0',
          )
          .get();
      await database
          .customSelect(
            'SELECT provider_model, provider_endpoint FROM ai_preferences LIMIT 0',
          )
          .get();
      await database
          .customSelect(
            'SELECT enabled, sort_order FROM environment_variables LIMIT 0',
          )
          .get();
      await database
          .customSelect(
            'SELECT history_retention_days FROM workspace_settings LIMIT 0',
          )
          .get();
      expect(
        (await database
                .customSelect("SELECT name FROM folders WHERE id = 'folder'")
                .getSingle())
            .data['name'],
        'Kept',
      );
      expect(
        (await database
                .customSelect(
                  "SELECT enabled FROM environment_variables WHERE id = 'variable'",
                )
                .getSingle())
            .data['enabled'],
        1,
      );
      final schemaVersion = await database
          .customSelect('PRAGMA user_version')
          .getSingle();
      expect(schemaVersion.data.values.single, 6);
      await database.close();
      await directory.delete(recursive: true);
    });
  }
}

void _createLegacySchema(sqlite.Database db, int version) {
  final v2 = version >= 2;
  db.execute(
    'CREATE TABLE workspaces (id TEXT PRIMARY KEY, name TEXT NOT NULL, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL${v2 ? ', sort_order INTEGER NOT NULL DEFAULT 0, production_strict_mode INTEGER NOT NULL DEFAULT 0' : ''})',
  );
  db.execute(
    'CREATE TABLE collections (id TEXT PRIMARY KEY, workspace_id TEXT NOT NULL, name TEXT NOT NULL, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL${v2 ? ', sort_order INTEGER NOT NULL DEFAULT 0' : ''})',
  );
  db.execute(
    'CREATE TABLE folders (id TEXT PRIMARY KEY, collection_id TEXT NOT NULL, name TEXT NOT NULL, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL${v2 ? ', sort_order INTEGER NOT NULL DEFAULT 0' : ''})',
  );
  db.execute(
    'CREATE TABLE requests (id TEXT PRIMARY KEY, collection_id TEXT, folder_id TEXT, name TEXT NOT NULL, method TEXT NOT NULL, url TEXT NOT NULL, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL${v2 ? ", sort_order INTEGER NOT NULL DEFAULT 0, payload_json TEXT NOT NULL DEFAULT '{}'" : ''})',
  );
  db.execute(
    'CREATE TABLE request_headers (id TEXT PRIMARY KEY, request_id TEXT NOT NULL, name TEXT NOT NULL, value_or_secret_ref TEXT NOT NULL, is_secret INTEGER NOT NULL DEFAULT 0${v2 ? ', enabled INTEGER NOT NULL DEFAULT 1' : ''})',
  );
  db.execute(
    'CREATE TABLE request_query_params (id TEXT PRIMARY KEY, request_id TEXT NOT NULL, name TEXT NOT NULL, value TEXT NOT NULL${v2 ? ', enabled INTEGER NOT NULL DEFAULT 1' : ''})',
  );
  db.execute(
    'CREATE TABLE request_bodies (id TEXT PRIMARY KEY, request_id TEXT NOT NULL, type TEXT NOT NULL, content_or_secret_ref TEXT NOT NULL)',
  );
  db.execute(
    'CREATE TABLE environments (id TEXT PRIMARY KEY, name TEXT NOT NULL, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL${v2 ? ", workspace_id TEXT, kind TEXT NOT NULL DEFAULT 'custom', is_active INTEGER NOT NULL DEFAULT 0" : ''})',
  );
  db.execute(
    'CREATE TABLE environment_variables (id TEXT PRIMARY KEY, environment_id TEXT NOT NULL, name TEXT NOT NULL, value_or_secret_ref TEXT NOT NULL, is_secret INTEGER NOT NULL DEFAULT 0)',
  );
  db.execute(
    'CREATE TABLE request_history (id TEXT PRIMARY KEY, request_id TEXT NOT NULL, response_snapshot_id TEXT NOT NULL, created_at INTEGER NOT NULL${v2 ? ", snapshot_json TEXT NOT NULL DEFAULT '{}'" : ''})',
  );
  if (v2) {
    db.execute(
      'CREATE TABLE request_drafts (id TEXT PRIMARY KEY, request_id TEXT, title TEXT NOT NULL, payload_json TEXT NOT NULL, updated_at INTEGER NOT NULL)',
    );
  }
  if (version >= 3) {
    db.execute(
      "CREATE TABLE realtime_configurations (id TEXT PRIMARY KEY, workspace_id TEXT NOT NULL, protocol TEXT NOT NULL, name TEXT NOT NULL, url TEXT NOT NULL, payload_json TEXT NOT NULL DEFAULT '{}', created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)",
    );
    db.execute(
      'CREATE TABLE realtime_drafts (id TEXT PRIMARY KEY, configuration_id TEXT, workspace_id TEXT NOT NULL, protocol TEXT NOT NULL, title TEXT NOT NULL, payload_json TEXT NOT NULL, updated_at INTEGER NOT NULL)',
    );
    db.execute(
      'CREATE TABLE realtime_history (id TEXT PRIMARY KEY, workspace_id TEXT NOT NULL, configuration_id TEXT, protocol TEXT NOT NULL, status TEXT NOT NULL, summary_json TEXT NOT NULL, pinned INTEGER NOT NULL DEFAULT 0, tags_json TEXT NOT NULL DEFAULT \'[]\', notes TEXT NOT NULL DEFAULT \'\', created_at INTEGER NOT NULL)',
    );
    db.execute(
      'CREATE TABLE ai_preferences (id TEXT PRIMARY KEY, consent_granted INTEGER NOT NULL DEFAULT 0, provider_name TEXT, include_bodies INTEGER NOT NULL DEFAULT 0, include_headers INTEGER NOT NULL DEFAULT 0, include_history INTEGER NOT NULL DEFAULT 0, include_events INTEGER NOT NULL DEFAULT 0, updated_at INTEGER NOT NULL)',
    );
  }
  if (version >= 4) {
    db.execute('ALTER TABLE folders ADD COLUMN parent_folder_id TEXT');
    db.execute(
      'ALTER TABLE environment_variables ADD COLUMN enabled INTEGER NOT NULL DEFAULT 1',
    );
    db.execute(
      'ALTER TABLE environment_variables ADD COLUMN sort_order INTEGER NOT NULL DEFAULT 0',
    );
    db.execute(
      'CREATE TABLE workspace_settings (workspace_id TEXT PRIMARY KEY, history_retention_days INTEGER NOT NULL DEFAULT 30, history_maximum_count INTEGER NOT NULL DEFAULT 1000, response_preview_bytes INTEGER NOT NULL DEFAULT 1048576, production_strict_mode INTEGER NOT NULL DEFAULT 1, updated_at INTEGER NOT NULL)',
    );
  }
}
