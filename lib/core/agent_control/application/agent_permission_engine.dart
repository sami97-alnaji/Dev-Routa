// ignore_for_file: curly_braces_in_flow_control_structures

import '../domain/agent_models.dart';
import 'agent_tool_registry.dart';

class PermissionDecision {
  const PermissionDecision(
    this.allowed, {
    this.requiresApproval = false,
    this.category,
  });
  final bool allowed;
  final bool requiresApproval;
  final String? category;
}

class AgentPermissionEngine {
  PermissionDecision evaluate({
    required AgentPermissionMode mode,
    required AgentToolDefinition tool,
    required bool production,
  }) {
    if (tool.risk == AgentRisk.destructive)
      return const PermissionDecision(
        false,
        requiresApproval: true,
        category: 'destructive_requires_separate_approval',
      );
    if (production && tool.risk == AgentRisk.networkExecuting)
      return const PermissionDecision(
        false,
        requiresApproval: true,
        category: 'production_requires_approval',
      );
    if (mode == AgentPermissionMode.observe)
      return tool.risk == AgentRisk.readOnly
          ? const PermissionDecision(true)
          : const PermissionDecision(false, category: 'observe_read_only');
    if (mode == AgentPermissionMode.suggest)
      return const PermissionDecision(false, category: 'suggest_non_mutating');
    if (mode == AgentPermissionMode.draftEditor)
      return (tool.risk == AgentRisk.readOnly ||
              tool.risk == AgentRisk.draftChanging)
          ? const PermissionDecision(true)
          : const PermissionDecision(false, category: 'draft_only');
    if (mode == AgentPermissionMode.testOperator && production)
      return const PermissionDecision(
        false,
        category: 'test_blocks_production',
      );
    if (tool.requiresApproval)
      return const PermissionDecision(
        false,
        requiresApproval: true,
        category: 'approval_required',
      );
    return const PermissionDecision(true);
  }

  bool consume(
    ApprovalGrant? grant,
    AgentToolCallRequest call,
    AgentToolDefinition tool,
    DateTime now,
  ) {
    if (grant == null || grant.used || !now.isBefore(grant.expiresAt))
      return false;
    if (grant.runId != (call.input['runId'] as String? ?? '') ||
        grant.toolName != tool.name ||
        grant.workspaceId != call.workspaceId ||
        grant.environmentId != call.environmentId)
      return false;
    grant.used = true;
    return true;
  }
}
