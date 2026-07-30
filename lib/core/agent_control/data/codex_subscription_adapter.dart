import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';

import '../../../features/grpc/data/grpc_persistence_repository.dart';
import '../../security/secret_masker.dart';
import '../application/agent_orchestrator.dart';
import '../application/agent_tool_registry.dart';
import '../application/app_command.dart';
import '../application/app_command_bus.dart';
import '../application/codex_agent_commands.dart';
import '../domain/agent_models.dart';

/// Windows-only adapter for the locally installed official Codex App Server.
/// It never reads Codex credentials: the child client owns ChatGPT auth.
class CodexSubscriptionAdapter implements SubscriptionAgentAdapter {
  CodexSubscriptionAdapter({
    required AgentOrchestrator Function(String workspaceId)
    orchestratorForWorkspace,
    CodexExecutableLocator? locator,
    CodexIsolatedRuntime? runtime,
  }) : _orchestratorForWorkspace = orchestratorForWorkspace,
       _locator = locator ?? CodexExecutableLocator(),
       _runtime = runtime ?? CodexIsolatedRuntime();

  final AgentOrchestrator Function(String workspaceId)
  _orchestratorForWorkspace;
  final CodexExecutableLocator _locator;
  final CodexIsolatedRuntime _runtime;
  final Map<String, _CodexRunHandle> _runs = <String, _CodexRunHandle>{};
  final StreamController<OfficialSignInProgress> _signInEvents =
      StreamController<OfficialSignInProgress>.broadcast();
  Process? _loginProcess;
  bool _verificationUrlOpened = false;

  Stream<OfficialSignInProgress> get signInEvents => _signInEvents.stream;

  @override
  String get providerId => 'codex';

  @override
  Future<AgentInstallationStatus> detectInstallation() async =>
      _locator.discover() == null
      ? AgentInstallationStatus.notInstalled
      : AgentInstallationStatus.installed;

  @override
  Future<AgentAuthenticationStatus> authenticationStatus() async {
    final executable = _locator.discover();
    if (executable == null) return AgentAuthenticationStatus.unknown;
    try {
      final result = await Process.run(
        executable,
        const <String>['login', 'status'],
        environment: await _runtime.environment(),
        includeParentEnvironment: false,
        runInShell: false,
      );
      final text = SecretMasker.redactText(
        '${result.stdout}\n${result.stderr}',
      );
      return text.contains('Logged in using ChatGPT')
          ? AgentAuthenticationStatus.authenticated
          : AgentAuthenticationStatus.unauthenticated;
    } catch (_) {
      return AgentAuthenticationStatus.unknown;
    }
  }

  /// Proves that the isolated profile has no configured third-party MCP server.
  Future<CodexRuntimeReadiness> runtimeReadiness() async {
    final executable = _locator.discover();
    if (executable == null) return const CodexRuntimeReadiness.notInstalled();
    try {
      await _runtime.ensure();
      final authentication = await authenticationStatus();
      if (authentication != AgentAuthenticationStatus.authenticated) {
        return CodexRuntimeReadiness(
          isolatedProfileReady: true,
          authentication: authentication,
          mcpServerCount: null,
          noMcpStartupEvents: true,
          failureCategory: 'isolated_login_required',
          failedProbeStage: 'authentication',
        );
      }
      final session = await Directory.systemTemp.createTemp('devroute-codex-');
      _CodexAppServer? server;
      try {
        server = await _CodexAppServer.start(
          executable,
          session.path,
          await _runtime.environment(),
        );
        await server.initialize();
        final count = await server.mcpServerCount();
        return CodexRuntimeReadiness(
          isolatedProfileReady: true,
          authentication: authentication,
          mcpServerCount: count,
          noMcpStartupEvents: server.noMcpStartupEvents,
          detectedMcpServerNames: server.detectedMcpServerNames,
          mcpStartupNotificationCount: server.mcpStartupNotificationCount,
          failureCategory: count == 0 && server.noMcpStartupEvents
              ? null
              : 'third_party_mcp_detected',
          failedProbeStage: count == 0 && server.noMcpStartupEvents
              ? null
              : 'mcp_status_probe',
        );
      } finally {
        await server?.close();
        await session.delete(recursive: true);
      }
    } on _CodexFailure catch (error) {
      return CodexRuntimeReadiness.profileFailure(error.category);
    } on TimeoutException {
      return const CodexRuntimeReadiness.profileFailure('readiness_timeout');
    } catch (_) {
      return const CodexRuntimeReadiness.profileFailure(
        'mcp_status_probe_failed',
      );
    }
  }

  @override
  Future<AgentCapabilities> capabilities() async => const AgentCapabilities(
    <String>{'app.capabilities', 'grpc.history.search', 'cancellation'},
  );

  @override
  Future<OfficialSignInLaunchResult> launchOfficialSignIn() async {
    final executable = _locator.discover();
    if (executable == null) {
      return const OfficialSignInLaunchResult(
        launched: false,
        category: 'not_installed',
      );
    }
    if (_loginProcess != null) {
      return const OfficialSignInLaunchResult(launched: true);
    }
    try {
      final environment = await _runtime.environment();
      final process = await Process.start(
        executable,
        const <String>['login', '--device-auth'],
        environment: environment,
        includeParentEnvironment: false,
        runInShell: false,
      );
      _loginProcess = process;
      _verificationUrlOpened = false;
      final firstOutput = Completer<CodexDeviceAuthOutput>();
      final output = CodexDeviceAuthOutputCollector();
      void onChunk(String raw) {
        final parsed = output.addChunk(raw);
        if (parsed == null) return;
        final progress = OfficialSignInProgress(
          lifecycle: 'awaiting_user_verification',
          instructions: parsed.instructions,
          verificationUrl: parsed.verificationUrl,
          deviceCode: parsed.deviceCode,
        );
        _signInEvents.add(progress);
        if (parsed.verificationUrl != null && !_verificationUrlOpened) {
          _verificationUrlOpened = true;
          unawaited(
            Process.start('explorer.exe', <String>[
              parsed.verificationUrl!,
            ], runInShell: false),
          );
        }
        if (!firstOutput.isCompleted) firstOutput.complete(parsed);
      }

      process.stdout.transform(utf8.decoder).listen(onChunk);
      process.stderr.transform(utf8.decoder).listen(onChunk);
      unawaited(_watchLoginExit(process));
      final parsed = await firstOutput.future.timeout(
        const Duration(seconds: 5),
        onTimeout: CodexDeviceAuthOutput.empty,
      );
      return OfficialSignInLaunchResult(
        launched: true,
        instructions: parsed.instructions,
        verificationUrl: parsed.verificationUrl,
        deviceCode: parsed.deviceCode,
      );
    } catch (_) {
      return const OfficialSignInLaunchResult(
        launched: false,
        category: 'official_sign_in_launch_failed',
      );
    }
  }

  @override
  AgentRunHandle startRun(AgentRunRequest request) {
    final handle = _CodexRunHandle(request.runId);
    _runs[request.runId] = handle;
    unawaited(_run(request, handle));
    return handle;
  }

  Future<void> _run(AgentRunRequest request, _CodexRunHandle handle) async {
    final executable = _locator.discover();
    if (executable == null) return handle.fail('not_installed');
    final readiness = await runtimeReadiness();
    if (!readiness.canRun) {
      return handle.fail(readiness.effectiveFailureCategory);
    }
    final session = await Directory.systemTemp.createTemp('devroute-codex-');
    _CodexAppServer? server;
    try {
      server = await _CodexAppServer.start(
        executable,
        session.path,
        await _runtime.environment(),
      );
      handle.attach(server);
      await server.initialize();
      if (await server.mcpServerCount() != 0 || !server.noMcpStartupEvents) {
        throw const _CodexFailure('third_party_mcp_detected');
      }
      final threadId = await server.startRestrictedThread();
      await server.startTurn(
        threadId,
        const <String>[
          'Call app_capabilities first.',
          'Then call grpc_history_search.',
          'Do not use any other DevRoute tool.',
          'Return a short structured summary.',
        ].join(' '),
        (tool, arguments) => _dispatchTool(request, tool, arguments),
      );
      final result = await server.completed.timeout(
        const Duration(seconds: 60),
      );
      handle.complete(
        server.noMcpStartupEvents
            ? result
            : const AgentRunResult(
                status: AgentRunStatus.failed,
                results: <AgentToolCallResult>[],
                failureCategory: 'third_party_mcp_detected',
              ),
      );
    } on TimeoutException {
      handle.fail('app_server_timeout');
    } on _CodexFailure catch (error) {
      handle.fail(error.category);
    } catch (_) {
      handle.fail('app_server_failure');
    } finally {
      await server?.close();
      await session.delete(recursive: true);
      _runs.remove(request.runId);
    }
  }

  Future<Map<String, Object?>> _dispatchTool(
    AgentRunRequest request,
    String externalName,
    Object? arguments,
  ) async {
    final tool = switch (externalName) {
      'app_capabilities' => 'app.capabilities',
      'grpc_history_search' => 'grpc.history.search',
      _ => throw const _CodexFailure('unknown_dynamic_tool'),
    };
    if (arguments is! Map) throw const _CodexFailure('invalid_tool_input');
    final run = await _orchestratorForWorkspace(request.workspaceId).run(
      providerId: providerId,
      request: AgentRunRequest(
        runId: '${request.runId}:$tool',
        workspaceId: request.workspaceId,
        calls: <AgentToolCallRequest>[
          AgentToolCallRequest(
            toolName: tool,
            input: const <String, Object?>{},
            workspaceId: request.workspaceId,
          ),
        ],
      ),
      mode: AgentPermissionMode.observe,
      production: false,
      maximumSteps: 1,
      maximumNetworkOperations: 0,
    );
    final call = run.results.singleOrNull;
    if (run.status != AgentRunStatus.completed ||
        call == null ||
        !call.success) {
      throw _CodexFailure(
        call?.failureCategory ?? run.failureCategory ?? 'tool_failure',
      );
    }
    return call.output;
  }

  @override
  Future<void> cancelRun(String runId) async => _runs[runId]?.cancel();

  @override
  Future<void> disconnect() async {
    await Future.wait(_runs.values.map((run) => run.cancel()));
    await cancelOfficialSignIn();
  }

  Future<void> cancelOfficialSignIn() async {
    final process = _loginProcess;
    if (process == null) return;
    process.kill();
    _loginProcess = null;
    _signInEvents.add(const OfficialSignInProgress(lifecycle: 'cancelled'));
  }

  Future<void> _watchLoginExit(Process process) async {
    final exitCode = await process.exitCode;
    if (!identical(_loginProcess, process)) return;
    _loginProcess = null;
    final status = await authenticationStatus();
    _signInEvents.add(
      status == AgentAuthenticationStatus.authenticated
          ? const OfficialSignInProgress(lifecycle: 'authenticated')
          : OfficialSignInProgress(
              lifecycle: 'failed',
              failureCategory: exitCode == 0
                  ? 'isolated_login_required'
                  : 'official_sign_in_failed',
            ),
    );
  }
}

/// Owns DevRoute's profile without inspecting, copying, or linking global Codex
/// credentials. Codex itself writes the official login only after user consent.
class CodexIsolatedRuntime {
  CodexIsolatedRuntime({Directory? homeDirectory})
    : _homeDirectory = homeDirectory;

  static const String configToml = '''cli_auth_credentials_store = "file"
approval_policy = "never"
sandbox_mode = "read-only"
allow_login_shell = false

[tools]
web_search = false

[shell_environment_policy]
inherit = "none"
''';

  final Directory? _homeDirectory;

  Directory get homeDirectory {
    if (_homeDirectory != null) return _homeDirectory;
    final localAppData = Platform.environment['LOCALAPPDATA'];
    if (localAppData == null || localAppData.isEmpty) {
      throw const _CodexFailure('isolated_profile_unavailable');
    }
    return Directory('$localAppData\\DevRoute\\codex-home');
  }

  Future<void> ensure() async {
    final directory = homeDirectory;
    await directory.create(recursive: true);
    await File(
      '${directory.path}${Platform.pathSeparator}config.toml',
    ).writeAsString(configToml, flush: true);
  }

  Future<Map<String, String>> environment() async {
    await ensure();
    String required(String key) {
      final value = Platform.environment[key];
      if (value == null || value.isEmpty) {
        throw _CodexFailure('isolated_environment_unavailable');
      }
      return value;
    }

    return <String, String>{
      'CODEX_HOME': homeDirectory.path,
      'SystemRoot': required('SystemRoot'),
      'TEMP': required('TEMP'),
      'TMP': required('TMP'),
    };
  }
}

class CodexRuntimeReadiness {
  const CodexRuntimeReadiness({
    required this.isolatedProfileReady,
    required this.authentication,
    required this.mcpServerCount,
    required this.noMcpStartupEvents,
    this.failureCategory,
    this.failedProbeStage,
    this.detectedMcpServerNames = const <String>[],
    this.mcpStartupNotificationCount = 0,
  });

  const CodexRuntimeReadiness.notInstalled()
    : isolatedProfileReady = false,
      authentication = AgentAuthenticationStatus.unknown,
      mcpServerCount = null,
      noMcpStartupEvents = true,
      failureCategory = 'not_installed',
      failedProbeStage = 'installation',
      detectedMcpServerNames = const <String>[],
      mcpStartupNotificationCount = 0;

  const CodexRuntimeReadiness.profileFailure(String this.failureCategory)
    : isolatedProfileReady = false,
      authentication = AgentAuthenticationStatus.unknown,
      mcpServerCount = null,
      noMcpStartupEvents = false,
      failedProbeStage = 'runtime_probe',
      detectedMcpServerNames = const <String>[],
      mcpStartupNotificationCount = 0;

  final bool isolatedProfileReady;
  final AgentAuthenticationStatus authentication;
  final int? mcpServerCount;
  final bool noMcpStartupEvents;
  final String? failureCategory;
  final String? failedProbeStage;
  final List<String> detectedMcpServerNames;
  final int mcpStartupNotificationCount;

  bool get canRun =>
      isolatedProfileReady &&
      authentication == AgentAuthenticationStatus.authenticated &&
      mcpServerCount == 0 &&
      noMcpStartupEvents;

  String get effectiveFailureCategory {
    if (failureCategory != null) return failureCategory!;
    if (!isolatedProfileReady) return 'isolated_profile_unavailable';
    if (authentication != AgentAuthenticationStatus.authenticated) {
      return 'isolated_login_required';
    }
    return 'third_party_mcp_detected';
  }
}

class CodexDeviceAuthOutput {
  const CodexDeviceAuthOutput({
    this.instructions,
    this.verificationUrl,
    this.deviceCode,
  });

  factory CodexDeviceAuthOutput.parse(String output) {
    final raw = stripAnsi(
      output,
    ).replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final url = RegExp(r'https://[^\s]+').firstMatch(raw)?.group(0);
    final code =
        RegExp(
          r'^\s*([A-Z0-9]{3,8}(?:-[A-Z0-9]{3,8})+)\s*$',
          multiLine: true,
        ).firstMatch(raw)?.group(1) ??
        (RegExp(
              r'(?:device|user|verification|one[- ]time)\s+code|enter\s+(?:the\s+)?code',
              caseSensitive: false,
            ).hasMatch(raw)
            ? RegExp(
                r'\b([A-Z0-9]{3,8}(?:-[A-Z0-9]{3,8})+)\b',
              ).firstMatch(raw)?.group(1)
            : null);
    final sanitized = SecretMasker.redactText(raw).trim();
    return CodexDeviceAuthOutput(
      instructions: sanitized.isEmpty ? null : sanitized,
      verificationUrl: url,
      deviceCode: code,
    );
  }

  static CodexDeviceAuthOutput empty() => const CodexDeviceAuthOutput();

  static String stripAnsi(String value) =>
      value.replaceAll(RegExp(r'\x1B\[[0-?]*[ -/]*[@-~]'), '');

  final String? instructions;
  final String? verificationUrl;
  final String? deviceCode;
}

class CodexDeviceAuthOutputCollector {
  String _raw = '';
  String? _fingerprint;

  CodexDeviceAuthOutput? addChunk(String chunk) {
    _raw =
        '${_raw.length >= 4096 ? _raw.substring(_raw.length - 2048) : _raw}$chunk';
    final parsed = CodexDeviceAuthOutput.parse(_raw);
    final fingerprint = [
      parsed.instructions,
      parsed.verificationUrl,
      parsed.deviceCode,
    ].join('\u0000');
    if (fingerprint == _fingerprint) return null;
    _fingerprint = fingerprint;
    return parsed;
  }
}

class CodexExecutableLocator {
  String? discover() {
    if (!Platform.isWindows) return null;
    final appData = Platform.environment['APPDATA'];
    if (appData == null) return null;
    final path =
        '$appData\\npm\\node_modules\\@openai\\codex\\node_modules\\@openai\\codex-win32-x64\\vendor\\x86_64-pc-windows-msvc\\bin\\codex.exe';
    return File(path).existsSync() ? path : null;
  }
}

class _CodexAppServer {
  _CodexAppServer(this._process, this._cwd);
  final Process _process;
  final String _cwd;
  final Map<int, Completer<Map<String, Object?>>> _requests =
      <int, Completer<Map<String, Object?>>>{};
  final Completer<AgentRunResult> _completed = Completer<AgentRunResult>();
  late final StreamSubscription<String> _stdout;
  late final StreamSubscription<String> _stderr;
  int _nextId = 0;
  String? _threadId;
  String? _turnId;
  String? _model;
  final List<AgentToolCallResult> _toolResults = <AgentToolCallResult>[];
  Future<Map<String, Object?>> Function(String, Object?)? _toolHandler;
  String _stderrText = '';
  Future<AgentRunResult> get completed => _completed.future;

  static Future<_CodexAppServer> start(
    String executable,
    String cwd,
    Map<String, String> environment,
  ) async {
    final process = await Process.start(
      executable,
      const <String>['app-server', '--stdio'],
      workingDirectory: cwd,
      includeParentEnvironment: false,
      runInShell: false,
      environment: environment,
    );
    final server = _CodexAppServer(process, cwd);
    server._stdout = process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(server._onLine);
    server._stderr = process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
          final text = SecretMasker.redactText('${server._stderrText}\n$line');
          server._stderrText = text.length <= 2048
              ? text
              : text.substring(0, 2048);
        });
    process.exitCode.then((_) {
      if (!server._completed.isCompleted) {
        server._completed.complete(
          AgentRunResult(
            status: AgentRunStatus.failed,
            results: const <AgentToolCallResult>[],
            failureCategory: 'app_server_exited',
          ),
        );
      }
    });
    return server;
  }

  Future<void> initialize() async {
    await _request('initialize', <String, Object?>{
      'clientInfo': <String, Object?>{
        'name': 'devroute',
        'title': 'DevRoute AI Agents',
        'version': '0.4.0',
      },
      'capabilities': <String, Object?>{'experimentalApi': true},
    });
    _notify('initialized', const <String, Object?>{});
    final models = await _request('model/list', const <String, Object?>{
      'limit': 20,
      'includeHidden': false,
    });
    final data = models['data'];
    if (data is List) {
      final selected = data.cast<Object?>().whereType<Map>().firstWhere(
        (item) => item['isDefault'] == true && item['model'] is String,
        orElse: () => const <String, Object?>{},
      );
      _model = selected['model'] as String?;
    }
    if (_model == null) throw const _CodexFailure('no_supported_model');
  }

  final List<String> _detectedMcpServerNames = <String>[];
  int _mcpStartupNotificationCount = 0;
  bool get noMcpStartupEvents => _detectedMcpServerNames.isEmpty;
  List<String> get detectedMcpServerNames =>
      List<String>.unmodifiable(_detectedMcpServerNames);
  int get mcpStartupNotificationCount => _mcpStartupNotificationCount;

  Future<int> mcpServerCount() async {
    final response = await _request('mcpServerStatus/list', <String, Object?>{
      'limit': 100,
      'detail': 'toolsAndAuthOnly',
    });
    final data = response['data'];
    return data is List ? data.length : 0;
  }

  Future<String> startRestrictedThread() async {
    final response = await _request('thread/start', <String, Object?>{
      'ephemeral': true,
      'cwd': _cwd,
      'approvalPolicy': 'never',
      'sandbox': 'read-only',
      'model': _model,
      // Verified against codex-cli 0.142.5 with experimentalApi during initialize.
      'dynamicTools': <Object?>[
        <String, Object?>{
          'type': 'function',
          'name': 'app_capabilities',
          'description': 'Return sanitized DevRoute capabilities.',
          'inputSchema': <String, Object?>{
            'type': 'object',
            'properties': <String, Object?>{},
            'additionalProperties': false,
          },
        },
        <String, Object?>{
          'type': 'function',
          'name': 'grpc_history_search',
          'description': 'Return bounded sanitized gRPC history summary.',
          'inputSchema': <String, Object?>{
            'type': 'object',
            'properties': <String, Object?>{},
            'additionalProperties': false,
          },
        },
      ],
    });
    final thread = response['thread'];
    if (thread is! Map || thread['id'] is! String) {
      throw const _CodexFailure('invalid_thread_response');
    }
    return _threadId = thread['id'] as String;
  }

  Future<void> startTurn(
    String threadId,
    String prompt,
    Future<Map<String, Object?>> Function(String, Object?) toolHandler,
  ) async {
    _toolHandler = toolHandler;
    final response = await _request('turn/start', <String, Object?>{
      'threadId': threadId,
      'input': <Object?>[
        <String, Object?>{'type': 'text', 'text': prompt},
      ],
      'approvalPolicy': 'never',
      'sandboxPolicy': <String, Object?>{
        'type': 'readOnly',
        'access': <String, Object?>{
          'type': 'restricted',
          'includePlatformDefaults': false,
          'readableRoots': <Object?>[],
        },
      },
    });
    final turn = response['turn'];
    if (turn is! Map || turn['id'] is! String) {
      throw const _CodexFailure('invalid_turn_response');
    }
    _turnId = turn['id'] as String;
  }

  void _onLine(String line) {
    Object? decoded;
    try {
      decoded = jsonDecode(line);
    } catch (_) {
      return;
    }
    if (decoded is! Map) return;
    final message = decoded.cast<String, Object?>();
    final id = message['id'];
    if (id is int && _requests.containsKey(id)) {
      final completer = _requests.remove(id)!;
      if (message['error'] != null) {
        completer.completeError(_CodexFailure('protocol_error'));
      } else {
        completer.complete(
          (message['result'] as Map?)?.cast<String, Object?>() ??
              const <String, Object?>{},
        );
      }
      return;
    }
    if (message['method'] == 'item/tool/call') {
      unawaited(_handleToolCall(message));
      return;
    }
    if (message['method'] == 'mcpServer/startupStatus/updated') {
      _mcpStartupNotificationCount++;
      final params = message['params'] as Map?;
      final server =
          params?['server'] ??
          params?['serverName'] ??
          params?['name'] ??
          params?['id'];
      final name = server?.toString();
      if (name != null &&
          name.isNotEmpty &&
          !_detectedMcpServerNames.contains(name)) {
        _detectedMcpServerNames.add(name);
      }
      return;
    }
    if (message['method'] == 'turn/completed') {
      final params = message['params'] as Map?;
      final turn = params?['turn'] as Map?;
      final status = turn?['status']?.toString();
      if (!_completed.isCompleted) {
        _completed.complete(
          AgentRunResult(
            status: status == 'interrupted'
                ? AgentRunStatus.cancelled
                : (status == 'completed'
                      ? AgentRunStatus.completed
                      : AgentRunStatus.failed),
            results: List<AgentToolCallResult>.unmodifiable(_toolResults),
          ),
        );
      }
    }
  }

  Future<void> _handleToolCall(Map<String, Object?> message) async {
    final id = message['id'];
    final params = message['params'] as Map?;
    if (id is! int || params == null || _toolHandler == null) return;
    try {
      final output = await _toolHandler!(
        params['tool']?.toString() ?? '',
        params['arguments'],
      );
      _toolResults.add(
        AgentToolCallResult(
          toolName: params['tool']?.toString() ?? 'unknown',
          success: true,
          output: output,
        ),
      );
      _respond(id, <String, Object?>{
        'success': true,
        'contentItems': <Object?>[
          <String, Object?>{'type': 'inputText', 'text': jsonEncode(output)},
        ],
      });
    } on _CodexFailure catch (error) {
      _respond(id, <String, Object?>{
        'success': false,
        'contentItems': <Object?>[
          <String, Object?>{
            'type': 'inputText',
            'text': jsonEncode(<String, Object?>{'error': error.category}),
          },
        ],
      });
    } catch (_) {
      _respond(id, const <String, Object?>{
        'success': false,
        'contentItems': <Object?>[],
      });
    }
  }

  Future<Map<String, Object?>> _request(
    String method,
    Map<String, Object?> params,
  ) {
    final id = ++_nextId;
    final completer = Completer<Map<String, Object?>>();
    _requests[id] = completer;
    _send(<String, Object?>{'method': method, 'id': id, 'params': params});
    return completer.future.timeout(const Duration(seconds: 15));
  }

  void _notify(String method, Map<String, Object?> params) =>
      _send(<String, Object?>{'method': method, 'params': params});
  void _respond(int id, Map<String, Object?> result) =>
      _send(<String, Object?>{'id': id, 'result': result});
  void _send(Map<String, Object?> message) =>
      _process.stdin.writeln(jsonEncode(message));
  Future<void> interrupt() async {
    if (_threadId != null && _turnId != null) {
      try {
        await _request('turn/interrupt', <String, Object?>{
          'threadId': _threadId,
          'turnId': _turnId,
        });
      } catch (_) {}
    }
  }

  Future<void> close() async {
    await interrupt();
    _process.kill();
    await _stdout.cancel();
    await _stderr.cancel();
  }
}

class _CodexRunHandle implements AgentRunHandle {
  _CodexRunHandle(this.runId);
  @override
  final String runId;
  final StreamController<AgentRunEvent> _events =
      StreamController<AgentRunEvent>.broadcast();
  final Completer<AgentRunResult> _result = Completer<AgentRunResult>();
  _CodexAppServer? _server;
  @override
  Stream<AgentRunEvent> get events => _events.stream;
  @override
  Future<AgentRunResult> get result => _result.future;
  void attach(_CodexAppServer server) {
    _server = server;
    _events.add(const AgentRunEvent('app_server_started'));
  }

  void complete(AgentRunResult result) {
    if (!_result.isCompleted) _result.complete(result);
    _events.add(const AgentRunEvent('completed'));
    _events.close();
  }

  void fail(String category) => complete(
    AgentRunResult(
      status: AgentRunStatus.failed,
      results: const <AgentToolCallResult>[],
      failureCategory: category,
    ),
  );
  @override
  Future<void> cancel() async {
    _events.add(const AgentRunEvent('cancelling'));
    await _server?.interrupt();
    if (!_result.isCompleted) {
      _result.complete(
        const AgentRunResult(
          status: AgentRunStatus.cancelled,
          results: <AgentToolCallResult>[],
        ),
      );
    }
  }
}

class _CodexFailure implements Exception {
  const _CodexFailure(this.category);
  final String category;
}

/// Registers only the two read-only dynamic tools and routes both through AppCommandBus.
class CodexAgentCommandBindings {
  CodexAgentCommandBindings(this._bus, this._history);
  final AppCommandBus _bus;
  final GrpcPersistenceRepository _history;
  void register() {
    _bus.register<AppCapabilitiesCommand, Map<String, Object?>>(
      _CapabilitiesHandler(),
    );
    _bus.register<GrpcHistorySearchCommand, Map<String, Object?>>(
      _GrpcHistoryHandler(_history),
    );
  }

  AgentToolRegistry registry(String workspaceId) {
    final registry = AgentToolRegistry();
    AgentToolDefinition tool(
      String name,
      Future<Map<String, Object?>> Function() execute,
    ) => AgentToolDefinition(
      name: name,
      version: '1',
      description: name,
      risk: AgentRisk.readOnly,
      permission: AgentPermissionMode.observe,
      requiresApproval: false,
      timeout: const Duration(seconds: 5),
      cancellable: true,
      idempotency: AgentIdempotency.idempotent,
      validator: (input) => input.isEmpty,
      execute: (_) => execute(),
      maximumInputBytes: 256,
      maximumOutputBytes: 4096,
      allowedInputFields: const <String>{},
      rejectUnknownFields: true,
      availability: AgentToolAvailability.available,
    );
    registry.register(
      tool(
        'app.capabilities',
        () => _bus.execute<AppCapabilitiesCommand, Map<String, Object?>>(
          const AppCapabilitiesCommand(),
          AppCommandContext(
            operationId: const Uuid().v4(),
            workspaceId: workspaceId,
          ),
        ),
      ),
    );
    registry.register(
      tool(
        'grpc.history.search',
        () => _bus.execute<GrpcHistorySearchCommand, Map<String, Object?>>(
          const GrpcHistorySearchCommand(),
          AppCommandContext(
            operationId: const Uuid().v4(),
            workspaceId: workspaceId,
          ),
        ),
      ),
    );
    return registry;
  }
}

class _CapabilitiesHandler
    implements AppCommandHandler<AppCapabilitiesCommand, Map<String, Object?>> {
  @override
  Future<Map<String, Object?>> handle(
    AppCapabilitiesCommand command,
    AppCommandContext context,
  ) async => const <String, Object?>{
    'toolsAllowed': 2,
    'tools': <String>['app.capabilities', 'grpc.history.search'],
    'networkExecution': false,
    'fileModification': false,
    'directDatabaseAccess': false,
  };
}

class _GrpcHistoryHandler
    implements
        AppCommandHandler<GrpcHistorySearchCommand, Map<String, Object?>> {
  _GrpcHistoryHandler(this._history);
  final GrpcPersistenceRepository _history;
  @override
  Future<Map<String, Object?>> handle(
    GrpcHistorySearchCommand command,
    AppCommandContext context,
  ) async {
    final entries = await _history.history(context.workspaceId, limit: 10);
    return <String, Object?>{
      'totalCount': entries.length,
      'records': entries
          .map(
            (entry) => <String, Object?>{
              'protocol': 'gRPC',
              'method': SecretMasker.redactText(
                '${entry.methodIdentity['service'] ?? ''}/${entry.methodIdentity['method'] ?? ''}',
              ),
              'statusCategory': entry.outcome.name,
              'timestamp': entry.createdAt.toUtc().toIso8601String(),
            },
          )
          .toList(growable: false),
    };
  }
}
