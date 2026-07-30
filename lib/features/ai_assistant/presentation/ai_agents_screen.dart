import 'package:flutter/material.dart';

import '../application/codex_agents_controller.dart';

class AiAgentsScreen extends StatelessWidget {
  const AiAgentsScreen({
    super.key,
    required this.controller,
    required this.workspaceId,
  });
  final CodexAgentsController controller;
  final String workspaceId;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) => ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('AI Agents', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Codex', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                _row('Installation status', controller.installation.name),
                _row(
                  'ChatGPT authentication status',
                  controller.authentication.name,
                ),
                _row('Current lifecycle state', controller.lifecycle),
                _row('Tool bridge status', controller.bridgeStatus),
                _row(
                  'Tools allowed',
                  '2: app.capabilities, grpc.history.search',
                ),
                _row('Sandbox', 'read-only'),
                _row('External network', 'disabled for the agent sandbox'),
                _row('API key', 'not used'),
                if (controller.lastTool != null)
                  _row('Last tool called', controller.lastTool!),
                if (controller.lastResult != null)
                  _row('Last sanitized result', controller.lastResult!),
                if (controller.lastFailure != null)
                  _row('Last typed failure', controller.lastFailure!),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: controller.refresh,
                      child: const Text('Detect Codex'),
                    ),
                    OutlinedButton(
                      onPressed: controller.openOfficialSignIn,
                      child: const Text('Open official sign-in'),
                    ),
                    FilledButton(
                      onPressed: controller.installation.name == 'installed'
                          ? () => controller.runConnectionTest(workspaceId)
                          : null,
                      child: const Text('Run connection test'),
                    ),
                    TextButton(
                      onPressed:
                          controller.lifecycle == 'idle' ||
                              controller.lifecycle == 'completed' ||
                              controller.lifecycle == 'failed'
                          ? null
                          : controller.cancel,
                      child: const Text('Cancel active run'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Audit timeline', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: controller.audit.isEmpty
                ? const Text('No activity yet.')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: controller.audit
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Text(entry),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ),
      ],
    ),
  );
  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 230, child: Text(label)),
        Expanded(child: SelectableText(value)),
      ],
    ),
  );
}
