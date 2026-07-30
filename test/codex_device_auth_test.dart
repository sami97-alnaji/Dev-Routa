import 'dart:async';

import 'package:devroute_ai_studio/core/agent_control/data/codex_subscription_adapter.dart';
import 'package:devroute_ai_studio/core/agent_control/domain/agent_models.dart';
import 'package:devroute_ai_studio/features/ai_assistant/application/codex_agents_controller.dart';
import 'package:devroute_ai_studio/features/ai_assistant/presentation/ai_agents_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('device-auth chunks retain the official URL and user code', () {
    final collector = CodexDeviceAuthOutputCollector();
    CodexDeviceAuthOutput? output;
    for (final chunk in <String>[
      '\u001b[90mFollow the device code auth',
      'orization:\r\nOpen https://auth.openai.com/codex/',
      'device\u001b[0m\r\nEnter this one-time code:\r\n\u001b[94m3DI-',
      'JA190\u001b[0m',
    ]) {
      output = collector.addChunk(chunk) ?? output;
    }

    expect(output!.verificationUrl, 'https://auth.openai.com/codex/device');
    expect(output.deviceCode, '3DI-JA190');
    expect(collector.addChunk(''), isNull);
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
    await tester.pump();
    await tester.pumpWidget(
      MaterialApp(
        home: AiAgentsScreen(controller: controller, workspaceId: 'workspace'),
      ),
    );

    expect(find.text('Authentication instructions'), findsOneWidget);
    expect(find.text('https://auth.openai.com/device'), findsOneWidget);
    expect(find.text('ABCD-EFGH'), findsOneWidget);
    expect(find.text('Copy verification URL'), findsOneWidget);
    expect(find.text('Copy device code'), findsOneWidget);
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
  Future<OfficialSignInLaunchResult> launchOfficialSignIn() async {
    events.add(
      const OfficialSignInProgress(
        lifecycle: 'awaiting_user_verification',
        instructions: 'Open the official verification URL.',
        verificationUrl: 'https://auth.openai.com/device',
        deviceCode: 'ABCD-EFGH',
      ),
    );
    return const OfficialSignInLaunchResult(launched: true);
  }
}
