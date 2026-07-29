import 'package:devroute_ai_studio/core/agent_control/application/agent_orchestrator.dart';
import 'package:devroute_ai_studio/core/agent_control/application/agent_permission_engine.dart';
import 'package:devroute_ai_studio/core/agent_control/application/agent_tool_registry.dart';
import 'package:devroute_ai_studio/core/agent_control/application/app_command.dart';
import 'package:devroute_ai_studio/core/agent_control/application/app_command_bus.dart';
import 'package:devroute_ai_studio/core/agent_control/application/automation_validator.dart';
import 'package:devroute_ai_studio/core/agent_control/data/agent_process_runner.dart';
import 'package:devroute_ai_studio/core/agent_control/data/fake_subscription_agent_adapter.dart';
import 'package:devroute_ai_studio/core/agent_control/domain/agent_models.dart';
import 'package:flutter_test/flutter_test.dart';

class _Command implements AppCommand<String> {
  const _Command(this.value);
  final String value;
  @override
  String get commandType => 'test';
}

class _Handler implements AppCommandHandler<_Command, String> {
  @override
  Future<String> handle(_Command command, AppCommandContext context) async {
    context.cancellation.throwIfCancelled();
    return command.value;
  }
}

void main() {
  test(
    'command bus dispatches, rejects duplicates and unknown commands',
    () async {
      final bus = AppCommandBus()..register<_Command, String>(_Handler());
      expect(
        await bus.execute(
          const _Command('ok'),
          AppCommandContext(operationId: '1', workspaceId: 'w'),
        ),
        'ok',
      );
      expect(
        () => bus.register<_Command, String>(_Handler()),
        throwsA(isA<AppCommandException>()),
      );
      expect(
        () => bus.execute(
          _Unknown(),
          AppCommandContext(operationId: '2', workspaceId: 'w'),
        ),
        throwsA(isA<AppCommandException>()),
      );
    },
  );
  test('registry and permissions default deny sensitive execution', () {
    final registry = AgentToolRegistry.foundation();
    expect(
      registry.tools.map((tool) => tool.name),
      containsAll(<String>[
        'app.capabilities',
        'workspace.list',
        'grpc.history.search',
        'grpc.history.replayAsDraft',
        'grpc.invoke.preview',
        'grpc.invoke.execute',
      ]),
    );
    final engine = AgentPermissionEngine();
    expect(
      engine
          .evaluate(
            mode: AgentPermissionMode.observe,
            tool: registry.require('grpc.history.search'),
            production: false,
          )
          .allowed,
      isTrue,
    );
    expect(
      engine
          .evaluate(
            mode: AgentPermissionMode.observe,
            tool: registry.require('grpc.history.replayAsDraft'),
            production: false,
          )
          .allowed,
      isFalse,
    );
    expect(
      engine
          .evaluate(
            mode: AgentPermissionMode.testOperator,
            tool: registry.require('grpc.invoke.execute'),
            production: true,
          )
          .allowed,
      isFalse,
    );
  });
  test(
    'orchestrator sanitizes outputs, audits order and blocks network without approval',
    () async {
      final audit = InMemoryAgentAuditSink();
      final orchestrator = AgentOrchestrator(
        AgentToolRegistry.foundation(),
        AgentPermissionEngine(),
        audit,
      );
      final result = await orchestrator.run(
        providerId: 'fakeTestAgent',
        mode: AgentPermissionMode.observe,
        production: false,
        request: const AgentRunRequest(
          runId: 'run',
          workspaceId: 'w',
          calls: <AgentToolCallRequest>[
            AgentToolCallRequest(
              toolName: 'app.capabilities',
              input: <String, Object?>{},
              workspaceId: 'w',
            ),
            AgentToolCallRequest(
              toolName: 'grpc.invoke.execute',
              input: <String, Object?>{},
              workspaceId: 'w',
            ),
          ],
        ),
      );
      expect(result.results.first.success, isTrue);
      expect(result.results.last.failureCategory, 'observe_read_only');
      expect(audit.entries.map((entry) => entry.phase), <String>[
        'started',
        'completed',
      ]);
    },
  );
  test(
    'automation validator and fake process boundary reject unsafe definitions',
    () async {
      final registry = AgentToolRegistry.foundation();
      final validator = AutomationValidator();
      final invalid = AutomationDefinition(
        id: 'a',
        name: 'token=secret',
        enabled: true,
        trigger: 'manual',
        steps: const <String>['missing', 'missing'],
        limits: const AutomationLimits(
          maximumSteps: 0,
          maximumRequests: 0,
          maximumDuration: Duration.zero,
          maximumRetries: 0,
        ),
        workspaceId: 'w',
      );
      expect(
        validator.validate(invalid, registry),
        containsAll(<String>[
          'missing_limits',
          'cycle',
          'unknown_tool',
          'embedded_secret',
        ]),
      );
      final runner = FakeAgentProcessRunner();
      await expectLater(
        runner.run(
          const AgentProcessRequest(
            executablePath: 'cmd.exe',
            arguments: <String>['/c', 'bad'],
            workingDirectory: 'outside',
            allowedEnvironmentKeys: <String>{},
            timeout: Duration(seconds: 1),
            maximumStdoutBytes: 4,
            maximumStderrBytes: 4,
          ),
        ),
        throwsA(isA<AppCommandException>()),
      );
    },
  );
  test('fake adapter is the only executable foundation provider', () async {
    final fake = FakeSubscriptionAgentAdapter();
    expect(fake.providerId, 'fakeTestAgent');
    expect(await fake.detectInstallation(), AgentInstallationStatus.installed);
    final handle = fake.startRun(
      const AgentRunRequest(
        runId: 'r',
        workspaceId: 'w',
        calls: <AgentToolCallRequest>[],
      ),
    );
    await handle.cancel();
    expect((await handle.result).status, AgentRunStatus.cancelled);
  });
}

class _Unknown implements AppCommand<void> {
  @override
  String get commandType => 'unknown';
}
