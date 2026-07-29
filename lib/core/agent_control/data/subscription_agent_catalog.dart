import '../domain/agent_models.dart';

class SubscriptionAgentCatalog {
  SubscriptionAgentCatalog._(this._records);
  final Map<String, AgentProviderRecord> _records;
  static final SubscriptionAgentCatalog official = SubscriptionAgentCatalog._(
    Map<String, AgentProviderRecord>.unmodifiable(<String, AgentProviderRecord>{
      'codex': const AgentProviderRecord(
        kind: AgentProviderKind.codex,
        providerId: 'codex',
        displayName: 'Codex',
        supportStatus: AgentProviderSupportStatus.contractOnly,
        executable: false,
        executableAllowed: false,
        authentication: AgentAuthenticationStatus.unknown,
        capabilities: <String>{},
        officialClientRequired: true,
        externalVerificationRequired: false,
        explanation: 'Official-client contract only; execution is deferred.',
      ),
      'claudeCode': const AgentProviderRecord(
        kind: AgentProviderKind.claudeCode,
        providerId: 'claudeCode',
        displayName: 'Claude Code',
        supportStatus: AgentProviderSupportStatus.contractOnly,
        executable: false,
        executableAllowed: false,
        authentication: AgentAuthenticationStatus.unknown,
        capabilities: <String>{},
        officialClientRequired: true,
        externalVerificationRequired: false,
        explanation: 'Official-client contract only; execution is deferred.',
      ),
      'googleOfficialClient': const AgentProviderRecord(
        kind: AgentProviderKind.googleOfficialClient,
        providerId: 'googleOfficialClient',
        displayName: 'Google official client',
        supportStatus: AgentProviderSupportStatus.verificationRequired,
        executable: false,
        executableAllowed: false,
        authentication: AgentAuthenticationStatus.verificationRequired,
        capabilities: <String>{},
        officialClientRequired: true,
        externalVerificationRequired: true,
        explanation: 'Unsupported pending official-contract verification.',
      ),
      'fakeTestAgent': const AgentProviderRecord(
        kind: AgentProviderKind.fakeTestAgent,
        providerId: 'fakeTestAgent',
        displayName: 'Fake test agent',
        supportStatus: AgentProviderSupportStatus.supportedForTesting,
        executable: true,
        executableAllowed: true,
        authentication: AgentAuthenticationStatus.unauthenticated,
        capabilities: <String>{'structuredToolCalls'},
        officialClientRequired: false,
        externalVerificationRequired: false,
        explanation: 'The only executable provider, and only in tests.',
      ),
    }),
  );
  Iterable<AgentProviderRecord> get records => _records.values;
  AgentProviderRecord require(String providerId) =>
      _records[providerId] ??
      (throw const AgentProviderException('unknown_provider'));
}

class AgentProviderException implements Exception {
  const AgentProviderException(this.category);
  final String category;
}
