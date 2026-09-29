import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../../features/grpc/data/grpc_persistence_repository.dart';
import '../../security/secret_masker.dart';
import '../application/agent_orchestrator.dart';
import '../application/agent_tool_registry.dart';
import '../application/app_command.dart';
import '../application/app_command_bus.dart';
import '../application/codex_agent_commands.dart';
import '../domain/agent_models.dart';

typedef CodexStatusProcessRunner =
    Future<ProcessResult> Function(
      String executable,
      List<String> arguments, {
      required Map<String, String> environment,
    });

typedef CodexMcpSessionLauncher =
    Future<CodexMcpProbeSession> Function(
      String executable,
      String workingDirectory,
      Map<String, String> environment,
    );

typedef CodexDynamicToolHandler =
    Future<CodexDynamicToolResult> Function(
      String invocationId,
      String tool,
      Object? arguments,
    );

class CodexCliVersion implements Comparable<CodexCliVersion> {
  const CodexCliVersion(this.major, this.minor, this.patch);

  factory CodexCliVersion.parse(String output) {
    final match = RegExp(r'codex-cli\s+(\d+)\.(\d+)\.(\d+)').firstMatch(output);
    if (match == null) throw const FormatException('codex_cli_version_invalid');
    return CodexCliVersion(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  final int major;
  final int minor;
  final int patch;

  @override
  int compareTo(CodexCliVersion other) {
    final majorOrder = major.compareTo(other.major);
    if (majorOrder != 0) return majorOrder;
    final minorOrder = minor.compareTo(other.minor);
    if (minorOrder != 0) return minorOrder;
    return patch.compareTo(other.patch);
  }

  @override
  String toString() => '$major.$minor.$patch';
}

class CodexModelSelection {
  const CodexModelSelection({
    required this.id,
    required this.displayName,
    required this.minimumCliVersion,
  });

  static const CodexModelSelection gpt56Luna = CodexModelSelection(
    id: 'gpt-5.6-luna',
    displayName: 'GPT-5.6 Luna',
    minimumCliVersion: CodexCliVersion(0, 144, 0),
  );

  final String id;
  final String displayName;
  final CodexCliVersion minimumCliVersion;

  bool supportsCliVersion(CodexCliVersion version) =>
      version.compareTo(minimumCliVersion) >= 0;
}

class _CodexCliVersionProbe {
  const _CodexCliVersionProbe.success(this.version) : failureCategory = null;

  const _CodexCliVersionProbe.failure(this.failureCategory) : version = null;

  final CodexCliVersion? version;
  final String? failureCategory;
}

class CodexDynamicToolResult {
  const CodexDynamicToolResult({
    required this.internalToolName,
    required this.output,
  });

  final String internalToolName;
  final Map<String, Object?> output;
}

class CodexToolInvocationEvidence {
  const CodexToolInvocationEvidence({
    required this.provider,
    required this.effectiveModel,
    required this.modelVisibleTool,
    required this.internalTool,
    required this.invocationId,
    required this.duration,
    required this.schemaValidationPassed,
    required this.permissionDecision,
    required this.typedExecutionPassed,
    required this.structuredResultReturned,
    required this.outcome,
  });

  final String provider;
  final String effectiveModel;
  final String modelVisibleTool;
  final String internalTool;
  final String invocationId;
  final Duration duration;
  final bool schemaValidationPassed;
  final String permissionDecision;
  final bool typedExecutionPassed;
  final bool structuredResultReturned;
  final String outcome;
}

class CodexRealTurnTrace {
  const CodexRealTurnTrace({
    required this.appServer,
    required this.duration,
    required this.threadId,
    required this.turnId,
    required this.turnStarted,
    required this.turnCompletedReceived,
    required this.completionState,
    required this.mcpServerCount,
    required this.detectedMcpServerNames,
    required this.mcpStartupNotificationCount,
    required this.toolInvocations,
    required this.finalModelResponse,
    required this.mutationCommandCount,
    required this.arbitraryShellUsed,
    required this.rawSecretCategories,
    required this.directApiObserved,
  });

  final CodexAppServerTrace appServer;
  final Duration duration;
  final String? threadId;
  final String? turnId;
  final bool turnStarted;
  final bool turnCompletedReceived;
  final String? completionState;
  final int? mcpServerCount;
  final List<String> detectedMcpServerNames;
  final int mcpStartupNotificationCount;
  final List<CodexToolInvocationEvidence> toolInvocations;
  final String? finalModelResponse;
  final int mutationCommandCount;
  final bool arbitraryShellUsed;
  final Map<String, String> rawSecretCategories;
  final bool directApiObserved;
}

class CodexTurnFailureDiagnostics {
  const CodexTurnFailureDiagnostics({
    required this.message,
    required this.codexErrorInfoType,
    required this.httpStatusCode,
    required this.additionalDetailsCategory,
  });

  final String? message;
  final String? codexErrorInfoType;
  final int? httpStatusCode;
  final String? additionalDetailsCategory;
}

class CodexAppServerStderrMetadata {
  const CodexAppServerStderrMetadata({
    required this.observedAt,
    required this.timestampPresent,
    required this.severity,
    required this.category,
    required this.httpStatusCode,
    required this.endpointHost,
  });

  final DateTime observedAt;
  final bool timestampPresent;
  final String severity;
  final String category;
  final int? httpStatusCode;
  final String? endpointHost;
}

abstract interface class CodexMcpProbeSession {
  CodexAppServerTrace get trace;
  bool get noMcpStartupEvents;
  List<String> get detectedMcpServerNames;
  int get mcpStartupNotificationCount;
  Future<void> initialize();
  Future<int> mcpServerCount();
  Future<void> close();
}

class CodexMcpProbeFailure implements Exception {
  const CodexMcpProbeFailure(this.category, {this.code, this.safeMessage});
  final String category;
  final int? code;
  final String? safeMessage;
}

class CodexAppServerProtocol {
  const CodexAppServerProtocol._();

  /// Returns the requested model only when it is explicitly visible to the
  /// authenticated App Server session. There is intentionally no fallback.
  static String? selectAvailableModel(
    Object? modelList,
    String requestedModel,
  ) {
    if (modelList is! List) return null;
    for (final item in modelList.whereType<Map>()) {
      if (item['model'] == requestedModel) return requestedModel;
    }
    return null;
  }

  static Map<String, Object?> restrictedThreadStartParams({
    required String cwd,
    required String model,
  }) => <String, Object?>{
    'ephemeral': true,
    'cwd': cwd,
    'approvalPolicy': 'never',
    'sandbox': 'read-only',
    'model': model,
  };

  static String parseThreadId(Map<String, Object?> result) {
    final thread = result['thread'];
    if (thread is! Map || thread['id'] is! String) {
      throw const CodexMcpProbeFailure('invalid_thread_response');
    }
    return thread['id'] as String;
  }

  static String parseTurnId(Map<String, Object?> result) {
    final turn = result['turn'];
    if (turn is! Map || turn['id'] is! String) {
      throw const CodexMcpProbeFailure('invalid_turn_response');
    }
    return turn['id'] as String;
  }

  static Map<String, Object?> turnStartParams({
    required String threadId,
    required String prompt,
  }) => <String, Object?>{
    'threadId': threadId,
    'input': <Object?>[
      <String, Object?>{'type': 'text', 'text': prompt},
    ],
    'approvalPolicy': 'never',
    'sandboxPolicy': <String, Object?>{
      'type': 'readOnly',
      'networkAccess': false,
    },
  };

  static bool isResponseFor(Map<String, Object?> message, int requestId) =>
      message['id'] == requestId &&
      (message.containsKey('result') || message.containsKey('error'));

  static bool isTurnStarted(Map<String, Object?> message) =>
      message['method'] == 'turn/started';

  static String? turnCompletedStatus(Map<String, Object?> message) {
    if (message['method'] != 'turn/completed') return null;
    final params = message['params'];
    final turn = params is Map ? params['turn'] : null;
    return turn is Map ? turn['status']?.toString() : null;
  }

  static CodexTurnFailureDiagnostics? turnCompletedFailure(
    Map<String, Object?> message,
  ) {
    if (message['method'] != 'turn/completed') return null;
    final params = message['params'];
    final turn = params is Map ? params['turn'] : null;
    final error = turn is Map ? turn['error'] : null;
    if (error is! Map) return null;
    final safeMessage = _boundedSafeText(
      SecretMasker.redactText(error['message']?.toString() ?? ''),
    );
    final codexErrorInfo = error['codexErrorInfo'];
    return CodexTurnFailureDiagnostics(
      message: safeMessage,
      codexErrorInfoType: _codexErrorInfoType(codexErrorInfo),
      httpStatusCode: _codexErrorHttpStatus(codexErrorInfo),
      additionalDetailsCategory: _classifyFailureText(
        error['additionalDetails']?.toString(),
      ),
    );
  }

  static String eventType(Map<String, Object?> message) {
    final method = message['method']?.toString() ?? 'unknown';
    final params = message['params'];
    final item = params is Map ? params['item'] : null;
    if (item is! Map || item['type'] == null) return method;
    final status = item['status']?.toString();
    return '$method:${item['type']}${status == null ? '' : ':$status'}';
  }

  static String failureStage(
    List<String> eventTypes,
    List<String> serverRequestMethods,
  ) {
    if (serverRequestMethods.isNotEmpty ||
        eventTypes.any((event) => event.startsWith('item/tool/call'))) {
      return 'during_approval_or_tool_processing';
    }
    if (eventTypes.any(
      (event) => event.startsWith('item/completed:agentMessage'),
    )) {
      return 'after_assistant_item';
    }
    if (eventTypes.any(
      (event) =>
          event.startsWith('item/started:userMessage') ||
          event.startsWith('item/completed:userMessage'),
    )) {
      return 'after_user_message_before_model_sampling';
    }
    return 'before_user_message_item';
  }

  static CodexAppServerStderrMetadata? stderrMetadata(String line) {
    final safe = SecretMasker.redactText(line);
    if (safe.trim().isEmpty) return null;
    final lower = safe.toLowerCase();
    final status = RegExp(r'\b([1-5]\d{2})\b').firstMatch(safe);
    final severity = RegExp(
      r'\b(error|warn|warning|info|debug)\b',
      caseSensitive: false,
    ).firstMatch(safe)?.group(1)?.toLowerCase();
    return CodexAppServerStderrMetadata(
      observedAt: DateTime.now().toUtc(),
      timestampPresent: RegExp(
        r'\d{4}-\d{2}-\d{2}[t ]',
        caseSensitive: false,
      ).hasMatch(safe),
      severity: severity ?? 'unknown',
      category: _classifyFailureText(safe) ?? 'unknown',
      httpStatusCode: status == null ? null : int.parse(status.group(1)!),
      endpointHost: lower.contains('openai.com')
          ? 'openai'
          : (RegExp(r'https?://', caseSensitive: false).hasMatch(safe)
                ? 'other'
                : null),
    );
  }

  static String? _boundedSafeText(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return trimmed.length <= 256 ? trimmed : '${trimmed.substring(0, 256)}...';
  }

  static String? _codexErrorInfoType(Object? value) {
    if (value is String) return value;
    if (value is! Map || value.isEmpty) return null;
    return value.keys.first.toString();
  }

  static int? _codexErrorHttpStatus(Object? value) {
    if (value is! Map || value.isEmpty) return null;
    final nested = value.values.first;
    if (nested is! Map) return null;
    return nested['httpStatusCode'] is int
        ? nested['httpStatusCode'] as int
        : null;
  }

  static String? _classifyFailureText(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final lower = value.toLowerCase();
    if (lower.contains('unauthorized') || lower.contains('authentication')) {
      return 'authentication_error';
    }
    if (lower.contains('rate limit') || lower.contains('usage limit')) {
      return 'rate_limit';
    }
    if (lower.contains('overloaded') || lower.contains('unavailable model')) {
      return 'model_unavailable';
    }
    if (lower.contains('invalid request') || lower.contains('bad request')) {
      return 'invalid_request';
    }
    if (lower.contains('unsupported parameter')) {
      return 'unsupported_parameter';
    }
    if (lower.contains('sandbox')) return 'sandbox_error';
    if (lower.contains('working directory') || lower.contains('cwd')) {
      return 'cwd_error';
    }
    if (lower.contains('tool schema') || lower.contains('dynamic tool')) {
      return 'tool_schema_error';
    }
    if (lower.contains('approval')) return 'approval_error';
    if (lower.contains('websocket')) return 'websocket_error';
    if (lower.contains('timeout')) return 'timeout';
    if (lower.contains('connect') ||
        lower.contains('network') ||
        lower.contains('http')) {
      return 'upstream_connection_error';
    }
    if (lower.contains('server')) return 'server_error';
    return 'unknown';
  }

  static String protocolErrorCategory(String method) => switch (method) {
    'thread/start' => 'thread_start_protocol_error',
    'turn/start' => 'turn_start_protocol_error',
    _ => 'protocol_error',
  };

  static String timeoutCategory(String method) => switch (method) {
    'thread/start' => 'thread_start_timeout',
    'turn/start' => 'turn_start_timeout',
    _ => 'protocol_timeout',
  };
}

/// Windows-only adapter for the locally installed official Codex App Server.
/// It never reads Codex credentials: the child client owns ChatGPT auth.
class CodexSubscriptionAdapter implements SubscriptionAgentAdapter {
  CodexSubscriptionAdapter({
    required AgentOrchestrator Function(String workspaceId)
    orchestratorForWorkspace,
    CodexExecutableLocator? locator,
    CodexIsolatedRuntime? runtime,
    CodexStatusProcessRunner? statusProcessRunner,
    CodexMcpSessionLauncher? mcpSessionLauncher,
    CodexModelSelection modelSelection = CodexModelSelection.gpt56Luna,
    Duration authStatusTimeout = const Duration(seconds: 5),
  }) : _orchestratorForWorkspace = orchestratorForWorkspace,
       _locator = locator ?? CodexExecutableLocator(),
       _runtime = runtime ?? CodexIsolatedRuntime(),
       _statusProcessRunner = statusProcessRunner ?? _runStatusProcess,
       _mcpSessionLauncher = mcpSessionLauncher ?? _CodexAppServer.start,
       _modelSelection = modelSelection,
       _authStatusTimeout = authStatusTimeout;

  final AgentOrchestrator Function(String workspaceId)
  _orchestratorForWorkspace;
  final CodexExecutableLocator _locator;
  final CodexIsolatedRuntime _runtime;
  final CodexStatusProcessRunner _statusProcessRunner;
  final CodexMcpSessionLauncher _mcpSessionLauncher;
  final CodexModelSelection _modelSelection;
  final Duration _authStatusTimeout;
  final Map<String, _CodexRunHandle> _runs = <String, _CodexRunHandle>{};
  final StreamController<OfficialSignInProgress> _signInEvents =
      StreamController<OfficialSignInProgress>.broadcast();
  Process? _loginProcess;
  bool _verificationUrlOpened = false;

  static const String realTurnPrompt =
      'Inspect the DevRoute capabilities available to you, then search the gRPC '
      'history using the provided DevRoute tools. Do not modify application '
      'state, do not execute arbitrary shell commands, and use only the tools '
      'exposed by DevRoute.';
  static const String simpleConnectivityPrompt =
      'Reply with a short confirmation and do not use tools.';

  CodexRealTurnTrace? lastRealTurnTrace;

  Stream<OfficialSignInProgress> get signInEvents => _signInEvents.stream;

  CodexModelSelection get modelSelection => _modelSelection;

  @override
  String get providerId => 'codex';

  @override
  Future<AgentInstallationStatus> detectInstallation() async =>
      _locator.discover() == null
      ? AgentInstallationStatus.notInstalled
      : AgentInstallationStatus.installed;

  @override
  Future<AgentAuthenticationStatus> authenticationStatus() async =>
      (await _probeAuthentication()).status;

  static Future<ProcessResult> _runStatusProcess(
    String executable,
    List<String> arguments, {
    required Map<String, String> environment,
  }) => Process.run(
    executable,
    arguments,
    environment: environment,
    includeParentEnvironment: false,
    runInShell: false,
  );

  Future<_CodexAuthenticationProbe> _probeAuthentication() async {
    final executable = _locator.discover();
    if (executable == null) {
      return const _CodexAuthenticationProbe.unknown('process_spawn_failed');
    }
    try {
      final result = await _statusProcessRunner(executable, const <String>[
        'login',
        'status',
      ], environment: await _runtime.environment()).timeout(_authStatusTimeout);
      final text = SecretMasker.redactText(
        '${result.stdout}\n${result.stderr}',
      );
      if (text.contains('Logged in using ChatGPT')) {
        return const _CodexAuthenticationProbe.authenticated();
      }
      if (RegExp('not logged in', caseSensitive: false).hasMatch(text)) {
        return const _CodexAuthenticationProbe.unauthenticated();
      }
      if (result.exitCode != 0) {
        return const _CodexAuthenticationProbe.unknown('process_nonzero_exit');
      }
      return _CodexAuthenticationProbe.unknown(
        result.stderr.toString().trim().isEmpty
            ? 'status_parse_failed'
            : 'unexpected_stderr',
      );
    } on TimeoutException {
      return const _CodexAuthenticationProbe.unknown('process_timeout');
    } on ProcessException {
      return const _CodexAuthenticationProbe.unknown('process_spawn_failed');
    } on _CodexFailure catch (error) {
      return _CodexAuthenticationProbe.unknown(error.category);
    } catch (_) {
      return const _CodexAuthenticationProbe.unknown('process_exception');
    }
  }

  Future<_CodexCliVersionProbe> _probeCliVersion(String executable) async {
    try {
      final result = await _statusProcessRunner(executable, const <String>[
        '--version',
      ], environment: await _runtime.environment()).timeout(_authStatusTimeout);
      if (result.exitCode != 0) {
        return const _CodexCliVersionProbe.failure(
          'codex_version_nonzero_exit',
        );
      }
      final text = SecretMasker.redactText(
        '${result.stdout}\n${result.stderr}',
      );
      try {
        return _CodexCliVersionProbe.success(CodexCliVersion.parse(text));
      } on FormatException {
        return const _CodexCliVersionProbe.failure(
          'codex_version_parse_failed',
        );
      }
    } on TimeoutException {
      return const _CodexCliVersionProbe.failure('codex_version_timeout');
    } on ProcessException {
      return const _CodexCliVersionProbe.failure(
        'codex_version_process_start_failed',
      );
    } catch (_) {
      return const _CodexCliVersionProbe.failure('codex_version_probe_failed');
    }
  }

  /// Proves that the isolated profile has no configured third-party MCP server.
  Future<CodexRuntimeReadiness> runtimeReadiness() async {
    final executable = _locator.discover();
    if (executable == null) return const CodexRuntimeReadiness.notInstalled();
    final diagnostics = CodexRuntimeDiagnostics.capture(
      executablePath: executable,
    );
    try {
      await _runtime.ensure();
    } on FileSystemException catch (error) {
      return CodexRuntimeReadiness.runtimeFailure(
        stage: 'isolated_home_probe',
        category: 'isolated_home_prepare_failed',
        diagnostics: diagnostics.withFailure(
          exceptionType: error.runtimeType.toString(),
          osErrorCode: error.osError?.errorCode,
        ),
      );
    } on _CodexFailure catch (error) {
      return CodexRuntimeReadiness.runtimeFailure(
        stage: 'isolated_home_probe',
        category: error.category,
        diagnostics: diagnostics.withFailure(
          exceptionType: error.runtimeType.toString(),
        ),
      );
    } catch (error) {
      return CodexRuntimeReadiness.runtimeFailure(
        stage: 'isolated_home_probe',
        category: 'isolated_home_probe_failed',
        diagnostics: diagnostics.withFailure(
          exceptionType: error.runtimeType.toString(),
        ),
      );
    }
    Directory? mcpSession;
    CodexMcpProbeSession? mcpServer;
    var appServerSubstage = 'mcp_not_started';
    String? filesystemOperation;
    String? filesystemPath;
    String? failedAppServerSubstage;
    String? failedFilesystemOperation;
    String? failedFilesystemPath;
    int? mcpCount;
    try {
      final probe = await _probeAuthentication();
      final authentication = probe.status;
      if (authentication != AgentAuthenticationStatus.authenticated) {
        return CodexRuntimeReadiness(
          isolatedProfileReady: true,
          authentication: authentication,
          mcpServerCount: null,
          noMcpStartupEvents: true,
          failureCategory: probe.failureCategory ?? 'isolated_login_required',
          failedProbeStage: 'authentication_probe',
          authenticationProbeAttempted: true,
          diagnostics: diagnostics,
        );
      }
      final versionProbe = await _probeCliVersion(executable);
      if (versionProbe.version == null) {
        return CodexRuntimeReadiness(
          isolatedProfileReady: true,
          authentication: authentication,
          mcpServerCount: null,
          noMcpStartupEvents: true,
          failureCategory: versionProbe.failureCategory,
          failedProbeStage: 'version_probe',
          authenticationProbeAttempted: true,
          selectedModelId: _modelSelection.id,
          requiredCodexVersion: _modelSelection.minimumCliVersion.toString(),
          diagnostics: diagnostics,
        );
      }
      final codexVersion = versionProbe.version!;
      if (!_modelSelection.supportsCliVersion(codexVersion)) {
        return CodexRuntimeReadiness(
          isolatedProfileReady: true,
          authentication: authentication,
          mcpServerCount: null,
          noMcpStartupEvents: true,
          failureCategory: 'CODEX_UPDATE_REQUIRED_FOR_SELECTED_MODEL',
          failedProbeStage: 'model_compatibility',
          authenticationProbeAttempted: true,
          detectedCodexVersion: codexVersion.toString(),
          selectedModelId: _modelSelection.id,
          requiredCodexVersion: _modelSelection.minimumCliVersion.toString(),
          diagnostics: diagnostics,
        );
      }
      appServerSubstage = 'mcp_session_create';
      filesystemOperation = 'create';
      filesystemPath = Directory.systemTemp.path;
      mcpSession = await Directory.systemTemp.createTemp('devroute-codex-');
      try {
        appServerSubstage = 'mcp_process_start';
        filesystemOperation = 'process_start';
        filesystemPath = executable;
        mcpServer = await _mcpSessionLauncher(
          executable,
          mcpSession.path,
          await _runtime.environment(),
        );
        appServerSubstage = 'mcp_initialize';
        filesystemOperation = null;
        filesystemPath = null;
        await mcpServer.initialize();
        appServerSubstage = 'mcp_status';
        mcpCount = await mcpServer.mcpServerCount();
      } catch (_) {
        failedAppServerSubstage = appServerSubstage;
        failedFilesystemOperation = filesystemOperation;
        failedFilesystemPath = filesystemPath;
        rethrow;
      } finally {
        appServerSubstage = 'mcp_cleanup_close';
        filesystemOperation = 'close';
        filesystemPath = null;
        await mcpServer?.close();
        appServerSubstage = 'mcp_cleanup_delete';
        filesystemOperation = 'delete';
        filesystemPath = mcpSession.path;
        await mcpSession.delete(recursive: true);
      }
      final server = mcpServer;
      final count = mcpCount;
      return CodexRuntimeReadiness(
        isolatedProfileReady: true,
        authentication: authentication,
        mcpServerCount: count,
        noMcpStartupEvents: server.noMcpStartupEvents,
        detectedMcpServerNames: server.detectedMcpServerNames,
        mcpStartupNotificationCount: server.mcpStartupNotificationCount,
        detectedCodexVersion: codexVersion.toString(),
        selectedModelId: _modelSelection.id,
        requiredCodexVersion: _modelSelection.minimumCliVersion.toString(),
        failureCategory: count == 0 && server.noMcpStartupEvents
            ? null
            : 'third_party_mcp_detected',
        failedProbeStage: count == 0 && server.noMcpStartupEvents
            ? null
            : 'mcp_probe',
        authenticationProbeAttempted: true,
        diagnostics: diagnostics.withMcpTrace(server.trace),
      );
    } on CodexMcpProbeFailure catch (error) {
      return CodexRuntimeReadiness.runtimeFailure(
        stage: 'mcp_probe',
        category: error.category,
        isolatedProfileReady: true,
        authentication: AgentAuthenticationStatus.authenticated,
        authenticationProbeAttempted: true,
        diagnostics: diagnostics.withFailure(
          exceptionType: error.runtimeType.toString(),
          operation: failedFilesystemOperation ?? filesystemOperation,
          path: _safeDiagnosticPath(failedFilesystemPath ?? filesystemPath),
          appServerSubstage: failedAppServerSubstage ?? appServerSubstage,
          trace: mcpServer?.trace,
        ),
      );
    } on _CodexFailure catch (error) {
      return CodexRuntimeReadiness.runtimeFailure(
        stage: 'mcp_probe',
        category: error.category,
        isolatedProfileReady: true,
        authentication: AgentAuthenticationStatus.authenticated,
        authenticationProbeAttempted: true,
        diagnostics: diagnostics.withFailure(
          exceptionType: error.runtimeType.toString(),
          operation: failedFilesystemOperation ?? filesystemOperation,
          path: _safeDiagnosticPath(failedFilesystemPath ?? filesystemPath),
          appServerSubstage: failedAppServerSubstage ?? appServerSubstage,
          trace: mcpServer?.trace,
        ),
      );
    } on TimeoutException {
      return CodexRuntimeReadiness.runtimeFailure(
        stage: 'mcp_probe',
        category: 'mcp_probe_timeout',
        isolatedProfileReady: true,
        authentication: AgentAuthenticationStatus.authenticated,
        authenticationProbeAttempted: true,
        diagnostics: diagnostics.withFailure(
          timedOut: true,
          operation: failedFilesystemOperation ?? filesystemOperation,
          path: failedFilesystemPath ?? filesystemPath,
          appServerSubstage: failedAppServerSubstage ?? appServerSubstage,
          trace: mcpServer?.trace,
        ),
      );
    } on ProcessException catch (error) {
      return CodexRuntimeReadiness.runtimeFailure(
        stage: 'mcp_probe',
        category: 'mcp_process_start_failed',
        isolatedProfileReady: true,
        authentication: AgentAuthenticationStatus.authenticated,
        authenticationProbeAttempted: true,
        diagnostics: diagnostics.withFailure(
          exceptionType: error.runtimeType.toString(),
          osErrorCode: error.errorCode,
          operation: failedFilesystemOperation ?? filesystemOperation,
          path: _safeDiagnosticPath(failedFilesystemPath ?? filesystemPath),
          appServerSubstage: failedAppServerSubstage ?? appServerSubstage,
          trace: mcpServer?.trace,
        ),
      );
    } on FormatException catch (error) {
      return CodexRuntimeReadiness.runtimeFailure(
        stage: 'mcp_probe',
        category: 'mcp_response_parse_failed',
        isolatedProfileReady: true,
        authentication: AgentAuthenticationStatus.authenticated,
        authenticationProbeAttempted: true,
        diagnostics: diagnostics.withFailure(
          exceptionType: error.runtimeType.toString(),
          appServerSubstage: failedAppServerSubstage ?? appServerSubstage,
          trace: mcpServer?.trace,
        ),
      );
    } on FileSystemException catch (error) {
      return CodexRuntimeReadiness.runtimeFailure(
        stage: 'mcp_probe',
        category:
            (failedAppServerSubstage ?? appServerSubstage).startsWith(
              'mcp_cleanup_',
            )
            ? 'mcp_probe_cleanup_failed'
            : 'mcp_filesystem_failed',
        isolatedProfileReady: true,
        authentication: AgentAuthenticationStatus.authenticated,
        authenticationProbeAttempted: true,
        diagnostics: diagnostics.withFailure(
          exceptionType: error.runtimeType.toString(),
          osErrorCode: error.osError?.errorCode,
          osErrorCategory: _safeOsErrorCategory(error.osError),
          operation: failedFilesystemOperation ?? filesystemOperation,
          path: _safeDiagnosticPath(
            error.path ?? failedFilesystemPath ?? filesystemPath,
          ),
          appServerSubstage: failedAppServerSubstage ?? appServerSubstage,
          trace: mcpServer?.trace,
        ),
      );
    } catch (error) {
      return CodexRuntimeReadiness.runtimeFailure(
        stage: 'mcp_probe',
        category: 'mcp_status_probe_failed',
        isolatedProfileReady: true,
        authentication: AgentAuthenticationStatus.authenticated,
        authenticationProbeAttempted: true,
        diagnostics: diagnostics.withFailure(
          exceptionType: error.runtimeType.toString(),
          operation: failedFilesystemOperation ?? filesystemOperation,
          path: _safeDiagnosticPath(failedFilesystemPath ?? filesystemPath),
          appServerSubstage: failedAppServerSubstage ?? appServerSubstage,
          trace: mcpServer?.trace,
        ),
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
  AgentRunHandle startRun(AgentRunRequest request) =>
      _startRun(request, realTurnPrompt);

  AgentRunHandle startSimpleRun(AgentRunRequest request) =>
      _startRun(request, simpleConnectivityPrompt);

  AgentRunHandle _startRun(AgentRunRequest request, String prompt) {
    final handle = _CodexRunHandle(request.runId);
    _runs[request.runId] = handle;
    unawaited(_run(request, handle, prompt));
    return handle;
  }

  Future<void> _run(
    AgentRunRequest request,
    _CodexRunHandle handle,
    String prompt,
  ) async {
    final executable = _locator.discover();
    if (executable == null) return handle.fail('not_installed');
    final readiness = await runtimeReadiness();
    if (!readiness.canRun) {
      return handle.fail(readiness.effectiveFailureCategory);
    }
    final session = await Directory.systemTemp.createTemp('devroute-codex-');
    _CodexAppServer? server;
    final stopwatch = Stopwatch()..start();
    final invocations = <CodexToolInvocationEvidence>[];
    AgentRunResult terminalResult;
    int? finalMcpServerCount;
    try {
      server = await _CodexAppServer.start(
        executable,
        session.path,
        await _runtime.environment(),
        modelSelection: _modelSelection,
      );
      handle.attach(server);
      await server.initialize();
      if (await server.mcpServerCount() != 0 || !server.noMcpStartupEvents) {
        throw const _CodexFailure('third_party_mcp_detected');
      }
      final threadId = await server.startRestrictedThread();
      await server.startTurn(
        threadId,
        prompt,
        (invocationId, tool, arguments) =>
            _dispatchTool(request, invocationId, tool, arguments, invocations),
      );
      final result = await server.completed.timeout(
        const Duration(seconds: 60),
      );
      finalMcpServerCount = await server.mcpServerCount();
      terminalResult = finalMcpServerCount == 0 && server.noMcpStartupEvents
          ? result
          : const AgentRunResult(
              status: AgentRunStatus.failed,
              results: <AgentToolCallResult>[],
              failureCategory: 'third_party_mcp_detected',
            );
    } on TimeoutException {
      terminalResult = _failedRun('app_server_timeout');
    } on CodexMcpProbeFailure catch (error) {
      terminalResult = _failedRun(error.category);
    } on _CodexFailure catch (error) {
      terminalResult = _failedRun(error.category);
    } catch (_) {
      terminalResult = _failedRun('app_server_failure');
    } finally {
      await server?.close();
      await session.delete(recursive: true);
      stopwatch.stop();
      if (server != null) {
        lastRealTurnTrace = CodexRealTurnTrace(
          appServer: server.trace,
          duration: stopwatch.elapsed,
          threadId: server.threadId,
          turnId: server.turnId,
          turnStarted: server.turnStarted,
          turnCompletedReceived: server.turnCompletedReceived,
          completionState: server.completionState,
          mcpServerCount: finalMcpServerCount,
          detectedMcpServerNames: server.detectedMcpServerNames,
          mcpStartupNotificationCount: server.mcpStartupNotificationCount,
          toolInvocations: List<CodexToolInvocationEvidence>.unmodifiable(
            invocations,
          ),
          finalModelResponse: server.finalModelResponse,
          mutationCommandCount: 0,
          arbitraryShellUsed: server.arbitraryShellUsed,
          rawSecretCategories: server.rawSecretCategories,
          directApiObserved: server.directApiObserved,
        );
      }
      _runs.remove(request.runId);
    }
    handle.complete(terminalResult);
  }

  AgentRunResult _failedRun(String category) => AgentRunResult(
    status: AgentRunStatus.failed,
    results: const <AgentToolCallResult>[],
    failureCategory: category,
  );

  Future<CodexDynamicToolResult> _dispatchTool(
    AgentRunRequest request,
    String invocationId,
    String externalName,
    Object? arguments,
    List<CodexToolInvocationEvidence> invocations,
  ) async {
    final stopwatch = Stopwatch()..start();
    final tool = switch (externalName) {
      'app_capabilities' => 'app.capabilities',
      'grpc_history_search' => 'grpc.history.search',
      _ => throw const _CodexFailure('unknown_dynamic_tool'),
    };
    if (arguments is! Map) throw const _CodexFailure('invalid_tool_input');
    Map<String, Object?> input;
    try {
      input = Map<String, Object?>.from(arguments);
    } catch (_) {
      throw const _CodexFailure('invalid_tool_input');
    }
    final run = await _orchestratorForWorkspace(request.workspaceId).run(
      providerId: providerId,
      request: AgentRunRequest(
        runId: '${request.runId}:$tool',
        workspaceId: request.workspaceId,
        calls: <AgentToolCallRequest>[
          AgentToolCallRequest(
            toolName: tool,
            input: input,
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
      stopwatch.stop();
      invocations.add(
        CodexToolInvocationEvidence(
          provider: providerId,
          effectiveModel: _modelSelection.id,
          modelVisibleTool: externalName,
          internalTool: tool,
          invocationId: invocationId,
          duration: stopwatch.elapsed,
          schemaValidationPassed: run.failureCategory != 'maximum_input_bytes',
          permissionDecision: run.failureCategory ?? 'failed',
          typedExecutionPassed: false,
          structuredResultReturned: false,
          outcome: 'failure',
        ),
      );
      throw _CodexFailure(
        call?.failureCategory ?? run.failureCategory ?? 'tool_failure',
      );
    }
    stopwatch.stop();
    invocations.add(
      CodexToolInvocationEvidence(
        provider: providerId,
        effectiveModel: _modelSelection.id,
        modelVisibleTool: externalName,
        internalTool: tool,
        invocationId: invocationId,
        duration: stopwatch.elapsed,
        schemaValidationPassed: true,
        permissionDecision: 'pass',
        typedExecutionPassed: true,
        structuredResultReturned: true,
        outcome: 'success',
      ),
    );
    return CodexDynamicToolResult(internalToolName: tool, output: call.output);
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

[features]
apps = false
shell_tool = false

[shell_environment_policy]
inherit = "none"
''';

  final Directory? _homeDirectory;

  Directory get homeDirectory {
    if (_homeDirectory != null) return _homeDirectory;
    final environment = Platform.environment;
    final String? appDataDirectory;
    if (Platform.isWindows) {
      appDataDirectory = environment['LOCALAPPDATA'];
    } else if (Platform.isLinux) {
      final xdgDataHome = environment['XDG_DATA_HOME'];
      final userHome = environment['HOME'];
      appDataDirectory = xdgDataHome != null && xdgDataHome.isNotEmpty
          ? xdgDataHome
          : userHome == null || userHome.isEmpty
          ? null
          : path.join(userHome, '.local', 'share');
    } else if (Platform.isMacOS) {
      final userHome = environment['HOME'];
      appDataDirectory = userHome == null || userHome.isEmpty
          ? null
          : path.join(userHome, 'Library', 'Application Support');
    } else {
      appDataDirectory = null;
    }
    if (appDataDirectory == null || appDataDirectory.isEmpty) {
      throw const _CodexFailure('isolated_profile_unavailable');
    }
    return Directory(path.join(appDataDirectory, 'DevRoute', 'codex-home'));
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

    final temporaryDirectory = Directory.systemTemp.path;
    final environment = <String, String>{
      'CODEX_HOME': homeDirectory.path,
      'HOME': homeDirectory.path,
      'TEMP': temporaryDirectory,
      'TMP': temporaryDirectory,
      'TMPDIR': temporaryDirectory,
    };
    if (Platform.isWindows) {
      environment['SystemRoot'] = required('SystemRoot');
    }
    return environment;
  }
}

class _CodexAuthenticationProbe {
  const _CodexAuthenticationProbe._(this.status, this.failureCategory);

  const _CodexAuthenticationProbe.authenticated()
    : this._(AgentAuthenticationStatus.authenticated, null);

  const _CodexAuthenticationProbe.unauthenticated()
    : this._(AgentAuthenticationStatus.unauthenticated, null);

  const _CodexAuthenticationProbe.unknown(String category)
    : this._(AgentAuthenticationStatus.unknown, category);

  final AgentAuthenticationStatus status;
  final String? failureCategory;
}

class CodexRuntimeDiagnostics {
  const CodexRuntimeDiagnostics({
    this.executablePath,
    this.workingDirectoryConfigured = false,
    this.environmentKeyPresence = const <String, bool>{},
    this.exceptionType,
    this.osErrorCode,
    this.processExitCode,
    this.timedOut = false,
    this.operation,
    this.path,
    this.osErrorCategory,
    this.appServerSubstage,
    this.processStarted = false,
    this.initializeSent = false,
    this.initializeResponseReceived = false,
    this.initializedNotificationSent = false,
    this.mcpStatusRequestSent = false,
    this.mcpStatusResponseReceived = false,
    this.processExited = false,
    this.cleanupStarted = false,
  });

  factory CodexRuntimeDiagnostics.capture({required String executablePath}) =>
      CodexRuntimeDiagnostics(
        executablePath: executablePath,
        environmentKeyPresence: <String, bool>{
          for (final key in const <String>[
            'SystemRoot',
            'WINDIR',
            'TEMP',
            'TMP',
            'USERPROFILE',
            'LOCALAPPDATA',
            'APPDATA',
            'PATH',
          ])
            key: Platform.environment[key]?.isNotEmpty ?? false,
        },
      );

  final String? executablePath;
  final bool workingDirectoryConfigured;
  final Map<String, bool> environmentKeyPresence;
  final String? exceptionType;
  final int? osErrorCode;
  final int? processExitCode;
  final bool timedOut;
  final String? operation;
  final String? path;
  final String? osErrorCategory;
  final String? appServerSubstage;
  final bool processStarted;
  final bool initializeSent;
  final bool initializeResponseReceived;
  final bool initializedNotificationSent;
  final bool mcpStatusRequestSent;
  final bool mcpStatusResponseReceived;
  final bool processExited;
  final bool cleanupStarted;

  CodexRuntimeDiagnostics withFailure({
    String? exceptionType,
    int? osErrorCode,
    int? processExitCode,
    bool timedOut = false,
    String? operation,
    String? path,
    String? osErrorCategory,
    String? appServerSubstage,
    CodexAppServerTrace? trace,
  }) => CodexRuntimeDiagnostics(
    executablePath: executablePath,
    workingDirectoryConfigured:
        workingDirectoryConfigured || (trace?.processStarted ?? false),
    environmentKeyPresence: environmentKeyPresence,
    exceptionType: exceptionType,
    osErrorCode: osErrorCode,
    processExitCode: processExitCode ?? trace?.processExitCode,
    timedOut: timedOut,
    operation: operation,
    path: path,
    osErrorCategory: osErrorCategory,
    appServerSubstage: appServerSubstage,
    processStarted: trace?.processStarted ?? false,
    initializeSent: trace?.initializeSent ?? false,
    initializeResponseReceived: trace?.initializeResponseReceived ?? false,
    initializedNotificationSent: trace?.initializedNotificationSent ?? false,
    mcpStatusRequestSent: trace?.mcpStatusRequestSent ?? false,
    mcpStatusResponseReceived: trace?.mcpStatusResponseReceived ?? false,
    processExited: trace?.processExited ?? false,
    cleanupStarted: trace?.cleanupStarted ?? false,
  );

  CodexRuntimeDiagnostics withMcpTrace(CodexAppServerTrace trace) =>
      CodexRuntimeDiagnostics(
        executablePath: executablePath,
        workingDirectoryConfigured: true,
        environmentKeyPresence: environmentKeyPresence,
        processExitCode: trace.processExitCode,
        processStarted: trace.processStarted,
        initializeSent: trace.initializeSent,
        initializeResponseReceived: trace.initializeResponseReceived,
        initializedNotificationSent: trace.initializedNotificationSent,
        mcpStatusRequestSent: trace.mcpStatusRequestSent,
        mcpStatusResponseReceived: trace.mcpStatusResponseReceived,
        processExited: trace.processExited,
        cleanupStarted: trace.cleanupStarted,
      );
}

String? _safeDiagnosticPath(String? path) {
  if (path == null) return null;
  final normalized = path.replaceAll('/', '\\');
  if (normalized.toLowerCase().endsWith('\\auth.json')) {
    final separator = normalized.lastIndexOf('\\');
    return '${normalized.substring(0, separator)}\\<redacted-credential-file>';
  }
  return normalized;
}

String? _safeOsErrorCategory(OSError? error) {
  if (error == null) return null;
  if (error.errorCode == 5) return 'access_denied';
  if (error.errorCode == 32) return 'file_in_use';
  if (error.errorCode == 3) return 'path_not_found';
  return 'os_error';
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
    this.authenticationProbeAttempted = false,
    this.detectedCodexVersion,
    this.selectedModelId,
    this.requiredCodexVersion,
    this.diagnostics = const CodexRuntimeDiagnostics(),
  });

  const CodexRuntimeReadiness.notInstalled()
    : isolatedProfileReady = false,
      authentication = AgentAuthenticationStatus.unknown,
      mcpServerCount = null,
      noMcpStartupEvents = true,
      failureCategory = 'not_installed',
      failedProbeStage = 'installation',
      detectedMcpServerNames = const <String>[],
      mcpStartupNotificationCount = 0,
      authenticationProbeAttempted = false,
      detectedCodexVersion = null,
      selectedModelId = null,
      requiredCodexVersion = null,
      diagnostics = const CodexRuntimeDiagnostics();

  const CodexRuntimeReadiness.profileFailure(String this.failureCategory)
    : isolatedProfileReady = false,
      authentication = AgentAuthenticationStatus.unknown,
      mcpServerCount = null,
      noMcpStartupEvents = false,
      failedProbeStage = 'runtime_probe',
      detectedMcpServerNames = const <String>[],
      mcpStartupNotificationCount = 0,
      authenticationProbeAttempted = false,
      detectedCodexVersion = null,
      selectedModelId = null,
      requiredCodexVersion = null,
      diagnostics = const CodexRuntimeDiagnostics();

  factory CodexRuntimeReadiness.runtimeFailure({
    required String stage,
    required String category,
    required CodexRuntimeDiagnostics diagnostics,
    bool isolatedProfileReady = false,
    AgentAuthenticationStatus authentication =
        AgentAuthenticationStatus.unknown,
    bool authenticationProbeAttempted = false,
  }) => CodexRuntimeReadiness(
    isolatedProfileReady: isolatedProfileReady,
    authentication: authentication,
    mcpServerCount: null,
    noMcpStartupEvents: true,
    failureCategory: category,
    failedProbeStage: stage,
    authenticationProbeAttempted: authenticationProbeAttempted,
    diagnostics: diagnostics,
  );

  final bool isolatedProfileReady;
  final AgentAuthenticationStatus authentication;
  final int? mcpServerCount;
  final bool noMcpStartupEvents;
  final String? failureCategory;
  final String? failedProbeStage;
  final List<String> detectedMcpServerNames;
  final int mcpStartupNotificationCount;
  final bool authenticationProbeAttempted;
  final String? detectedCodexVersion;
  final String? selectedModelId;
  final String? requiredCodexVersion;
  final CodexRuntimeDiagnostics diagnostics;

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

class CodexAppServerTrace {
  bool processStarted = false;
  bool initializeSent = false;
  bool initializeResponseReceived = false;
  bool initializedNotificationSent = false;
  bool mcpStatusRequestSent = false;
  bool mcpStatusResponseReceived = false;
  bool processExited = false;
  int? processExitCode;
  bool cleanupStarted = false;
  String? failedRequestMethod;
  int? protocolErrorCode;
  String? protocolErrorMessage;
  String? selectedModel;
  String? turnFailureMessage;
  String? codexErrorInfoType;
  int? turnFailureHttpStatus;
  String? additionalDetailsCategory;
  String? turnFailureStage;
  final List<String> eventTypes = <String>[];
  final List<String> serverRequestMethods = <String>[];
  final List<CodexAppServerStderrMetadata> stderrMetadata =
      <CodexAppServerStderrMetadata>[];

  void recordEventType(String eventType) {
    if (eventTypes.length < 64) eventTypes.add(eventType);
  }

  void recordServerRequestMethod(String method) {
    if (!serverRequestMethods.contains(method) &&
        serverRequestMethods.length < 16) {
      serverRequestMethods.add(method);
    }
  }

  void recordStderr(CodexAppServerStderrMetadata metadata) {
    if (stderrMetadata.length < 8) stderrMetadata.add(metadata);
  }
}

class _CodexAppServer implements CodexMcpProbeSession {
  _CodexAppServer(this._process, this._cwd, this.trace, this._modelSelection);
  final Process _process;
  final String _cwd;
  @override
  final CodexAppServerTrace trace;
  final CodexModelSelection _modelSelection;
  final Map<int, _PendingCodexRequest> _requests =
      <int, _PendingCodexRequest>{};
  final Completer<AgentRunResult> _completed = Completer<AgentRunResult>();
  late final StreamSubscription<String> _stdout;
  late final StreamSubscription<String> _stderr;
  int _nextId = 0;
  String? _threadId;
  String? _turnId;
  String? _model;
  bool _turnStarted = false;
  bool _turnCompletedReceived = false;
  String? _completionState;
  String? _finalModelResponse;
  bool _arbitraryShellUsed = false;
  bool _directApiObserved = false;
  final Map<String, String> _rawSecretCategories = <String, String>{};
  final List<AgentToolCallResult> _toolResults = <AgentToolCallResult>[];
  CodexDynamicToolHandler? _toolHandler;
  String _stderrText = '';
  Future<AgentRunResult> get completed => _completed.future;
  String? get turnId => _turnId;
  String? get threadId => _threadId;
  bool get turnStarted => _turnStarted;
  bool get turnCompletedReceived => _turnCompletedReceived;
  String? get completionState => _completionState;
  String? get finalModelResponse => _finalModelResponse;
  bool get arbitraryShellUsed => _arbitraryShellUsed;
  bool get directApiObserved => _directApiObserved;
  Map<String, String> get rawSecretCategories =>
      Map<String, String>.unmodifiable(_rawSecretCategories);

  static Future<_CodexAppServer> start(
    String executable,
    String cwd,
    Map<String, String> environment, {
    CodexModelSelection modelSelection = CodexModelSelection.gpt56Luna,
  }) async {
    final trace = CodexAppServerTrace();
    final process = await Process.start(
      executable,
      const <String>['app-server', '--stdio'],
      workingDirectory: cwd,
      includeParentEnvironment: false,
      runInShell: false,
      environment: environment,
    );
    trace.processStarted = true;
    final server = _CodexAppServer(process, cwd, trace, modelSelection);
    server._stdout = process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(server._onLine);
    server._stderr = process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
          server._auditRuntimeText(line, 'app_server_stderr');
          final metadata = CodexAppServerProtocol.stderrMetadata(line);
          if (metadata != null) server.trace.recordStderr(metadata);
          final text = SecretMasker.redactText('${server._stderrText}\n$line');
          server._stderrText = text.length <= 2048
              ? text
              : text.substring(0, 2048);
        });
    process.exitCode.then((exitCode) {
      trace.processExited = true;
      trace.processExitCode = exitCode;
      for (final request in server._requests.values) {
        if (!request.completer.isCompleted) {
          request.completer.completeError(
            const CodexMcpProbeFailure('app_server_exited'),
          );
        }
      }
      server._requests.clear();
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

  @override
  Future<void> initialize() async {
    trace.initializeSent = true;
    await _request('initialize', <String, Object?>{
      'clientInfo': <String, Object?>{
        'name': 'devroute',
        'title': 'DevRoute AI Agents',
        'version': '0.4.0',
      },
      'capabilities': <String, Object?>{'experimentalApi': true},
    });
    trace.initializeResponseReceived = true;
    _notify('initialized', const <String, Object?>{});
    trace.initializedNotificationSent = true;
    final models = await _request('model/list', const <String, Object?>{
      'limit': 20,
      'includeHidden': false,
    });
    _model = CodexAppServerProtocol.selectAvailableModel(
      models['data'],
      _modelSelection.id,
    );
    if (_model == null) {
      throw const _CodexFailure('CODEX_SELECTED_MODEL_UNAVAILABLE');
    }
    trace.selectedModel = _model;
  }

  final List<String> _detectedMcpServerNames = <String>[];
  int _mcpStartupNotificationCount = 0;
  @override
  bool get noMcpStartupEvents => _mcpStartupNotificationCount == 0;
  @override
  List<String> get detectedMcpServerNames =>
      List<String>.unmodifiable(_detectedMcpServerNames);
  @override
  int get mcpStartupNotificationCount => _mcpStartupNotificationCount;

  @override
  Future<int> mcpServerCount() async {
    trace.mcpStatusRequestSent = true;
    final response = await _request('mcpServerStatus/list', <String, Object?>{
      'limit': 100,
      'detail': 'toolsAndAuthOnly',
    });
    trace.mcpStatusResponseReceived = true;
    final data = response['data'];
    if (data is! List) {
      throw const CodexMcpProbeFailure('mcp_response_invalid');
    }
    for (final item in data.whereType<Map>()) {
      final name = item['name']?.toString();
      if (name != null &&
          name.isNotEmpty &&
          !_detectedMcpServerNames.contains(name)) {
        _detectedMcpServerNames.add(name);
      }
    }
    return data.length;
  }

  Future<String> startRestrictedThread() async {
    final response = await _request('thread/start', <String, Object?>{
      ...CodexAppServerProtocol.restrictedThreadStartParams(
        cwd: _cwd,
        model: _model!,
      ),
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
    return _threadId = CodexAppServerProtocol.parseThreadId(response);
  }

  Future<void> startTurn(
    String threadId,
    String prompt,
    CodexDynamicToolHandler toolHandler,
  ) async {
    _toolHandler = toolHandler;
    final response = await _request(
      'turn/start',
      CodexAppServerProtocol.turnStartParams(
        threadId: threadId,
        prompt: prompt,
      ),
    );
    _turnId = CodexAppServerProtocol.parseTurnId(response);
  }

  void _onLine(String line) {
    _auditRuntimeText(line, 'app_server_stdout');
    Object? decoded;
    try {
      decoded = jsonDecode(line);
    } catch (_) {
      for (final request in _requests.values) {
        if (!request.completer.isCompleted) {
          request.completer.completeError(
            const CodexMcpProbeFailure('protocol_parse_failed'),
          );
        }
      }
      _requests.clear();
      return;
    }
    if (decoded is! Map) return;
    final message = decoded.cast<String, Object?>();
    final id = message['id'];
    if (id is int && _requests.containsKey(id)) {
      final pending = _requests.remove(id)!;
      final completer = pending.completer;
      if (message['error'] != null) {
        final error = message['error'];
        final errorMap = error is Map ? error : const <String, Object?>{};
        final code = errorMap['code'] is int ? errorMap['code'] as int : null;
        final rawMessage = errorMap['message']?.toString() ?? '';
        final safeMessage = SecretMasker.redactText(rawMessage);
        trace.failedRequestMethod = pending.method;
        trace.protocolErrorCode = code;
        trace.protocolErrorMessage = safeMessage.length <= 256
            ? safeMessage
            : '${safeMessage.substring(0, 256)}...';
        completer.completeError(
          CodexMcpProbeFailure(
            CodexAppServerProtocol.protocolErrorCategory(pending.method),
            code: code,
            safeMessage: trace.protocolErrorMessage,
          ),
        );
      } else {
        final result = message['result'];
        if (result is! Map) {
          completer.completeError(
            const CodexMcpProbeFailure('protocol_response_invalid'),
          );
        } else {
          completer.complete(result.cast<String, Object?>());
        }
      }
      return;
    }
    final method = message['method']?.toString();
    if (method != null) {
      trace.recordEventType(CodexAppServerProtocol.eventType(message));
      if (id is int) trace.recordServerRequestMethod(method);
    }
    if (message['method'] == 'item/tool/call') {
      unawaited(_handleToolCall(message));
      return;
    }
    if (CodexAppServerProtocol.isTurnStarted(message)) {
      _turnStarted = true;
      return;
    }
    if (message['method'] == 'item/started' ||
        message['method'] == 'item/completed') {
      final params = message['params'] as Map?;
      final item = params?['item'] as Map?;
      if (item?['type'] == 'commandExecution') _arbitraryShellUsed = true;
      if (message['method'] == 'item/completed' &&
          item?['type'] == 'agentMessage' &&
          item?['text'] is String) {
        final safe = SecretMasker.redactText(item!['text'] as String);
        _finalModelResponse = safe.length <= 1024
            ? safe
            : '${safe.substring(0, 1024)}...';
      }
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
      final status = CodexAppServerProtocol.turnCompletedStatus(message);
      _turnCompletedReceived = true;
      _completionState = status;
      final failure = CodexAppServerProtocol.turnCompletedFailure(message);
      if (failure != null) {
        trace.turnFailureMessage = failure.message;
        trace.codexErrorInfoType = failure.codexErrorInfoType;
        trace.turnFailureHttpStatus = failure.httpStatusCode;
        trace.additionalDetailsCategory = failure.additionalDetailsCategory;
        trace.turnFailureStage = CodexAppServerProtocol.failureStage(
          trace.eventTypes,
          trace.serverRequestMethods,
        );
      }
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
      final dispatch = await _toolHandler!(
        params['callId']?.toString() ?? id.toString(),
        params['tool']?.toString() ?? '',
        params['arguments'],
      );
      _toolResults.add(
        AgentToolCallResult(
          toolName: dispatch.internalToolName,
          success: true,
          output: dispatch.output,
        ),
      );
      _respond(id, <String, Object?>{
        'success': true,
        'contentItems': <Object?>[
          <String, Object?>{
            'type': 'inputText',
            'text': jsonEncode(dispatch.output),
          },
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

  void _auditRuntimeText(String text, String channel) {
    const categories = <String>[
      'Authorization',
      'Bearer',
      'Cookie',
      'OPENAI_API_KEY',
      'CODEX_API_KEY',
      'CODEX_ACCESS_TOKEN',
      'access_token',
      'refresh_token',
      'device_secret',
      'client_secret',
    ];
    for (final category in categories) {
      if (text.contains(category)) _rawSecretCategories[category] = channel;
    }
    if (text.contains('api.openai.com') ||
        text.contains('/v1/responses') ||
        text.contains('/v1/chat/completions')) {
      _directApiObserved = true;
    }
  }

  Future<Map<String, Object?>> _request(
    String method,
    Map<String, Object?> params,
  ) {
    final id = ++_nextId;
    final completer = Completer<Map<String, Object?>>();
    _requests[id] = _PendingCodexRequest(method, completer);
    _send(<String, Object?>{'method': method, 'id': id, 'params': params});
    return completer.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        _requests.remove(id);
        trace.failedRequestMethod = method;
        throw CodexMcpProbeFailure(
          CodexAppServerProtocol.timeoutCategory(method),
        );
      },
    );
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

  @override
  Future<void> close() async {
    trace.cleanupStarted = true;
    await interrupt();
    await _process.stdin.close();
    if (!trace.processExited) _process.kill();
    await _process.exitCode.timeout(const Duration(seconds: 5));
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

class _PendingCodexRequest {
  const _PendingCodexRequest(this.method, this.completer);

  final String method;
  final Completer<Map<String, Object?>> completer;
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
