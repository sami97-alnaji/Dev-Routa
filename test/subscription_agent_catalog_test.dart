import 'package:devroute_ai_studio/core/agent_control/data/subscription_agent_catalog.dart';
import 'package:devroute_ai_studio/core/agent_control/domain/agent_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalog has exactly four safe non-credential records', () {
    final catalog = SubscriptionAgentCatalog.official;
    expect(
      catalog.records.map((record) => record.providerId),
      containsAll(<String>[
        'codex',
        'claudeCode',
        'googleOfficialClient',
        'fakeTestAgent',
      ]),
    );
    expect(catalog.records, hasLength(4));
    expect(catalog.require('fakeTestAgent').executableAllowed, isTrue);
    expect(
      catalog.require('codex').supportStatus,
      AgentProviderSupportStatus.supportedForTesting,
    );
    expect(catalog.require('claudeCode').executable, isFalse);
    expect(
      catalog.require('googleOfficialClient').supportStatus,
      AgentProviderSupportStatus.verificationRequired,
    );
    expect(
      () => catalog.require('unknown'),
      throwsA(isA<AgentProviderException>()),
    );
  });
}
