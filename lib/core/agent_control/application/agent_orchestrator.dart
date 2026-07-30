import 'dart:async';
import 'dart:convert';

import '../../security/secret_masker.dart';
import '../data/approval_grant_store.dart';
import '../data/subscription_agent_catalog.dart';
import '../domain/agent_models.dart';
import 'agent_permission_engine.dart';
import 'agent_tool_registry.dart';
import 'app_command.dart';

class AgentOrchestrator {
  AgentOrchestrator(this._registry, this._permissions, this._audit,
      {SubscriptionAgentCatalog? catalog,
      InMemoryApprovalGrantStore? approvals,
      DateTime Function()? clock})
      : _catalog = catalog ?? SubscriptionAgentCatalog.official,
        _approvals = approvals ?? InMemoryApprovalGrantStore(),
        _clock = clock ?? DateTime.now;

  final AgentToolRegistry _registry;
  final AgentPermissionEngine _permissions;
  final AgentAuditSink _audit;
  final SubscriptionAgentCatalog _catalog;
  final InMemoryApprovalGrantStore _approvals;
  final DateTime Function() _clock;

  AgentOrchestratorRunHandle startRun({
    required String providerId,
    required AgentRunRequest request,
    required AgentPermissionMode mode,
    required bool production,
    int maximumSteps = 8,
    int maximumNetworkOperations = 8,
    Duration maximumRunDuration = const Duration(seconds: 30),
  }) {
    final control = _RunControl();
    final handle = _OwnedRun(request.runId, control.cancel);
    unawaited(_drive(handle, control, providerId, request, mode, production,
        maximumSteps, maximumNetworkOperations, maximumRunDuration));
    return handle;
  }

  Future<void> _drive(
      _OwnedRun handle,
      _RunControl control,
      String providerId,
      AgentRunRequest request,
      AgentPermissionMode mode,
      bool production,
      int maximumSteps,
      int maximumNetworkOperations,
      Duration maximumRunDuration) async {
    handle.emit(AgentRunLifecycle.created);
    handle.emit(AgentRunLifecycle.running);
    final result = await _run(
      providerId: providerId,
      request: request,
      mode: mode,
      production: production,
      maximumSteps: maximumSteps,
      maximumNetworkOperations: maximumNetworkOperations,
      maximumDuration: maximumRunDuration,
      control: control,
      detailedAudit: true,
    );
    handle.complete(result, _lifecycleFor(result));
  }

  Future<AgentRunResult> run({
    required String providerId,
    required AgentRunRequest request,
    required AgentPermissionMode mode,
    required bool production,
    int maximumSteps = 8,
    int maximumNetworkOperations = 8,
    Duration maximumDuration = const Duration(seconds: 30),
  }) => _run(
      providerId: providerId,
      request: request,
      mode: mode,
      production: production,
      maximumSteps: maximumSteps,
      maximumNetworkOperations: maximumNetworkOperations,
      maximumDuration: maximumDuration,
      control: _RunControl(),
      detailedAudit: false);

  Future<AgentRunResult> _run({
    required String providerId,
    required AgentRunRequest request,
    required AgentPermissionMode mode,
    required bool production,
    required int maximumSteps,
    required int maximumNetworkOperations,
    required Duration maximumDuration,
    required _RunControl control,
    required bool detailedAudit,
  }) async {
    final audit = _RunAudit(this, request, providerId, detailedAudit);
    await audit.run('received');
    await audit.run('started');
    final provider = _providerFailure(providerId);
    if (provider != null) {
      await audit.run('provider_denied', failure: provider);
      await audit.run('failed', failure: provider);
      return _failed(const <AgentToolCallResult>[], provider);
    }
    if (request.calls.length > maximumSteps) {
      await audit.run('failed', failure: 'maximum_steps');
      return _failed(const <AgentToolCallResult>[], 'maximum_steps');
    }
    try {
      return await _executeAll(request, providerId, mode, production,
              maximumNetworkOperations, control, audit)
          .timeout(maximumDuration, onTimeout: () {
        control.cancel();
        return _timedOut(audit);
      });
    } on _RunCancelled {
      await audit.run('cancelling');
      await audit.run('cancelled');
      return const AgentRunResult(
          status: AgentRunStatus.cancelled, results: <AgentToolCallResult>[]);
    } catch (_) {
      const category = 'tool_failure';
      await audit.run('failed', failure: category);
      return _failed(const <AgentToolCallResult>[], category);
    }
  }

  Future<AgentRunResult> _timedOut(_RunAudit audit) async {
    await audit.run('timed_out', failure: 'maximum_run_duration');
    return const AgentRunResult(
        status: AgentRunStatus.timedOut,
        results: <AgentToolCallResult>[],
        failureCategory: 'maximum_run_duration');
  }

  Future<AgentRunResult> _executeAll(
      AgentRunRequest request,
      String provider,
      AgentPermissionMode mode,
      bool production,
      int maximumNetworkOperations,
      _RunControl control,
      _RunAudit audit) async {
    final results = <AgentToolCallResult>[];
    var networkOperations = 0;
    for (final call in request.calls) {
      if (control.cancelled) throw const _RunCancelled();
      final tool = _tool(call.toolName);
      if (tool != null && tool.risk == AgentRisk.networkExecuting &&
          networkOperations >= maximumNetworkOperations) {
        final failure = _failure(call.toolName, 'maximum_network_operations');
        results.add(failure);
        await audit.run('failed', failure: failure.failureCategory);
        return _failed(results, failure.failureCategory!);
      }
      if (tool != null && tool.risk == AgentRisk.networkExecuting) {
        networkOperations++;
      }
      final result = await _execute(provider, request.runId, call, mode,
          production, control, audit);
      results.add(result);
      if (!result.success) {
        await audit.run('failed', failure: result.failureCategory);
        return _failed(results, result.failureCategory!);
      }
    }
    await audit.run('completed');
    return AgentRunResult(status: AgentRunStatus.completed, results: results);
  }

  AgentToolDefinition? _tool(String name) {
    try { return _registry.require(name); } catch (_) { return null; }
  }

  String? _providerFailure(String id) {
    try {
      final record = _catalog.require(id);
      if (!record.executableAllowed) {
        return record.supportStatus == AgentProviderSupportStatus.verificationRequired
            ? 'provider_verification_required' : 'provider_contract_only';
      }
      return null;
    } catch (_) { return 'unknown_provider'; }
  }

  Future<AgentToolCallResult> _execute(
      String provider, String runId, AgentToolCallRequest call,
      AgentPermissionMode mode, bool production, _RunControl control,
      _RunAudit audit) async {
    final tool = _tool(call.toolName);
    await audit.tool(call, 'received');
    if (tool == null) return _toolFailure(audit, call, 'unknown_tool');
    if (!tool.accepts(call.input)) return _toolFailure(audit, call, 'maximum_input_bytes');
    final decision = _permissions.evaluate(mode: mode, tool: tool, production: production);
    if (!decision.allowed) {
      final grant = call.approval;
      if (!decision.requiresApproval || grant == null) {
        return _toolFailure(audit, call, decision.requiresApproval ? 'approval_required' : (decision.category ?? 'unauthorized'), phase: decision.requiresApproval ? 'approval_required' : 'denied');
      }
      final use = _approvals.consume(approvalId: grant.approvalId, runId: runId,
          toolName: tool.name, toolVersion: tool.version, workspaceId: call.workspaceId,
          environmentId: call.environmentId, risk: tool.risk, now: _clock());
      if (!use.allowed) return _toolFailure(audit, call, use.rejection!.name, phase: 'denied');
    }
    if (tool.availability == AgentToolAvailability.unavailableInFoundation) {
      return _toolFailure(audit, call, 'execution_unavailable_in_foundation');
    }
    await audit.tool(call, 'started');
    try {
      final execution = tool.execute(call.input).timeout(tool.timeout);
      execution.ignore();
      final output = await Future.any<Map<String, Object?>>(<Future<Map<String, Object?>>>[
        execution,
        control.token.cancelled.then<Map<String, Object?>>((_) => throw const _RunCancelled()),
      ]);
      if (control.cancelled) throw const _RunCancelled();
      if (utf8.encode(jsonEncode(output)).length > tool.maximumOutputBytes) {
        return _toolFailure(audit, call, 'maximum_output_bytes');
      }
      final safeOutput = <String, Object?>{'summary': _safe(output.toString())};
      await audit.tool(call, 'completed', output: safeOutput['summary'] as String);
      return AgentToolCallResult(toolName: tool.name, success: true, output: safeOutput);
    } on _RunCancelled { rethrow; }
    catch (_) { return _toolFailure(audit, call, 'tool_failure'); }
  }

  Future<AgentToolCallResult> _toolFailure(_RunAudit audit,
      AgentToolCallRequest call, String category, {String phase = 'failed'}) async {
    await audit.tool(call, phase, failure: category);
    return _failure(call.toolName, category);
  }

  AgentRunResult _failed(List<AgentToolCallResult> results, String category) =>
      AgentRunResult(status: AgentRunStatus.failed, results: results, failureCategory: category);
  AgentToolCallResult _failure(String tool, String category) => AgentToolCallResult(
      toolName: tool, success: false, output: const <String, Object?>{}, failureCategory: category);
  String _safe(String value) => SecretMasker.redactText(value);
  AgentRunLifecycle _lifecycleFor(AgentRunResult result) => switch (result.status) {
    AgentRunStatus.completed => AgentRunLifecycle.completed,
    AgentRunStatus.cancelled => AgentRunLifecycle.cancelled,
    AgentRunStatus.timedOut => AgentRunLifecycle.timedOut,
    _ => AgentRunLifecycle.failed,
  };
}

class _RunControl {
  final CancellationToken token = CancellationToken();
  bool get cancelled => token.isCancelled;
  void cancel() => token.cancel();
}
class _RunCancelled implements Exception { const _RunCancelled(); }

class _RunAudit {
  _RunAudit(this.owner, this.request, this.provider, this.detailed);
  final AgentOrchestrator owner; final AgentRunRequest request; final String provider; final bool detailed;
  var _sequence = 0;
  Future<void> run(String phase, {String? failure}) => detailed ? _record(phase: 'run.$phase', tool: '', input: '', failure: failure) : Future<void>.value();
  Future<void> tool(AgentToolCallRequest call, String phase, {String? output, String? failure}) {
    if (!detailed && phase != 'started' && phase != 'completed') return Future<void>.value();
    return _record(phase: detailed ? 'tool.$phase' : phase, tool: call.toolName, input: owner._safe(call.input.toString()), output: output, failure: failure, workspace: call.workspaceId, environment: call.environmentId);
  }
  Future<void> _record({required String phase, required String tool, required String input, String? output, String? failure, String? workspace, String? environment}) => owner._audit.record(AgentAuditEntry(
    eventId: '${request.runId}:${_sequence++}', runId: request.runId, timestamp: owner._clock(), providerId: provider, toolName: tool, workspaceId: workspace ?? request.workspaceId, environmentId: environment, decision: failure == null ? 'allowed' : 'rejected', phase: phase, inputSummary: input, outputSummary: output == null ? null : owner._safe(output), failureCategory: failure));
}

abstract interface class AgentOrchestratorRunHandle implements AgentRunHandle { Stream<AgentRunLifecycle> get lifecycle; }
class _OwnedRun implements AgentOrchestratorRunHandle {
  _OwnedRun(this.runId, this._onCancel);
  @override final String runId; final void Function() _onCancel;
  final _events = StreamController<AgentRunEvent>.broadcast();
  final _lifecycle = StreamController<AgentRunLifecycle>.broadcast();
  final _eventHistory = <AgentRunEvent>[];
  final _lifecycleHistory = <AgentRunLifecycle>[];
  final _result = Completer<AgentRunResult>(); bool _cancelled = false;
  @override
  Stream<AgentRunEvent> get events async* {
    yield* Stream<AgentRunEvent>.fromIterable(List<AgentRunEvent>.of(_eventHistory));
    yield* _events.stream;
  }
  @override
  Stream<AgentRunLifecycle> get lifecycle async* {
    yield* Stream<AgentRunLifecycle>.fromIterable(List<AgentRunLifecycle>.of(_lifecycleHistory));
    yield* _lifecycle.stream;
  }
  @override Future<AgentRunResult> get result => _result.future;
  void emit(AgentRunLifecycle phase) { if (!_result.isCompleted) { final event = AgentRunEvent(phase.name); _eventHistory.add(event); _lifecycleHistory.add(phase); _events.add(event); _lifecycle.add(phase); } }
  void complete(AgentRunResult value, AgentRunLifecycle phase) { if (_result.isCompleted) return; emit(phase); _result.complete(value); unawaited(_events.close()); unawaited(_lifecycle.close()); }
  @override Future<void> cancel() async { if (_cancelled || _result.isCompleted) return; _cancelled = true; emit(AgentRunLifecycle.cancelling); _onCancel(); }
}
