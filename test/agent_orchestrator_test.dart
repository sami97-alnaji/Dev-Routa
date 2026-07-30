import 'dart:async';

import 'package:devroute_ai_studio/core/agent_control/application/agent_orchestrator.dart';
import 'package:devroute_ai_studio/core/agent_control/application/agent_permission_engine.dart';
import 'package:devroute_ai_studio/core/agent_control/application/agent_tool_registry.dart';
import 'package:devroute_ai_studio/core/agent_control/data/approval_grant_store.dart';
import 'package:devroute_ai_studio/core/agent_control/domain/agent_models.dart';
import 'package:flutter_test/flutter_test.dart';

AgentToolDefinition tool(String name, Future<Map<String, Object?>> Function(Map<String, Object?>) execute,
    {AgentRisk risk = AgentRisk.readOnly, bool approval = false, int input = 64, int output = 64, String version = '1'}) =>
    AgentToolDefinition(name: name, version: version, description: name, risk: risk,
      permission: risk == AgentRisk.readOnly ? AgentPermissionMode.observe : AgentPermissionMode.approvedOperator,
      requiresApproval: approval, timeout: const Duration(seconds: 5), cancellable: true,
      idempotency: AgentIdempotency.idempotent, validator: (_) => true, execute: execute,
      maximumInputBytes: input, maximumOutputBytes: output, allowedInputFields: const {'value'},
      rejectUnknownFields: false, availability: AgentToolAvailability.available);

AgentRunRequest request(String id, List<AgentToolCallRequest> calls) => AgentRunRequest(runId: id, workspaceId: 'w', calls: calls);
AgentToolCallRequest call(String name, {Map<String, Object?> input = const {}, ApprovalGrant? approval, String? environment, String workspace = 'w'}) =>
    AgentToolCallRequest(toolName: name, input: input, workspaceId: workspace, environmentId: environment, approval: approval);
ApprovalGrant grant(String id, String run, String tool, {String? environment, String workspace = 'w', String version = '1', AgentRisk risk = AgentRisk.networkExecuting, DateTime? expires}) => ApprovalGrant(
  approvalId: id, runId: run, toolName: tool, toolVersion: version, workspaceId: workspace, environmentId: environment,
  risk: risk, safeInputSummary: 'safe', estimatedRequestCount: 1, expiresAt: expires ?? DateTime(2030));

AgentOrchestrator subject(AgentToolRegistry registry, InMemoryAgentAuditSink audit, {InMemoryApprovalGrantStore? grants}) =>
    AgentOrchestrator(registry, AgentPermissionEngine(), audit, approvals: grants);

List<String> phases(InMemoryAgentAuditSink audit) => audit.entries.map((e) => e.phase).toList();

void main() {
  test('success follows the run and tool audit order', () async {
    final registry = AgentToolRegistry()..register(tool('read', (_) async => {'ok': true}));
    final audit = InMemoryAgentAuditSink();
    final result = await subject(registry, audit).startRun(providerId: 'fakeTestAgent', request: request('success', [call('read')]), mode: AgentPermissionMode.observe, production: false).result;
    expect(result.status, AgentRunStatus.completed);
    expect(phases(audit), ['run.received', 'run.started', 'tool.received', 'tool.started', 'tool.completed', 'run.completed']);
  });

  test('whole-run timeout is terminal and ignores a late success', () async {
    final gate = Completer<Map<String, Object?>>();
    final registry = AgentToolRegistry()..register(tool('first', (_) async => {'ok': true}))..register(tool('blocked', (_) => gate.future));
    final audit = InMemoryAgentAuditSink();
    final handle = subject(registry, audit).startRun(providerId: 'fakeTestAgent', request: request('timeout', [call('first'), call('blocked')]), mode: AgentPermissionMode.observe, production: false, maximumRunDuration: const Duration(milliseconds: 10));
    final lifecycle = handle.lifecycle.toList();
    final result = await handle.result.timeout(const Duration(seconds: 1));
    gate.complete({'late': true});
    await Future<void>(() {});
    expect(result.status, AgentRunStatus.timedOut);
    expect(await lifecycle, contains(AgentRunLifecycle.timedOut));
    expect(phases(audit).where((p) => p == 'run.completed'), isEmpty);
    expect(phases(audit).where((p) => p == 'run.timed_out'), hasLength(1));
  });

  test('cancellation while blocked is idempotent and late failures are ignored', () async {
    final gate = Completer<Map<String, Object?>>();
    gate.future.ignore();
    final registry = AgentToolRegistry()..register(tool('blocked', (_) => gate.future));
    final audit = InMemoryAgentAuditSink();
    final handle = subject(registry, audit).startRun(providerId: 'fakeTestAgent', request: request('cancel', [call('blocked')]), mode: AgentPermissionMode.observe, production: false);
    final lifecycle = handle.lifecycle.toList();
    await Future<void>(() {});
    await handle.cancel(); await handle.cancel();
    final result = await handle.result.timeout(const Duration(seconds: 1));
    final uncaught = <Object>[];
    await runZonedGuarded(() async {
      gate.completeError(StateError('late'));
      await Future<void>.microtask(() {});
    }, (error, _) => uncaught.add(error));
    expect(result.status, AgentRunStatus.cancelled);
    expect(await lifecycle, [AgentRunLifecycle.created, AgentRunLifecycle.running, AgentRunLifecycle.cancelling, AgentRunLifecycle.cancelled]);
    expect(phases(audit).where((p) => p == 'run.cancelled'), hasLength(1));
    expect(uncaught, isEmpty);
  });

  test('maximum steps fails before any executor runs', () async {
    var calls = 0; final registry = AgentToolRegistry()..register(tool('read', (_) async { calls++; return {}; }));
    final result = await subject(registry, InMemoryAgentAuditSink()).run(providerId: 'fakeTestAgent', request: request('steps', [call('read'), call('read')]), mode: AgentPermissionMode.observe, production: false, maximumSteps: 1);
    expect(result.failureCategory, 'maximum_steps'); expect(calls, 0);
  });

  test('maximum network operations blocks excess call before execution', () async {
    var calls = 0; final store = InMemoryApprovalGrantStore();
    final registry = AgentToolRegistry()..register(tool('net', (_) async { calls++; return {}; }, risk: AgentRisk.networkExecuting, approval: true));
    store..add(grant('one', 'net-run', 'net'))..add(grant('two', 'net-run', 'net'));
    final result = await subject(registry, InMemoryAgentAuditSink(), grants: store).run(providerId: 'fakeTestAgent', request: request('net-run', [call('net', approval: grant('one', 'net-run', 'net')), call('net', approval: grant('two', 'net-run', 'net'))]), mode: AgentPermissionMode.approvedOperator, production: false, maximumNetworkOperations: 1);
    expect(result.failureCategory, 'maximum_network_operations'); expect(calls, 1);
  });

  test('input and output byte limits use fail-fast sanitized results', () async {
    var inputs = 0; final registry = AgentToolRegistry()
      ..register(tool('input', (_) async { inputs++; return {}; }, input: 4))
      ..register(tool('output', (_) async => {'value': '123456789'}, output: 4));
    final orchestrator = subject(registry, InMemoryAgentAuditSink());
    final tooBigInput = await orchestrator.run(providerId: 'fakeTestAgent', request: request('in', [call('input', input: {'value': 'é'})]), mode: AgentPermissionMode.observe, production: false);
    final tooBigOutput = await orchestrator.run(providerId: 'fakeTestAgent', request: request('out', [call('output')]), mode: AgentPermissionMode.observe, production: false);
    expect(tooBigInput.failureCategory, 'maximum_input_bytes'); expect(inputs, 0);
    expect(tooBigOutput.failureCategory, 'maximum_output_bytes'); expect(tooBigOutput.results.single.output, isEmpty);
  });

  test('approval integration consumes grants only through exact request scope', () async {
    Future<AgentRunResult> execute(ApprovalGrant? approval, {String run = 'run', String toolName = 'net', String workspace = 'w', String? environment, bool production = false, String version = '1'}) async {
      final registry = AgentToolRegistry()..register(tool(toolName, (_) async => {'ok': true}, risk: AgentRisk.networkExecuting, approval: true, version: version));
      final store = InMemoryApprovalGrantStore(); if (approval != null) store.add(approval);
      return subject(registry, InMemoryAgentAuditSink(), grants: store).run(providerId: 'fakeTestAgent', request: request(run, [call(toolName, approval: approval, workspace: workspace, environment: environment)]), mode: AgentPermissionMode.approvedOperator, production: production);
    }
    final valid = grant('valid', 'valid-run', 'net');
    final reuseStore = InMemoryApprovalGrantStore()..add(valid);
    final reuseRegistry = AgentToolRegistry()
      ..register(tool('net', (_) async => {'ok': true}, risk: AgentRisk.networkExecuting, approval: true));
    final reuse = subject(reuseRegistry, InMemoryAgentAuditSink(), grants: reuseStore);
    Future<AgentRunResult> runReusable() => reuse.run(
      providerId: 'fakeTestAgent',
      request: request('valid-run', [call('net', approval: valid)]),
      mode: AgentPermissionMode.approvedOperator,
      production: false,
    );
    final first = await runReusable();
    expect(first.status, AgentRunStatus.completed);
    final second = await runReusable();
    expect(second.failureCategory, 'alreadyConsumed');
    final cases = <({ApprovalGrant grant, String run, String toolName, String workspace, String? environment, String version, String expected})>[
      (grant: grant('expired', 'expired-run', 'net', expires: DateTime(2000)), run: 'expired-run', toolName: 'net', workspace: 'w', environment: null, version: '1', expected: 'expired'),
      (grant: grant('run', 'other', 'net'), run: 'run', toolName: 'net', workspace: 'w', environment: null, version: '1', expected: 'runMismatch'),
      (grant: grant('tool', 'tool-run', 'other'), run: 'tool-run', toolName: 'net', workspace: 'w', environment: null, version: '1', expected: 'toolMismatch'),
      (grant: grant('version', 'version-run', 'net'), run: 'version-run', toolName: 'net', workspace: 'w', environment: null, version: '2', expected: 'toolMismatch'),
      (grant: grant('workspace', 'workspace-run', 'net', workspace: 'other'), run: 'workspace-run', toolName: 'net', workspace: 'w', environment: null, version: '1', expected: 'scopeMismatch'),
      (grant: grant('environment', 'environment-run', 'net', environment: 'other'), run: 'environment-run', toolName: 'net', workspace: 'w', environment: 'e', version: '1', expected: 'scopeMismatch'),
      (grant: grant('risk', 'risk-run', 'net', risk: AgentRisk.readOnly), run: 'risk-run', toolName: 'net', workspace: 'w', environment: null, version: '1', expected: 'riskMismatch'),
    ];
    for (final item in cases) {
      final value = await execute(item.grant, run: item.run, toolName: item.toolName, workspace: item.workspace, environment: item.environment, version: item.version);
      expect(value.failureCategory, item.expected);
    }
    final missing = await execute(null, run: 'missing');
    expect(missing.failureCategory, 'approval_required');
    final productionGrant = grant('production', 'production-run', 'net');
    expect((await execute(productionGrant, run: 'production-run', production: true)).status, AgentRunStatus.completed);
  });

  test('provider denials never execute a tool and are audited', () async {
    var invoked = 0; final registry = AgentToolRegistry()..register(tool('read', (_) async { invoked++; return {}; }));
    for (final item in {'unknown': 'unknown_provider', 'codex': 'provider_contract_only', 'claudeCode': 'provider_contract_only', 'googleOfficialClient': 'provider_verification_required'}.entries) {
      final audit = InMemoryAgentAuditSink(); final result = await subject(registry, audit).startRun(providerId: item.key, request: request(item.key, [call('read')]), mode: AgentPermissionMode.observe, production: false).result;
      expect(result.failureCategory, item.value); expect(phases(audit), ['run.received', 'run.started', 'run.provider_denied', 'run.failed']);
    }
    expect(invoked, 0);
  });

  test('grpc execute needs approval and remains unavailable with approval', () async {
    final registry = AgentToolRegistry.foundation(); final store = InMemoryApprovalGrantStore();
    final noApproval = await subject(registry, InMemoryAgentAuditSink(), grants: store).run(providerId: 'fakeTestAgent', request: request('g1', [call('grpc.invoke.execute')]), mode: AgentPermissionMode.approvedOperator, production: false);
    final approved = grant('grpc', 'g2', 'grpc.invoke.execute'); store.add(approved);
    final unavailable = await subject(registry, InMemoryAgentAuditSink(), grants: store).run(providerId: 'fakeTestAgent', request: request('g2', [call('grpc.invoke.execute', approval: approved)]), mode: AgentPermissionMode.approvedOperator, production: false);
    expect(noApproval.failureCategory, 'approval_required'); expect(unavailable.failureCategory, 'execution_unavailable_in_foundation');
  });

  test('permission denial and tool failure have terminal audit only once', () async {
    final registry = AgentToolRegistry()..register(tool('draft', (_) async => {}, risk: AgentRisk.draftChanging))..register(tool('bad', (_) async => throw StateError('fail')));
    final audit = InMemoryAgentAuditSink(); final orchestrator = subject(registry, audit);
    final denied = await orchestrator.startRun(providerId: 'fakeTestAgent', request: request('denied', [call('draft')]), mode: AgentPermissionMode.observe, production: false).result;
    final failed = await orchestrator.startRun(providerId: 'fakeTestAgent', request: request('failed', [call('bad')]), mode: AgentPermissionMode.observe, production: false).result;
    expect(denied.failureCategory, 'observe_read_only'); expect(failed.failureCategory, 'tool_failure');
    expect(audit.entries.where((e) => e.runId == 'denied' && e.phase == 'run.failed'), hasLength(1));
    expect(audit.entries.where((e) => e.runId == 'failed' && e.phase == 'run.failed'), hasLength(1));
  });
}
