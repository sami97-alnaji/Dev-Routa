import 'dart:async';
import 'dart:io';

import 'package:devroute_ai_studio/core/agent_control/data/codex_subscription_adapter.dart';
import 'package:devroute_ai_studio/core/agent_control/domain/agent_models.dart';
import 'package:devroute_ai_studio/features/ai_assistant/application/codex_agents_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('devroute-mcp-test-');
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('successful lifecycle returns a verified empty MCP inventory', () async {
    final session = _FakeMcpSession();
    final readiness = await _adapter(root, session: session).runtimeReadiness();

    expect(readiness.isolatedProfileReady, isTrue);
    expect(readiness.authentication, AgentAuthenticationStatus.authenticated);
    expect(readiness.mcpServerCount, 0);
    expect(readiness.detectedMcpServerNames, isEmpty);
    expect(readiness.mcpStartupNotificationCount, 0);
    expect(readiness.noMcpStartupEvents, isTrue);
    expect(readiness.failureCategory, isNull);
    expect(readiness.failedProbeStage, isNull);
    expect(readiness.canRun, isTrue);
    expect(session.trace.initializeSent, isTrue);
    expect(session.trace.initializeResponseReceived, isTrue);
    expect(session.trace.initializedNotificationSent, isTrue);
    expect(session.trace.mcpStatusRequestSent, isTrue);
    expect(session.trace.mcpStatusResponseReceived, isTrue);
    expect(session.trace.cleanupStarted, isTrue);
    expect(session.trace.processExited, isTrue);
  });

  test('GPT-5.6 Luna requires and accepts the documented CLI minimum', () {
    final model = CodexModelSelection.gpt56Luna;

    expect(model.id, 'gpt-5.6-luna');
    expect(
      model.supportsCliVersion(CodexCliVersion.parse('codex-cli 0.143.9')),
      isFalse,
    );
    expect(
      model.supportsCliVersion(CodexCliVersion.parse('codex-cli 0.144.0')),
      isTrue,
    );
  });

  test(
    'readiness blocks Luna rather than silently choosing an older model',
    () async {
      final readiness = await _adapter(
        root,
        statusProcessRunner: (_, arguments, {required environment}) async =>
            ProcessResult(
              1,
              0,
              arguments.length == 1 && arguments.single == '--version'
                  ? 'codex-cli 0.143.9'
                  : 'Logged in using ChatGPT',
              '',
            ),
      ).runtimeReadiness();

      expect(
        readiness.failureCategory,
        'CODEX_UPDATE_REQUIRED_FOR_SELECTED_MODEL',
      );
      expect(readiness.failedProbeStage, 'model_compatibility');
      expect(readiness.selectedModelId, 'gpt-5.6-luna');
      expect(readiness.detectedCodexVersion, '0.143.9');
      expect(readiness.requiredCodexVersion, '0.144.0');
      expect(readiness.canRun, isFalse);
    },
  );

  test('Luna model selection is exact and never falls back', () {
    final visibleModels = <Object?>[
      <String, Object?>{'model': 'gpt-5.6-sol'},
      <String, Object?>{'model': 'gpt-5.6-terra'},
      <String, Object?>{'model': 'gpt-5.5'},
    ];

    expect(
      CodexAppServerProtocol.selectAvailableModel(
        visibleModels,
        CodexModelSelection.gpt56Luna.id,
      ),
      isNull,
    );
    expect(
      CodexAppServerProtocol.selectAvailableModel(<Object?>[
        ...visibleModels,
        <String, Object?>{'model': 'gpt-5.6-luna'},
      ], CodexModelSelection.gpt56Luna.id),
      'gpt-5.6-luna',
    );
  });

  test('process spawn exception has an exact startup category', () async {
    final readiness = await _adapter(
      root,
      launcher: (_, _, _) => throw ProcessException(
        r'C:\test\codex.exe',
        const <String>['app-server', '--stdio'],
        'denied',
        5,
      ),
    ).runtimeReadiness();

    expect(readiness.failureCategory, 'mcp_process_start_failed');
    expect(readiness.diagnostics.appServerSubstage, 'mcp_process_start');
    expect(readiness.diagnostics.processStarted, isFalse);
    expect(readiness.canRun, isFalse);
  });

  test('cleanup PathAccessException is not a status failure', () async {
    final session = _FakeMcpSession(
      closeFailure: PathAccessException(
        r'C:\safe-temp\devroute-codex-test',
        const OSError('file in use', 32),
        'delete failed',
      ),
    );
    final readiness = await _adapter(root, session: session).runtimeReadiness();

    expect(readiness.failureCategory, 'mcp_probe_cleanup_failed');
    expect(readiness.diagnostics.appServerSubstage, 'mcp_cleanup_close');
    expect(readiness.diagnostics.exceptionType, 'PathAccessException');
    expect(readiness.diagnostics.osErrorCode, 32);
    expect(readiness.diagnostics.osErrorCategory, 'file_in_use');
  });

  test('malformed JSON is classified as a protocol parse failure', () async {
    final readiness = await _adapter(
      root,
      session: _FakeMcpSession(
        initializeFailure: const CodexMcpProbeFailure('protocol_parse_failed'),
      ),
    ).runtimeReadiness();

    expect(readiness.failureCategory, 'protocol_parse_failed');
    expect(readiness.diagnostics.appServerSubstage, 'mcp_initialize');
    expect(readiness.mcpServerCount, isNull);
  });

  test('process exit before initialize is reported directly', () async {
    final session = _FakeMcpSession(
      initializeFailure: const CodexMcpProbeFailure('app_server_exited'),
    )..trace.processExited = true;
    session.trace.processExitCode = 17;
    final readiness = await _adapter(root, session: session).runtimeReadiness();

    expect(readiness.failureCategory, 'app_server_exited');
    expect(readiness.diagnostics.processExited, isTrue);
    expect(readiness.diagnostics.processExitCode, 17);
  });

  test('MCP timeout is bounded and typed', () async {
    final readiness = await _adapter(
      root,
      session: _FakeMcpSession(
        statusFailure: TimeoutException('bounded test timeout'),
      ),
    ).runtimeReadiness();

    expect(readiness.failureCategory, 'mcp_probe_timeout');
    expect(readiness.diagnostics.timedOut, isTrue);
    expect(readiness.diagnostics.appServerSubstage, 'mcp_status');
  });

  test('third-party inventory preserves count and names', () async {
    final readiness = await _adapter(
      root,
      session: _FakeMcpSession(
        count: 1,
        names: const <String>['third-party-test'],
      ),
    ).runtimeReadiness();

    expect(readiness.mcpServerCount, 1);
    expect(readiness.detectedMcpServerNames, <String>['third-party-test']);
    expect(readiness.failureCategory, 'third_party_mcp_detected');
    expect(readiness.canRun, isFalse);
  });

  test('startup notifications independently block readiness', () async {
    final readiness = await _adapter(
      root,
      session: _FakeMcpSession(startupNotificationCount: 1),
    ).runtimeReadiness();

    expect(readiness.mcpServerCount, 0);
    expect(readiness.mcpStartupNotificationCount, 1);
    expect(readiness.noMcpStartupEvents, isFalse);
    expect(readiness.failureCategory, 'third_party_mcp_detected');
  });

  test('invalid structured MCP response remains unknown', () async {
    final readiness = await _adapter(
      root,
      session: _FakeMcpSession(
        statusFailure: const CodexMcpProbeFailure('mcp_response_invalid'),
      ),
    ).runtimeReadiness();

    expect(readiness.failureCategory, 'mcp_response_invalid');
    expect(readiness.mcpServerCount, isNull);
  });

  test('isolated config disables the built-in apps MCP gateway', () {
    expect(CodexIsolatedRuntime.configToml, contains('[features]'));
    expect(CodexIsolatedRuntime.configToml, contains('apps = false'));
    expect(CodexIsolatedRuntime.configToml, contains('shell_tool = false'));
    expect(CodexIsolatedRuntime.configToml, isNot(contains('mcp_servers')));
  });

  test('real turn prompt leaves typed-tool selection to Codex', () {
    expect(
      CodexSubscriptionAdapter.realTurnPrompt,
      'Inspect the DevRoute capabilities available to you, then search the gRPC '
      'history using the provided DevRoute tools. Do not modify application '
      'state, do not execute arbitrary shell commands, and use only the tools '
      'exposed by DevRoute.',
    );
    expect(
      CodexSubscriptionAdapter.realTurnPrompt,
      isNot(contains('app_capabilities')),
    );
    expect(
      CodexSubscriptionAdapter.realTurnPrompt,
      isNot(contains('grpc_history_search')),
    );
  });

  test(
    'connection test performs readiness without starting a model turn',
    () async {
      final adapter = _adapter(root);
      final controller = CodexAgentsController(adapter);
      addTearDown(controller.dispose);

      await controller.refresh();
      await controller.runConnectionTest('workspace');

      expect(controller.connectionTestSucceeded, isTrue);
      expect(controller.lifecycle, 'connection_test_succeeded');
      expect(controller.realTurnTrace, isNull);
    },
  );

  test('thread/start parses result.thread.id', () {
    expect(
      CodexAppServerProtocol.parseThreadId(<String, Object?>{
        'thread': <String, Object?>{'id': 'thread-1'},
      }),
      'thread-1',
    );
  });

  test('thread/start does not require a turn id', () {
    final result = <String, Object?>{
      'thread': <String, Object?>{'id': 'thread-only'},
    };
    expect(CodexAppServerProtocol.parseThreadId(result), 'thread-only');
    expect(result, isNot(contains('turn')));
  });

  test('thread/start retains the explicitly selected Luna model', () {
    final params = CodexAppServerProtocol.restrictedThreadStartParams(
      cwd: r'C:\workspace',
      model: CodexModelSelection.gpt56Luna.id,
    );

    expect(params['model'], 'gpt-5.6-luna');
    expect(params['sandbox'], 'read-only');
  });

  test('durable tool evidence retains the effective Luna model', () {
    final appServer = CodexAppServerTrace()..selectedModel = 'gpt-5.6-luna';
    final trace = CodexRealTurnTrace(
      appServer: appServer,
      duration: Duration.zero,
      threadId: 'thread-luna',
      turnId: 'turn-luna',
      turnStarted: true,
      turnCompletedReceived: true,
      completionState: 'completed',
      mcpServerCount: 0,
      detectedMcpServerNames: const <String>[],
      mcpStartupNotificationCount: 0,
      toolInvocations: const <CodexToolInvocationEvidence>[
        CodexToolInvocationEvidence(
          provider: 'codex',
          effectiveModel: 'gpt-5.6-luna',
          modelVisibleTool: 'app_capabilities',
          internalTool: 'app.capabilities',
          invocationId: 'tool-luna',
          duration: Duration.zero,
          schemaValidationPassed: true,
          permissionDecision: 'pass',
          typedExecutionPassed: true,
          structuredResultReturned: true,
          outcome: 'success',
        ),
      ],
      finalModelResponse: 'confirmed',
      mutationCommandCount: 0,
      arbitraryShellUsed: false,
      rawSecretCategories: const <String, String>{},
      directApiObserved: false,
    );

    expect(trace.appServer.selectedModel, 'gpt-5.6-luna');
    expect(trace.toolInvocations.single.effectiveModel, 'gpt-5.6-luna');
  });

  test('turn/start receives the parsed thread id and text input', () {
    final params = CodexAppServerProtocol.turnStartParams(
      threadId: 'thread-2',
      prompt: 'prompt',
    );
    expect(params['threadId'], 'thread-2');
    expect(params['input'], <Object?>[
      <String, Object?>{'type': 'text', 'text': 'prompt'},
    ]);
    expect(params['sandboxPolicy'], <String, Object?>{
      'type': 'readOnly',
      'networkAccess': false,
    });
  });

  test('turn/start parses result.turn.id', () {
    expect(
      CodexAppServerProtocol.parseTurnId(<String, Object?>{
        'turn': <String, Object?>{'id': 'turn-1'},
      }),
      'turn-1',
    );
  });

  test('thread id and turn id remain distinct', () {
    final threadId = CodexAppServerProtocol.parseThreadId(<String, Object?>{
      'thread': <String, Object?>{'id': 'thread-3'},
    });
    final turnId = CodexAppServerProtocol.parseTurnId(<String, Object?>{
      'turn': <String, Object?>{'id': 'turn-3'},
    });
    expect(threadId, isNot(turnId));
  });

  test('thread/started notification is not a request response', () {
    final notification = <String, Object?>{
      'method': 'thread/started',
      'params': <String, Object?>{
        'thread': <String, Object?>{'id': 'thread-4'},
      },
    };
    expect(CodexAppServerProtocol.isResponseFor(notification, 4), isFalse);
  });

  test('turn/started notification is recognized', () {
    expect(
      CodexAppServerProtocol.isTurnStarted(<String, Object?>{
        'method': 'turn/started',
        'params': <String, Object?>{},
      }),
      isTrue,
    );
  });

  test('turn/completed status is parsed from its notification', () {
    expect(
      CodexAppServerProtocol.turnCompletedStatus(<String, Object?>{
        'method': 'turn/completed',
        'params': <String, Object?>{
          'turn': <String, Object?>{'status': 'completed'},
        },
      }),
      'completed',
    );
  });

  test('failed turn/completed extracts safe structured diagnostics', () {
    final diagnostics = CodexAppServerProtocol.turnCompletedFailure(<
      String,
      Object?
    >{
      'method': 'turn/completed',
      'params': <String, Object?>{
        'turn': <String, Object?>{
          'status': 'failed',
          'error': <String, Object?>{
            'message':
                'upstream token=should-not-appear returned 503 without credentials',
            'codexErrorInfo': <String, Object?>{
              'httpConnectionFailed': <String, Object?>{'httpStatusCode': 503},
            },
            'additionalDetails': 'response connection failed',
          },
        },
      },
    });
    expect(diagnostics, isNotNull);
    expect(diagnostics!.message, contains('503'));
    expect(diagnostics.message, isNot(contains('should-not-appear')));
    expect(diagnostics.codexErrorInfoType, 'httpConnectionFailed');
    expect(diagnostics.httpStatusCode, 503);
    expect(diagnostics.additionalDetailsCategory, 'upstream_connection_error');
  });

  test('completed turn has no failure diagnostics', () {
    expect(
      CodexAppServerProtocol.turnCompletedFailure(<String, Object?>{
        'method': 'turn/completed',
        'params': <String, Object?>{
          'turn': <String, Object?>{'status': 'completed'},
        },
      }),
      isNull,
    );
  });

  test('event sequence retains item types without item content', () {
    expect(
      CodexAppServerProtocol.eventType(<String, Object?>{
        'method': 'item/completed',
        'params': <String, Object?>{
          'item': <String, Object?>{
            'type': 'agentMessage',
            'status': 'completed',
            'text': 'not included in the event type',
          },
        },
      }),
      'item/completed:agentMessage:completed',
    );
  });

  test('stderr diagnostics retain only safe metadata', () {
    final metadata = CodexAppServerProtocol.stderrMetadata(
      '2026-08-11T16:00:00Z ERROR https://api.openai.com/v1/responses 503',
    );
    expect(metadata, isNotNull);
    expect(metadata!.timestampPresent, isTrue);
    expect(metadata.severity, 'error');
    expect(metadata.category, 'upstream_connection_error');
    expect(metadata.httpStatusCode, 503);
    expect(metadata.endpointHost, 'openai');
  });

  test('thread/start JSON-RPC error has a precise category', () {
    expect(
      CodexAppServerProtocol.protocolErrorCategory('thread/start'),
      'thread_start_protocol_error',
    );
  });

  test('turn/start JSON-RPC error has a precise category', () {
    expect(
      CodexAppServerProtocol.protocolErrorCategory('turn/start'),
      'turn_start_protocol_error',
    );
  });

  test('turn/start timeout has a precise category', () {
    expect(
      CodexAppServerProtocol.timeoutCategory('turn/start'),
      'turn_start_timeout',
    );
  });
}

CodexSubscriptionAdapter _adapter(
  Directory root, {
  _FakeMcpSession? session,
  CodexMcpSessionLauncher? launcher,
  CodexStatusProcessRunner? statusProcessRunner,
}) => CodexSubscriptionAdapter(
  orchestratorForWorkspace: (_) => throw UnsupportedError('not used'),
  locator: _TestLocator(),
  runtime: CodexIsolatedRuntime(homeDirectory: root),
  statusProcessRunner:
      statusProcessRunner ??
      (_, arguments, {required environment}) async => ProcessResult(
        1,
        0,
        arguments.length == 1 && arguments.single == '--version'
            ? 'codex-cli 0.147.0'
            : 'Logged in using ChatGPT',
        '',
      ),
  mcpSessionLauncher:
      launcher ?? (_, _, _) async => session ?? _FakeMcpSession(),
);

class _TestLocator extends CodexExecutableLocator {
  @override
  String? discover() => r'C:\test\codex.exe';
}

class _FakeMcpSession implements CodexMcpProbeSession {
  _FakeMcpSession({
    this.count = 0,
    this.names = const <String>[],
    this.startupNotificationCount = 0,
    this.initializeFailure,
    this.statusFailure,
    this.closeFailure,
  }) {
    trace.processStarted = true;
  }

  final int count;
  final List<String> names;
  final int startupNotificationCount;
  final Object? initializeFailure;
  final Object? statusFailure;
  final Object? closeFailure;

  @override
  final CodexAppServerTrace trace = CodexAppServerTrace();

  @override
  List<String> get detectedMcpServerNames => names;

  @override
  int get mcpStartupNotificationCount => startupNotificationCount;

  @override
  bool get noMcpStartupEvents => startupNotificationCount == 0;

  @override
  Future<void> initialize() async {
    trace.initializeSent = true;
    if (initializeFailure != null) throw initializeFailure!;
    trace.initializeResponseReceived = true;
    trace.initializedNotificationSent = true;
  }

  @override
  Future<int> mcpServerCount() async {
    trace.mcpStatusRequestSent = true;
    if (statusFailure != null) throw statusFailure!;
    trace.mcpStatusResponseReceived = true;
    return count;
  }

  @override
  Future<void> close() async {
    trace.cleanupStarted = true;
    if (closeFailure != null) throw closeFailure!;
    if (!trace.processExited) {
      trace.processExited = true;
      trace.processExitCode = -1;
    }
  }
}
