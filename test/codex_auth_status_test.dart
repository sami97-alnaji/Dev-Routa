import 'dart:async';
import 'dart:io';

import 'package:devroute_ai_studio/core/agent_control/application/agent_orchestrator.dart';
import 'package:devroute_ai_studio/core/agent_control/data/codex_subscription_adapter.dart';
import 'package:devroute_ai_studio/core/agent_control/domain/agent_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('recognizes ChatGPT login status across line endings', () async {
    for (final output in <String>[
      'Logged in using ChatGPT',
      'Logged in using ChatGPT\n',
      '\r\nLogged in using ChatGPT\r\n',
    ]) {
      final root = await Directory.systemTemp.createTemp('codex-auth-status-');
      addTearDown(() => root.delete(recursive: true));
      final adapter = _adapter(
        root,
        runner: (_, _, {required environment}) async =>
            ProcessResult(1, 0, output, ''),
      );

      expect(
        await adapter.authenticationStatus(),
        AgentAuthenticationStatus.authenticated,
      );
    }
  });

  test('recognizes the expected not-logged-in result', () async {
    final root = await Directory.systemTemp.createTemp('codex-auth-status-');
    addTearDown(() => root.delete(recursive: true));
    final adapter = _adapter(
      root,
      runner: (_, _, {required environment}) async =>
          ProcessResult(1, 1, 'Not logged in', ''),
    );

    expect(
      await adapter.authenticationStatus(),
      AgentAuthenticationStatus.unauthenticated,
    );
  });

  test(
    'reports a safe spawn category instead of collapsing to unknown',
    () async {
      final root = await Directory.systemTemp.createTemp('codex-auth-status-');
      addTearDown(() => root.delete(recursive: true));
      final adapter = _adapter(
        root,
        runner: (_, _, {required environment}) => throw ProcessException(
          'codex.exe',
          const <String>['login', 'status'],
          'spawn failed',
        ),
      );

      final readiness = await adapter.runtimeReadiness();

      expect(readiness.authentication, AgentAuthenticationStatus.unknown);
      expect(readiness.failureCategory, 'process_spawn_failed');
      expect(readiness.failedProbeStage, 'authentication_probe');
    },
  );

  test('reports a bounded status timeout', () async {
    final root = await Directory.systemTemp.createTemp('codex-auth-status-');
    addTearDown(() => root.delete(recursive: true));
    final gate = Completer<ProcessResult>();
    final adapter = _adapter(
      root,
      timeout: const Duration(milliseconds: 1),
      runner: (_, _, {required environment}) => gate.future,
    );

    final readiness = await adapter.runtimeReadiness();

    expect(readiness.authentication, AgentAuthenticationStatus.unknown);
    expect(readiness.failureCategory, 'process_timeout');
  });

  test('reports unexpected status output safely', () async {
    final root = await Directory.systemTemp.createTemp('codex-auth-status-');
    addTearDown(() => root.delete(recursive: true));
    final adapter = _adapter(
      root,
      runner: (_, _, {required environment}) async =>
          ProcessResult(1, 0, 'unexpected response', ''),
    );

    final readiness = await adapter.runtimeReadiness();

    expect(readiness.authentication, AgentAuthenticationStatus.unknown);
    expect(readiness.failureCategory, 'status_parse_failed');
  });

  test('passes only the isolated safe environment to the auth probe', () async {
    final root = await Directory.systemTemp.createTemp('codex-auth-status-');
    addTearDown(() => root.delete(recursive: true));
    Map<String, String>? captured;
    final adapter = _adapter(
      root,
      runner: (_, arguments, {required environment}) async {
        captured = environment;
        expect(arguments, <String>['login', 'status']);
        return ProcessResult(1, 0, 'Logged in using ChatGPT', '');
      },
    );

    expect(
      await adapter.authenticationStatus(),
      AgentAuthenticationStatus.authenticated,
    );
    expect(captured!['CODEX_HOME'], root.path);
    expect(captured!['HOME'], root.path);
    expect(
      captured!.keys,
      containsAll(<String>['HOME', 'TEMP', 'TMP', 'TMPDIR']),
    );
    expect(captured!.containsKey('SystemRoot'), Platform.isWindows);
    expect(captured!.containsKey('OPENAI_API_KEY'), isFalse);
    expect(captured!.containsKey('CODEX_API_KEY'), isFalse);
    expect(captured!.containsKey('CODEX_ACCESS_TOKEN'), isFalse);
    expect(captured!.containsKey('OPENAI_BASE_URL'), isFalse);
  });
}

CodexSubscriptionAdapter _adapter(
  Directory root, {
  required CodexStatusProcessRunner runner,
  Duration timeout = const Duration(seconds: 1),
}) => CodexSubscriptionAdapter(
  orchestratorForWorkspace: _unsupportedOrchestrator,
  locator: _TestLocator(),
  runtime: CodexIsolatedRuntime(homeDirectory: root),
  statusProcessRunner: runner,
  authStatusTimeout: timeout,
);

AgentOrchestrator _unsupportedOrchestrator(String _) =>
    throw UnimplementedError();

class _TestLocator extends CodexExecutableLocator {
  @override
  String? discover() => r'C:\test\codex.exe';
}
