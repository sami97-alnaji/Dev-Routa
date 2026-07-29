import 'dart:async';

enum AgentProviderKind {
  codex,
  claudeCode,
  googleOfficialClient,
  fakeTestAgent,
}

enum AgentInstallationStatus { installed, notInstalled, unknown }

enum AgentAuthenticationStatus {
  authenticated,
  unauthenticated,
  unknown,
  verificationRequired,
}

enum AgentRisk {
  readOnly,
  draftChanging,
  stateChanging,
  networkExecuting,
  destructive,
  productionSensitive,
}

enum AgentPermissionMode {
  observe,
  suggest,
  draftEditor,
  testOperator,
  approvedOperator,
  automationAgent,
  productionRestricted,
}

enum AgentRunStatus { running, completed, cancelled, failed }

enum AgentIdempotency { idempotent, nonIdempotent, unknown }

enum AgentProviderSupportStatus {
  supportedForTesting,
  contractOnly,
  verificationRequired,
}

enum AgentRunLifecycle {
  created,
  running,
  awaitingApproval,
  cancelling,
  cancelled,
  completed,
  failed,
  timedOut,
}

class AgentCapabilities {
  const AgentCapabilities(this.values);
  final Set<String> values;
}

class OfficialSignInLaunchResult {
  const OfficialSignInLaunchResult({required this.launched, this.category});
  final bool launched;
  final String? category;
}

class AgentRunRequest {
  const AgentRunRequest({
    required this.runId,
    required this.workspaceId,
    required this.calls,
  });
  final String runId;
  final String workspaceId;
  final List<AgentToolCallRequest> calls;
}

class AgentRunEvent {
  const AgentRunEvent(this.kind, {this.message});
  final String kind;
  final String? message;
}

class AgentRunResult {
  const AgentRunResult({
    required this.status,
    required this.results,
    this.failureCategory,
  });
  final AgentRunStatus status;
  final List<AgentToolCallResult> results;
  final String? failureCategory;
}

abstract interface class AgentRunHandle {
  String get runId;
  Stream<AgentRunEvent> get events;
  Future<AgentRunResult> get result;
  Future<void> cancel();
}

abstract interface class SubscriptionAgentAdapter {
  String get providerId;
  Future<AgentInstallationStatus> detectInstallation();
  Future<AgentAuthenticationStatus> authenticationStatus();
  Future<AgentCapabilities> capabilities();
  Future<OfficialSignInLaunchResult> launchOfficialSignIn();
  AgentRunHandle startRun(AgentRunRequest request);
  Future<void> cancelRun(String runId);
  Future<void> disconnect();
}

class AgentProviderRecord {
  const AgentProviderRecord({
    required this.kind,
    required this.providerId,
    required this.displayName,
    required this.supportStatus,
    required this.executable,
    required this.executableAllowed,
    required this.authentication,
    required this.capabilities,
    required this.officialClientRequired,
    required this.externalVerificationRequired,
    required this.explanation,
  });
  final AgentProviderKind kind;
  final String providerId;
  final String displayName;
  final AgentProviderSupportStatus supportStatus;
  final bool executable;
  final bool executableAllowed;
  final AgentAuthenticationStatus authentication;
  final Set<String> capabilities;
  final bool officialClientRequired;
  final bool externalVerificationRequired;
  final String explanation;
}

class AgentToolCallRequest {
  const AgentToolCallRequest({
    required this.toolName,
    required this.input,
    required this.workspaceId,
    this.environmentId,
    this.approval,
  });
  final String toolName;
  final Map<String, Object?> input;
  final String workspaceId;
  final String? environmentId;
  final ApprovalGrant? approval;
}

class AgentToolCallResult {
  const AgentToolCallResult({
    required this.toolName,
    required this.success,
    required this.output,
    this.failureCategory,
  });
  final String toolName;
  final bool success;
  final Map<String, Object?> output;
  final String? failureCategory;
}

class ApprovalRequest {
  const ApprovalRequest({
    required this.approvalId,
    required this.runId,
    required this.toolName,
    required this.workspaceId,
    this.environmentId,
    required this.risk,
    required this.safeInputSummary,
    required this.estimatedRequestCount,
    required this.expiresAt,
    this.runScoped = false,
  });
  final String approvalId;
  final String runId;
  final String toolName;
  final String workspaceId;
  final String? environmentId;
  final AgentRisk risk;
  final String safeInputSummary;
  final int estimatedRequestCount;
  final DateTime expiresAt;
  final bool runScoped;
}

class ApprovalGrant extends ApprovalRequest {
  ApprovalGrant({
    required super.approvalId,
    required super.runId,
    required super.toolName,
    required super.workspaceId,
    super.environmentId,
    required super.risk,
    required super.safeInputSummary,
    required super.estimatedRequestCount,
    required super.expiresAt,
    super.runScoped,
    required this.toolVersion,
  });
  final String toolVersion;
  bool used = false;
}

class AgentAuditEntry {
  const AgentAuditEntry({
    required this.eventId,
    required this.runId,
    required this.timestamp,
    required this.providerId,
    required this.toolName,
    required this.workspaceId,
    this.environmentId,
    required this.decision,
    required this.phase,
    required this.inputSummary,
    this.outputSummary,
    this.failureCategory,
  });
  final String eventId;
  final String runId;
  final DateTime timestamp;
  final String providerId;
  final String toolName;
  final String workspaceId;
  final String? environmentId;
  final String decision;
  final String phase;
  final String inputSummary;
  final String? outputSummary;
  final String? failureCategory;
}

abstract interface class AgentAuditSink {
  Future<void> record(AgentAuditEntry entry);
}

class InMemoryAgentAuditSink implements AgentAuditSink {
  final List<AgentAuditEntry> entries = <AgentAuditEntry>[];
  @override
  Future<void> record(AgentAuditEntry entry) async => entries.add(entry);
}

class AutomationLimits {
  const AutomationLimits({
    required this.maximumSteps,
    required this.maximumRequests,
    required this.maximumDuration,
    required this.maximumRetries,
    this.allowProduction = false,
  });
  final int maximumSteps;
  final int maximumRequests;
  final Duration maximumDuration;
  final int maximumRetries;
  final bool allowProduction;
}

class AutomationDefinition {
  const AutomationDefinition({
    required this.id,
    required this.name,
    required this.enabled,
    required this.trigger,
    required this.steps,
    required this.limits,
    required this.workspaceId,
    this.environmentId,
    this.explicitProductionPolicy = false,
  });
  final String id;
  final String name;
  final bool enabled;
  final String trigger;
  final List<String> steps;
  final AutomationLimits limits;
  final String workspaceId;
  final String? environmentId;
  final bool explicitProductionPolicy;
}
