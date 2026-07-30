import 'dart:async';

import 'package:devroute_ai_studio/core/agent_control/data/codex_subscription_adapter.dart';
import 'package:devroute_ai_studio/core/agent_control/domain/agent_models.dart';
import 'package:devroute_ai_studio/features/ai_assistant/application/codex_agents_controller.dart';
import 'package:devroute_ai_studio/features/ai_assistant/presentation/ai_agents_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('device-auth output retains the official URL and user code', () {
    final output = CodexDeviceAuthOutput.parse(
      'Open https://auth.openai.com/device and enter device code ABCD-EFGH.',
    );

    expect(output.verificationUrl, 'https://auth.openai.com/device');
    expect(output.deviceCode, 'ABCD-EFGH');
  });

  testWidgets('controller exposes device-auth details in AI Agents UI', (
    tester,
  ) async {
    final adapter = _DeviceAuthAdapter();
    final controller = CodexAgentsController(adapter);
    addTearDown(() async {
      controller.dispose();
      await adapter.events.close();
    });

    await controller.openOfficialSignIn();
    await tester.pumpWidget(
      MaterialApp(
        home: AiAgentsScreen(controller: controller, workspaceId: 'workspace'),
      ),
    );

    expect(find.text('Authentication instructions'), findsOneWidget);
    expect(find.text('https://auth.openai.com/device'), findsOneWidget);
    expect(find.text('ABCD-EFGH'), findsOneWidget);
  });
}

class _DeviceAuthAdapter extends CodexSubscriptionAdapter {
  _DeviceAuthAdapter()
    : super(orchestratorForWorkspace: (_) => throw UnimplementedError());

  final StreamController<OfficialSignInProgress> events =
      StreamController<OfficialSignInProgress>.broadcast();

  @override
  Stream<OfficialSignInProgress> get signInEvents => events.stream;

  @override
  Future<OfficialSignInLaunchResult> launchOfficialSignIn() async =>
      const OfficialSignInLaunchResult(
        launched: true,
        instructions: 'Open the official verification URL.',
        verificationUrl: 'https://auth.openai.com/device',
        deviceCode: 'ABCD-EFGH',
      );
}
