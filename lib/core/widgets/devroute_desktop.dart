import 'package:flutter/material.dart';

/// A compact bordered workbench region. It deliberately avoids Card padding,
/// elevation, and mobile-sized headers.
class DevRoutePane extends StatelessWidget {
  const DevRoutePane({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.trailing,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerTheme.color!),
        // Desktop panes meet at thin dividers.  They are not floating mobile
        // cards, so keep the corner treatment deliberately restrained.
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            DevRoutePanelHeader(
              title: title!,
              subtitle: subtitle,
              trailing: trailing,
            ),
          if (title != null) const Divider(height: 1),
          Expanded(
            child: Padding(padding: padding, child: child),
          ),
        ],
      ),
    );
  }
}

/// The shared context bar for a desktop work surface.
///
/// It keeps identity, scope, and actions in one compact row rather than
/// recreating a large mobile-style page title in every destination.
class DevRoutePageBar extends StatelessWidget {
  const DevRoutePageBar({
    super.key,
    required this.eyebrow,
    required this.title,
    this.detail,
    this.trailing,
    this.compact = false,
  });

  final String eyebrow;
  final Widget title;
  final String? detail;
  final Widget? trailing;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: compact ? 42 : 56,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: compact
                    ? [
                        DefaultTextStyle.merge(
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                          child: title,
                        ),
                      ]
                    : [
                        Text(
                          eyebrow.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                        ),
                        const SizedBox(height: 2),
                        DefaultTextStyle.merge(
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                          child: title,
                        ),
                      ],
              ),
            ),
            if (!compact)
              if (detail case final nonNullDetail?) ...[
                Flexible(
                  child: Text(
                    nonNullDetail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// A compact table/list header used inside a workbench pane.
class DevRouteListHeader extends StatelessWidget {
  const DevRouteListHeader({
    super.key,
    required this.title,
    this.count,
    this.trailing,
  });

  final String title;
  final int? count;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 38,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          if (count case final nonNullCount?) ...[
            const SizedBox(width: 6),
            Text(
              '$nonNullCount',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const Spacer(),
          ?trailing,
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
  Widget build(BuildContext context) {
    final trailingWidget = trailing;
    return SizedBox(
      height: subtitle == null ? 36 : 54,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.labelLarge),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            // ignore: use_null_aware_elements
            if (trailingWidget != null) trailingWidget,
          ],
        ),
      ),
    );
  }
}

class DevRouteTabStrip extends StatelessWidget {
  const DevRouteTabStrip({
    super.key,
    required this.tabs,
    required this.activeIndex,
    required this.onSelected,
    this.onClose,
    this.onNew,
  });
  final List<DevRouteWorkbenchTab> tabs;
  final int activeIndex;
  final ValueChanged<int> onSelected;
  final ValueChanged<int>? onClose;
  final VoidCallback? onNew;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 34,
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 2),
              itemCount: tabs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 2),
              itemBuilder: (context, index) {
                final tab = tabs[index];
                final selected = index == activeIndex;
                return Material(
                  color: selected ? colors.surface : Colors.transparent,
                  child: InkWell(
                    onTap: () => onSelected(index),
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 120),
                      padding: const EdgeInsets.only(left: 9, right: 4),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: selected
                                ? colors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                          left: BorderSide(color: colors.outlineVariant),
                          right: BorderSide(color: colors.outlineVariant),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (tab.dirty)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(
                                Icons.circle,
                                size: 6,
                                color: colors.primary,
                              ),
                            ),
                          Flexible(
                            child: Text(
                              tab.label,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                          if (onClose != null)
                            IconButton(
                              tooltip: 'Close tab',
                              onPressed: () => onClose!(index),
                              icon: const Icon(Icons.close, size: 15),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (onNew != null)
            IconButton(
              tooltip: 'New tab',
              onPressed: onNew,
              icon: const Icon(Icons.add, size: 18),
            ),
        ],
      ),
    );
  }
}

class DevRouteWorkbenchTab {
  const DevRouteWorkbenchTab({required this.label, this.dirty = false});
  final String label;
  final bool dirty;
}

class DevRouteSplitter extends StatelessWidget {
  const DevRouteSplitter({
    super.key,
    required this.axis,
    required this.onDrag,
    this.onReset,
  });
  final Axis axis;
  final ValueChanged<double> onDrag;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: axis == Axis.horizontal
        ? SystemMouseCursors.resizeColumn
        : SystemMouseCursors.resizeRow,
    child: GestureDetector(
      behavior: HitTestBehavior.translucent,
      onDoubleTap: onReset,
      onHorizontalDragUpdate: axis == Axis.horizontal
          ? (details) => onDrag(details.delta.dx)
          : null,
      onVerticalDragUpdate: axis == Axis.vertical
          ? (details) => onDrag(details.delta.dy)
          : null,
      child: SizedBox(
        width: axis == Axis.horizontal ? 6 : double.infinity,
        height: axis == Axis.vertical ? 6 : double.infinity,
        child: Center(
          child: Container(
            width: axis == Axis.horizontal ? 1 : 26,
            height: axis == Axis.vertical ? 1 : 26,
            color: Theme.of(context).dividerTheme.color,
          ),
        ),
      ),
    ),
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
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 26,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.labelLarge),
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
  );
}
