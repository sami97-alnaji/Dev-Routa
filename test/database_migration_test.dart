import 'dart:io';

import 'package:devroute_ai_studio/core/storage/database_schema.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  for (final version in <int>[1, 2, 3, 4, 5, 6]) {
    test('schema version $version upgrades to version 7 without reset', () async {
      final directory = await Directory.systemTemp.createTemp(
        'devroute-migration-',
      );
      final file = File(
        '${directory.path}${Platform.pathSeparator}database.sqlite',
      );
      final raw = sqlite.sqlite3.open(file.path);
      _createLegacySchema(raw, version);
      raw.execute(
        "INSERT INTO workspaces (id, name, created_at, updated_at${version >= 2 ? ', sort_order, production_strict_mode' : ''}) VALUES ('workspace', 'Kept workspace', 1, 1${version >= 2 ? ', 0, 0' : ''})",
      );
      raw.execute(
        "INSERT INTO collections (id, workspace_id, name, created_at, updated_at${version >= 2 ? ', sort_order' : ''}) VALUES ('collection', 'workspace', 'Kept collection', 1, 1${version >= 2 ? ', 0' : ''})",
      );
      raw.execute(
        "INSERT INTO folders (id, collection_id, name, created_at, updated_at${version >= 2 ? ', sort_order' : ''}) VALUES ('folder', 'collection', 'Kept', 1, 1${version >= 2 ? ', 0' : ''})",
      );
      raw.execute(
        "INSERT INTO environment_variables (id, environment_id, name, value_or_secret_ref, is_secret) VALUES ('variable', 'environment', 'HOST', 'localhost', 0)",
      );
      if (version >= 3) {
        raw.execute(
          "INSERT INTO realtime_configurations (id, workspace_id, protocol, name, url, payload_json, created_at, updated_at) VALUES ('realtime', 'workspace', 'websocket', 'Kept realtime', 'ws://localhost', '{}', 1, 1)",
        );
        raw.execute(
          "INSERT INTO realtime_history (id, workspace_id, configuration_id, protocol, status, summary_json, pinned, tags_json, notes, created_at${version >= 5 ? ', collection_id, request_id, environment_id, failure_category' : ''}) VALUES ('realtime-history', 'workspace', 'realtime', 'websocket', 'completed', '{}', 0, '[]', '', 1${version >= 5 ? ', NULL, NULL, NULL, NULL' : ''})",
        );
      }
      raw.execute('PRAGMA user_version = $version');
      if (version >= 6) {
        raw.execute(
          "INSERT INTO graphql_drafts (id, workspace_id, title, endpoint, document, variables_json, headers_json, updated_at) VALUES ('graphql-draft', 'workspace', 'Kept', 'https://example.test', 'query Kept { kept }', '{}', '{}', 1)",
        );
        raw.execute(
          "INSERT INTO graphql_history (id, draft_id, workspace_id, operation_type, summary_json, created_at) VALUES ('graphql-history', 'graphql-draft', 'workspace', 'query', '{}', 1)",
        );
        raw.execute(
          "INSERT INTO graphql_saved_requests (id, workspace_id, name, payload_json, sort_order, created_at, updated_at) VALUES ('graphql-saved', 'workspace', 'Kept saved', '{}', 0, 1, 1)",
        );
        raw.execute(
          "INSERT INTO graphql_schema_snapshots (id, workspace_id, endpoint_fingerprint, schema_hash, snapshot_json, fetched_at) VALUES ('graphql-schema', 'workspace', 'endpoint', 'hash', '{}', 1)",
        );
      }
      raw.close();

      final database = AppDatabase.forTesting(NativeDatabase(file));
      await database
          .customSelect('SELECT parent_folder_id FROM folders LIMIT 0')
          .get();
      for (final table in <String>[
        'grpc_descriptor_snapshots',
        'grpc_saved_requests',
        'grpc_drafts',
        'grpc_invocation_history',
        'grpc_stored_stream_events',
      ]) {
        expect(
          (await database
                  .customSelect('SELECT COUNT(*) AS count FROM $table')
                  .getSingle())
              .read<int>('count'),
          0,
        );
      }
      final indexes =
          (await database
                  .customSelect(
                    "SELECT name FROM sqlite_master WHERE type = 'index' AND name LIKE 'grpc_%'",
                  )
                  .get())
              .map((row) => row.read<String>('name'))
              .toSet();
      expect(
        indexes,
        containsAll(<String>{
          'grpc_descriptor_workspace_fingerprint',
          'grpc_saved_location_order',
          'grpc_draft_workspace_order',
          'grpc_history_filters',
          'grpc_stream_event_sequence',
        }),
      );
      expect(
        await database.customSelect('PRAGMA foreign_key_check').get(),
        isEmpty,
      );
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
      expect(schemaVersion.data.values.single, 7);
      if (version >= 6) {
        expect(
          (await database
                  .customSelect(
                    "SELECT title FROM graphql_drafts WHERE id = 'graphql-draft'",
                  )
                  .getSingle())
              .read<String>('title'),
          'Kept',
        );
        expect(
          (await database
                  .customSelect(
                    "SELECT COUNT(*) AS count FROM graphql_history WHERE id = 'graphql-history'",
                  )
                  .getSingle())
              .read<int>('count'),
          1,
        );
        expect(
          (await database
                  .customSelect(
                    "SELECT name FROM graphql_saved_requests WHERE id = 'graphql-saved'",
                  )
                  .getSingle())
              .read<String>('name'),
          'Kept saved',
        );
        expect(
          (await database
                  .customSelect(
                    "SELECT schema_hash FROM graphql_schema_snapshots WHERE id = 'graphql-schema'",
                  )
                  .getSingle())
              .read<String>('schema_hash'),
          'hash',
        );
      }
      if (version >= 3) {
        expect(
          (await database
                  .customSelect(
                    "SELECT name FROM realtime_configurations WHERE id = 'realtime'",
                  )
                  .getSingle())
              .read<String>('name'),
          'Kept realtime',
        );
      }
      await database.close();

      final reopened = AppDatabase.forTesting(NativeDatabase(file));
      expect(
        (await reopened.customSelect('PRAGMA user_version').getSingle())
            .data
            .values
            .single,
        7,
      );
      await reopened.close();
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
  if (version >= 5) {
    db.execute('ALTER TABLE realtime_history ADD COLUMN collection_id TEXT');
    db.execute('ALTER TABLE realtime_history ADD COLUMN request_id TEXT');
    db.execute('ALTER TABLE realtime_history ADD COLUMN environment_id TEXT');
    db.execute('ALTER TABLE realtime_history ADD COLUMN failure_category TEXT');
    db.execute('ALTER TABLE ai_preferences ADD COLUMN provider_model TEXT');
    db.execute('ALTER TABLE ai_preferences ADD COLUMN provider_endpoint TEXT');
    db.execute(
      'ALTER TABLE workspace_settings ADD COLUMN realtime_retention_days INTEGER NOT NULL DEFAULT 30',
    );
    db.execute(
      'ALTER TABLE workspace_settings ADD COLUMN realtime_maximum_count INTEGER NOT NULL DEFAULT 500',
    );
  }
  if (version >= 6) {
    db.execute(
      "CREATE TABLE graphql_drafts (id TEXT PRIMARY KEY, workspace_id TEXT NOT NULL, title TEXT NOT NULL, endpoint TEXT NOT NULL, document TEXT NOT NULL, operation_name TEXT, variables_json TEXT NOT NULL DEFAULT '{}', headers_json TEXT NOT NULL DEFAULT '{}', updated_at INTEGER NOT NULL)",
    );
    db.execute(
      'CREATE TABLE graphql_history (id TEXT PRIMARY KEY, draft_id TEXT, workspace_id TEXT NOT NULL, operation_type TEXT NOT NULL, summary_json TEXT NOT NULL, created_at INTEGER NOT NULL)',
    );
    db.execute(
      'CREATE TABLE graphql_saved_requests (id TEXT PRIMARY KEY, workspace_id TEXT NOT NULL, collection_id TEXT, folder_id TEXT, name TEXT NOT NULL, payload_json TEXT NOT NULL, sort_order INTEGER NOT NULL DEFAULT 0, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)',
    );
    db.execute(
      'CREATE TABLE graphql_schema_snapshots (id TEXT PRIMARY KEY, workspace_id TEXT NOT NULL, endpoint_fingerprint TEXT NOT NULL, schema_hash TEXT NOT NULL, snapshot_json TEXT NOT NULL, fetched_at INTEGER NOT NULL)',
    );
  }
}
