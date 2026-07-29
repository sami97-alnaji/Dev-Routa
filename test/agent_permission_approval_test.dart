import 'package:devroute_ai_studio/core/agent_control/data/approval_grant_store.dart';
import 'package:devroute_ai_studio/core/agent_control/domain/agent_models.dart';
import 'package:flutter_test/flutter_test.dart';

ApprovalGrant grant({DateTime? expiry}) => ApprovalGrant(
  approvalId: 'a',
  runId: 'r',
  toolName: 'grpc.invoke.execute',
  toolVersion: '1',
  workspaceId: 'w',
  environmentId: 'e',
  risk: AgentRisk.networkExecuting,
  safeInputSummary: 'safe',
  estimatedRequestCount: 1,
  expiresAt: expiry ?? DateTime.utc(2030),
);
void main() {
  test('approval is atomic, one-time and scope-bound', () {
    final store = InMemoryApprovalGrantStore()..add(grant());
    final now = DateTime.utc(2029);
    expect(
      store
          .consume(
            approvalId: 'a',
            runId: 'r',
            toolName: 'grpc.invoke.execute',
            toolVersion: '1',
            workspaceId: 'w',
            environmentId: 'e',
            risk: AgentRisk.networkExecuting,
            now: now,
          )
          .allowed,
      isTrue,
    );
    expect(
      store
          .consume(
            approvalId: 'a',
            runId: 'r',
            toolName: 'grpc.invoke.execute',
            toolVersion: '1',
            workspaceId: 'w',
            environmentId: 'e',
            risk: AgentRisk.networkExecuting,
            now: now,
          )
          .rejection,
      ApprovalRejection.alreadyConsumed,
    );
  });
  test(
    'approval rejects expired, run, tool, workspace, environment and risk mismatch',
    () {
      final now = DateTime.utc(2029);
      ApprovalRejection consume(
        ApprovalGrant item, {
        String runId = 'r',
        String tool = 'grpc.invoke.execute',
        String workspace = 'w',
        String? environment = 'e',
        AgentRisk risk = AgentRisk.networkExecuting,
      }) {
        final store = InMemoryApprovalGrantStore()..add(item);
        return store
            .consume(
              approvalId: 'a',
              runId: runId,
              toolName: tool,
              toolVersion: '1',
              workspaceId: workspace,
              environmentId: environment,
              risk: risk,
              now: now,
            )
            .rejection!;
      }

      expect(
        consume(grant(expiry: DateTime.utc(2028))),
        ApprovalRejection.expired,
      );
      expect(consume(grant(), runId: 'x'), ApprovalRejection.runMismatch);
      expect(consume(grant(), tool: 'other'), ApprovalRejection.toolMismatch);
      expect(consume(grant(), workspace: 'x'), ApprovalRejection.scopeMismatch);
      expect(
        consume(grant(), environment: 'x'),
        ApprovalRejection.scopeMismatch,
      );
      expect(
        consume(grant(), risk: AgentRisk.readOnly),
        ApprovalRejection.riskMismatch,
      );
    },
  );
}
