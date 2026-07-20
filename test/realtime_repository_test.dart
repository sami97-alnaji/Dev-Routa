import 'package:devroute_ai_studio/core/storage/database_schema.dart';
import 'package:devroute_ai_studio/core/ai/consent_ai_service.dart';
import 'package:devroute_ai_studio/features/realtime/data/realtime_repository.dart';
import 'package:devroute_ai_studio/features/realtime/domain/realtime_models.dart';
import 'package:devroute_ai_studio/shared/models/api_models.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'realtime config, draft, history metadata and retention round-trip',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = RealtimeRepository(database);
      final config = RealtimeSessionConfig(
        id: 'config',
        workspaceId: 'workspace',
        collectionId: 'collection',
        requestId: 'request',
        environmentId: 'environment',
        protocol: RealtimeProtocolType.httpStream,
        streamMode: HttpStreamMode.ndjson,
        method: HttpMethod.post,
        url: 'http://localhost/stream',
        body: const RequestBodyModel(
          type: RequestBodyType.rawText,
          content: 'hello',
        ),
        auth: const RequestAuthModel(
          type: AuthType.bearer,
          tokenSecretRef: 'secure-token-ref',
        ),
        reconnectPolicy: const ReconnectPolicy(enabled: true, maxAttempts: 4),
      );
      await repository.saveConfiguration(config);
      await repository.saveDraft(config);
      final restored = (await repository.configurations('workspace')).single;
      expect(restored.streamMode, HttpStreamMode.ndjson);
      expect(restored.body?.content, 'hello');
      expect(restored.auth.tokenSecretRef, 'secure-token-ref');
      expect(
        (await repository.drafts('workspace')).single.method,
        HttpMethod.post,
      );

      final ended = DateTime.now();
      await repository.saveSession(
        RealtimeSessionSnapshot(
          config: config,
          state: RealtimeSessionState(
            config: config,
            status: RealtimeConnectionStatus.failed,
            failure: const RealtimeFailure('network', 'password=secret'),
            metrics: RealtimeMetrics(
              startedAt: ended.subtract(const Duration(seconds: 1)),
              endedAt: ended,
            ),
            messages: <RealtimeMessage>[
              RealtimeMessage(
                sequence: 1,
                direction: RealtimeMessageDirection.inbound,
                payloadType: RealtimePayloadType.text,
                timestamp: ended,
                content: 'authorization: secret',
              ),
            ],
          ),
        ),
      );
      var history = await repository.history(
        filter: const RealtimeHistoryFilter(
          workspaceId: 'workspace',
          collectionId: 'collection',
          failureCategory: 'network',
        ),
      );
      expect(history, hasLength(1));
      expect(history.single.summary.toString(), isNot(contains('secret')));
      await repository.updateMetadata(
        history.single.id,
        pinned: true,
        tags: const ['qa'],
        notes: 'local',
      );
      history = await repository.history();
      expect(history.single.pinned, isTrue);
      expect(history.single.tags, ['qa']);
      await repository.saveRetention('workspace', days: 7, maximumCount: 10);
      final retention = await repository.retention('workspace');
      expect(retention.days, 7);
      expect(retention.maximumCount, 10);
      await repository.saveAiPreferences(
        const AiConsentOptions(granted: true, includeEvents: true),
      );
      final preferences = await repository.aiPreferences();
      expect(preferences.granted, isTrue);
      expect(preferences.includeEvents, isTrue);
      await repository.retain(maximumCount: 0);
      expect(await repository.history(), isEmpty);
    },
  );
}
