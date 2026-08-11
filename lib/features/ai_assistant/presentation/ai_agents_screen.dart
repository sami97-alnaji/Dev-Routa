import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/agent_control/data/codex_subscription_adapter.dart';
import '../../../core/agent_control/domain/agent_models.dart';
import '../../../core/widgets/devroute_desktop.dart';
import '../application/codex_agents_controller.dart';

class AiAgentsScreen extends StatefulWidget {
  const AiAgentsScreen({
    super.key,
    required this.controller,
    required this.workspaceId,
  });
  final CodexAgentsController controller;
  final String workspaceId;

  @override
  State<AiAgentsScreen> createState() => _AiAgentsScreenState();
}

class _AiAgentsScreenState extends State<AiAgentsScreen> {
  bool _inspectorOpen = false;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final controller = widget.controller;
      return LayoutBuilder(
        builder: (context, constraints) {
          final sideInspector = constraints.maxWidth >= 1080 && _inspectorOpen;
          final compact = constraints.maxWidth < 680;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ConsoleHeader(
                controller: controller,
                compact: compact,
                inspectorOpen: _inspectorOpen,
                onInspectorToggle: () =>
                    setState(() => _inspectorOpen = !_inspectorOpen),
              ),
              const Divider(height: 1),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(compact ? 8 : 12),
                  child: sideInspector
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: _MainPanel(
                                      controller: controller,
                                      workspaceId: widget.workspaceId,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Expanded(
                                    flex: 2,
                                    child: _AuditTimeline(
                                      controller: controller,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 330,
                              child: _RuntimeInspector(controller: controller),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _MainPanel(
                                controller: controller,
                                workspaceId: widget.workspaceId,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              flex: 2,
                              child: _AuditTimeline(controller: controller),
                            ),
                            if (_inspectorOpen) ...[
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 260,
                                child: _RuntimeInspector(
                                  controller: controller,
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

class _MainPanel extends StatelessWidget {
  const _MainPanel({required this.controller, required this.workspaceId});
  final CodexAgentsController controller;
  final String workspaceId;

  @override
  Widget build(BuildContext context) => _ConsolePane(
    title: 'Codex',
    subtitle:
        'Restricted workspace agent · ${controller.modelSelection.displayName}',
    trailing: _StatusPill(ready: controller.readiness.canRun),
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _RunStatusStrip(controller: controller),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Text(
              'RUN CONTROL',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
                letterSpacing: .8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _readinessMessage(controller.readiness),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                OutlinedButton.icon(
                  onPressed: controller.refresh,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Detect Codex'),
                ),
                OutlinedButton.icon(
                  onPressed: controller.signInActive
                      ? null
                      : controller.openOfficialSignIn,
                  icon: const Icon(Icons.login, size: 16),
                  label: const Text('Open official sign-in'),
                ),
                if (controller.connectionTestSucceeded != true)
                  FilledButton.icon(
                    onPressed: controller.readiness.canRun
                        ? () => controller.runConnectionTest(workspaceId)
                        : null,
                    icon: const Icon(Icons.network_check, size: 16),
                    label: const Text('Run connection test'),
                  )
                else if (!controller.simpleTurnSucceeded)
                  FilledButton.tonalIcon(
                    onPressed: controller.readiness.canRun
                        ? () => controller.runSimpleTurn(workspaceId)
                        : null,
                    icon: const Icon(Icons.bolt, size: 16),
                    label: const Text('Run simple Codex turn'),
                  )
                else
                  FilledButton.tonalIcon(
                    onPressed: controller.readiness.canRun
                        ? () => controller.runRealTurn(workspaceId)
                        : null,
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('Run real Codex turn'),
                  ),
                TextButton.icon(
                  onPressed: controller.hasActiveRun ? controller.cancel : null,
                  icon: const Icon(Icons.stop_circle_outlined, size: 16),
                  label: const Text('Cancel active run'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const _PermissionLedger(),
          ],
        ),
      ),
    ),
  );

  String _readinessMessage(CodexRuntimeReadiness readiness) {
    if (readiness.canRun) return 'Ready to run in this workspace.';
    if (!readiness.authenticationProbeAttempted) {
      return 'Codex runtime readiness is blocked before authentication.';
    }
    if (readiness.authentication != AgentAuthenticationStatus.authenticated) {
      return 'Official sign-in is required before an agent can run.';
    }
    if (readiness.failureCategory ==
        'CODEX_UPDATE_REQUIRED_FOR_SELECTED_MODEL') {
      return '${controller.modelSelection.displayName} requires Codex CLI '
          '${readiness.requiredCodexVersion ?? controller.modelSelection.minimumCliVersion} '
          'or later; detected ${readiness.detectedCodexVersion ?? 'unknown'}.';
    }
    if (readiness.failureCategory == 'CODEX_SELECTED_MODEL_UNAVAILABLE') {
      return '${controller.modelSelection.displayName} is not available to this '
          'authenticated Codex session.';
    }
    return 'Codex MCP readiness is blocked.';
  }
}

class _RuntimeInspector extends StatelessWidget {
  const _RuntimeInspector({required this.controller});
  final CodexAgentsController controller;

  @override
  Widget build(BuildContext context) => _ConsolePane(
    title: 'Runtime details',
    subtitle: 'Read-only diagnostics and safety metadata',
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (controller.authenticationInstructions != null)
              _row(
                'Authentication instructions',
                controller.authenticationInstructions!,
              ),
            if (controller.verificationUrl != null)
              _row('Verification URL', controller.verificationUrl!),
            if (controller.deviceCode != null)
              _row('User/device code', controller.deviceCode!),
            if (controller.verificationUrl != null ||
                controller.deviceCode != null)
              Wrap(
                spacing: 8,
                children: [
                  if (controller.verificationUrl != null)
                    TextButton.icon(
                      onPressed: () => Clipboard.setData(
                        ClipboardData(text: controller.verificationUrl!),
                      ),
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy verification URL'),
                    ),
                  if (controller.deviceCode != null)
                    TextButton.icon(
                      onPressed: () => Clipboard.setData(
                        ClipboardData(text: controller.deviceCode!),
                      ),
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy device code'),
                    ),
                ],
              ),
            _row('Tools allowed', '2: app.capabilities, grpc.history.search'),
            _row(
              'Configured Codex model',
              '${controller.modelSelection.displayName} (${controller.modelSelection.id})',
            ),
            _row(
              'Required Codex CLI',
              controller.modelSelection.minimumCliVersion.toString(),
            ),
            _row(
              'Detected Codex CLI',
              controller.readiness.detectedCodexVersion ?? 'not checked',
            ),
            _row('Sandbox', 'read-only'),
            _row('External network', 'Codex official service only'),
            _row('API key', 'not used'),
            _row(
              'Isolated profile status',
              controller.readiness.isolatedProfileReady ? 'ready' : 'not ready',
            ),
            _row(
              'Isolated ChatGPT login status',
              !controller.readiness.authenticationProbeAttempted
                  ? 'not checked'
                  : controller.readiness.authentication ==
                        AgentAuthenticationStatus.authenticated
                  ? 'authenticated'
                  : controller.readiness.authentication ==
                        AgentAuthenticationStatus.unauthenticated
                  ? 'isolated_login_required'
                  : 'authentication_probe_failed',
            ),
            _row(
              'Runtime probe',
              controller.readiness.failedProbeStage == 'isolated_home_probe' ||
                      controller.readiness.failedProbeStage ==
                          'runtime_process_probe'
                  ? 'failed'
                  : controller.readiness.isolatedProfileReady
                  ? 'passed'
                  : 'not checked',
            ),
            _row(
              'Failed stage',
              controller.readiness.failedProbeStage ?? 'none',
            ),
            _row(
              'Failure category',
              controller.readiness.failureCategory ?? 'none',
            ),
            _row(
              'Exception type',
              controller.readiness.diagnostics.exceptionType ?? 'none',
            ),
            _row(
              'OS error code',
              controller.readiness.diagnostics.osErrorCode?.toString() ??
                  'none',
            ),
            _row(
              'OS error category',
              controller.readiness.diagnostics.osErrorCategory ?? 'none',
            ),
            _row(
              'Filesystem operation',
              controller.readiness.diagnostics.operation ?? 'none',
            ),
            _row(
              'Filesystem path',
              controller.readiness.diagnostics.path ?? 'none',
            ),
            _row(
              'App-server substage',
              controller.readiness.diagnostics.appServerSubstage ?? 'none',
            ),
            _row(
              'Process exit code',
              controller.readiness.diagnostics.processExitCode?.toString() ??
                  'none',
            ),
            _row(
              'Timeout',
              controller.readiness.diagnostics.timedOut ? 'yes' : 'no',
            ),
            _row(
              'Executable',
              controller.readiness.diagnostics.executablePath ??
                  'not discovered',
            ),
            _row(
              'Custom working directory',
              controller.readiness.diagnostics.workingDirectoryConfigured
                  ? 'configured'
                  : 'not configured',
            ),
            _row(
              'Environment keys present',
              controller.readiness.diagnostics.environmentKeyPresence.entries
                  .map((entry) => '${entry.key}=${entry.value}')
                  .join(', '),
            ),
            _row(
              'App-server lifecycle',
              <String>[
                'processStarted=${controller.readiness.diagnostics.processStarted}',
                'initializeSent=${controller.readiness.diagnostics.initializeSent}',
                'initializeResponseReceived=${controller.readiness.diagnostics.initializeResponseReceived}',
                'initializedNotificationSent=${controller.readiness.diagnostics.initializedNotificationSent}',
                'mcpStatusRequestSent=${controller.readiness.diagnostics.mcpStatusRequestSent}',
                'mcpStatusResponseReceived=${controller.readiness.diagnostics.mcpStatusResponseReceived}',
                'processExited=${controller.readiness.diagnostics.processExited}',
                'cleanupStarted=${controller.readiness.diagnostics.cleanupStarted}',
              ].join(', '),
            ),
            _row(
              'Third-party MCP servers',
              controller.readiness.mcpServerCount?.toString() ?? 'not checked',
            ),
            _row(
              'Readiness failure',
              controller.readiness.failureCategory ?? 'none',
            ),
            _row(
              'Detected MCP server names',
              controller.readiness.detectedMcpServerNames.isEmpty
                  ? 'none'
                  : controller.readiness.detectedMcpServerNames.join(', '),
            ),
            _row(
              'MCP startup notifications',
              controller.readiness.mcpStartupNotificationCount.toString(),
            ),
            _row('Tool bridge status', controller.bridgeStatus),
            if (controller.connectionTestDuration != null)
              _row(
                'Connection test duration',
                '${controller.connectionTestDuration!.inMilliseconds} ms',
              ),
            if (controller.realTurnTrace != null) ...[
              _row(
                'Real thread ID',
                controller.realTurnTrace!.threadId ?? 'none',
              ),
              _row('Real turn ID', controller.realTurnTrace!.turnId ?? 'none'),
              _row(
                'Selected Codex model',
                controller.realTurnTrace!.appServer.selectedModel ?? 'none',
              ),
              _row(
                'Real turn completion',
                'started=${controller.realTurnTrace!.turnStarted}, '
                    'turn/completed=${controller.realTurnTrace!.turnCompletedReceived}, '
                    'state=${controller.realTurnTrace!.completionState ?? 'none'}, '
                    'duration=${controller.realTurnTrace!.duration.inMilliseconds}ms',
              ),
              if (controller.realTurnTrace!.appServer.turnFailureMessage !=
                  null)
                _row(
                  'Turn failure message',
                  controller.realTurnTrace!.appServer.turnFailureMessage!,
                ),
              if (controller.realTurnTrace!.appServer.codexErrorInfoType !=
                  null)
                _row(
                  'Codex error info',
                  'type=${controller.realTurnTrace!.appServer.codexErrorInfoType}, '
                      'httpStatus=${controller.realTurnTrace!.appServer.turnFailureHttpStatus ?? 'none'}, '
                      'additionalDetails=${controller.realTurnTrace!.appServer.additionalDetailsCategory ?? 'none'}',
                ),
              if (controller.realTurnTrace!.appServer.turnFailureStage != null)
                _row(
                  'Turn failure stage',
                  controller.realTurnTrace!.appServer.turnFailureStage!,
                ),
              if (controller.realTurnTrace!.appServer.eventTypes.isNotEmpty)
                _row(
                  'App-server event sequence',
                  controller.realTurnTrace!.appServer.eventTypes.join(' > '),
                ),
              if (controller
                  .realTurnTrace!
                  .appServer
                  .serverRequestMethods
                  .isNotEmpty)
                _row(
                  'App-server server requests',
                  controller.realTurnTrace!.appServer.serverRequestMethods.join(
                    ', ',
                  ),
                ),
              if (controller.realTurnTrace!.appServer.stderrMetadata.isNotEmpty)
                _row(
                  'App-server stderr',
                  controller.realTurnTrace!.appServer.stderrMetadata
                      .map(
                        (entry) =>
                            '${entry.severity}/${entry.category}/http=${entry.httpStatusCode ?? 'none'}/host=${entry.endpointHost ?? 'none'}',
                      )
                      .join(', '),
                ),
              _row(
                'Model-selected tools',
                controller.realTurnTrace!.toolInvocations.isEmpty
                    ? 'none'
                    : controller.realTurnTrace!.toolInvocations
                          .map((entry) => entry.internalTool)
                          .join(', '),
              ),
              for (final entry in controller.realTurnTrace!.toolInvocations)
                _row(
                  'Tool audit ${entry.internalTool}',
                  'provider=${entry.provider}, model=${entry.effectiveModel}, '
                      'invocation=${entry.invocationId}, '
                      'schema=${entry.schemaValidationPassed ? 'pass' : 'fail'}, '
                      'permission=${entry.permissionDecision}, '
                      'typed=${entry.typedExecutionPassed ? 'pass' : 'fail'}, '
                      'structured=${entry.structuredResultReturned}, '
                      'outcome=${entry.outcome}, '
                      'duration=${entry.duration.inMilliseconds}ms',
                ),
              _row(
                'Real turn safety',
                'mutationCommands=${controller.realTurnTrace!.mutationCommandCount}, '
                    'arbitraryShell=${controller.realTurnTrace!.arbitraryShellUsed}, '
                    'rawSecretCategories=${controller.realTurnTrace!.rawSecretCategories.length}, '
                    'directApi=${controller.realTurnTrace!.directApiObserved}',
              ),
              if (controller.realTurnTrace!.finalModelResponse != null)
                _row(
                  'Final model response',
                  controller.realTurnTrace!.finalModelResponse!,
                ),
            ],
            if (controller.lastTool != null)
              _row('Last tool called', controller.lastTool!),
            if (controller.lastResult != null)
              _row('Last sanitized result', controller.lastResult!),
            if (controller.lastFailure != null)
              _row('Last typed failure', controller.lastFailure!),
          ],
        ),
      ),
    ),
  );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: .55,
          ),
        ),
        const SizedBox(height: 2),
        SelectableText(value, style: const TextStyle(fontSize: 12)),
      ],
    ),
  );
}

class _ConsoleHeader extends StatelessWidget {
  const _ConsoleHeader({
    required this.controller,
    required this.compact,
    required this.inspectorOpen,
    required this.onInspectorToggle,
  });

  final CodexAgentsController controller;
  final bool compact;
  final bool inspectorOpen;
  final VoidCallback onInspectorToggle;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final narrow = compact || constraints.maxWidth < 560;
      final iconOnly = constraints.maxWidth < 420;
      return SizedBox(
        height: narrow ? 52 : 64,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: narrow ? 10 : 14),
          child: Row(
            children: [
              Container(
                width: narrow ? 30 : 34,
                height: narrow ? 30 : 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.smart_toy_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    narrow ? 'Console' : 'Codex Console',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (!narrow) ...[
                Text(
                  controller.modelSelection.displayName,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              if (!iconOnly) ...[
                _StatusPill(ready: controller.readiness.canRun),
                const SizedBox(width: 4),
              ],
              if (iconOnly)
                IconButton(
                  tooltip: 'Runtime details',
                  onPressed: onInspectorToggle,
                  icon: Icon(inspectorOpen ? Icons.close : Icons.tune_outlined),
                )
              else
                TextButton.icon(
                  onPressed: onInspectorToggle,
                  icon: Icon(
                    inspectorOpen ? Icons.close : Icons.tune_outlined,
                    size: 17,
                  ),
                  label: Text(
                    inspectorOpen ? 'Hide details' : 'Runtime details',
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _RunStatusStrip extends StatelessWidget {
  const _RunStatusStrip({required this.controller});
  final CodexAgentsController controller;

  @override
  Widget build(BuildContext context) {
    final checks = <(String, String, bool)>[
      ('INSTALLATION', controller.installation.name, true),
      (
        'AUTHENTICATION',
        controller.authentication.name,
        controller.authentication == AgentAuthenticationStatus.authenticated,
      ),
      (
        'RUNTIME',
        controller.readiness.canRun ? 'ready' : 'blocked',
        controller.readiness.canRun,
      ),
      (
        'CONNECTION',
        switch (controller.connectionTestSucceeded) {
          true => 'passed',
          false => 'failed',
          null => 'not run',
        },
        controller.connectionTestSucceeded == true,
      ),
      ('SESSION', controller.lifecycle, controller.simpleTurnSucceeded),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 620;
        final width = narrow
            ? (constraints.maxWidth - 6) / 2
            : (constraints.maxWidth - 24) / 5;
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final check in checks)
              SizedBox(
                width: width,
                child: _ConsoleMetric(
                  label: check.$1,
                  value: check.$2,
                  positive: check.$3,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ConsoleMetric extends StatelessWidget {
  const _ConsoleMetric({
    required this.label,
    required this.value,
    required this.positive,
  });
  final String label;
  final String value;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final accent = positive ? const Color(0xFF36C58A) : const Color(0xFFE5A348);
    final divider =
        Theme.of(context).dividerTheme.color ??
        Theme.of(context).colorScheme.outlineVariant;
    return Container(
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: .28),
        border: Border(
          left: BorderSide(color: accent, width: 2),
          top: BorderSide(color: divider),
          right: BorderSide(color: divider),
          bottom: BorderSide(color: divider),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: .65,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: accent),
          ),
        ],
      ),
    );
  }
}

class _PermissionLedger extends StatelessWidget {
  const _PermissionLedger();

  @override
  Widget build(BuildContext context) {
    final divider =
        Theme.of(context).dividerTheme.color ??
        Theme.of(context).colorScheme.outlineVariant;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: .2),
        border: Border.all(color: divider),
      ),
      child: const Padding(
        padding: EdgeInsets.all(10),
        child: Wrap(
          spacing: 14,
          runSpacing: 7,
          children: [
            _LedgerItem(icon: Icons.shield_outlined, text: 'Read-only sandbox'),
            _LedgerItem(icon: Icons.key_outlined, text: 'No API key'),
            _LedgerItem(
              icon: Icons.settings_ethernet,
              text: '2 permitted tools',
            ),
            _LedgerItem(icon: Icons.public_off, text: 'Official service only'),
          ],
        ),
      ),
    );
  }
}

class _LedgerItem extends StatelessWidget {
  const _LedgerItem({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        size: 15,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      const SizedBox(width: 6),
      Text(text, style: Theme.of(context).textTheme.labelSmall),
    ],
  );
}

class _AuditTimeline extends StatelessWidget {
  const _AuditTimeline({required this.controller});
  final CodexAgentsController controller;

  @override
  Widget build(BuildContext context) => _ConsolePane(
    title: 'Audit timeline',
    subtitle: controller.audit.isEmpty
        ? 'No activity recorded for this workspace'
        : '${controller.audit.length} verified events',
    trailing: const Icon(Icons.history_outlined, size: 18),
    child: controller.audit.isEmpty
        ? const DevRouteEmptyState(
            icon: Icons.history_outlined,
            title: 'No activity yet',
            message:
                'Run a connection test to create the first auditable event.',
          )
        : ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: controller.audit.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 15,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectableText(
                      controller.audit[index],
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            ),
          ),
  );
}

class _ConsolePane extends StatelessWidget {
  const _ConsolePane({
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final Widget child;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(
        color:
            Theme.of(context).dividerTheme.color ??
            Theme.of(context).colorScheme.outlineVariant,
      ),
      borderRadius: BorderRadius.circular(3),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DevRoutePanelHeader(
          title: title,
          subtitle: subtitle,
          trailing: trailing,
        ),
        const Divider(height: 1),
        Expanded(child: child),
      ],
    ),
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.ready});
  final bool ready;
  @override
  Widget build(BuildContext context) => Container(
    height: 28,
    padding: const EdgeInsets.symmetric(horizontal: 9),
    decoration: BoxDecoration(
      border: Border.all(
        color:
            Theme.of(context).dividerTheme.color ??
            Theme.of(context).colorScheme.outlineVariant,
      ),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.circle,
          size: 7,
          color: ready ? const Color(0xFF36C58A) : const Color(0xFFE5A348),
        ),
        const SizedBox(width: 6),
        Text(
          ready ? 'Ready' : 'Sign-in required',
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ],
    ),
  );
}
