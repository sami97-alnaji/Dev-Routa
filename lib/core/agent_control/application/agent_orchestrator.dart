// ignore_for_file: curly_braces_in_flow_control_structures

import '../../security/secret_masker.dart';
import '../domain/agent_models.dart';
import 'agent_permission_engine.dart';
import 'agent_tool_registry.dart';

class AgentOrchestrator {
  AgentOrchestrator(this._registry, this._permissions, this._audit);
  final AgentToolRegistry _registry;
  final AgentPermissionEngine _permissions;
  final AgentAuditSink _audit;
  Future<AgentRunResult> run({
    required String providerId,
    required AgentRunRequest request,
    required AgentPermissionMode mode,
    required bool production,
    int maximumSteps = 8,
    Duration maximumDuration = const Duration(seconds: 30),
  }) async {
    if (request.calls.length > maximumSteps)
      return const AgentRunResult(
        status: AgentRunStatus.failed,
        results: <AgentToolCallResult>[],
        failureCategory: 'maximum_steps',
      );
    final results = <AgentToolCallResult>[];
    try {
      for (final call in request.calls) {
        final result =
            await _execute(
              providerId,
              request.runId,
              call,
              mode,
              production,
            ).timeout(
              maximumDuration,
              onTimeout: () => throw StateError('maximum_duration'),
            );
        results.add(result);
      }
      return AgentRunResult(status: AgentRunStatus.completed, results: results);
    } catch (error) {
      return AgentRunResult(
        status: AgentRunStatus.failed,
        results: results,
        failureCategory: _safe(error.toString()),
      );
    }
  }

  Future<AgentToolCallResult> _execute(
    String provider,
    String runId,
    AgentToolCallRequest call,
    AgentPermissionMode mode,
    bool production,
  ) async {
    AgentToolDefinition tool;
    try {
      tool = _registry.require(call.toolName);
    } catch (_) {
      return _failure(call.toolName, 'unknown_tool');
    }
    if (!tool.validator(call.input))
      return _failure(call.toolName, 'invalid_input');
    final decision = _permissions.evaluate(
      mode: mode,
      tool: tool,
      production: production,
    );
    if (!decision.allowed &&
        !(decision.requiresApproval &&
            _permissions.consume(call.approval, call, tool, DateTime.now())))
      return _failure(call.toolName, decision.category ?? 'unauthorized');
    await _audit.record(
      AgentAuditEntry(
        eventId: '$runId:${tool.name}:before',
        runId: runId,
        timestamp: DateTime.now(),
        providerId: provider,
        toolName: tool.name,
        workspaceId: call.workspaceId,
        environmentId: call.environmentId,
        decision: 'allowed',
        phase: 'started',
        inputSummary: _safe(call.input.toString()),
      ),
    );
    try {
      final output = await tool.execute(call.input).timeout(tool.timeout);
      final safeOutput = <String, Object?>{'summary': _safe(output.toString())};
      await _audit.record(
        AgentAuditEntry(
          eventId: '$runId:${tool.name}:after',
          runId: runId,
          timestamp: DateTime.now(),
          providerId: provider,
          toolName: tool.name,
          workspaceId: call.workspaceId,
          environmentId: call.environmentId,
          decision: 'allowed',
          phase: 'completed',
          inputSummary: _safe(call.input.toString()),
          outputSummary: safeOutput['summary'] as String,
        ),
      );
      return AgentToolCallResult(
        toolName: tool.name,
        success: true,
        output: safeOutput,
      );
    } catch (_) {
      return _failure(tool.name, 'tool_failure');
    }
  }

  AgentToolCallResult _failure(String tool, String category) =>
      AgentToolCallResult(
        toolName: tool,
        success: false,
        output: <String, Object?>{},
        failureCategory: category,
      );
  String _safe(String value) => SecretMasker.redactText(value);
}
