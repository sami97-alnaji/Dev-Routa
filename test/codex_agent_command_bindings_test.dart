import 'package:devroute_ai_studio/core/agent_control/application/app_command_bus.dart';
import 'package:devroute_ai_studio/core/agent_control/data/codex_subscription_adapter.dart';
import 'package:devroute_ai_studio/core/storage/database_schema.dart';
import 'package:devroute_ai_studio/features/grpc/data/grpc_persistence_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'two dynamic Codex tools route through the command bus with sanitized output',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final bus = AppCommandBus();
      final bindings = CodexAgentCommandBindings(
        bus,
        GrpcPersistenceRepository(database),
      )..register();
      final registry = bindings.registry('safe-workspace');
      expect(
        registry.tools.map((tool) => tool.name),
        unorderedEquals(<String>['app.capabilities', 'grpc.history.search']),
      );
      final capabilities = await registry
          .require('app.capabilities')
          .execute(const <String, Object?>{});
      final history = await registry
          .require('grpc.history.search')
          .execute(const <String, Object?>{});
      expect(capabilities['toolsAllowed'], 2);
      expect(capabilities['networkExecution'], isFalse);
      expect(history['totalCount'], 0);
    },
  );
}
