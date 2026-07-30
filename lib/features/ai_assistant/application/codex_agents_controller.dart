import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/agent_control/data/codex_subscription_adapter.dart';
import '../../../core/agent_control/domain/agent_models.dart';

class CodexAgentsService {
  const CodexAgentsService(this.controller);
  final CodexAgentsController controller;
}

class CodexAgentsController extends ChangeNotifier {
  CodexAgentsController(this._adapter) {
    _signInSubscription = _adapter.signInEvents.listen(_applySignInProgress);
  }
  final CodexSubscriptionAdapter _adapter;
  AgentInstallationStatus installation = AgentInstallationStatus.unknown;
  AgentAuthenticationStatus authentication = AgentAuthenticationStatus.unknown;
  CodexRuntimeReadiness readiness =
      const CodexRuntimeReadiness.profileFailure();
  String lifecycle = 'idle';
  String bridgeStatus = 'dynamic tools (2)';
  String? lastTool;
  String? lastResult;
  String? lastFailure;
  String? authenticationInstructions;
  String? verificationUrl;
  String? deviceCode;
  final List<String> audit = <String>[];
  AgentRunHandle? _active;
  StreamSubscription<OfficialSignInProgress>? _signInSubscription;

  Future<void> refresh() async {
    installation = await _adapter.detectInstallation();
    readiness = await _adapter.runtimeReadiness();
    authentication = readiness.authentication;
    _audit('status refreshed');
    notifyListeners();
  }

  Future<void> openOfficialSignIn() async {
    final result = await _adapter.launchOfficialSignIn();
    lastFailure = result.category;
    authenticationInstructions = result.instructions;
    verificationUrl = result.verificationUrl;
    deviceCode = result.deviceCode;
    lifecycle = result.launched ? 'awaiting_user_verification' : 'failed';
    _audit(
      result.launched
          ? 'official sign-in opened'
          : 'official sign-in unavailable',
    );
    notifyListeners();
  }

  Future<void> runConnectionTest(String workspaceId) async {
    if (_active != null || !readiness.canRun) return;
    lifecycle = 'starting';
    lastFailure = null;
    lastResult = null;
    lastTool = null;
    _audit('connection test requested');
    notifyListeners();
    final handle = _adapter.startRun(
      AgentRunRequest(
        runId: const Uuid().v4(),
        workspaceId: workspaceId,
        calls: <AgentToolCallRequest>[
          AgentToolCallRequest(
            toolName: 'app.capabilities',
            input: const <String, Object?>{},
            workspaceId: workspaceId,
          ),
          AgentToolCallRequest(
            toolName: 'grpc.history.search',
            input: const <String, Object?>{},
            workspaceId: workspaceId,
          ),
        ],
      ),
    );
    _active = handle;
    final subscription = handle.events.listen((event) {
      lifecycle = event.kind;
      _audit(event.kind);
      notifyListeners();
    });
    final result = await handle.result;
    await subscription.cancel();
    _active = null;
    lifecycle = result.status.name;
    lastFailure = result.failureCategory;
    lastTool = result.results.isEmpty ? lastTool : result.results.last.toolName;
    lastResult = result.results.isEmpty
        ? null
        : result.results.last.output['summary']?.toString();
    _audit(
      'run ${result.status.name}${result.failureCategory == null ? '' : ': ${result.failureCategory}'}',
    );
    notifyListeners();
  }

  Future<void> cancel() async {
    final active = _active;
    if (active == null) {
      await _adapter.cancelOfficialSignIn();
      return;
    }
    lifecycle = 'cancelling';
    _audit('cancellation requested');
    notifyListeners();
    await active.cancel();
  }

  void _applySignInProgress(OfficialSignInProgress progress) {
    lifecycle = progress.lifecycle;
    authenticationInstructions =
        progress.instructions ?? authenticationInstructions;
    verificationUrl = progress.verificationUrl ?? verificationUrl;
    deviceCode = progress.deviceCode ?? deviceCode;
    lastFailure = progress.failureCategory;
    _audit('login ${progress.lifecycle}');
    if (progress.lifecycle == 'authenticated') unawaited(refresh());
    notifyListeners();
  }

  @override
  void dispose() {
    _signInSubscription?.cancel();
    super.dispose();
  }

  void _audit(String value) {
    audit.add('${DateTime.now().toLocal().toIso8601String()}  $value');
    if (audit.length > 8) audit.removeAt(0);
  }
}
