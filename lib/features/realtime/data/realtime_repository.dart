import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/storage/database_schema.dart';
import '../../../shared/models/api_models.dart';
import '../domain/realtime_models.dart';

class RealtimeHistoryEntry {
  const RealtimeHistoryEntry({
    required this.id,
    required this.workspaceId,
    required this.protocol,
    required this.status,
    required this.summary,
    required this.pinned,
    required this.tags,
    required this.notes,
    required this.createdAt,
  });
  final String id;
  final String workspaceId;
  final RealtimeProtocolType protocol;
  final String status;
  final Map<String, dynamic> summary;
  final bool pinned;
  final List<String> tags;
  final String notes;
  final DateTime createdAt;
}

class RealtimeRepository {
  RealtimeRepository(this._database);
  final AppDatabase _database;
  static const _uuid = Uuid();

  Future<void> saveConfiguration(RealtimeSessionConfig config) async {
    final now = DateTime.now();
    await _database.customStatement(
      'INSERT OR REPLACE INTO realtime_configurations (id, workspace_id, protocol, name, url, payload_json, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, COALESCE((SELECT created_at FROM realtime_configurations WHERE id = ?), ?), ?)',
      <Variable>[
        Variable.withString(config.id),
        Variable.withString(config.workspaceId ?? ''),
        Variable.withString(config.protocol.name),
        Variable.withString(config.name),
        Variable.withString(config.url),
        Variable.withString(jsonEncode(_payload(config))),
        Variable.withString(config.id),
        Variable.withDateTime(now),
        Variable.withDateTime(now),
      ],
    );
  }

  Future<void> saveDraft(
    RealtimeSessionConfig config,
  ) => _database.customStatement(
    'INSERT OR REPLACE INTO realtime_drafts (id, configuration_id, workspace_id, protocol, title, payload_json, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?)',
    <Variable>[
      Variable.withString('active-${config.id}'),
      Variable.withString(config.id),
      Variable.withString(config.workspaceId ?? ''),
      Variable.withString(config.protocol.name),
      Variable.withString(config.name),
      Variable.withString(jsonEncode(_payload(config))),
      Variable.withDateTime(DateTime.now()),
    ],
  );

  Future<RealtimeSessionConfig?> draft(String configurationId) async {
    final row = await _database
        .customSelect(
          'SELECT * FROM realtime_drafts WHERE configuration_id = ? ORDER BY updated_at DESC LIMIT 1',
          variables: <Variable>[Variable.withString(configurationId)],
        )
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    final payload =
        jsonDecode(row.read<String>('payload_json')) as Map<String, dynamic>;
    return _fromPayload(
      id: configurationId,
      workspaceId: row.read<String>('workspace_id'),
      protocol: RealtimeProtocolType.values.byName(
        row.read<String>('protocol'),
      ),
      payload: payload,
    );
  }

  Future<List<RealtimeSessionConfig>> configurations(String workspaceId) async {
    final rows = await _database
        .customSelect(
          'SELECT * FROM realtime_configurations WHERE workspace_id = ? ORDER BY updated_at DESC',
          variables: <Variable>[Variable.withString(workspaceId)],
        )
        .get();
    return rows
        .map(
          (row) => _fromPayload(
            id: row.read<String>('id'),
            workspaceId: row.read<String>('workspace_id'),
            protocol: RealtimeProtocolType.values.byName(
              row.read<String>('protocol'),
            ),
            payload:
                jsonDecode(row.read<String>('payload_json'))
                    as Map<String, dynamic>,
            name: row.read<String>('name'),
            url: row.read<String>('url'),
          ),
        )
        .toList();
  }

  Map<String, Object?> _payload(RealtimeSessionConfig config) =>
      <String, Object?>{
        'headers': config.headers
            .map(
              (item) => <String, Object?>{
                'key': item.key,
                'value': item.isSecret ? '' : item.value,
                'enabled': item.enabled,
                'isSecret': item.isSecret,
                'secretRef': item.secretRef,
              },
            )
            .toList(),
        'params': config.queryParams
            .map(
              (item) => <String, Object?>{
                'key': item.key,
                'value': item.value,
                'enabled': item.enabled,
              },
            )
            .toList(),
        'method': config.method.name,
        'subprotocols': config.subprotocols,
        'lastEventId': config.lastEventId,
        'reconnect': <String, Object?>{
          'enabled': config.reconnectPolicy.enabled,
          'maxAttempts': config.reconnectPolicy.maxAttempts,
          'initialDelayMs': config.reconnectPolicy.initialDelay.inMilliseconds,
          'maxDelayMs': config.reconnectPolicy.maxDelay.inMilliseconds,
        },
      };

  RealtimeSessionConfig _fromPayload({
    required String id,
    required String workspaceId,
    required RealtimeProtocolType protocol,
    required Map<String, dynamic> payload,
    String? name,
    String? url,
  }) {
    final reconnect =
        (payload['reconnect'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    return RealtimeSessionConfig(
      id: id,
      workspaceId: workspaceId.isEmpty ? null : workspaceId,
      protocol: protocol,
      name: name ?? payload['name'] as String? ?? 'Untitled realtime request',
      url: url ?? payload['url'] as String? ?? '',
      method: HttpMethod.values.byName(payload['method'] as String? ?? 'get'),
      headers: ((payload['headers'] as List?) ?? const <Object>[]).map((item) {
        final value = (item as Map).cast<String, dynamic>();
        return RequestHeaderModel(
          key: value['key'] as String? ?? '',
          value: value['value'] as String? ?? '',
          enabled: value['enabled'] as bool? ?? true,
          isSecret: value['isSecret'] as bool? ?? false,
          secretRef: value['secretRef'] as String?,
        );
      }).toList(),
      queryParams: ((payload['params'] as List?) ?? const <Object>[]).map((
        item,
      ) {
        final value = (item as Map).cast<String, dynamic>();
        return RequestQueryParamModel(
          key: value['key'] as String? ?? '',
          value: value['value'] as String? ?? '',
          enabled: value['enabled'] as bool? ?? true,
        );
      }).toList(),
      subprotocols: ((payload['subprotocols'] as List?) ?? const <Object>[])
          .map((item) => item.toString())
          .toList(),
      lastEventId: payload['lastEventId'] as String?,
      reconnectPolicy: ReconnectPolicy(
        enabled: reconnect['enabled'] as bool? ?? false,
        maxAttempts: reconnect['maxAttempts'] as int? ?? 3,
        initialDelay: Duration(
          milliseconds: reconnect['initialDelayMs'] as int? ?? 1000,
        ),
        maxDelay: Duration(
          milliseconds: reconnect['maxDelayMs'] as int? ?? 15000,
        ),
      ),
    );
  }

  Future<void> saveSession(RealtimeSessionSnapshot snapshot) async {
    final config = snapshot.config;
    final state = snapshot.state;
    final summary = <String, Object?>{
      'url': config.url,
      'name': config.name,
      'bytesIn': state.metrics.bytesIn,
      'bytesOut': state.metrics.bytesOut,
      'durationMs': state.metrics.duration?.inMilliseconds,
      'failure': state.failure?.message,
      'events': state.messages
          .map(
            (message) => <String, Object?>{
              'direction': message.direction.name,
              'type': message.payloadType.name,
              'content': message.content,
              'event': message.eventName,
              'id': message.eventId,
              'size': message.sizeBytes,
              'time': message.timestamp.toIso8601String(),
            },
          )
          .toList(),
    };
    await _database.customStatement(
      'INSERT INTO realtime_history (id, workspace_id, configuration_id, protocol, status, summary_json, pinned, tags_json, notes, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      <Variable>[
        Variable.withString(_uuid.v4()),
        Variable.withString(config.workspaceId ?? ''),
        Variable.withString(config.id),
        Variable.withString(config.protocol.name),
        Variable.withString(state.status.name),
        Variable.withString(jsonEncode(summary)),
        Variable.withBool(false),
        Variable.withString('[]'),
        Variable.withString(''),
        Variable.withDateTime(DateTime.now()),
      ],
    );
  }

  Future<List<RealtimeHistoryEntry>> history({
    RealtimeProtocolType? protocol,
    String search = '',
  }) async {
    final result = await _database
        .customSelect(
          'SELECT * FROM realtime_history ${protocol == null ? '' : 'WHERE protocol = ?'} ORDER BY created_at DESC',
          variables: protocol == null
              ? const <Variable>[]
              : <Variable>[Variable.withString(protocol.name)],
        )
        .get();
    return result
        .map((row) {
          final summary =
              jsonDecode(row.read<String>('summary_json'))
                  as Map<String, dynamic>;
          return RealtimeHistoryEntry(
            id: row.read<String>('id'),
            workspaceId: row.read<String>('workspace_id'),
            protocol: RealtimeProtocolType.values.byName(
              row.read<String>('protocol'),
            ),
            status: row.read<String>('status'),
            summary: summary,
            pinned: row.read<bool>('pinned'),
            tags: (jsonDecode(row.read<String>('tags_json')) as List)
                .cast<String>(),
            notes: row.read<String>('notes'),
            createdAt: row.read<DateTime>('created_at'),
          );
        })
        .where(
          (item) =>
              search.isEmpty ||
              jsonEncode(
                item.summary,
              ).toLowerCase().contains(search.toLowerCase()),
        )
        .toList();
  }

  Future<void> updateMetadata(
    String id, {
    bool? pinned,
    List<String>? tags,
    String? notes,
  }) async {
    final sets = <String>[];
    final values = <Variable>[];
    if (pinned != null) {
      sets.add('pinned = ?');
      values.add(Variable.withBool(pinned));
    }
    if (tags != null) {
      sets.add('tags_json = ?');
      values.add(Variable.withString(jsonEncode(tags)));
    }
    if (notes != null) {
      sets.add('notes = ?');
      values.add(Variable.withString(notes));
    }
    if (sets.isEmpty) {
      return;
    }
    values.add(Variable.withString(id));
    await _database.customStatement(
      'UPDATE realtime_history SET ${sets.join(', ')} WHERE id = ?',
      values,
    );
  }

  Future<void> retain({required int maximumCount, DateTime? olderThan}) async {
    if (olderThan != null) {
      await _database.customStatement(
        'DELETE FROM realtime_history WHERE created_at < ?',
        <Variable>[Variable.withDateTime(olderThan)],
      );
    }
    await _database.customStatement(
      'DELETE FROM realtime_history WHERE id IN (SELECT id FROM realtime_history ORDER BY created_at DESC LIMIT -1 OFFSET ?)',
      <Variable>[Variable.withInt(maximumCount)],
    );
  }
}
