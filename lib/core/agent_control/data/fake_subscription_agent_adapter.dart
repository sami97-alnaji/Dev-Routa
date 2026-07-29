import 'dart:async';
import '../domain/agent_models.dart';

class FakeSubscriptionAgentAdapter implements SubscriptionAgentAdapter {
  final Map<String, _FakeHandle> _runs = <String, _FakeHandle>{};
  @override
  String get providerId => 'fakeTestAgent';
  @override
  Future<AgentInstallationStatus> detectInstallation() async =>
      AgentInstallationStatus.installed;
  @override
  Future<AgentAuthenticationStatus> authenticationStatus() async =>
      AgentAuthenticationStatus.unauthenticated;
  @override
  Future<AgentCapabilities> capabilities() async =>
      const AgentCapabilities(<String>{'structuredToolCalls'});
  @override
  Future<OfficialSignInLaunchResult> launchOfficialSignIn() async =>
      const OfficialSignInLaunchResult(
        launched: false,
        category: 'not_supported_in_foundation',
      );
  @override
  AgentRunHandle startRun(AgentRunRequest request) =>
      _runs.putIfAbsent(request.runId, () => _FakeHandle(request.runId));
  @override
  Future<void> cancelRun(String runId) async => _runs[runId]?.cancel();
  @override
  Future<void> disconnect() async {}
}

class _FakeHandle implements AgentRunHandle {
  _FakeHandle(this.runId);
  @override
  final String runId;
  final StreamController<AgentRunEvent> _events =
      StreamController<AgentRunEvent>.broadcast();
  final Completer<AgentRunResult> _result = Completer<AgentRunResult>();
  @override
  Stream<AgentRunEvent> get events => _events.stream;
  @override
  Future<AgentRunResult> get result => _result.future;
  @override
  Future<void> cancel() async {
    if (!_result.isCompleted) {
      _events.add(const AgentRunEvent('cancelled'));
      _result.complete(
        const AgentRunResult(
          status: AgentRunStatus.cancelled,
          results: <AgentToolCallResult>[],
        ),
      );
      await _events.close();
    }
  }
}
