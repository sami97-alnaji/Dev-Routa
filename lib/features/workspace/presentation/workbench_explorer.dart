import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/models/api_models.dart';
import '../../requests/presentation/request_workflow_cubit.dart';
import 'workspace_cubit.dart';

/// The persistent, data-backed navigation surface for the desktop workbench.
///
/// It deliberately exposes the user's real workspace records instead of a
/// static list of destination names. This keeps collections, open requests,
/// environments, and history one interaction away from the active editor.
class WorkbenchExplorer extends StatefulWidget {
  const WorkbenchExplorer({
    super.key,
    required this.onClose,
    required this.onOpenRequests,
    required this.onOpenHistory,
  });

  final VoidCallback onClose;
  final VoidCallback onOpenRequests;
  final VoidCallback onOpenHistory;

  @override
  State<WorkbenchExplorer> createState() => _WorkbenchExplorerState();
}

class _WorkbenchExplorerState extends State<WorkbenchExplorer> {
  final _filterController = TextEditingController();
  String _filter = '';

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  bool _matches(String value) =>
      _filter.isEmpty || value.toLowerCase().contains(_filter.toLowerCase());

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<WorkspaceCubit, WorkspaceState>(
    builder: (context, state) {
      final workspace = context.read<WorkspaceCubit>();
      final colors = Theme.of(context).colorScheme;
      final collections = state.collections
          .where((item) => _matches(item.name))
          .toList();
      final requests = state.savedRequests
          .where((item) => _matches(item.name) || _matches(item.url))
          .toList();
      final environments = state.environments
          .where((item) => _matches(item.name))
          .toList();
      return ColoredBox(
        color: colors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 40,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 4),
                child: Row(
                  children: [
                    const Icon(Icons.folder_open_outlined, size: 17),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Explorer',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Hide explorer (Ctrl+B)',
                      onPressed: widget.onClose,
                      icon: const Icon(Icons.vertical_split_outlined, size: 18),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
              child: TextField(
                key: const Key('workbench-explorer-filter'),
                controller: _filterController,
                onChanged: (value) => setState(() => _filter = value.trim()),
                decoration: const InputDecoration(
                  hintText: 'Filter workspace',
                  prefixIcon: Icon(Icons.search, size: 17),
                ),
              ),
            ),
            Expanded(
              child: state.loading
                  ? const Center(
                      child: SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.only(bottom: 8),
                      children: [
                        _ExplorerSectionHeader(
                          label: 'Collections',
                          count: collections.length,
                        ),
                        if (collections.isEmpty)
                          const _ExplorerHint('No collections yet'),
                        for (final collection in collections) ...[
                          _ExplorerRow(
                            icon: collection.id == state.selectedCollectionId
                                ? Icons.folder_open_outlined
                                : Icons.folder_outlined,
                            label: collection.name,
                            selected:
                                collection.id == state.selectedCollectionId,
                            onTap: () async {
                              await workspace.selectCollection(collection.id);
                              widget.onOpenRequests();
                            },
                          ),
                          if (collection.id == state.selectedCollectionId)
                            ..._collectionContents(state, requests),
                        ],
                        _ExplorerSectionHeader(
                          label: 'Requests',
                          count: requests.length,
                        ),
                        if (state.selectedCollectionId == null &&
                            requests.isEmpty)
                          const _ExplorerHint(
                            'Select a collection to browse requests',
                          ),
                        if (state.selectedCollectionId == null)
                          for (final request in requests)
                            _RequestRow(
                              request: request,
                              onTap: () {
                                context
                                    .read<RequestWorkflowCubit>()
                                    .openRequest(request);
                                widget.onOpenRequests();
                              },
                            ),
                        _ExplorerSectionHeader(
                          label: 'Environments',
                          count: environments.length,
                        ),
                        if (environments.isEmpty)
                          const _ExplorerHint('No environment selected'),
                        for (final environment in environments)
                          _ExplorerRow(
                            icon: Icons.circle,
                            iconSize: 8,
                            iconColor:
                                environment.kind == EnvironmentKind.production
                                ? const Color(0xFFE5A348)
                                : colors.primary,
                            label: environment.name,
                            selected:
                                environment.id == state.selectedEnvironmentId,
                            trailing:
                                environment.id == state.selectedEnvironmentId
                                ? const Icon(Icons.check, size: 15)
                                : null,
                            onTap: () =>
                                workspace.setEnvironment(environment.id),
                          ),
                        _ExplorerSectionHeader(label: 'History'),
                        _ExplorerRow(
                          icon: Icons.history_outlined,
                          label: 'Recent requests',
                          trailing: state.history.isEmpty
                              ? null
                              : Text(
                                  '${state.history.length}',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                          onTap: widget.onOpenHistory,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      );
    },
  );

  List<Widget> _collectionContents(
    WorkspaceState state,
    List<ApiRequestModel> requests,
  ) {
    final children = <Widget>[];
    for (final folder in state.folders.where(
      (item) => item.parentFolderId == null && _matches(item.name),
    )) {
      children.add(
        _ExplorerRow(
          indent: 1,
          icon: Icons.folder_outlined,
          label: folder.name,
          subdued: true,
        ),
      );
      for (final request in requests.where(
        (item) => item.folderId == folder.id,
      )) {
        children.add(
          _RequestRow(
            request: request,
            indent: 2,
            onTap: () {
              context.read<RequestWorkflowCubit>().openRequest(request);
              widget.onOpenRequests();
            },
          ),
        );
      }
    }
    for (final request in requests.where((item) => item.folderId == null)) {
      children.add(
        _RequestRow(
          request: request,
          indent: 1,
          onTap: () {
            context.read<RequestWorkflowCubit>().openRequest(request);
            widget.onOpenRequests();
          },
        ),
      );
    }
    if (children.isEmpty) {
      children.add(const _ExplorerHint('No saved requests'));
    }
    return children;
  }
}

class _ExplorerSectionHeader extends StatelessWidget {
  const _ExplorerSectionHeader({required this.label, this.count});

  final String label;
  final int? count;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 14, 10, 4),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: .7,
            ),
          ),
        ),
        if (count != null)
          Text(
            '$count',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    ),
  );
}

class _ExplorerHint extends StatelessWidget {
  const _ExplorerHint(this.message);

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
    child: Text(
      message,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

class _ExplorerRow extends StatelessWidget {
  const _ExplorerRow({
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
    this.selected = false,
    this.subdued = false,
    this.indent = 0,
    this.iconSize = 16,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool selected;
  final bool subdued;
  final int indent;
  final double iconSize;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = selected
        ? colors.onSurface
        : subdued
        ? colors.onSurfaceVariant
        : colors.onSurface;
    return Padding(
      padding: EdgeInsets.only(left: 4 + indent * 12, right: 4, bottom: 1),
      child: Material(
        color: selected
            ? colors.primary.withValues(alpha: .13)
            : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 30,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Icon(icon, size: iconSize, color: iconColor ?? foreground),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: foreground,
                        fontWeight: selected ? FontWeight.w700 : null,
                      ),
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RequestRow extends StatelessWidget {
  const _RequestRow({
    required this.request,
    required this.onTap,
    this.indent = 0,
  });

  final ApiRequestModel request;
  final VoidCallback onTap;
  final int indent;

  @override
  Widget build(BuildContext context) => _ExplorerRow(
    indent: indent,
    icon: Icons.chevron_right,
    iconSize: 15,
    label: '${request.method.name.toUpperCase()}  ${request.name}',
    onTap: onTap,
  );
}
