import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/ai/consent_ai_service.dart';
import '../../../core/storage/database_schema.dart';
import '../../../core/security/secret_masker.dart';
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

class RealtimeHistoryFilter {
  const RealtimeHistoryFilter({
    this.workspaceId,
    this.collectionId,
    this.requestId,
    this.environmentId,
    this.protocol,
    this.status,
    this.failureCategory,
    this.from,
    this.to,
    this.search = '',
  });
  final String? workspaceId;
  final String? collectionId;
  final String? requestId;
  final String? environmentId;
  final RealtimeProtocolType? protocol;
  final String? status;
  final String? failureCategory;
  final DateTime? from;
  final DateTime? to;
  final String search;
}

class RealtimeRepository {
  RealtimeRepository(this._database);
  final AppDatabase _database;
  static const _uuid = Uuid();

  Future<void> saveConfiguration(RealtimeSessionConfig config) async {
    final now = DateTime.now();
    await _database.customStatement(
      'INSERT OR REPLACE INTO realtime_configurations (id, workspace_id, protocol, name, url, payload_json, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, COALESCE((SELECT created_at FROM realtime_configurations WHERE id = ?), ?), ?)',
      <Object?>[
        config.id,
        config.workspaceId ?? '',
        config.protocol.name,
        config.name,
        config.url,
        jsonEncode(_payload(config)),
        config.id,
        _date(now),
        _date(now),
      ],
    );
  }

  Future<void> saveDraft(
    RealtimeSessionConfig config,
  ) => _database.customStatement(
    'INSERT OR REPLACE INTO realtime_drafts (id, configuration_id, workspace_id, protocol, title, payload_json, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?)',
    <Object?>[
      'active-${config.id}',
      config.id,
      config.workspaceId ?? '',
      config.protocol.name,
      config.name,
      jsonEncode(_payload(config)),
      _date(DateTime.now()),
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
        'url': config.url,
        'name': config.name,
        'body': config.body == null
            ? null
            : <String, Object?>{
                'type': config.body!.type.name,
                'content': config.body!.content,
                'contentType': config.body!.contentType,
                'filePath': config.body!.filePath,
              },
        'auth': <String, Object?>{
          'type': config.auth.type.name,
          'username': config.auth.username,
          'passwordSecretRef': config.auth.passwordSecretRef,
          'tokenSecretRef': config.auth.tokenSecretRef,
          'apiKeyName': config.auth.apiKeyName,
          'apiKeySecretRef': config.auth.apiKeySecretRef,
        },
        'subprotocols': config.subprotocols,
        'lastEventId': config.lastEventId,
        'connectionTimeoutMs': config.connectionTimeout.inMilliseconds,
        'maxEvents': config.maxEvents,
        'streamMode': config.streamMode.name,
        'collectionId': config.collectionId,
        'requestId': config.requestId,
        'environmentId': config.environmentId,
        'productionEnvironment': config.productionEnvironment,
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
    final body = (payload['body'] as Map?)?.cast<String, dynamic>();
    final auth =
        (payload['auth'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    return RealtimeSessionConfig(
      id: id,
      workspaceId: workspaceId.isEmpty ? null : workspaceId,
      protocol: protocol,
      name: name ?? payload['name'] as String? ?? 'Untitled realtime request',
      url: url ?? payload['url'] as String? ?? '',
      method: HttpMethod.values.byName(payload['method'] as String? ?? 'get'),
      body: body == null
          ? null
          : RequestBodyModel(
              type: RequestBodyType.values.byName(
                body['type'] as String? ?? 'none',
              ),
              content: body['content'] as String? ?? '',
              contentType: body['contentType'] as String?,
              filePath: body['filePath'] as String?,
            ),
      auth: RequestAuthModel(
        type: AuthType.values.byName(auth['type'] as String? ?? 'none'),
        username: auth['username'] as String? ?? '',
        passwordSecretRef: auth['passwordSecretRef'] as String?,
        tokenSecretRef: auth['tokenSecretRef'] as String?,
        apiKeyName: auth['apiKeyName'] as String? ?? '',
        apiKeySecretRef: auth['apiKeySecretRef'] as String?,
      ),
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
      connectionTimeout: Duration(
        milliseconds: payload['connectionTimeoutMs'] as int? ?? 15000,
      ),
      maxEvents: payload['maxEvents'] as int? ?? 500,
      streamMode: HttpStreamMode.values.byName(
        payload['streamMode'] as String? ?? 'raw',
      ),
      collectionId: payload['collectionId'] as String?,
      requestId: payload['requestId'] as String?,
      environmentId: payload['environmentId'] as String?,
      productionEnvironment: payload['productionEnvironment'] as bool? ?? false,
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
      'droppedMessages': state.droppedMessages,
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
    final sanitizedSummary = SecretMasker.redactText(jsonEncode(summary));
    await _database.customStatement(
      'INSERT INTO realtime_history (id, workspace_id, configuration_id, protocol, status, collection_id, request_id, environment_id, failure_category, summary_json, pinned, tags_json, notes, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      <Object?>[
        _uuid.v4(),
        config.workspaceId ?? '',
        config.id,
        config.protocol.name,
        state.status.name,
        config.collectionId,
        config.requestId,
        config.environmentId,
        state.failure?.category,
        sanitizedSummary,
        0,
        '[]',
        '',
        _date(DateTime.now()),
      ],
    );
  }

  Future<List<RealtimeHistoryEntry>> history({
    RealtimeProtocolType? protocol,
    String search = '',
    RealtimeHistoryFilter? filter,
  }) async {
    filter ??= RealtimeHistoryFilter(protocol: protocol, search: search);
    final where = <String>[];
    final variables = <Variable>[];
    void add(String clause, Object value) {
      where.add(clause);
      variables.add(Variable(value));
    }

    if (filter.workspaceId != null) {
      add('workspace_id = ?', filter.workspaceId!);
    }
    if (filter.collectionId != null) {
      add('collection_id = ?', filter.collectionId!);
    }
    if (filter.requestId != null) add('request_id = ?', filter.requestId!);
    if (filter.environmentId != null) {
      add('environment_id = ?', filter.environmentId!);
    }
    if (filter.protocol != null) add('protocol = ?', filter.protocol!.name);
    if (filter.status != null) add('status = ?', filter.status!);
    if (filter.failureCategory != null) {
      add('failure_category = ?', filter.failureCategory!);
    }
    if (filter.from != null) add('created_at >= ?', filter.from!);
    if (filter.to != null) add('created_at <= ?', filter.to!);
    final result = await _database
        .customSelect(
          'SELECT * FROM realtime_history ${where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}'} ORDER BY pinned DESC, created_at DESC',
          variables: variables,
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
              filter!.search.isEmpty ||
              jsonEncode(
                item.summary,
              ).toLowerCase().contains(filter.search.toLowerCase()),
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
    final values = <Object?>[];
    if (pinned != null) {
      sets.add('pinned = ?');
      values.add(pinned ? 1 : 0);
    }
    if (tags != null) {
      sets.add('tags_json = ?');
      values.add(jsonEncode(tags));
    }
    if (notes != null) {
      sets.add('notes = ?');
      values.add(notes);
    }
    if (sets.isEmpty) {
      return;
    }
    values.add(id);
    await _database.customStatement(
      'UPDATE realtime_history SET ${sets.join(', ')} WHERE id = ?',
      values,
    );
  }

  Future<void> retain({required int maximumCount, DateTime? olderThan}) async {
    if (olderThan != null) {
      await _database.customStatement(
        'DELETE FROM realtime_history WHERE created_at < ?',
        <Object?>[_date(olderThan)],
      );
    }
    await _database.customStatement(
      'DELETE FROM realtime_history WHERE id IN (SELECT id FROM realtime_history ORDER BY created_at DESC LIMIT -1 OFFSET ?)',
      <Object?>[maximumCount],
    );
  }

  Future<({int days, int maximumCount})> retention(String workspaceId) async {
    final row = await _database
        .customSelect(
          'SELECT realtime_retention_days, realtime_maximum_count FROM workspace_settings WHERE workspace_id = ?',
          variables: <Variable>[Variable.withString(workspaceId)],
        )
        .getSingleOrNull();
    return (
      days: row?.read<int>('realtime_retention_days') ?? 30,
      maximumCount: row?.read<int>('realtime_maximum_count') ?? 500,
    );
  }

  Future<void> saveRetention(
    String workspaceId, {
    required int days,
    required int maximumCount,
  }) async {
    await _database.customStatement(
      'INSERT OR IGNORE INTO workspace_settings (workspace_id, updated_at) VALUES (?, ?)',
      <Object?>[workspaceId, _date(DateTime.now())],
    );
    await _database.customStatement(
      'UPDATE workspace_settings SET realtime_retention_days = ?, realtime_maximum_count = ?, updated_at = ? WHERE workspace_id = ?',
      <Object?>[days, maximumCount, _date(DateTime.now()), workspaceId],
    );
    await retain(
      maximumCount: maximumCount,
      olderThan: DateTime.now().subtract(Duration(days: days)),
    );
  }

  Future<AiConsentOptions> aiPreferences() async {
    final row = await _database
        .customSelect("SELECT * FROM ai_preferences WHERE id = 'default'")
        .getSingleOrNull();
    if (row == null) return const AiConsentOptions();
    return AiConsentOptions(
      granted: row.read<bool>('consent_granted'),
      includeBodies: row.read<bool>('include_bodies'),
      includeHeaders: row.read<bool>('include_headers'),
      includeHistory: row.read<bool>('include_history'),
      includeEvents: row.read<bool>('include_events'),
    );
  }

  Future<void> saveAiPreferences(
    AiConsentOptions options,
  ) => _database.customStatement(
    'INSERT OR REPLACE INTO ai_preferences (id, consent_granted, provider_name, provider_model, provider_endpoint, include_bodies, include_headers, include_history, include_events, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    <Object?>[
      'default',
      options.granted ? 1 : 0,
      'fake-local-test-provider',
      null,
      null,
      options.includeBodies ? 1 : 0,
      options.includeHeaders ? 1 : 0,
      options.includeHistory ? 1 : 0,
      options.includeEvents ? 1 : 0,
      _date(DateTime.now()),
    ],
  );

  Future<List<RealtimeSessionConfig>> drafts(String workspaceId) async {
    final rows = await _database
        .customSelect(
          'SELECT * FROM realtime_drafts WHERE workspace_id = ? ORDER BY updated_at DESC',
          variables: <Variable>[Variable.withString(workspaceId)],
        )
        .get();
    return rows.map((row) {
      final payload =
          jsonDecode(row.read<String>('payload_json')) as Map<String, dynamic>;
      return _fromPayload(
        id: row.read<String?>('configuration_id') ?? row.read<String>('id'),
        workspaceId: row.read<String>('workspace_id'),
        protocol: RealtimeProtocolType.values.byName(
          row.read<String>('protocol'),
        ),
        payload: payload,
        name: row.read<String>('title'),
      );
    }).toList();
  }

  Future<void> deleteConfiguration(String id) async {
    await _database.transaction(() async {
      await _database.customStatement(
        'DELETE FROM realtime_drafts WHERE configuration_id = ?',
        <Object?>[id],
      );
      await _database.customStatement(
        'DELETE FROM realtime_configurations WHERE id = ?',
        <Object?>[id],
      );
    });
  }

  Future<void> deleteDraft(String configurationId) => _database.customStatement(
    'DELETE FROM realtime_drafts WHERE configuration_id = ?',
    <Object?>[configurationId],
  );

  Future<void> deleteHistory(String id) => _database.customStatement(
    'DELETE FROM realtime_history WHERE id = ?',
    <Object?>[id],
  );

  Future<void> clearHistory({String? workspaceId}) => _database.customStatement(
    workspaceId == null
        ? 'DELETE FROM realtime_history'
        : 'DELETE FROM realtime_history WHERE workspace_id = ?',
    workspaceId == null ? const <Variable>[] : <Object?>[workspaceId],
  );

  Future<RealtimeSessionConfig?> reopen(String historyId) async {
    final row = await _database
        .customSelect(
          'SELECT configuration_id FROM realtime_history WHERE id = ?',
          variables: <Variable>[Variable.withString(historyId)],
        )
        .getSingleOrNull();
    final id = row?.read<String?>('configuration_id');
    if (id == null) return null;
    final rows = await _database
        .customSelect(
          'SELECT * FROM realtime_configurations WHERE id = ?',
          variables: <Variable>[Variable.withString(id)],
        )
        .get();
    if (rows.isEmpty) return null;
    final item = rows.single;
    return _fromPayload(
      id: const Uuid().v4(),
      workspaceId: item.read<String>('workspace_id'),
      protocol: RealtimeProtocolType.values.byName(
        item.read<String>('protocol'),
      ),
      payload:
          jsonDecode(item.read<String>('payload_json')) as Map<String, dynamic>,
      name: '${item.read<String>('name')} (reopened)',
      url: item.read<String>('url'),
    );
  }

  static int _date(DateTime value) => value.millisecondsSinceEpoch ~/ 1000;
}
