import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

class DevRoutePanel extends StatelessWidget {
  const DevRoutePanel({
    super.key,
    required this.child,
    this.header,
    this.padding = const EdgeInsets.all(DevRouteSpacing.md),
    this.backgroundColor = DevRouteColors.panel,
  });

  final Widget child;
  final Widget? header;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) => Material(
    color: backgroundColor,
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: DevRouteColors.border),
      borderRadius: BorderRadius.circular(6),
    ),
    clipBehavior: Clip.antiAlias,
    child: LayoutBuilder(
      builder: (context, constraints) => Column(
        mainAxisSize: constraints.hasBoundedHeight
            ? MainAxisSize.max
            : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?header,
          if (constraints.hasBoundedHeight)
            Expanded(
              child: Padding(padding: padding, child: child),
            )
          else
            Padding(padding: padding, child: child),
        ],
      ),
    ),
  );
}

class DevRoutePanelHeader extends StatelessWidget {
  const DevRoutePanelHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 42),
    padding: const EdgeInsets.symmetric(
      horizontal: DevRouteSpacing.md,
      vertical: DevRouteSpacing.sm,
    ),
    decoration: const BoxDecoration(
      color: DevRouteColors.panelSecondary,
      border: Border(bottom: BorderSide(color: DevRouteColors.border)),
      borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              if (subtitle != null)
                Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

enum DevRouteStatusTone { neutral, info, success, warning, error }

class DevRouteStatusBadge extends StatelessWidget {
  const DevRouteStatusBadge(
    this.label, {
    super.key,
    this.tone = DevRouteStatusTone.neutral,
    this.icon,
  });

  final String label;
  final DevRouteStatusTone tone;
  final IconData? icon;

  Color get _color => switch (tone) {
    DevRouteStatusTone.info => Colors.lightBlueAccent,
    DevRouteStatusTone.success => DevRouteColors.success,
    DevRouteStatusTone.warning => Colors.amberAccent,
    DevRouteStatusTone.error => Colors.redAccent,
    DevRouteStatusTone.neutral => DevRouteColors.secondaryText,
  };

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: _color.withValues(alpha: .11),
      border: Border.all(color: _color.withValues(alpha: .55)),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: _color),
          const SizedBox(width: 5),
        ],
        Text(
          label,
          style: TextStyle(
            color: _color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class DevRouteToolbar extends StatelessWidget {
  const DevRouteToolbar({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(DevRouteSpacing.sm),
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: const BoxDecoration(
      color: DevRouteColors.panel,
      border: Border(
        top: BorderSide(color: DevRouteColors.border),
        bottom: BorderSide(color: DevRouteColors.border),
      ),
    ),
    child: Wrap(
      spacing: DevRouteSpacing.sm,
      runSpacing: DevRouteSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    ),
  );
}

class DevRouteToolbarButton extends StatelessWidget {
  const DevRouteToolbarButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.primary = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) => primary
      ? FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 16),
          label: Text(label),
        )
      : OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 16),
          label: Text(label),
        );
}

class DevRouteTabs extends StatelessWidget {
  const DevRouteTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 38,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: tabs.length,
      separatorBuilder: (_, _) => const SizedBox(width: 2),
      itemBuilder: (context, index) => InkWell(
        onTap: () => onSelected(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: index == selectedIndex
                ? DevRouteColors.panelSecondary
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: index == selectedIndex
                    ? DevRouteColors.accent
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            tabs[index],
            style: TextStyle(
              fontSize: 12,
              color: index == selectedIndex
                  ? DevRouteColors.primaryText
                  : DevRouteColors.secondaryText,
            ),
          ),
        ),
      ),
    ),
  );
}

class DevRouteSplitView extends StatefulWidget {
  const DevRouteSplitView({
    super.key,
    required this.first,
    required this.second,
    this.initialRatio = .5,
    this.minFirst = 260,
    this.minSecond = 260,
  });

  final Widget first;
  final Widget second;
  final double initialRatio;
  final double minFirst;
  final double minSecond;

  @override
  State<DevRouteSplitView> createState() => _DevRouteSplitViewState();
}

class _DevRouteSplitViewState extends State<DevRouteSplitView> {
  late double _ratio = widget.initialRatio;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final available = constraints.maxWidth - 7;
      if (available < widget.minFirst + widget.minSecond) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: widget.first),
            Container(height: 7, color: DevRouteColors.background),
            Expanded(child: widget.second),
          ],
        );
      }
      final minRatio = (widget.minFirst / available).clamp(.18, .7);
      final maxRatio = (1 - widget.minSecond / available).clamp(.3, .82);
      final ratio = _ratio.clamp(minRatio, maxRatio);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: available * ratio, child: widget.first),
          MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (details) => setState(() {
                _ratio = (_ratio + details.delta.dx / available).clamp(
                  minRatio,
                  maxRatio,
                );
              }),
              child: Container(
                width: 7,
                color: DevRouteColors.background,
                alignment: Alignment.center,
                child: Container(width: 1, color: DevRouteColors.border),
              ),
            ),
          ),
          Expanded(child: widget.second),
        ],
      );
    },
  );
}

class DevRouteEmptyState extends StatelessWidget {
  const DevRouteEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.all(DevRouteSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 30, color: DevRouteColors.secondaryText),
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (action != null) ...[const SizedBox(height: 12), action!],
            ],
          ),
        ),
      ),
    ),
  );
}

class DevRouteCopyField extends StatelessWidget {
  const DevRouteCopyField({
    super.key,
    required this.label,
    required this.value,
    this.monospace = false,
    this.copyLabel,
  });

  final String label;
  final String value;
  final bool monospace;
  final String? copyLabel;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: TextFormField(
          key: ValueKey('$label-$value'),
          initialValue: value,
          readOnly: true,
          style: monospace ? const TextStyle(fontFamily: 'monospace') : null,
          decoration: InputDecoration(labelText: label, isDense: true),
        ),
      ),
      TextButton.icon(
        onPressed: () => Clipboard.setData(ClipboardData(text: value)),
        icon: const Icon(Icons.copy_outlined, size: 16),
        label: Text(copyLabel ?? 'Copy'),
      ),
    ],
  );
}

class DevRouteCodeViewer extends StatelessWidget {
  const DevRouteCodeViewer({
    super.key,
    required this.content,
    this.emptyMessage = 'No output yet.',
  });

  final String? content;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(DevRouteSpacing.md),
    decoration: BoxDecoration(
      color: DevRouteColors.sidebar,
      border: Border.all(color: DevRouteColors.border),
      borderRadius: BorderRadius.circular(4),
    ),
    child: SelectableText(
      content?.trim().isNotEmpty == true ? content! : emptyMessage,
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: 12,
        height: 1.45,
        color: content?.trim().isNotEmpty == true
            ? DevRouteColors.primaryText
            : DevRouteColors.secondaryText,
      ),
    ),
  );
}

class DevRouteAuditTimeline extends StatelessWidget {
  const DevRouteAuditTimeline({super.key, required this.entries});

  final List<String> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const DevRouteEmptyState(
        icon: Icons.timeline_outlined,
        title: 'No activity yet',
        message: 'Detection, sign-in, and run events will appear here.',
      );
    }
    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final failed =
            entry.toLowerCase().contains('fail') ||
            entry.toLowerCase().contains('error');
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                failed ? Icons.error_outline : Icons.check_circle_outline,
                size: 15,
                color: failed ? Colors.redAccent : DevRouteColors.success,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SelectableText(
                  entry,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DevRouteSectionHeader extends StatelessWidget {
  const DevRouteSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            if (subtitle != null)
              Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      ...actions,
    ],
  );
}
