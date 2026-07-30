import 'package:flutter/material.dart';

import '../../../core/agent_control/domain/agent_models.dart';
import '../../../core/presentation/devroute_ui.dart';
import '../../../core/theme/app_theme.dart';
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
    builder: (context, _) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DevRouteSectionHeader(
          title: 'AI Agents',
          subtitle:
              'Use locally installed agent clients through restricted DevRoute tools.',
          actions: [
            DevRouteStatusBadge(
              controller.readiness.canRun ? 'Runtime ready' : 'Setup required',
              tone: controller.readiness.canRun
                  ? DevRouteStatusTone.success
                  : DevRouteStatusTone.warning,
            ),
          ],
        ),
        const SizedBox(height: DevRouteSpacing.md),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final providers = _providers();
              final details = _codexDetails(context);
              if (constraints.maxWidth < 820) {
                return ListView(
                  children: [
                    SizedBox(height: 164, child: providers),
                    const SizedBox(height: DevRouteSpacing.sm),
                    SizedBox(height: 980, child: details),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(width: 216, child: providers),
                  const SizedBox(width: DevRouteSpacing.sm),
                  Expanded(child: details),
                ],
              );
            },
          ),
        ),
      ],
    ),
  );

  Widget _providers() => DevRoutePanel(
    padding: EdgeInsets.zero,
    header: const DevRoutePanelHeader(title: 'Providers'),
    child: ListView(
      children: const [
        _ProviderTile(
          icon: Icons.terminal,
          name: 'Codex',
          subtitle: 'Official local client',
          selected: true,
        ),
        _ProviderTile(
          icon: Icons.code,
          name: 'Claude Code',
          subtitle: 'Coming later',
        ),
        _ProviderTile(
          icon: Icons.auto_awesome_outlined,
          name: 'Google client',
          subtitle: 'Verification required',
        ),
      ],
    ),
  );

  Widget _codexDetails(BuildContext context) => DevRoutePanel(
    padding: EdgeInsets.zero,
    header: DevRoutePanelHeader(
      title: 'Codex',
      subtitle: 'Official CLI · isolated subscription profile',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DevRouteStatusBadge(
            controller.lifecycle,
            tone: _lifecycleTone(controller.lifecycle),
          ),
          const SizedBox(width: DevRouteSpacing.sm),
          IconButton(
            tooltip: 'Refresh Codex status',
            onPressed: controller.refresh,
            icon: const Icon(Icons.refresh, size: 18),
          ),
        ],
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _statusGrid(),
        const SizedBox(height: DevRouteSpacing.sm),
        DevRouteToolbar(
          padding: const EdgeInsets.symmetric(
            horizontal: DevRouteSpacing.sm,
            vertical: 6,
          ),
          children: [
            DevRouteToolbarButton(
              label: 'Detect Codex',
              icon: Icons.radar,
              onPressed: controller.refresh,
            ),
            DevRouteToolbarButton(
              label: controller.signInActive
                  ? 'Sign-in active'
                  : 'Open official sign-in',
              icon: Icons.login,
              onPressed: controller.signInActive
                  ? null
                  : controller.openOfficialSignIn,
            ),
            DevRouteToolbarButton(
              label: 'Run connection test',
              icon: Icons.play_arrow,
              primary: true,
              onPressed: controller.readiness.canRun
                  ? () => controller.runConnectionTest(workspaceId)
                  : null,
            ),
            DevRouteToolbarButton(
              label: 'Cancel active run',
              icon: Icons.stop_circle_outlined,
              onPressed: _hasActiveOperation ? controller.cancel : null,
            ),
          ],
        ),
        const SizedBox(height: DevRouteSpacing.sm),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_needsAuthentication) ...[
                  _authentication(),
                  const SizedBox(height: DevRouteSpacing.sm),
                ],
                SizedBox(height: 150, child: _tools()),
                const SizedBox(height: DevRouteSpacing.sm),
                SizedBox(height: 210, child: _runOutput()),
                const SizedBox(height: DevRouteSpacing.sm),
                SizedBox(height: 190, child: _audit()),
                const SizedBox(height: DevRouteSpacing.sm),
                _diagnostics(),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  bool get _needsAuthentication =>
      controller.authentication != AgentAuthenticationStatus.authenticated ||
      controller.authenticationInstructions != null ||
      controller.verificationUrl != null ||
      controller.deviceCode != null;

  bool get _hasActiveOperation =>
      controller.signInActive ||
      !const {
        'idle',
        'ready',
        'completed',
        'failed',
        'cancelled',
      }.contains(controller.lifecycle);

  Widget _statusGrid() => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth < 760
          ? (constraints.maxWidth - 8) / 2
          : (constraints.maxWidth - 18) / 4;
      final items = <(String, String, DevRouteStatusTone)>[
        (
          'Installation status',
          controller.installation.name,
          controller.installation == AgentInstallationStatus.installed
              ? DevRouteStatusTone.success
              : DevRouteStatusTone.warning,
        ),
        (
          'Isolated profile status',
          controller.readiness.isolatedProfileReady ? 'ready' : 'not ready',
          controller.readiness.isolatedProfileReady
              ? DevRouteStatusTone.success
              : DevRouteStatusTone.error,
        ),
        (
          'ChatGPT authentication status',
          controller.readiness.authentication.name,
          controller.readiness.authentication ==
                  AgentAuthenticationStatus.authenticated
              ? DevRouteStatusTone.success
              : DevRouteStatusTone.warning,
        ),
        (
          'Runtime readiness',
          controller.readiness.canRun ? 'ready' : 'blocked',
          controller.readiness.canRun
              ? DevRouteStatusTone.success
              : DevRouteStatusTone.warning,
        ),
        (
          'Isolated ChatGPT login status',
          controller.readiness.authentication ==
                  AgentAuthenticationStatus.authenticated
              ? 'authenticated'
              : 'isolated_login_required',
          controller.readiness.authentication ==
                  AgentAuthenticationStatus.authenticated
              ? DevRouteStatusTone.success
              : DevRouteStatusTone.warning,
        ),
        (
          'Third-party MCP servers',
          controller.readiness.mcpServerCount?.toString() ?? 'not checked',
          controller.readiness.mcpServerCount == 0
              ? DevRouteStatusTone.success
              : DevRouteStatusTone.warning,
        ),
        ('Sandbox', 'read-only', DevRouteStatusTone.info),
        ('API key', 'not used', DevRouteStatusTone.success),
        (
          'External network',
          'Codex official service only',
          DevRouteStatusTone.neutral,
        ),
      ];
      return Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final item in items)
            SizedBox(
              width: width,
              child: _StatusCell(label: item.$1, value: item.$2, tone: item.$3),
            ),
        ],
      );
    },
  );

  Widget _authentication() => DevRoutePanel(
    header: const DevRoutePanelHeader(
      title: 'Authentication',
      subtitle: 'Complete official ChatGPT device authorization when required.',
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (controller.authenticationInstructions != null) ...[
          const Text(
            'Authentication instructions',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          SelectableText(
            controller.authenticationInstructions!,
            style: const TextStyle(fontSize: 12, height: 1.35),
          ),
        ],
        if (controller.verificationUrl != null) ...[
          const SizedBox(height: DevRouteSpacing.sm),
          DevRouteCopyField(
            label: 'Verification URL',
            value: controller.verificationUrl!,
            copyLabel: 'Copy verification URL',
          ),
        ],
        if (controller.deviceCode != null) ...[
          const SizedBox(height: DevRouteSpacing.sm),
          DevRouteCopyField(
            label: 'Device code',
            value: controller.deviceCode!,
            monospace: true,
            copyLabel: 'Copy device code',
          ),
        ],
        const SizedBox(height: DevRouteSpacing.sm),
        DevRouteStatusBadge(
          controller.lifecycle,
          tone: _lifecycleTone(controller.lifecycle),
          icon: Icons.security,
        ),
      ],
    ),
  );

  Widget _tools() => DevRoutePanel(
    padding: EdgeInsets.zero,
    header: const DevRoutePanelHeader(
      title: 'Allowed tools',
      subtitle: 'The model cannot access services outside this explicit set.',
    ),
    child: const _ToolsTable(),
  );

  Widget _runOutput() => DevRoutePanel(
    header: DevRoutePanelHeader(
      title: 'Run output',
      subtitle: 'Sanitized application result',
      trailing: DevRouteStatusBadge(
        controller.lifecycle,
        tone: _lifecycleTone(controller.lifecycle),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: DevRouteSpacing.lg,
          runSpacing: DevRouteSpacing.xs,
          children: [
            Text('Lifecycle  ${controller.lifecycle}'),
            Text('Last tool  ${controller.lastTool ?? '—'}'),
            if (controller.lastFailure != null)
              Text(
                'Failure  ${controller.lastFailure}',
                style: const TextStyle(color: Colors.redAccent),
              ),
          ],
        ),
        const SizedBox(height: DevRouteSpacing.sm),
        Expanded(
          child: SingleChildScrollView(
            child: DevRouteCodeViewer(content: controller.lastResult),
          ),
        ),
      ],
    ),
  );

  Widget _audit() => DevRoutePanel(
    header: const DevRoutePanelHeader(
      title: 'Audit timeline',
      subtitle: 'Restricted run lifecycle and tool events',
    ),
    child: DevRouteAuditTimeline(entries: controller.audit),
  );

  Widget _diagnostics() => DecoratedBox(
    decoration: BoxDecoration(
      color: DevRouteColors.panel,
      border: Border.all(color: DevRouteColors.border),
      borderRadius: BorderRadius.circular(6),
    ),
    child: ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: DevRouteSpacing.md),
      title: const Text('Runtime diagnostics'),
      subtitle: const Text('MCP and typed readiness details'),
      childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      children: [
        _diagnosticRow(
          'Readiness failure',
          controller.readiness.effectiveFailureCategory,
        ),
        _diagnosticRow(
          'Detected MCP server names',
          controller.readiness.detectedMcpServerNames.isEmpty
              ? 'none'
              : controller.readiness.detectedMcpServerNames.join(', '),
        ),
        _diagnosticRow(
          'MCP startup notifications',
          controller.readiness.mcpStartupNotificationCount.toString(),
        ),
        _diagnosticRow('Tool bridge status', controller.bridgeStatus),
        _diagnosticRow(
          'Isolated ChatGPT login status',
          controller.readiness.authentication ==
                  AgentAuthenticationStatus.authenticated
              ? 'authenticated'
              : 'isolated_login_required',
        ),
        _diagnosticRow(
          'Third-party MCP servers',
          controller.readiness.mcpServerCount?.toString() ?? 'not checked',
        ),
      ],
    ),
  );

  Widget _diagnosticRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 210,
          child: Text(
            label,
            style: const TextStyle(color: DevRouteColors.secondaryText),
          ),
        ),
        Expanded(child: SelectableText(value)),
      ],
    ),
  );

  DevRouteStatusTone _lifecycleTone(String lifecycle) {
    if (const {'ready', 'completed', 'authenticated'}.contains(lifecycle)) {
      return DevRouteStatusTone.success;
    }
    if (const {'failed', 'error'}.contains(lifecycle)) {
      return DevRouteStatusTone.error;
    }
    if (const {
      'starting',
      'running',
      'awaiting_user_verification',
    }.contains(lifecycle)) {
      return DevRouteStatusTone.info;
    }
    return DevRouteStatusTone.neutral;
  }
}

class _ProviderTile extends StatelessWidget {
  const _ProviderTile({
    required this.icon,
    required this.name,
    required this.subtitle,
    this.selected = false,
  });

  final IconData icon;
  final String name;
  final String subtitle;
  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: selected ? DevRouteColors.hover : Colors.transparent,
      border: Border(
        left: BorderSide(
          color: selected ? DevRouteColors.accent : Colors.transparent,
          width: 3,
        ),
      ),
    ),
    child: ListTile(
      dense: true,
      leading: Icon(
        icon,
        size: 18,
        color: selected ? DevRouteColors.accent : DevRouteColors.secondaryText,
      ),
      title: Text(name),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
    ),
  );
}

class _StatusCell extends StatelessWidget {
  const _StatusCell({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final DevRouteStatusTone tone;

  @override
  Widget build(BuildContext context) => Container(
    height: 60,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: DevRouteColors.panelSecondary,
      border: Border.all(color: DevRouteColors.border),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: switch (tone) {
                  DevRouteStatusTone.success => DevRouteColors.success,
                  DevRouteStatusTone.warning => Colors.amberAccent,
                  DevRouteStatusTone.error => Colors.redAccent,
                  DevRouteStatusTone.info => Colors.lightBlueAccent,
                  DevRouteStatusTone.neutral => DevRouteColors.secondaryText,
                },
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _ToolsTable extends StatelessWidget {
  const _ToolsTable();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const _ToolRow(
        name: 'Tool',
        access: 'Access',
        risk: 'Risk',
        availability: 'Availability',
        header: true,
      ),
      const Divider(height: 1),
      const _ToolRow(
        name: 'app.capabilities',
        access: 'Read only',
        risk: 'Low',
        availability: 'Available',
      ),
      const Divider(height: 1),
      const _ToolRow(
        name: 'grpc.history.search',
        access: 'Sanitized read',
        risk: 'Low',
        availability: 'Available',
      ),
    ],
  );
}

class _ToolRow extends StatelessWidget {
  const _ToolRow({
    required this.name,
    required this.access,
    required this.risk,
    required this.availability,
    this.header = false,
  });

  final String name;
  final String access;
  final String risk;
  final String availability;
  final bool header;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Row(
      children: [
        _cell(name, flex: 3, mono: !header),
        _cell(access, flex: 2),
        _cell(risk),
        _cell(availability, flex: 2),
      ],
    ),
  );

  Widget _cell(String value, {int flex = 1, bool mono = false}) => Expanded(
    flex: flex,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Text(
        value,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: mono ? 'monospace' : null,
          fontSize: 12,
          fontWeight: header ? FontWeight.w600 : FontWeight.normal,
          color: header
              ? DevRouteColors.secondaryText
              : DevRouteColors.primaryText,
        ),
      ),
    ),
  );
}
