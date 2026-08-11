import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/diagnostics/developer_diagnostics.dart';
import '../../../core/diagnostics/history_comparison_service.dart';
import '../../../core/rest/request_safety_service.dart';
import '../../../core/rest/safe_export_service.dart';
import '../../../core/rest/token_candidate_service.dart';
import '../../../core/rest/variable_resolution_service.dart';
import '../../../core/security/secret_masker.dart';
import '../../../core/storage/local_workspace_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/devroute_desktop.dart';
import '../../../features/realtime/presentation/realtime_screen.dart';
import '../../../features/graphql/presentation/graphql_screen.dart';
import '../../../features/graphql/data/graphql_repository.dart';
import '../../../features/graphql/data/graphql_introspection_service.dart';
import '../../../features/graphql/application/graphql_schema_cubit.dart';
import '../../../features/graphql/presentation/graphql_workflow_cubit.dart';
import '../../../features/graphql/application/graphql_execution_service.dart';
import '../../../features/graphql/application/graphql_subscription_service.dart';
import '../../../features/ai_assistant/application/codex_agents_controller.dart';
import '../../../features/ai_assistant/presentation/ai_agents_screen.dart';
import '../../../features/grpc/presentation/grpc_screen.dart';
import '../../../shared/models/api_models.dart';
import '../../requests/presentation/request_workflow_cubit.dart';
import 'workspace_cubit.dart';
import 'workbench_explorer.dart';
import 'workbench_layout_preferences.dart';

class _ShellDestination {
  const _ShellDestination({
    required this.label,
    required this.compactLabel,
    required this.description,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final String compactLabel;
  final String description;
  final IconData icon;
  final IconData selectedIcon;
}

const _shellDestinations = <_ShellDestination>[
  _ShellDestination(
    label: 'Workspace',
    compactLabel: 'Workspace',
    description: 'Organise collections, requests, and environments.',
    icon: Icons.grid_view_outlined,
    selectedIcon: Icons.grid_view_rounded,
  ),
  _ShellDestination(
    label: 'Requests',
    compactLabel: 'Request',
    description: 'Compose, send, and inspect HTTP requests.',
    icon: Icons.send_outlined,
    selectedIcon: Icons.send_rounded,
  ),
  _ShellDestination(
    label: 'History',
    compactLabel: 'History',
    description: 'Review previous requests and compare outcomes.',
    icon: Icons.history_outlined,
    selectedIcon: Icons.history_rounded,
  ),
  _ShellDestination(
    label: 'Environments',
    compactLabel: 'Environment',
    description: 'Keep variables and secure references in one place.',
    icon: Icons.tune_outlined,
    selectedIcon: Icons.tune_rounded,
  ),
  _ShellDestination(
    label: 'Settings',
    compactLabel: 'Settings',
    description: 'Control retention, privacy, and workspace behaviour.',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings_rounded,
  ),
  _ShellDestination(
    label: 'Realtime',
    compactLabel: 'Live',
    description: 'Observe WebSocket, SSE, and streaming connections.',
    icon: Icons.sensors_outlined,
    selectedIcon: Icons.sensors_rounded,
  ),
  _ShellDestination(
    label: 'GraphQL',
    compactLabel: 'GraphQL',
    description: 'Explore schemas and operate GraphQL services.',
    icon: Icons.account_tree_outlined,
    selectedIcon: Icons.account_tree_rounded,
  ),
  _ShellDestination(
    label: 'gRPC',
    compactLabel: 'gRPC',
    description: 'Inspect descriptors, invoke services, and review history.',
    icon: Icons.swap_calls_outlined,
    selectedIcon: Icons.swap_calls_rounded,
  ),
  _ShellDestination(
    label: 'AI Agents',
    compactLabel: 'Agents',
    description:
        'Connect to official subscription agents and inspect readiness.',
    icon: Icons.smart_toy_outlined,
    selectedIcon: Icons.smart_toy_rounded,
  ),
];

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialSection = 0});
  final int initialSection;
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _selected = widget.initialSection;
  final _urlController = TextEditingController();
  String? _historyMethod;
  int? _historyMinimumStatus;
  final Set<String> _restComparison = <String>{};
  String _responseSearch = '';
  bool _rawResponse = false;
  GraphqlWorkflowCubit? _graphqlWorkflow;
  String? _graphqlWorkspaceId;
  StreamSubscription<GraphqlWorkflowState>? _graphqlStateSubscription;
  bool _allowExit = false;
  bool _exitDialogOpen = false;
  bool _sidebarCollapsed = false;
  double _sidebarWidth = 252;
  double _requestEditorHeight = 292;

  @override
  void initState() {
    super.initState();
    unawaited(_restoreWorkbenchLayout());
  }

  @override
  void dispose() {
    _urlController.dispose();
    _graphqlStateSubscription?.cancel();
    _graphqlWorkflow?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final rail = width >= 720;
    final explorerAvailable = width >= 960;
    final explorerVisible = explorerAvailable && !_sidebarCollapsed;
    final requestState = context.watch<RequestWorkflowCubit>().state;
    final graphqlDirty = _graphqlWorkflow?.state.hasAnyDirty ?? false;
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyK, control: true):
            _openCommandPalette,
        const SingleActivator(LogicalKeyboardKey.keyN, control: true):
            _newRequest,
        const SingleActivator(LogicalKeyboardKey.keyB, control: true):
            _toggleSidebar,
      },
      child: Focus(
        autofocus: true,
        child: PopScope(
          canPop: _allowExit || (!requestState.hasAnyDirty && !graphqlDirty),
          onPopInvokedWithResult: (didPop, _) async {
            if (!didPop && (requestState.hasAnyDirty || graphqlDirty)) {
              await _guardExit(
                restDirty: requestState.hasAnyDirty,
                graphqlDirty: graphqlDirty,
              );
            }
          },
          child: Scaffold(
            appBar: !rail
                ? AppBar(
                    title: Text(_shellDestinations[_selected].label),
                    actions: [
                      IconButton(
                        tooltip: 'New request',
                        onPressed: _newRequest,
                        icon: const Icon(Icons.add_rounded),
                      ),
                      const SizedBox(width: 4),
                    ],
                  )
                : null,
            body: rail
                ? Row(
                    children: [
                      _ActivityRail(selected: _selected, onSelect: _select),
                      const VerticalDivider(width: 1),
                      if (explorerVisible) ...[
                        SizedBox(
                          width: _sidebarWidth,
                          child: WorkbenchExplorer(
                            onClose: _toggleSidebar,
                            onOpenRequests: () => _select(1),
                            onOpenHistory: () => _select(2),
                          ),
                        ),
                        DevRouteSplitter(
                          axis: Axis.horizontal,
                          onDrag: _changeSidebarWidth,
                          onReset: _resetSidebarWidth,
                        ),
                      ],
                      Expanded(child: _mainContent(rail: true)),
                    ],
                  )
                : _mainContent(rail: false),
            bottomNavigationBar: !rail ? _compactNavigation() : null,
          ),
        ),
      ),
    );
  }

  void _select(int value) => setState(() => _selected = value);

  void _toggleSidebar() {
    setState(() => _sidebarCollapsed = !_sidebarCollapsed);
    _persistWorkbenchLayout();
  }

  Future<void> _restoreWorkbenchLayout() async {
    final layout = await WorkbenchLayoutPreferences.load();
    if (!mounted) return;
    setState(() {
      _sidebarWidth = layout.sidebarWidth;
      _sidebarCollapsed = layout.sidebarCollapsed;
      _requestEditorHeight = layout.requestEditorHeight;
    });
  }

  void _persistWorkbenchLayout() => unawaited(
    WorkbenchLayoutPreferences.save(
      WorkbenchLayoutSnapshot(
        sidebarWidth: _sidebarWidth,
        sidebarCollapsed: _sidebarCollapsed,
        requestEditorHeight: _requestEditorHeight,
      ),
    ),
  );

  void _changeSidebarWidth(double delta) {
    setState(() => _sidebarWidth = (_sidebarWidth + delta).clamp(180, 420));
    _persistWorkbenchLayout();
  }

  void _resetSidebarWidth() {
    setState(() => _sidebarWidth = 252);
    _persistWorkbenchLayout();
  }

  void _changeRequestEditorHeight(double delta) {
    setState(() {
      _requestEditorHeight = (_requestEditorHeight + delta).clamp(180, 520);
    });
    _persistWorkbenchLayout();
  }

  void _resetRequestEditorHeight() {
    setState(() => _requestEditorHeight = 292);
    _persistWorkbenchLayout();
  }

  void _newRequest() {
    context.read<RequestWorkflowCubit>().newRequest(
      collectionId: context.read<WorkspaceCubit>().state.selectedCollectionId,
    );
    _select(1);
  }

  Widget _mainContent({required bool rail}) {
    final width = MediaQuery.sizeOf(context).width;
    // On desktop, panes own their padding and meet at dividers like a real
    // workbench.  A global floating margin was making every destination read
    // as a separate Flutter card.
    final padding = rail
        ? EdgeInsets.zero
        : width >= 600
        ? const EdgeInsets.fromLTRB(12, 10, 12, 12)
        : const EdgeInsets.fromLTRB(8, 8, 8, 8);
    return Column(
      children: [
        if (rail)
          _WorkspaceToolbar(
            destination: _shellDestinations[_selected],
            onNewRequest: _newRequest,
            onCommandPalette: _openCommandPalette,
            sidebarAvailable: width >= 960,
            sidebarVisible: width >= 960 && !_sidebarCollapsed,
            onToggleSidebar: _toggleSidebar,
          ),
        Expanded(
          child: SafeArea(
            top: !rail,
            child: Padding(padding: padding, child: _content()),
          ),
        ),
      ],
    );
  }

  Future<void> _openCommandPalette() async {
    final commands = <(String, IconData, VoidCallback)>[
      ('New REST request', Icons.add_rounded, _newRequest),
      for (var i = 0; i < _shellDestinations.length; i++)
        (
          'Open ${_shellDestinations[i].label}',
          _shellDestinations[i].icon,
          () => _select(i),
        ),
    ];
    final filter = TextEditingController();
    var query = '';
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) {
            final words = query
                .toLowerCase()
                .split(RegExp(r'\s+'))
                .where((word) => word.isNotEmpty);
            final visible = commands
                .where(
                  (command) => words.every(
                    (word) => command.$1.toLowerCase().contains(word),
                  ),
                )
                .toList();
            void runFirst() {
              if (visible.isEmpty) return;
              Navigator.pop(dialogContext);
              visible.first.$3();
            }

            return Dialog(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        key: const Key('command-palette-filter'),
                        controller: filter,
                        autofocus: true,
                        textInputAction: TextInputAction.go,
                        onChanged: (value) =>
                            setDialogState(() => query = value.trim()),
                        onSubmitted: (_) => runFirst(),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search_rounded),
                          hintText: 'Search commands…',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
                        child: Text(
                          query.isEmpty
                              ? 'QUICK ACTIONS'
                              : '${visible.length} MATCHING COMMANDS',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 360),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: visible.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 2),
                          itemBuilder: (context, index) {
                            final command = visible[index];
                            return ListTile(
                              dense: true,
                              leading: Icon(command.$2, size: 18),
                              title: Text(command.$1),
                              trailing: index == 0
                                  ? Text(
                                      '↵',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelSmall,
                                    )
                                  : null,
                              onTap: () {
                                Navigator.pop(dialogContext);
                                command.$3();
                              },
                            );
                          },
                        ),
                      ),
                      if (visible.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'No command matches this search.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    } finally {
      filter.dispose();
    }
  }

  Widget _compactNavigation() => NavigationBar(
    selectedIndex: switch (_selected) {
      0 => 0,
      1 => 1,
      5 => 2,
      6 => 3,
      _ => 4,
    },
    onDestinationSelected: (index) {
      switch (index) {
        case 0:
          _select(0);
        case 1:
          _select(1);
        case 2:
          _select(5);
        case 3:
          _select(6);
        case 4:
          _openMoreNavigation();
      }
    },
    destinations: const [
      NavigationDestination(
        icon: Icon(Icons.grid_view_outlined),
        selectedIcon: Icon(Icons.grid_view_rounded),
        label: 'Workspace',
      ),
      NavigationDestination(
        icon: Icon(Icons.send_outlined),
        selectedIcon: Icon(Icons.send_rounded),
        label: 'Request',
      ),
      NavigationDestination(
        icon: Icon(Icons.sensors_outlined),
        selectedIcon: Icon(Icons.sensors_rounded),
        label: 'Realtime',
      ),
      NavigationDestination(
        icon: Icon(Icons.account_tree_outlined),
        selectedIcon: Icon(Icons.account_tree_rounded),
        label: 'GraphQL',
      ),
      NavigationDestination(
        icon: Icon(Icons.more_horiz_rounded),
        selectedIcon: Icon(Icons.more_horiz_rounded),
        label: 'More',
      ),
    ],
  );

  Future<void> _openMoreNavigation() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: FractionallySizedBox(
          heightFactor: 0.68,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 18),
            child: ListView(
              children: [
                for (final index in const [2, 3, 4, 7, 8])
                  ListTile(
                    leading: Icon(_shellDestinations[index].icon),
                    title: Text(_shellDestinations[index].label),
                    subtitle: Text(_shellDestinations[index].description),
                    trailing: _selected == index
                        ? const Icon(Icons.check_rounded)
                        : null,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _select(index);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _content() => switch (_selected) {
    0 => _workspace(),
    1 => _request(),
    2 => _history(),
    3 => _environments(),
    4 => _settings(),
    5 => const RealtimeScreen(),
    6 => BlocBuilder<WorkspaceCubit, WorkspaceState>(
      builder: (context, state) {
        final workspaceId = state.selectedWorkspaceId;
        if (workspaceId == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final workflow = _ensureGraphqlWorkflow(workspaceId);
        return BlocProvider.value(
          value: workflow,
          child: BlocProvider(
            create: (context) => GraphqlSubscriptionCubit(
              context.read<GraphqlSubscriptionService>(),
            ),
            child: BlocProvider(
              create: (context) => GraphqlSchemaCubit(
                context.read<GraphqlRepository>(),
                workspaceId: workspaceId,
                fetcher: (request) =>
                    context.read<GraphqlIntrospectionService>().fetch(
                      endpoint: request.endpoint,
                      headers: request.headers,
                      request: request,
                    ),
              )..load(),
              child: const GraphqlScreen(),
            ),
          ),
        );
      },
    ),
    7 => const GrpcScreen(),
    8 => BlocBuilder<WorkspaceCubit, WorkspaceState>(
      builder: (context, state) => AiAgentsScreen(
        controller: context.read<CodexAgentsService>().controller,
        workspaceId: state.selectedWorkspaceId ?? '',
      ),
    ),
    _ => _workspace(),
  };

  GraphqlWorkflowCubit _ensureGraphqlWorkflow(String workspaceId) {
    if (_graphqlWorkflow != null && _graphqlWorkspaceId == workspaceId) {
      return _graphqlWorkflow!;
    }
    _graphqlStateSubscription?.cancel();
    _graphqlWorkflow?.close();
    final workflow = GraphqlWorkflowCubit(
      context.read<GraphqlRepository>(),
      context.read<GraphqlExecutionService>(),
      workspaceId: workspaceId,
    )..restoreDrafts();
    _graphqlWorkflow = workflow;
    _graphqlWorkspaceId = workspaceId;
    _graphqlStateSubscription = workflow.stream.listen((_) {
      if (mounted) setState(() {});
    });
    return workflow;
  }

  Widget _workspace() => BlocBuilder<WorkspaceCubit, WorkspaceState>(
    builder: (context, state) {
      final cubit = context.read<WorkspaceCubit>();
      if (state.loading) {
        return const Center(child: CircularProgressIndicator());
      }
      final activeWorkspace = state.workspaces
          .where((item) => item.id == state.selectedWorkspaceId)
          .firstOrNull;
      final selectedCollection = state.collections
          .where((item) => item.id == state.selectedCollectionId)
          .firstOrNull;
      final activeCollectionRequests = selectedCollection == null
          ? const <ApiRequestModel>[]
          : state.savedRequests
                .where((item) => item.collectionId == selectedCollection.id)
                .toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DevRoutePageBar(
            compact: MediaQuery.sizeOf(context).width < 700,
            eyebrow: 'Workspace',
            title: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: state.selectedWorkspaceId,
                isDense: true,
                isExpanded: true,
                items: state.workspaces
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.id,
                        child: Text(item.name, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (id) {
                  if (id != null) cubit.selectWorkspace(id);
                },
              ),
            ),
            detail:
                '${state.collections.length} collections · ${state.savedRequests.length} saved requests',
            trailing: Wrap(
              spacing: 4,
              children: [
                IconButton(
                  tooltip: 'New workspace',
                  onPressed: () async {
                    final name = await _askName('New workspace');
                    if (name != null) cubit.addWorkspace(name);
                  },
                  icon: const Icon(Icons.add_business_outlined),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Workspace actions',
                  enabled: activeWorkspace != null,
                  onSelected: (action) async {
                    if (activeWorkspace == null) return;
                    switch (action) {
                      case 'rename':
                        final name = await _askName(
                          'Rename workspace',
                          initial: activeWorkspace.name,
                        );
                        if (name != null) {
                          cubit.renameWorkspace(activeWorkspace.id, name);
                        }
                      case 'delete':
                        if (state.workspaces.length > 1 &&
                            await _confirm(
                              'Delete workspace?',
                              'Collections, requests, environments, drafts, and their secret references will be removed.',
                            )) {
                          cubit.removeWorkspace(activeWorkspace.id);
                        }
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'rename',
                      child: Text('Rename workspace'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete workspace'),
                    ),
                  ],
                  child: const Padding(
                    padding: EdgeInsets.all(7),
                    child: Icon(Icons.more_horiz, size: 19),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('workspace-search'),
                    onChanged: cubit.search,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded, size: 18),
                      hintText:
                          'Search requests, collections, URLs, and history',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _newRequest,
                  icon: const Icon(Icons.add_rounded, size: 17),
                  label: const Text('New request'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 820;
                final collectionsPane = DevRoutePane(
                  title: 'Collections',
                  subtitle: '${state.collections.length} in this workspace',
                  trailing: IconButton(
                    tooltip: 'New collection',
                    onPressed: () async {
                      final name = await _askName('New collection');
                      if (name != null) cubit.addCollection(name);
                    },
                    icon: const Icon(
                      Icons.create_new_folder_outlined,
                      size: 18,
                    ),
                  ),
                  child: state.collections.isEmpty
                      ? DevRouteEmptyState(
                          icon: Icons.folder_open_outlined,
                          title: 'Start with a collection',
                          message:
                              'Group requests by service, then keep drafts and environments beside the work.',
                          action: OutlinedButton.icon(
                            onPressed: () async {
                              final name = await _askName('New collection');
                              if (name != null) cubit.addCollection(name);
                            },
                            icon: const Icon(
                              Icons.create_new_folder_outlined,
                              size: 17,
                            ),
                            label: const Text('Create collection'),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: state.collections.length,
                          separatorBuilder: (_, _) => const Divider(
                            height: 1,
                            indent: 10,
                            endIndent: 10,
                          ),
                          itemBuilder: (context, index) {
                            final item = state.collections[index];
                            final selected =
                                item.id == state.selectedCollectionId;
                            final requestCount = state.savedRequests
                                .where(
                                  (request) => request.collectionId == item.id,
                                )
                                .length;
                            return Material(
                              color: selected
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.primary.withValues(alpha: .12)
                                  : Colors.transparent,
                              child: InkWell(
                                onTap: () => cubit.selectCollection(item.id),
                                child: SizedBox(
                                  height: 46,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      right: 5,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 3,
                                          height: 26,
                                          color: selected
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : Colors.transparent,
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          selected
                                              ? Icons.folder_open_outlined
                                              : Icons.folder_outlined,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 9),
                                        Expanded(
                                          child: Text(
                                            item.name,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelLarge,
                                          ),
                                        ),
                                        Text(
                                          '$requestCount',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.labelSmall,
                                        ),
                                        PopupMenuButton<String>(
                                          tooltip: 'Collection actions',
                                          onSelected: (action) async {
                                            switch (action) {
                                              case 'up':
                                                if (index > 0) {
                                                  cubit.reorderCollection(
                                                    item.id,
                                                    index - 1,
                                                  );
                                                }
                                              case 'down':
                                                if (index <
                                                    state.collections.length -
                                                        1) {
                                                  cubit.reorderCollection(
                                                    item.id,
                                                    index + 1,
                                                  );
                                                }
                                              case 'move':
                                                await _moveCollection(item);
                                              case 'duplicate':
                                                cubit.duplicateCollection(
                                                  item.id,
                                                );
                                              case 'rename':
                                                final name = await _askName(
                                                  'Rename collection',
                                                  initial: item.name,
                                                );
                                                if (name != null) {
                                                  cubit.renameCollection(
                                                    item.id,
                                                    name,
                                                  );
                                                }
                                              case 'delete':
                                                if (await _confirm(
                                                  'Delete collection?',
                                                  'Its folders, requests, drafts, and secret references will be removed.',
                                                )) {
                                                  cubit.removeCollection(
                                                    item.id,
                                                  );
                                                }
                                            }
                                          },
                                          itemBuilder: (_) => const [
                                            PopupMenuItem(
                                              value: 'up',
                                              child: Text('Move up'),
                                            ),
                                            PopupMenuItem(
                                              value: 'down',
                                              child: Text('Move down'),
                                            ),
                                            PopupMenuItem(
                                              value: 'move',
                                              child: Text('Move to workspace'),
                                            ),
                                            PopupMenuItem(
                                              value: 'duplicate',
                                              child: Text('Duplicate'),
                                            ),
                                            PopupMenuItem(
                                              value: 'rename',
                                              child: Text('Rename'),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Delete'),
                                            ),
                                          ],
                                          icon: const Icon(
                                            Icons.more_horiz,
                                            size: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                );
                final detailsPane = DevRoutePane(
                  title: selectedCollection?.name ?? 'Getting started',
                  subtitle: selectedCollection == null
                      ? 'Create a request now, or select a collection to browse it.'
                      : '${activeCollectionRequests.length} requests · ${state.folders.where((folder) => folder.collectionId == selectedCollection.id).length} folders',
                  trailing: selectedCollection == null
                      ? null
                      : FilledButton.icon(
                          onPressed: () {
                            context.read<RequestWorkflowCubit>().newRequest(
                              collectionId: selectedCollection.id,
                            );
                            _select(1);
                          },
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('New request'),
                        ),
                  child: selectedCollection == null
                      ? _workspaceOnboarding()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DevRouteListHeader(
                              title: 'Folders',
                              count: state.folders
                                  .where(
                                    (folder) =>
                                        folder.collectionId ==
                                        selectedCollection.id,
                                  )
                                  .length,
                              trailing: TextButton.icon(
                                onPressed: () async {
                                  final name = await _askName('New folder');
                                  if (name != null) cubit.addFolder(name);
                                },
                                icon: const Icon(
                                  Icons.create_new_folder_outlined,
                                  size: 16,
                                ),
                                label: const Text('Add folder'),
                              ),
                            ),
                            const Divider(height: 1),
                            if (state.folders
                                .where(
                                  (folder) =>
                                      folder.collectionId ==
                                      selectedCollection.id,
                                )
                                .isNotEmpty)
                              SizedBox(
                                height: 36,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  children: [
                                    for (final folder in state.folders.where(
                                      (folder) =>
                                          folder.collectionId ==
                                          selectedCollection.id,
                                    ))
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 4,
                                        ),
                                        child: OutlinedButton.icon(
                                          onPressed: () =>
                                              _folderActions(folder),
                                          icon: Icon(
                                            folder.parentFolderId == null
                                                ? Icons.folder_outlined
                                                : Icons
                                                      .subdirectory_arrow_right,
                                            size: 15,
                                          ),
                                          label: Text(folder.name),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            DevRouteListHeader(
                              title: 'Requests',
                              count: activeCollectionRequests.length,
                            ),
                            const Divider(height: 1),
                            Expanded(
                              child: activeCollectionRequests.isEmpty
                                  ? DevRouteEmptyState(
                                      icon: Icons.send_outlined,
                                      title: 'No saved requests',
                                      message:
                                          'Create a request here; drafts remain in the editor until you save them.',
                                      action: OutlinedButton.icon(
                                        onPressed: () {
                                          context
                                              .read<RequestWorkflowCubit>()
                                              .newRequest(
                                                collectionId:
                                                    selectedCollection.id,
                                              );
                                          _select(1);
                                        },
                                        icon: const Icon(
                                          Icons.add_rounded,
                                          size: 17,
                                        ),
                                        label: const Text('New request'),
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      itemCount:
                                          activeCollectionRequests.length,
                                      separatorBuilder: (_, _) => const Divider(
                                        height: 1,
                                        indent: 10,
                                        endIndent: 10,
                                      ),
                                      itemBuilder: (context, index) {
                                        final request =
                                            activeCollectionRequests[index];
                                        return ListTile(
                                          leading: _HttpMethodBadge(
                                            method: request.method.name,
                                          ),
                                          title: Text(request.name),
                                          subtitle: Text(
                                            request.url,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          onTap: () {
                                            context
                                                .read<RequestWorkflowCubit>()
                                                .openRequest(request);
                                            _select(1);
                                          },
                                          trailing: PopupMenuButton<String>(
                                            tooltip: 'Request actions',
                                            onSelected: (action) async {
                                              switch (action) {
                                                case 'up':
                                                  if (index > 0) {
                                                    cubit.reorderSavedRequest(
                                                      request.id,
                                                      index - 1,
                                                    );
                                                  }
                                                case 'down':
                                                  if (index <
                                                      activeCollectionRequests
                                                              .length -
                                                          1) {
                                                    cubit.reorderSavedRequest(
                                                      request.id,
                                                      index + 1,
                                                    );
                                                  }
                                                case 'duplicate':
                                                  cubit.duplicateSavedRequest(
                                                    request.id,
                                                  );
                                                case 'delete':
                                                  if (await _confirm(
                                                    'Delete request?',
                                                    'The saved request, draft, and its secret references will be removed.',
                                                  )) {
                                                    cubit.removeSavedRequest(
                                                      request.id,
                                                    );
                                                  }
                                              }
                                            },
                                            itemBuilder: (_) => const [
                                              PopupMenuItem(
                                                value: 'up',
                                                child: Text('Move up'),
                                              ),
                                              PopupMenuItem(
                                                value: 'down',
                                                child: Text('Move down'),
                                              ),
                                              PopupMenuItem(
                                                value: 'duplicate',
                                                child: Text('Duplicate'),
                                              ),
                                              PopupMenuItem(
                                                value: 'delete',
                                                child: Text('Delete'),
                                              ),
                                            ],
                                            icon: const Icon(
                                              Icons.more_horiz,
                                              size: 18,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                );
                if (compact) {
                  // At compact desktop and phone heights, showing two stacked
                  // panels leaves neither usable.  Keep the immediate task in
                  // focus: choose a collection first, then inspect it.
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: selectedCollection == null
                        ? collectionsPane
                        : detailsPane,
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 5, child: collectionsPane),
                      const SizedBox(width: 10),
                      Expanded(flex: 7, child: detailsPane),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
    },
  );

  Widget _workspaceOnboarding() => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your API work starts here',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        Text(
          'Create a request to explore an endpoint immediately, or create a collection first to keep service work together.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: _newRequest,
          icon: const Icon(Icons.add_rounded, size: 17),
          label: const Text('Create REST request'),
        ),
        const SizedBox(height: 20),
        const Divider(height: 1),
        const SizedBox(height: 14),
        _onboardingStep('1', 'Choose an environment before using variables.'),
        _onboardingStep(
          '2',
          'Compose a request and inspect the response in place.',
        ),
        _onboardingStep('3', 'Save repeatable work in a collection.'),
      ],
    ),
  );

  Widget _onboardingStep(String number, String message) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 19,
          height: 19,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: .16),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(number, style: Theme.of(context).textTheme.labelSmall),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    ),
  );

  Widget _request() => BlocConsumer<RequestWorkflowCubit, RequestWorkflowState>(
    listener: (context, state) {
      if (state.validationErrors.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.validationErrors.join('\n'))),
        );
      }
    },
    builder: (context, state) {
      final cubit = context.read<RequestWorkflowCubit>();
      final sendingActiveRequest = state.isSendingRequest(state.request.id);
      final workspace = context.watch<WorkspaceCubit>().state;
      if (_urlController.text != state.request.url) {
        _urlController.value = TextEditingValue(
          text: state.request.url,
          selection: TextSelection.collapsed(offset: state.request.url.length),
        );
      }
      return LayoutBuilder(
        builder: (context, constraints) {
          // A 720px-tall Windows window still has enough vertical room for a
          // compact response pane.  Treating it as phone-like hid the result
          // surface and left a misleading empty canvas.
          final compact =
              constraints.maxWidth < 620 || constraints.maxHeight < 520;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DevRouteTabStrip(
                tabs: state.tabs
                    .map(
                      (item) => DevRouteWorkbenchTab(
                        label: item.name,
                        dirty: state.dirtyIds.contains(item.id),
                      ),
                    )
                    .toList(),
                activeIndex: state.activeIndex,
                onSelected: cubit.selectTab,
                onClose: state.tabs.length == 1 && !state.isDirty
                    ? null
                    : (_) => _closeRequestTab(),
                onNew: () => cubit.newRequest(
                  collectionId: workspace.selectedCollectionId,
                ),
              ),
              const Divider(height: 1),
              _requestIdentityBar(
                state,
                cubit,
                workspace,
                savingDisabled: sendingActiveRequest,
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 620;
                    final method = Container(
                      height: 38,
                      padding: const EdgeInsets.only(left: 9, right: 5),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: .11),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<HttpMethod>(
                          value: state.request.method,
                          isDense: true,
                          items: HttpMethod.values
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(
                                    item.name.toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: _httpMethodColor(item.name),
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: sendingActiveRequest
                              ? null
                              : (value) => cubit.updateMethod(value!),
                        ),
                      ),
                    );
                    final url = TextField(
                      controller: _urlController,
                      enabled: !sendingActiveRequest,
                      onChanged: cubit.updateUrl,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.link_rounded, size: 17),
                        hintText: 'https://api.example.com/resource',
                      ),
                    );
                    final send = FilledButton.icon(
                      onPressed: sendingActiveRequest
                          ? cubit.cancel
                          : () => _sendWithSafety(cubit, state, workspace),
                      icon: Icon(
                        sendingActiveRequest
                            ? Icons.stop_circle_outlined
                            : Icons.send_rounded,
                        size: 17,
                      ),
                      label: Text(sendingActiveRequest ? 'Cancel' : 'Send'),
                    );
                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [method, const SizedBox(width: 8), send],
                          ),
                          const SizedBox(height: 8),
                          url,
                        ],
                      );
                    }
                    return Row(
                      children: [
                        method,
                        const SizedBox(width: 8),
                        Expanded(child: url),
                        const SizedBox(width: 8),
                        send,
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 2),
              _requestEditor(state, cubit, workspace, compact),
              DevRouteSplitter(
                axis: Axis.vertical,
                onDrag: _changeRequestEditorHeight,
                onReset: _resetRequestEditorHeight,
              ),
              const SizedBox(height: 2),
              Expanded(
                child: state.response == null && compact
                    ? const SizedBox.shrink()
                    : state.response == null
                    ? DevRoutePane(
                        title: 'Response',
                        subtitle: 'No response yet',
                        child: DevRouteEmptyState(
                          icon: Icons.http_outlined,
                          title: 'Ready to send',
                          message:
                              'Configure the request and press Send. Drafts autosave locally.',
                        ),
                      )
                    : DevRoutePane(
                        title: 'Response',
                        subtitle:
                            state.response!.error ??
                            '${state.response!.statusCode} · ${state.response!.durationMs} ms · ${state.response!.sizeBytes} B',
                        child: _response(
                          state.request,
                          state.response!,
                          state.sensitiveValues[state.request.id] ??
                              const <String>{},
                        ),
                      ),
              ),
            ],
          );
        },
      );
    },
  );

  Widget _requestIdentityBar(
    RequestWorkflowState state,
    RequestWorkflowCubit cubit,
    WorkspaceState workspace, {
    required bool savingDisabled,
  }) {
    final name = SizedBox(
      width: 240,
      child: TextFormField(
        key: ValueKey('${state.request.id}-name'),
        initialValue: state.request.name,
        onChanged: cubit.updateName,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        decoration: const InputDecoration(
          hintText: 'Request name',
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        ),
      ),
    );
    final collection = SizedBox(
      width: 138,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          isDense: true,
          isExpanded: true,
          value: state.request.collectionId,
          hint: const Text('Collection'),
          items: <DropdownMenuItem<String?>>[
            const DropdownMenuItem(value: null, child: Text('No collection')),
            ...workspace.collections.map(
              (item) => DropdownMenuItem(
                value: item.id,
                child: Text(item.name, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
          onChanged: (value) => cubit.assignLocation(value, null),
        ),
      ),
    );
    final folder = SizedBox(
      width: 118,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          isDense: true,
          isExpanded: true,
          value: state.request.folderId,
          hint: const Text('Folder'),
          items: <DropdownMenuItem<String?>>[
            const DropdownMenuItem(value: null, child: Text('No folder')),
            ...workspace.folders.map(
              (item) => DropdownMenuItem(
                value: item.id,
                child: Text(item.name, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
          onChanged: state.request.collectionId == null
              ? null
              : (value) =>
                    cubit.assignLocation(state.request.collectionId, value),
        ),
      ),
    );
    final save = IconButton(
      tooltip: 'Save request',
      onPressed: savingDisabled ? null : cubit.save,
      icon: const Icon(Icons.save_outlined, size: 18),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 780;
        return DevRoutePageBar(
          compact: compact,
          eyebrow: state.isDirty ? 'REST · unsaved draft' : 'REST request',
          title: name,
          detail: savingDisabled
              ? 'Request in flight'
              : 'Draft saved locally until you save it',
          trailing: compact
              ? save
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    collection,
                    const SizedBox(width: 8),
                    folder,
                    const SizedBox(width: 4),
                    save,
                  ],
                ),
        );
      },
    );
  }

  Widget _requestEditor(
    RequestWorkflowState state,
    RequestWorkflowCubit cubit,
    WorkspaceState workspace,
    bool compact,
  ) => SizedBox(
    height: compact ? 180 : _requestEditorHeight,
    child: DefaultTabController(
      length: 6,
      child: DevRoutePane(
        child: Column(
          children: [
            const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Params'),
                Tab(text: 'Headers'),
                Tab(text: 'Auth'),
                Tab(text: 'Body'),
                Tab(text: 'Settings'),
                Tab(text: 'Resolved Preview'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _keyValueList(
                    title: 'Query parameters',
                    items: state.request.queryParams
                        .map((item) => (item.key, item.value, item.enabled))
                        .toList(),
                    onAdd: () async {
                      final pair = await _askPair('Add query parameter');
                      if (pair != null) {
                        cubit.updateQueryParams(<RequestQueryParamModel>[
                          ...state.request.queryParams,
                          RequestQueryParamModel(key: pair.$1, value: pair.$2),
                        ]);
                      }
                    },
                    onRemove: (index) {
                      final values = List<RequestQueryParamModel>.of(
                        state.request.queryParams,
                      )..removeAt(index);
                      cubit.updateQueryParams(values);
                    },
                    onToggle: (index, enabled) {
                      final values = List<RequestQueryParamModel>.of(
                        state.request.queryParams,
                      );
                      final old = values[index];
                      values[index] = RequestQueryParamModel(
                        key: old.key,
                        value: old.value,
                        enabled: enabled,
                      );
                      cubit.updateQueryParams(values);
                    },
                  ),
                  _keyValueList(
                    title: 'Headers',
                    items: state.request.headers
                        .map(
                          (item) => (
                            item.key,
                            item.isSecret ? '[SECRET]' : item.value,
                            item.enabled,
                          ),
                        )
                        .toList(),
                    onAdd: () => _addHeader(state, cubit),
                    onRemove: (index) {
                      final values = List<RequestHeaderModel>.of(
                        state.request.headers,
                      )..removeAt(index);
                      cubit.updateHeaders(values);
                    },
                    onToggle: (index, enabled) {
                      final values = List<RequestHeaderModel>.of(
                        state.request.headers,
                      );
                      final old = values[index];
                      values[index] = RequestHeaderModel(
                        key: old.key,
                        value: old.value,
                        enabled: enabled,
                        isSecret: old.isSecret,
                        secretRef: old.secretRef,
                      );
                      cubit.updateHeaders(values);
                    },
                  ),
                  _authEditor(state.request, cubit),
                  _bodyEditor(state.request, cubit),
                  _requestSettingsEditor(state.request, cubit),
                  _resolvedPreview(state.request, workspace),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _keyValueList({
    required String title,
    required List<(String, String, bool)> items,
    required VoidCallback onAdd,
    required void Function(int) onRemove,
    required void Function(int, bool) onToggle,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      DevRouteListHeader(
        title: title,
        count: items.length,
        trailing: TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text('Add'),
        ),
      ),
      const Divider(height: 1),
      Container(
        height: 30,
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: .35),
        padding: const EdgeInsets.only(left: 6, right: 8),
        child: Row(
          children: [
            const SizedBox(width: 38),
            Expanded(
              flex: 4,
              child: Text('KEY', style: Theme.of(context).textTheme.labelSmall),
            ),
            Expanded(
              flex: 6,
              child: Text(
                'VALUE',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            const SizedBox(width: 28),
          ],
        ),
      ),
      const Divider(height: 1),
      Expanded(
        child: items.isEmpty
            ? Center(
                child: Text(
                  'No $title yet. Use Add to create one.',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 2),
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, indent: 8, endIndent: 8),
                itemBuilder: (context, index) => SizedBox(
                  height: 38,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6, right: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 38,
                          child: Checkbox(
                            value: items[index].$3,
                            onChanged: (value) =>
                                onToggle(index, value ?? true),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            items[index].$1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: SelectableText(
                            items[index].$2,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Remove $title value',
                          onPressed: () => onRemove(index),
                          icon: const Icon(Icons.close, size: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    ],
  );

  Widget _authEditor(
    ApiRequestModel request,
    RequestWorkflowCubit cubit,
  ) => ListView(
    padding: const EdgeInsets.all(12),
    children: [
      DropdownButtonFormField<AuthType>(
        initialValue: request.auth.type,
        decoration: const InputDecoration(
          labelText: 'Authentication type',
          border: OutlineInputBorder(),
        ),
        items: AuthType.values
            .map(
              (item) => DropdownMenuItem(value: item, child: Text(item.name)),
            )
            .toList(),
        onChanged: (type) => _configureAuth(type!, request, cubit),
      ),
      const SizedBox(height: 12),
      Text(
        request.auth.type == AuthType.none
            ? 'No authentication is configured.'
            : 'Secret value is stored only in secure storage. Reference: ${request.auth.tokenSecretRef ?? request.auth.passwordSecretRef ?? request.auth.apiKeySecretRef ?? 'not configured'}',
      ),
    ],
  );

  Widget _bodyEditor(
    ApiRequestModel request,
    RequestWorkflowCubit cubit,
  ) => ListView(
    padding: const EdgeInsets.all(12),
    children: [
      DropdownButtonFormField<RequestBodyType>(
        initialValue: request.body?.type ?? RequestBodyType.none,
        decoration: const InputDecoration(
          labelText: 'Body type',
          border: OutlineInputBorder(),
        ),
        items: RequestBodyType.values
            .map(
              (item) => DropdownMenuItem(value: item, child: Text(item.name)),
            )
            .toList(),
        onChanged: (type) => cubit.updateBody(
          RequestBodyModel(
            type: type!,
            content: type == RequestBodyType.none
                ? ''
                : request.body?.content ?? '',
            filePath: request.body?.filePath,
          ),
        ),
      ),
      if (request.body != null &&
          request.body!.type != RequestBodyType.none) ...[
        const SizedBox(height: 10),
        TextFormField(
          key: ValueKey('${request.id}-${request.body!.type.name}'),
          initialValue: request.body!.content,
          minLines: 3,
          maxLines: 6,
          onChanged: (value) => cubit.updateBody(
            RequestBodyModel(
              type: request.body!.type,
              content: value,
              contentType: request.body!.contentType,
              filePath: request.body!.filePath,
            ),
          ),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText:
                request.body!.type == RequestBodyType.multipart ||
                    request.body!.type == RequestBodyType.formData
                ? 'Enter field metadata as JSON or key=value lines; file paths remain local metadata.'
                : request.body!.type == RequestBodyType.binary
                ? 'Local binary file path metadata'
                : 'Request body',
          ),
        ),
      ],
    ],
  );

  Widget _requestSettingsEditor(
    ApiRequestModel request,
    RequestWorkflowCubit cubit,
  ) => ListView(
    padding: const EdgeInsets.all(12),
    children: [
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SizedBox(
            width: 190,
            child: _numberField(
              'Connect timeout ms',
              request.settings.connectTimeoutMs,
              (value) => cubit.updateSettings(
                _settingsCopy(request.settings, connect: value),
              ),
            ),
          ),
          SizedBox(
            width: 190,
            child: _numberField(
              'Send timeout ms',
              request.settings.sendTimeoutMs,
              (value) => cubit.updateSettings(
                _settingsCopy(request.settings, send: value),
              ),
            ),
          ),
          SizedBox(
            width: 190,
            child: _numberField(
              'Receive timeout ms',
              request.settings.receiveTimeoutMs,
              (value) => cubit.updateSettings(
                _settingsCopy(request.settings, receive: value),
              ),
            ),
          ),
        ],
      ),
      SwitchListTile(
        title: const Text('Follow redirects'),
        value: request.settings.followRedirects,
        onChanged: (value) => cubit.updateSettings(
          _settingsCopy(request.settings, redirects: value),
        ),
      ),
      SwitchListTile(
        title: const Text('Verify TLS certificates'),
        subtitle: const Text(
          'Disabling verification is rejected by validation for HTTPS requests.',
        ),
        value: request.settings.verifyCertificates,
        onChanged: (value) => cubit.updateSettings(
          _settingsCopy(request.settings, verify: value),
        ),
      ),
    ],
  );

  RequestSettingsModel _settingsCopy(
    RequestSettingsModel old, {
    int? connect,
    int? send,
    int? receive,
    bool? redirects,
    bool? verify,
  }) => RequestSettingsModel(
    connectTimeoutMs: connect ?? old.connectTimeoutMs,
    sendTimeoutMs: send ?? old.sendTimeoutMs,
    receiveTimeoutMs: receive ?? old.receiveTimeoutMs,
    followRedirects: redirects ?? old.followRedirects,
    maxRedirects: old.maxRedirects,
    verifyCertificates: verify ?? old.verifyCertificates,
  );

  Widget _resolvedPreview(ApiRequestModel request, WorkspaceState workspace) {
    final environment = <String, String>{
      for (final item in workspace.environmentVariables.where(
        (item) => item.enabled,
      ))
        item.key: item.isSecret ? '[SECRET]' : item.value,
    };
    final result = VariableResolutionService().resolve(
      request.url,
      environment: environment,
      secretKeys: workspace.environmentVariables
          .where((item) => item.isSecret)
          .map((item) => item.key)
          .toSet(),
    );
    final uri = Uri.tryParse(result.value);
    final query = <String, String>{
      if (uri != null) ...uri.queryParameters,
      for (final item in request.queryParams.where((item) => item.enabled))
        item.key: VariableResolutionService()
            .resolve(item.value, environment: environment)
            .value,
    };
    final previewUrl =
        uri?.replace(queryParameters: query).toString() ?? result.value;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        SelectableText('${request.method.name.toUpperCase()} $previewUrl'),
        const SizedBox(height: 8),
        for (final header in request.headers.where((item) => item.enabled))
          SelectableText(
            '${header.key}: ${header.isSecret ? '[REDACTED]' : VariableResolutionService().resolve(header.value, environment: environment).value}',
          ),
        if (result.unresolved.isNotEmpty)
          Text(
            'Unresolved: ${result.unresolved.join(', ')}',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        if (result.cycles.isNotEmpty)
          Text(
            'Cycles: ${result.cycles.join(', ')}',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    );
  }

  Widget _response(
    ApiRequestModel request,
    ApiResponseModel response,
    Set<String> sensitiveValues,
  ) {
    final candidates = TokenCandidateService().find(response.body);
    final diagnostics = DeveloperDiagnostics.forRequest(request, response);
    final shownBody = _formattedBody(response.body, raw: _rawResponse);
    final filteredBody = _responseSearch.isEmpty
        ? shownBody
        : shownBody
              .split('\n')
              .where(
                (line) =>
                    line.toLowerCase().contains(_responseSearch.toLowerCase()),
              )
              .join('\n');
    return DefaultTabController(
      length: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 2),
            child: Row(
              children: [
                if (response.isTruncated)
                  Expanded(
                    child: Text(
                      'Preview truncated to protect memory',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  )
                else
                  const Spacer(),
                IconButton(
                  tooltip: 'Safe copy',
                  onPressed: () => _copySafe(response.body, sensitiveValues),
                  icon: const Icon(Icons.copy_outlined),
                ),
                IconButton(
                  tooltip: 'Export sanitized response',
                  onPressed: () => _exportResponse(response, sensitiveValues),
                  icon: const Icon(Icons.download_outlined),
                ),
                if (candidates.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => _saveToken(response.body),
                    icon: const Icon(Icons.key_outlined, size: 17),
                    label: const Text('Save token…'),
                  ),
              ],
            ),
          ),
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Body'),
              Tab(text: 'Headers'),
              Tab(text: 'Cookies'),
              Tab(text: 'Timeline'),
              Tab(text: 'Diagnostics'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (value) =>
                                  setState(() => _responseSearch = value),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.search),
                                hintText: 'Search response',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment(
                                value: false,
                                label: Text('Pretty'),
                              ),
                              ButtonSegment(value: true, label: Text('Raw')),
                            ],
                            selected: <bool>{_rawResponse},
                            onSelectionChanged: (value) =>
                                setState(() => _rawResponse = value.first),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(12),
                        child: SelectableText(response.error ?? filteredBody),
                      ),
                    ),
                  ],
                ),
                ListView(
                  children: response.headers.entries
                      .map(
                        (item) => ListTile(
                          title: Text(item.key),
                          subtitle: SelectableText(item.value),
                        ),
                      )
                      .toList(),
                ),
                ListView(
                  children: response.cookies.isEmpty
                      ? const [ListTile(title: Text('No response cookies.'))]
                      : response.cookies
                            .map(
                              (_) => const ListTile(
                                title: Text('[REDACTED COOKIE]'),
                              ),
                            )
                            .toList(),
                ),
                ListView(
                  children: [
                    ListTile(
                      title: const Text('Started'),
                      subtitle: Text(response.timestamp.toLocal().toString()),
                    ),
                    ListTile(
                      title: const Text('Completed'),
                      subtitle: Text('${response.durationMs} ms'),
                    ),
                    ListTile(
                      title: const Text('Payload size'),
                      subtitle: Text('${response.sizeBytes} bytes'),
                    ),
                    if (response.isTruncated)
                      const ListTile(
                        title: Text('Preview bounded'),
                        subtitle: Text(
                          'The displayed body was truncated to protect memory.',
                        ),
                      ),
                  ],
                ),
                ListView(
                  children: diagnostics.isEmpty
                      ? const [ListTile(title: Text('No diagnostics.'))]
                      : diagnostics
                            .map(
                              (item) => ListTile(
                                leading: Icon(
                                  item.kind == DiagnosticKind.observed
                                      ? Icons.fact_check_outlined
                                      : Icons.lightbulb_outline,
                                ),
                                title: Text('${item.kind.name}: ${item.title}'),
                                subtitle: Text(item.detail),
                              ),
                            )
                            .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _history() => BlocBuilder<WorkspaceCubit, WorkspaceState>(
    builder: (context, state) {
      final cubit = context.read<WorkspaceCubit>();
      final filtered = state.history
          .where(
            (item) =>
                (_historyMethod == null || item.method == _historyMethod) &&
                (_historyMinimumStatus == null ||
                    (item.status ?? 0) >= _historyMinimumStatus!),
          )
          .toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DevRoutePageBar(
            eyebrow: 'History',
            title: const Text('Request activity'),
            detail: '${state.history.length} locally retained records',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  onPressed: state.history.isEmpty
                      ? null
                      : () async {
                          if (await _confirm(
                            'Clear all history?',
                            'This cannot be undone.',
                          )) {
                            cubit.clearAllHistory();
                          }
                        },
                  icon: const Icon(Icons.delete_sweep_outlined, size: 17),
                  label: const Text('Clear'),
                ),
                const SizedBox(width: 4),
                FilledButton.tonalIcon(
                  onPressed: _restComparison.length == 2
                      ? () => _compareRestHistory(
                          filtered
                              .where(
                                (item) => _restComparison.contains(item.id),
                              )
                              .toList(),
                        )
                      : null,
                  icon: const Icon(Icons.compare_arrows, size: 17),
                  label: const Text('Compare'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    onChanged: cubit.search,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded, size: 18),
                      hintText: 'Filter request activity',
                    ),
                  ),
                ),
                DropdownButton<String?>(
                  value: _historyMethod,
                  hint: const Text('All methods'),
                  items: <DropdownMenuItem<String?>>[
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All methods'),
                    ),
                    ...HttpMethod.values.map(
                      (item) => DropdownMenuItem(
                        value: item.name,
                        child: Text(item.name.toUpperCase()),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _historyMethod = value),
                ),
                DropdownButton<int?>(
                  value: _historyMinimumStatus,
                  hint: const Text('All outcomes'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All outcomes')),
                    DropdownMenuItem(value: 400, child: Text('Errors ≥400')),
                    DropdownMenuItem(value: 500, child: Text('Server ≥500')),
                  ],
                  onChanged: (value) =>
                      setState(() => _historyMinimumStatus = value),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: DevRoutePane(
                title: 'Activity',
                subtitle: '${filtered.length} matching records',
                child: filtered.isEmpty
                    ? const DevRouteEmptyState(
                        icon: Icons.history_outlined,
                        title: 'No matching activity',
                        message:
                            'Sent requests appear here with their outcome and duration.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1, indent: 10, endIndent: 10),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return ListTile(
                            leading: Checkbox(
                              value: _restComparison.contains(item.id),
                              onChanged: (selected) => setState(() {
                                if (selected == true &&
                                    _restComparison.length < 2) {
                                  _restComparison.add(item.id);
                                } else {
                                  _restComparison.remove(item.id);
                                }
                              }),
                            ),
                            title: Row(
                              children: [
                                _HttpMethodBadge(method: item.method),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item.url,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              '${item.status ?? 'Error'} · ${item.durationMs} ms · ${item.createdAt.toLocal()}',
                            ),
                            onTap: () => _showHistory(item),
                            trailing: Wrap(
                              children: [
                                IconButton(
                                  tooltip: 'Replay as new draft',
                                  onPressed: () => _replayHistory(item.id),
                                  icon: const Icon(Icons.replay_outlined),
                                ),
                                IconButton(
                                  tooltip: 'Delete',
                                  onPressed: () => cubit.removeHistory(item.id),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      );
    },
  );

  Widget _environments() => BlocBuilder<WorkspaceCubit, WorkspaceState>(
    builder: (context, state) {
      final cubit = context.read<WorkspaceCubit>();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DevRoutePageBar(
            eyebrow: 'Environments',
            title: const Text('Variables and secrets'),
            detail: '${state.environments.length} environments',
            trailing: FilledButton.icon(
              onPressed: () async {
                final name = await _askName('New environment');
                if (name != null) {
                  cubit.addEnvironment(name, EnvironmentKind.custom);
                }
              },
              icon: const Icon(Icons.add_rounded, size: 17),
              label: const Text('New'),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 720;
                return Flex(
                  direction: compact ? Axis.vertical : Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: compact ? null : 300,
                      height: compact ? 210 : null,
                      child: DevRoutePane(
                        title: 'Environments',
                        subtitle: 'Active scope and reusable values',
                        trailing: IconButton(
                          tooltip: 'New environment',
                          onPressed: () async {
                            final name = await _askName('New environment');
                            if (name != null) {
                              cubit.addEnvironment(
                                name,
                                EnvironmentKind.custom,
                              );
                            }
                          },
                          icon: const Icon(Icons.add, size: 18),
                        ),
                        child: ListView.builder(
                          itemCount: state.environments.length,
                          itemBuilder: (context, index) {
                            final item = state.environments[index];
                            final selected =
                                item.id == state.selectedEnvironmentId;
                            final colors = Theme.of(context).colorScheme;
                            return Material(
                              color: selected
                                  ? colors.primary.withValues(alpha: .11)
                                  : Colors.transparent,
                              child: InkWell(
                                onTap: () => cubit.selectEnvironment(item.id),
                                child: SizedBox(
                                  height: 54,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 11,
                                      right: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          item.isActive
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_unchecked,
                                          size: 16,
                                          color: item.isActive
                                              ? colors.primary
                                              : colors.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 9),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelLarge
                                                    ?.copyWith(
                                                      fontWeight: selected
                                                          ? FontWeight.w700
                                                          : FontWeight.w500,
                                                    ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                item.isActive
                                                    ? 'ACTIVE · ${item.kind.name.toUpperCase()}'
                                                    : item.kind.name
                                                          .toUpperCase(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color: colors
                                                          .onSurfaceVariant,
                                                      letterSpacing: .55,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          tooltip: '${item.name} actions',
                                          onSelected: (action) =>
                                              _environmentAction(action, item),
                                          itemBuilder: (_) => const [
                                            PopupMenuItem(
                                              value: 'activate',
                                              child: Text('Activate'),
                                            ),
                                            PopupMenuItem(
                                              value: 'rename',
                                              child: Text('Rename'),
                                            ),
                                            PopupMenuItem(
                                              value: 'duplicate',
                                              child: Text('Duplicate'),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (compact) const Divider() else const VerticalDivider(),
                    Expanded(
                      child: state.selectedEnvironmentId == null
                          ? const DevRouteEmptyState(
                              icon: Icons.tune_outlined,
                              title: 'Select an environment',
                              message:
                                  'Choose a scope from the left to edit its reusable values.',
                            )
                          : DevRoutePane(
                              title: 'Variables',
                              subtitle:
                                  '${state.environmentVariables.length} values in the active environment',
                              trailing: FilledButton.icon(
                                onPressed: () => _editVariable(),
                                icon: const Icon(Icons.add, size: 17),
                                label: const Text('Add'),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const _EnvironmentVariableHeader(),
                                  const Divider(height: 1),
                                  Expanded(
                                    child: state.environmentVariables.isEmpty
                                        ? const DevRouteEmptyState(
                                            icon: Icons.key_outlined,
                                            title: 'No variables yet',
                                            message:
                                                'Add a value once and reuse it safely across requests.',
                                          )
                                        : ListView.builder(
                                            itemCount: state
                                                .environmentVariables
                                                .length,
                                            itemBuilder: (context, index) {
                                              final variable = state
                                                  .environmentVariables[index];
                                              return _EnvironmentVariableRow(
                                                variable: variable,
                                                isFirst: index == 0,
                                                isLast:
                                                    index ==
                                                    state
                                                            .environmentVariables
                                                            .length -
                                                        1,
                                                onTap: () =>
                                                    _editVariable(variable),
                                                onEnabled: (value) =>
                                                    cubit.saveVariable(
                                                      id: variable.id,
                                                      key: variable.key,
                                                      value: variable.value,
                                                      secret: variable.isSecret,
                                                      enabled: value,
                                                    ),
                                                onMoveUp: () =>
                                                    cubit.reorderVariable(
                                                      variable.id,
                                                      index - 1,
                                                    ),
                                                onMoveDown: () =>
                                                    cubit.reorderVariable(
                                                      variable.id,
                                                      index + 1,
                                                    ),
                                                onDelete: () =>
                                                    cubit.removeVariable(
                                                      variable.id,
                                                    ),
                                              );
                                            },
                                          ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      );
    },
  );

  Widget _settings() => BlocBuilder<WorkspaceCubit, WorkspaceState>(
    builder: (context, state) {
      final cubit = context.read<WorkspaceCubit>();
      final settings = state.settings;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DevRoutePageBar(
            eyebrow: 'Settings',
            title: Text('Workspace preferences'),
            detail: 'History, response handling, and production safeguards',
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SettingsWorkbenchSection(
                  title: 'Request history',
                  subtitle:
                      'Local retention and the size of the working record.',
                  children: [
                    _SettingsNumberRow(
                      label: 'Retention period',
                      detail: 'Days to retain a request record locally',
                      value: settings.historyRetentionDays,
                      suffix: 'days',
                      onSubmitted: (value) => cubit.updateSettings(
                        WorkspaceSettingsModel(
                          historyRetentionDays: value,
                          historyMaximumCount: settings.historyMaximumCount,
                          responsePreviewBytes: settings.responsePreviewBytes,
                          productionStrictMode: settings.productionStrictMode,
                        ),
                      ),
                    ),
                    _SettingsNumberRow(
                      label: 'Record limit',
                      detail: 'Maximum request records saved per workspace',
                      value: settings.historyMaximumCount,
                      suffix: 'records',
                      onSubmitted: (value) => cubit.updateSettings(
                        WorkspaceSettingsModel(
                          historyRetentionDays: settings.historyRetentionDays,
                          historyMaximumCount: value,
                          responsePreviewBytes: settings.responsePreviewBytes,
                          productionStrictMode: settings.productionStrictMode,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _SettingsWorkbenchSection(
                  title: 'Response handling',
                  subtitle:
                      'Keep large payloads useful without overloading the workbench.',
                  children: [
                    _SettingsNumberRow(
                      label: 'Response preview limit',
                      detail:
                          'Maximum bytes rendered in the response inspector',
                      value: settings.responsePreviewBytes,
                      suffix: 'bytes',
                      onSubmitted: (value) => cubit.updateSettings(
                        WorkspaceSettingsModel(
                          historyRetentionDays: settings.historyRetentionDays,
                          historyMaximumCount: settings.historyMaximumCount,
                          responsePreviewBytes: value,
                          productionStrictMode: settings.productionStrictMode,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _SettingsWorkbenchSection(
                  title: 'Production safeguards',
                  subtitle:
                      'Deliberate controls for requests that can change live data.',
                  children: [
                    _SettingsSwitchRow(
                      icon: Icons.verified_user_outlined,
                      label: 'Confirm mutating production requests',
                      detail:
                          'Require confirmation for POST, PUT, PATCH, and DELETE.',
                      value: settings.productionStrictMode,
                      onChanged: (value) => cubit.updateSettings(
                        WorkspaceSettingsModel(
                          historyRetentionDays: settings.historyRetentionDays,
                          historyMaximumCount: settings.historyMaximumCount,
                          responsePreviewBytes: settings.responsePreviewBytes,
                          productionStrictMode: value,
                        ),
                      ),
                    ),
                    const _SettingsInformationRow(
                      icon: Icons.lock_outline,
                      label: 'TLS verification stays enabled',
                      detail:
                          'HTTPS requests cannot silently disable certificate verification.',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    },
  );

  Widget _numberField(String label, int value, ValueChanged<int> onSubmitted) =>
      TextFormField(
        key: ValueKey('$label-$value'),
        initialValue: value.toString(),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onFieldSubmitted: (text) {
          final parsed = int.tryParse(text);
          if (parsed != null && parsed > 0) onSubmitted(parsed);
        },
      );

  Future<void> _guardExit({
    required bool restDirty,
    required bool graphqlDirty,
  }) async {
    if (_exitDialogOpen) return;
    _exitDialogOpen = true;
    final scope = switch ((restDirty, graphqlDirty)) {
      (true, true) => 'REST and GraphQL',
      (true, false) => 'REST',
      (false, true) => 'GraphQL',
      (false, false) => '',
    };
    final discard = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Unsaved changes'),
        content: Text('There are unsaved changes in $scope.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Discard and exit'),
          ),
        ],
      ),
    );
    _exitDialogOpen = false;
    if (discard != true || !mounted) return;
    setState(() => _allowExit = true);
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) Navigator.of(context).maybePop();
  }

  Future<void> _closeRequestTab() async {
    final cubit = context.read<RequestWorkflowCubit>();
    if (!cubit.state.isDirty ||
        await _confirm(
          'Close request tab?',
          'Discard unsaved changes in this tab?',
        )) {
      await cubit.closeActive(discardChanges: true);
    }
  }

  Future<void> _moveCollection(CollectionModel collection) async {
    final state = context.read<WorkspaceCubit>().state;
    final targets = state.workspaces
        .where((item) => item.id != collection.workspaceId)
        .toList();
    if (targets.isEmpty) return;
    final target = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Move collection to workspace'),
        children: [
          for (final item in targets)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, item.id),
              child: Text(item.name),
            ),
        ],
      ),
    );
    if (target != null && mounted) {
      await context.read<WorkspaceCubit>().moveCollection(
        collection.id,
        target,
      );
    }
  }

  Future<void> _folderActions(FolderModel folder) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename'),
              onTap: () => Navigator.pop(context, 'rename'),
            ),
            ListTile(
              leading: const Icon(Icons.create_new_folder_outlined),
              title: const Text('Add child folder'),
              onTap: () => Navigator.pop(context, 'child'),
            ),
            ListTile(
              leading: const Icon(Icons.arrow_upward),
              title: const Text('Move up'),
              onTap: () => Navigator.pop(context, 'up'),
            ),
            ListTile(
              leading: const Icon(Icons.arrow_downward),
              title: const Text('Move down'),
              onTap: () => Navigator.pop(context, 'down'),
            ),
            ListTile(
              leading: const Icon(Icons.drive_file_move_outline),
              title: const Text('Move to collection'),
              onTap: () => Navigator.pop(context, 'move'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete'),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    final cubit = context.read<WorkspaceCubit>();
    final state = cubit.state;
    if (action == 'rename') {
      final name = await _askName('Rename folder', initial: folder.name);
      if (name != null) cubit.renameFolder(folder.id, name);
    }
    if (action == 'child') {
      final name = await _askName('New child folder');
      if (name != null) cubit.addFolder(name, parentId: folder.id);
    }
    if (action == 'up') {
      await cubit.reorderFolder(folder.id, state.folders.indexOf(folder) - 1);
    }
    if (action == 'down') {
      await cubit.reorderFolder(folder.id, state.folders.indexOf(folder) + 1);
    }
    if (action == 'move') {
      final targets = state.collections
          .where((item) => item.id != folder.collectionId)
          .toList();
      if (targets.isNotEmpty && mounted) {
        final target = await showDialog<String>(
          context: context,
          builder: (context) => SimpleDialog(
            title: const Text('Move folder to collection'),
            children: [
              for (final item in targets)
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, item.id),
                  child: Text(item.name),
                ),
            ],
          ),
        );
        if (target != null) await cubit.moveFolder(folder.id, target);
      }
    }
    if (action == 'delete' &&
        await _confirm(
          'Delete folder?',
          'Requests move to the collection root and child folders move up.',
        )) {
      cubit.removeFolder(folder.id);
    }
  }

  Future<void> _addHeader(
    RequestWorkflowState state,
    RequestWorkflowCubit cubit,
  ) async {
    final pair = await _askPair('Add header', allowSecret: true);
    if (pair == null) return;
    final secret = _isSensitive(pair.$1);
    cubit.updateHeaders(<RequestHeaderModel>[
      ...state.request.headers,
      RequestHeaderModel(key: pair.$1, value: pair.$2, isSecret: secret),
    ]);
  }

  Future<void> _configureAuth(
    AuthType type,
    ApiRequestModel request,
    RequestWorkflowCubit cubit,
  ) async {
    if (type == AuthType.none) {
      cubit.updateAuth(const RequestAuthModel());
      return;
    }
    final username = TextEditingController(text: request.auth.username);
    final keyName = TextEditingController(text: request.auth.apiKeyName);
    final secret = TextEditingController();
    final defaultRef = 'request.${request.id}.auth.${type.name}';
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Configure ${type.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (type == AuthType.basic)
              TextField(
                controller: username,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
            if (type == AuthType.apiKeyHeader || type == AuthType.apiKeyQuery)
              TextField(
                controller: keyName,
                decoration: const InputDecoration(labelText: 'API key name'),
              ),
            TextField(
              controller: secret,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Secret value',
                helperText: 'Saved to secure storage only after confirmation.',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save securely'),
          ),
        ],
      ),
    );
    if (result == true) {
      await cubit.configureAuth(
        RequestAuthModel(
          type: type,
          username: username.text,
          passwordSecretRef: type == AuthType.basic ? defaultRef : null,
          tokenSecretRef: type == AuthType.bearer ? defaultRef : null,
          apiKeyName: keyName.text,
          apiKeySecretRef:
              type == AuthType.apiKeyHeader || type == AuthType.apiKeyQuery
              ? defaultRef
              : null,
        ),
        secretValue: secret.text,
      );
    }
    _disposeAfterDialog(<TextEditingController>[username, keyName, secret]);
  }

  Future<void> _sendWithSafety(
    RequestWorkflowCubit cubit,
    RequestWorkflowState requestState,
    WorkspaceState workspace,
  ) async {
    final active = workspace.environments
        .where((item) => item.isActive)
        .firstOrNull;
    if (active != null &&
        RequestSafetyService().needsProductionConfirmation(
          environment: active.kind,
          method: requestState.request.method,
          strictMode: workspace.settings.productionStrictMode,
        )) {
      final host = Uri.tryParse(requestState.request.url)?.host ?? 'this host';
      if (!await _confirm(
        'Production request',
        'Confirm ${requestState.request.method.name.toUpperCase()} to $host.',
      )) {
        return;
      }
    }
    await cubit.send(
      environmentId: active?.id,
      previewLimitBytes: workspace.settings.responsePreviewBytes,
    );
    if (mounted) context.read<WorkspaceCubit>().load();
  }

  Future<void> _saveToken(String body) async {
    final requestCubit = context.read<RequestWorkflowCubit>();
    final values = TokenCandidateService().extract(body);
    if (values.isEmpty) return;
    var path = values.keys.first;
    final destination = TextEditingController(
      text: 'response.token.${DateTime.now().millisecondsSinceEpoch}',
    );
    var consent = false;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Save response token'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: path,
                items: values.keys
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(
                          '$item • ${SecretMasker.mask(values[item]!)}',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => path = value!,
              ),
              TextField(
                controller: destination,
                decoration: const InputDecoration(
                  labelText: 'Secure-storage destination',
                ),
              ),
              CheckboxListTile(
                value: consent,
                onChanged: (value) =>
                    setDialogState(() => consent = value ?? false),
                title: const Text(
                  'I explicitly approve saving this token to secure storage.',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: consent ? () => Navigator.pop(context, true) : null,
              child: const Text('Save token'),
            ),
          ],
        ),
      ),
    );
    if (saved == true && destination.text.trim().isNotEmpty) {
      await requestCubit.saveResponseToken(
        destination.text.trim(),
        values[path]!,
      );
    }
    _disposeAfterDialog(<TextEditingController>[destination]);
  }

  Future<void> _replayHistory(String id) async {
    final request = await context.read<WorkspaceCubit>().replayHistory(id);
    if (request != null && mounted) {
      context.read<RequestWorkflowCubit>().openRequest(request);
      _select(1);
    }
  }

  Future<void> _showHistory(HistoryEntry item) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${item.method.toUpperCase()} ${item.status ?? 'Error'}'),
        content: SizedBox(
          width: 720,
          height: 520,
          child: DefaultTabController(
            length: 4,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Body'),
                    Tab(text: 'Headers'),
                    Tab(text: 'Timeline'),
                    Tab(text: 'Diagnostics'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      SingleChildScrollView(
                        child: SelectableText(
                          item.snapshot['body']?.toString() ?? '',
                        ),
                      ),
                      SingleChildScrollView(
                        child: SelectableText(
                          const JsonEncoder.withIndent(
                            '  ',
                          ).convert(<String, Object?>{
                            'request': item.snapshot['requestHeaders'],
                            'response': item.snapshot['responseHeaders'],
                            'cookies': item.snapshot['cookies'],
                          }),
                        ),
                      ),
                      ListView(
                        children: [
                          ListTile(
                            title: const Text('Recorded'),
                            subtitle: Text(item.createdAt.toLocal().toString()),
                          ),
                          ListTile(
                            title: const Text('Duration'),
                            subtitle: Text('${item.durationMs} ms'),
                          ),
                          ListTile(
                            title: const Text('Size'),
                            subtitle: Text(
                              '${item.snapshot['sizeBytes'] ?? 0} bytes',
                            ),
                          ),
                        ],
                      ),
                      ListView(
                        children: [
                          ListTile(
                            title: Text(
                              item.snapshot['category']?.toString() ??
                                  'No failure category',
                            ),
                            subtitle: Text(
                              item.snapshot['error']?.toString() ??
                                  'No recorded error.',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _copySafe(jsonEncode(item.snapshot)),
            icon: const Icon(Icons.copy_outlined),
            label: const Text('Copy sanitized JSON'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _replayHistory(item.id);
            },
            icon: const Icon(Icons.replay_outlined),
            label: const Text('Replay'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _compareRestHistory(List<HistoryEntry> entries) async {
    if (entries.length != 2) return;
    final before = entries[0];
    final after = entries[1];
    final changes = <ComparisonChange>[
      ...HistoryComparisonService.compareValues(
        <String, Object?>{
          'status': before.status,
          'timingMs': before.durationMs,
          'sizeBytes': before.snapshot['sizeBytes'],
          'headers': before.snapshot['responseHeaders'],
        },
        <String, Object?>{
          'status': after.status,
          'timingMs': after.durationMs,
          'sizeBytes': after.snapshot['sizeBytes'],
          'headers': after.snapshot['responseHeaders'],
        },
      ),
      ...HistoryComparisonService.compareJsonText(
        before.snapshot['body']?.toString() ?? '',
        after.snapshot['body']?.toString() ?? '',
      ).map(
        (item) => ComparisonChange(
          'body${item.path.substring(1)}',
          item.before,
          item.after,
        ),
      ),
    ];
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('REST history comparison'),
        content: SizedBox(
          width: 760,
          height: 500,
          child: changes.isEmpty
              ? const Center(child: Text('No differences.'))
              : ListView(
                  children: changes
                      .map(
                        (item) => ListTile(
                          title: Text(item.path),
                          subtitle: SelectableText(
                            '${item.before}  →  ${item.after}',
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _environmentAction(String action, EnvironmentModel item) async {
    final cubit = context.read<WorkspaceCubit>();
    if (action == 'activate') await cubit.setEnvironment(item.id);
    if (action == 'duplicate') await cubit.duplicateEnvironment(item.id);
    if (action == 'rename') {
      final name = await _askName('Rename environment', initial: item.name);
      if (name != null) cubit.renameEnvironment(item.id, name);
    }
    if (action == 'delete' &&
        await _confirm(
          'Delete environment?',
          'Variables and owned secure-storage references will be removed.',
        )) {
      cubit.removeEnvironment(item.id);
    }
  }

  Future<void> _editVariable([EnvironmentVariableModel? variable]) async {
    final key = TextEditingController(text: variable?.key ?? '');
    final value = TextEditingController(text: variable?.value ?? '');
    var secret = variable?.isSecret ?? false;
    var enabled = variable?.enabled ?? true;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(variable == null ? 'Add variable' : 'Edit variable'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: key,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: value,
                obscureText: secret,
                decoration: InputDecoration(
                  labelText: secret && variable != null
                      ? 'New secret value (leave blank to keep current)'
                      : 'Value',
                ),
              ),
              SwitchListTile(
                value: secret,
                onChanged: (value) => setDialogState(() => secret = value),
                title: const Text('Secret'),
              ),
              SwitchListTile(
                value: enabled,
                onChanged: (value) => setDialogState(() => enabled = value),
                title: const Text('Enabled'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (saved == true && key.text.trim().isNotEmpty && mounted) {
      await context.read<WorkspaceCubit>().saveVariable(
        id: variable?.id,
        key: key.text.trim(),
        value: value.text,
        secret: secret,
        enabled: enabled,
      );
    }
    _disposeAfterDialog(<TextEditingController>[key, value]);
  }

  Future<String?> _askName(String title, {String initial = ''}) async {
    final controller = TextEditingController(text: initial);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    _disposeAfterDialog(<TextEditingController>[controller]);
    return value == null || value.isEmpty ? null : value;
  }

  Future<(String, String)?> _askPair(
    String title, {
    bool allowSecret = false,
  }) async {
    final key = TextEditingController();
    final value = TextEditingController();
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: key,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: value,
              decoration: const InputDecoration(
                labelText: 'Value',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, (key.text.trim(), value.text)),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    _disposeAfterDialog(<TextEditingController>[key, value]);
    return result == null || result.$1.isEmpty ? null : result;
  }

  bool _isSensitive(String value) => RegExp(
    r'authorization|api[-_ ]?key|token|cookie|password',
    caseSensitive: false,
  ).hasMatch(value);
  String _formattedBody(String body, {required bool raw}) {
    if (raw) return body;
    try {
      return const JsonEncoder.withIndent('  ').convert(jsonDecode(body));
    } catch (_) {
      return body;
    }
  }

  Future<void> _copySafe(
    String value, [
    Set<String> sensitiveValues = const <String>{},
  ]) async {
    await Clipboard.setData(
      ClipboardData(
        text: SafeExportService().sanitizedText(value, sensitiveValues),
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sanitized content copied.')),
      );
    }
  }

  Future<void> _exportResponse(
    ApiResponseModel response,
    Set<String> sensitiveValues,
  ) async {
    final file = await SafeExportService().exportResponse(
      response,
      sensitiveValues: sensitiveValues,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sanitized response exported to ${file.path}')),
      );
    }
  }

  Future<bool> _confirm(String title, String message) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ) ??
      false;

  void _disposeAfterDialog(List<TextEditingController> controllers) {
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 400), () {
        for (final controller in controllers) {
          controller.dispose();
        }
      }),
    );
  }
}

Color _httpMethodColor(String method) => switch (method.toUpperCase()) {
  'GET' => const Color(0xFF36C58A),
  'POST' => const Color(0xFF6E8CFF),
  'PUT' || 'PATCH' => const Color(0xFFE5A348),
  'DELETE' => const Color(0xFFE76A76),
  _ => const Color(0xFF9AA4B3),
};

class _HttpMethodBadge extends StatelessWidget {
  const _HttpMethodBadge({required this.method});

  final String method;

  @override
  Widget build(BuildContext context) {
    final normalized = method.toUpperCase();
    final color = _httpMethodColor(normalized);
    return Container(
      constraints: const BoxConstraints(minWidth: 40),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        normalized,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EnvironmentVariableHeader extends StatelessWidget {
  const _EnvironmentVariableHeader();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w800,
      letterSpacing: .65,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        return SizedBox(
          height: 34,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const SizedBox(width: 36),
                SizedBox(
                  width: compact ? 118 : 172,
                  child: Text('KEY', style: style),
                ),
                Expanded(child: Text('VALUE', style: style)),
                if (!compact)
                  SizedBox(width: 72, child: Text('TYPE', style: style)),
                const SizedBox(width: 108),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EnvironmentVariableRow extends StatelessWidget {
  const _EnvironmentVariableRow({
    required this.variable,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
    required this.onEnabled,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDelete,
  });

  final EnvironmentVariableModel variable;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;
  final ValueChanged<bool> onEnabled;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 560;
      final colors = Theme.of(context).colorScheme;
      final value = variable.isSecret
          ? '[SECURE STORAGE REFERENCE]'
          : variable.value;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerTheme.color!,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Checkbox(
                    value: variable.enabled,
                    onChanged: (enabled) => onEnabled(enabled ?? true),
                  ),
                ),
                SizedBox(
                  width: compact ? 118 : 172,
                  child: Text(
                    variable.key,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: variable.isSecret
                          ? colors.onSurfaceVariant
                          : colors.onSurface,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                if (!compact)
                  SizedBox(
                    width: 72,
                    child: Text(
                      variable.isSecret ? 'SECRET' : 'PLAIN',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: variable.isSecret
                            ? colors.tertiary
                            : colors.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .55,
                      ),
                    ),
                  ),
                IconButton(
                  tooltip: 'Move up',
                  onPressed: isFirst ? null : onMoveUp,
                  icon: const Icon(Icons.arrow_upward, size: 16),
                ),
                IconButton(
                  tooltip: 'Move down',
                  onPressed: isLast ? null : onMoveDown,
                  icon: const Icon(Icons.arrow_downward, size: 16),
                ),
                IconButton(
                  tooltip: 'Delete variable',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 17),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _SettingsWorkbenchSection extends StatelessWidget {
  const _SettingsWorkbenchSection({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 860),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerTheme.color!),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    ),
  );
}

class _SettingsNumberRow extends StatelessWidget {
  const _SettingsNumberRow({
    required this.label,
    required this.detail,
    required this.value,
    required this.suffix,
    required this.onSubmitted,
  });

  final String label;
  final String detail;
  final int value;
  final String suffix;
  final ValueChanged<int> onSubmitted;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 2),
              Text(
                detail,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 142,
          child: TextFormField(
            key: ValueKey('$label-$value'),
            initialValue: value.toString(),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              isDense: true,
              suffixText: suffix,
              border: const OutlineInputBorder(),
            ),
            onFieldSubmitted: (text) {
              final parsed = int.tryParse(text);
              if (parsed != null && parsed > 0) onSubmitted(parsed);
            },
          ),
        ),
      ],
    ),
  );
}

class _SettingsSwitchRow extends StatelessWidget {
  const _SettingsSwitchRow({
    required this.icon,
    required this.label,
    required this.detail,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String detail;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
    child: Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 2),
              Text(
                detail,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Switch(value: value, onChanged: onChanged),
      ],
    ),
  );
}

class _SettingsInformationRow extends StatelessWidget {
  const _SettingsInformationRow({
    required this.icon,
    required this.label,
    required this.detail,
  });

  final IconData icon;
  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 9, 14, 12),
    child: Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 2),
              Text(
                detail,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ActivityRail extends StatelessWidget {
  const _ActivityRail({required this.selected, required this.onSelect});
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    // Workspace is a first-class activity. Hiding it behind the Explorer made
    // the default desktop flow harder to discover on compact widths.
    final destinations = <int>[0, 1, 6, 5, 7, 8, 2, 3, 4];
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 48,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          const SizedBox(height: 7),
          Tooltip(
            message: 'DevRoute workspace',
            child: Icon(Icons.route_outlined, color: colors.primary, size: 22),
          ),
          const SizedBox(height: 10),
          for (final index in destinations)
            Tooltip(
              message: _shellDestinations[index].label,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: IconButton(
                  onPressed: () => onSelect(index),
                  style: IconButton.styleFrom(
                    backgroundColor: selected == index
                        ? colors.primary.withValues(alpha: .16)
                        : Colors.transparent,
                    foregroundColor: selected == index
                        ? colors.primary
                        : colors.onSurfaceVariant,
                  ),
                  icon: Icon(
                    selected == index
                        ? _shellDestinations[index].selectedIcon
                        : _shellDestinations[index].icon,
                    size: 20,
                  ),
                ),
              ),
            ),
          const Spacer(),
          Tooltip(
            message: 'Local workspace ready',
            child: Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(bottom: 13),
              decoration: const BoxDecoration(
                color: AppTheme.live,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Legacy navigation implementation retained temporarily while the responsive
// phone shell migrates to the workbench primitives.
// ignore: unused_element
class _NavigationSidebar extends StatelessWidget {
  const _NavigationSidebar({
    required this.expanded,
    required this.selected,
    required this.onSelect,
    required this.onNewRequest,
  });

  final bool expanded;
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onNewRequest;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: expanded ? 264 : 76,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(expanded ? 18 : 14, 20, 14, 16),
            child: expanded
                ? const _BrandLockup()
                : const _BrandMark(compact: true),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: FilledButton.icon(
                onPressed: onNewRequest,
                icon: const Icon(Icons.add_rounded),
                label: const Text('New request'),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: IconButton.filled(
                tooltip: 'New request',
                onPressed: onNewRequest,
                icon: const Icon(Icons.add_rounded),
              ),
            ),
          const Divider(indent: 14, endIndent: 14),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
              children: [
                for (var index = 0; index < _shellDestinations.length; index++)
                  _SidebarItem(
                    destination: _shellDestinations[index],
                    selected: selected == index,
                    expanded: expanded,
                    onTap: () => onSelect(index),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(expanded ? 18 : 14, 12, 14, 20),
            child: expanded
                ? Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.live,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Local workspace ready',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ),
                    ],
                  )
                : Tooltip(
                    message: 'Local workspace ready',
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: AppTheme.live,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const _BrandMark(),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DevRoute', style: Theme.of(context).textTheme.titleLarge),
          Text(
            'API STUDIO',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.25,
            ),
          ),
        ],
      ),
    ],
  );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 42.0 : 38.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(compact ? 14 : 13),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9BBCFF), Color(0xFF4E72F2)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x5C4E72F2),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(Icons.route_rounded, color: Color(0xFFF8FAFF)),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.destination,
    required this.selected,
    required this.expanded,
    required this.onTap,
  });

  final _ShellDestination destination;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final icon = selected ? destination.selectedIcon : destination.icon;
    final content = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: expanded ? 12 : 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: selected
                ? colors.primary.withValues(alpha: 0.16)
                : Colors.transparent,
          ),
          child: expanded
              ? Row(
                  children: [
                    Icon(icon, color: selected ? colors.primary : null),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        destination.label,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: selected ? colors.onSurface : null,
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Icon(icon, color: selected ? colors.primary : null),
                ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: expanded
          ? content
          : Tooltip(message: destination.label, child: content),
    );
  }
}

class _WorkspaceToolbar extends StatelessWidget {
  const _WorkspaceToolbar({
    required this.destination,
    required this.onNewRequest,
    required this.onCommandPalette,
    required this.sidebarAvailable,
    required this.sidebarVisible,
    required this.onToggleSidebar,
  });

  final _ShellDestination destination;
  final VoidCallback onNewRequest;
  final VoidCallback onCommandPalette;
  final bool sidebarAvailable;
  final bool sidebarVisible;
  final VoidCallback onToggleSidebar;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
      ),
      child: Row(
        children: [
          if (sidebarAvailable)
            IconButton(
              tooltip: sidebarVisible
                  ? 'Hide explorer (Ctrl+B)'
                  : 'Show explorer (Ctrl+B)',
              onPressed: onToggleSidebar,
              icon: Icon(
                sidebarVisible
                    ? Icons.vertical_split_outlined
                    : Icons.view_sidebar_outlined,
                size: 18,
              ),
            ),
          if (sidebarAvailable) const SizedBox(width: 5),
          Icon(destination.selectedIcon, color: colors.primary, size: 18),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              destination.label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          _EnvironmentMenu(),
          const SizedBox(width: 6),
          Tooltip(
            message: 'Command palette (Ctrl+K)',
            child: OutlinedButton.icon(
              onPressed: onCommandPalette,
              icon: const Icon(Icons.search_rounded, size: 17),
              label: const Text('Search'),
            ),
          ),
          const SizedBox(width: 4),
          PopupMenuButton<ThemeMode>(
            tooltip: 'Appearance',
            icon: const Icon(Icons.brightness_6_outlined, size: 18),
            onSelected: (mode) => DevRouteAppearance.mode.value = mode,
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: ThemeMode.system,
                child: Text('System appearance'),
              ),
              PopupMenuItem(
                value: ThemeMode.light,
                child: Text('Light appearance'),
              ),
              PopupMenuItem(
                value: ThemeMode.dark,
                child: Text('Dark appearance'),
              ),
            ],
          ),
          const SizedBox(width: 4),
          Tooltip(
            message: 'New request',
            child: FilledButton.icon(
              onPressed: onNewRequest,
              icon: const Icon(Icons.add_rounded, size: 17),
              label: const Text('New'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnvironmentMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final workspace = context.watch<WorkspaceCubit>().state;
    final active = workspace.environments
        .where((item) => item.id == workspace.selectedEnvironmentId)
        .firstOrNull;
    final production = active?.kind == EnvironmentKind.production;
    final dot = production ? const Color(0xFFE5A348) : AppTheme.live;
    return PopupMenuButton<String>(
      tooltip: 'Active environment',
      enabled: workspace.environments.isNotEmpty,
      onSelected: (id) => context.read<WorkspaceCubit>().setEnvironment(id),
      itemBuilder: (_) => [
        for (final environment in workspace.environments)
          PopupMenuItem(
            value: environment.id,
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: environment.kind == EnvironmentKind.production
                      ? const Color(0xFFE5A348)
                      : AppTheme.live,
                ),
                const SizedBox(width: 8),
                Text(environment.name),
                if (environment.isActive) ...[
                  const Spacer(),
                  const Icon(Icons.check, size: 16),
                ],
              ],
            ),
          ),
      ],
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: production
                ? const Color(0xFFE5A348).withValues(alpha: .65)
                : Theme.of(context).dividerTheme.color!,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 7, color: dot),
            const SizedBox(width: 6),
            Text(
              active?.name ?? 'No environment',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const Icon(Icons.arrow_drop_down, size: 16),
          ],
        ),
      ),
    );
  }
}
