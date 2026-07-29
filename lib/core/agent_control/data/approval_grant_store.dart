// ignore_for_file: curly_braces_in_flow_control_structures

import '../domain/agent_models.dart';

enum ApprovalRejection {
  missing,
  expired,
  alreadyConsumed,
  scopeMismatch,
  riskMismatch,
  runMismatch,
  toolMismatch,
}

class ApprovalUseResult {
  const ApprovalUseResult.allowed() : rejection = null;
  const ApprovalUseResult.rejected(this.rejection);
  final ApprovalRejection? rejection;
  bool get allowed => rejection == null;
}

class InMemoryApprovalGrantStore {
  final Map<String, ApprovalGrant> _grants = <String, ApprovalGrant>{};
  void add(ApprovalGrant grant) {
    if (_grants.containsKey(grant.approvalId))
      throw StateError('duplicate_approval');
    _grants[grant.approvalId] = grant;
  }

  ApprovalUseResult consume({
    required String approvalId,
    required String runId,
    required String toolName,
    required String toolVersion,
    required String workspaceId,
    required String? environmentId,
    required AgentRisk risk,
    required DateTime now,
  }) {
    final grant = _grants[approvalId];
    if (grant == null)
      return const ApprovalUseResult.rejected(ApprovalRejection.missing);
    if (grant.used)
      return const ApprovalUseResult.rejected(
        ApprovalRejection.alreadyConsumed,
      );
    if (!now.isBefore(grant.expiresAt))
      return const ApprovalUseResult.rejected(ApprovalRejection.expired);
    if (grant.runId != runId)
      return const ApprovalUseResult.rejected(ApprovalRejection.runMismatch);
    if (grant.toolName != toolName || grant.toolVersion != toolVersion)
      return const ApprovalUseResult.rejected(ApprovalRejection.toolMismatch);
    if (grant.workspaceId != workspaceId ||
        grant.environmentId != environmentId)
      return const ApprovalUseResult.rejected(ApprovalRejection.scopeMismatch);
    if (grant.risk != risk)
      return const ApprovalUseResult.rejected(ApprovalRejection.riskMismatch);
    grant.used = true;
    return const ApprovalUseResult.allowed();
  }
}
