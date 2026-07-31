import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/models/api_models.dart';
import '../data/graphql_repository.dart';
import '../application/graphql_schema_cubit.dart';
import '../application/graphql_subscription_service.dart';
import '../domain/graphql_document_parser.dart';
import '../domain/graphql_models.dart';
import 'graphql_history_comparison_view.dart';
import 'graphql_response_panel.dart';
import 'graphql_schema_panel.dart';
import 'graphql_subscription_panel.dart';
import 'graphql_workflow_cubit.dart';
import '../../workspace/presentation/workspace_cubit.dart';

/// Presentation-only GraphQL editor. Execution and cancellation belong to the
/// workflow/application layers so every tab remains isolated.
class GraphqlScreen extends StatefulWidget {
  const GraphqlScreen({super.key});
  @override
  State<GraphqlScreen> createState() => _GraphqlScreenState();
}

class _GraphqlScreenState extends State<GraphqlScreen> {
  final _endpoint = TextEditingController();
  final _document = TextEditingController();
  final _variables = TextEditingController();
  final _headers = TextEditingController();
  final _extensions = TextEditingController();
  final _secretRef = TextEditingController();
  final _username = TextEditingController();
  final _search = TextEditingController();

  @override
  void dispose() {
    _endpoint.dispose();
    _document.dispose();
    _variables.dispose();
    _headers.dispose();
    _extensions.dispose();
    _secretRef.dispose();
    _username.dispose();
    _search.dispose();
    super.dispose();
  }

  void _sync(
    String endpoint,
    String document,
    Map<String, Object?> variables,
    Map<String, String> headers,
    Map<String, Object?> extensions,
    RequestAuthModel auth,
  ) {
    if (_endpoint.text != endpoint) _endpoint.text = endpoint;
    if (_document.text != document) _document.text = document;
    final encoded = const JsonEncoder().convert(variables);
    if (_variables.text != encoded) _variables.text = encoded;
    final headerText = const JsonEncoder().convert(headers);
    if (_headers.text != headerText) _headers.text = headerText;
    final extensionText = const JsonEncoder().convert(extensions);
    if (_extensions.text != extensionText) _extensions.text = extensionText;
    if (_secretRef.text !=
        (auth.tokenSecretRef ??
            auth.passwordSecretRef ??
            auth.apiKeySecretRef ??
            '')) {
      _secretRef.text =
          auth.tokenSecretRef ??
          auth.passwordSecretRef ??
          auth.apiKeySecretRef ??
          '';
    }
    if (_username.text != auth.username) _username.text = auth.username;
  }

  Future<void> _openSchemaExplorer(
    BuildContext context,
    GraphqlRequest request,
    GraphqlWorkflowCubit cubit,
  ) async {
    final size = MediaQuery.sizeOf(context);
    final schemaCubit = context.read<GraphqlSchemaCubit>();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: schemaCubit,
        child: Dialog(
          child: SizedBox(
            width: size.width * 0.94,
            height: size.height * 0.9,
            child: GraphqlSchemaPanel(
              request: request,
              onUseOperation: (document) {
                cubit.updateDocument(document);
                Navigator.pop(dialogContext);
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    String cancelLabel = 'Cancel',
    String confirmLabel = 'Continue',
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(cancelLabel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(confirmLabel),
            ),
          ],
        ),
      ) ??
      false;

  Future<String?> _askName(
    BuildContext context, {
    required String title,
    String initial = '',
    String confirmLabel = 'Save',
  }) async {
    final controller = TextEditingController(text: initial);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setDialogState(() {}),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) Navigator.pop(context, value);
            },
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: controller.text.trim().isEmpty
                  ? null
                  : () => Navigator.pop(dialogContext, controller.text),
              child: Text(confirmLabel),
            ),
          ],
        ),
      ),
    );
    unawaited(
      Future<void>.delayed(
        const Duration(milliseconds: 300),
        controller.dispose,
      ),
    );
    return result;
  }

  Future<void> _closeTab(
    BuildContext context,
    GraphqlWorkflowCubit cubit,
    GraphqlDraft tab,
  ) async {
    final subscriptionCubit = context.read<GraphqlSubscriptionCubit>();
    if (tab.isDirty) {
      final choice = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Unsaved GraphQL changes'),
          content: Text('Save changes to "${tab.title}" before closing?'),
          actionsOverflowDirection: VerticalDirection.down,
          actionsOverflowAlignment: OverflowBarAlignment.end,
          actionsOverflowButtonSpacing: 8,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'discard'),
              child: const Text('Discard'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, 'save'),
              child: const Text('Save'),
            ),
          ],
        ),
      );
      if (choice == null || choice == 'cancel') return;
      if (choice == 'save') {
        if (!context.mounted) return;
        final saved = await _saveTab(context, cubit, tab);
        if (!saved || !context.mounted) return;
      }
    }
    if (subscriptionCubit.state[tab.id]?.isActive == true) {
      subscriptionCubit.stop(tab.id);
    }
    await cubit.closeTab(tab.id, discardChanges: true);
  }

  Future<bool> _saveTab(
    BuildContext context,
    GraphqlWorkflowCubit cubit,
    GraphqlDraft tab,
  ) async {
    if (tab.savedRequestId == null) {
      final name = await _askName(
        context,
        title: 'Save GraphQL request',
        initial: tab.title == 'Untitled GraphQL request' ? '' : tab.title,
      );
      if (name == null || name.trim().isEmpty) return false;
      try {
        await cubit.saveTab(tab.id, name: name.trim());
        return true;
      } on Object catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not save GraphQL request: $error')),
          );
        }
        return false;
      }
    }
    try {
      await cubit.saveTab(tab.id);
      return true;
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save GraphQL request: $error')),
        );
      }
      return false;
    }
  }

  Future<void> _renameSavedRequest(
    BuildContext context,
    GraphqlWorkflowCubit cubit,
    GraphqlSavedRequest request,
  ) async {
    final name = await _askName(
      context,
      title: 'Rename saved request',
      initial: request.name,
    );
    if (name == null) return;
    try {
      await cubit.renameSavedRequest(request.id, name);
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not rename request: $error')),
        );
      }
    }
  }

  Future<void> _deleteSavedRequest(
    BuildContext context,
    GraphqlWorkflowCubit cubit,
    GraphqlSavedRequest request,
  ) async {
    final hasDirtyLinkedTab = cubit.state.tabs.any(
      (tab) => tab.savedRequestId == request.id && tab.isDirty,
    );
    final delete = await _confirm(
      context,
      title: hasDirtyLinkedTab
          ? 'Delete saved request and keep draft?'
          : 'Delete saved request?',
      message: hasDirtyLinkedTab
          ? 'Unsaved edits will remain in an independent draft. The tab will not close.'
          : 'Deleting "${request.name}" removes the saved request from the workspace. Open tabs keep their current draft state.',
      confirmLabel: hasDirtyLinkedTab ? 'Delete and keep draft' : 'Delete',
    );
    if (!delete) return;
    await cubit.deleteSavedRequest(request.id);
  }

  Future<void> _moveSavedRequest(
    BuildContext context,
    GraphqlWorkflowCubit cubit,
    WorkspaceState workspace,
    GraphqlSavedRequest request,
  ) async {
    const root = '__workspace_root__';
    final collectionId = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Move saved request'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, root),
            child: const Text('Workspace root (unfiled)'),
          ),
          for (final collection in workspace.collections)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, collection.id),
              child: Text(collection.name),
            ),
        ],
      ),
    );
    if (collectionId == null) return;
    if (!context.mounted) return;

    String? folderId;
    if (collectionId != root) {
      final folders = await context.read<WorkspaceCubit>().foldersForCollection(
        collectionId,
      );
      if (!context.mounted) return;
      folderId = await showDialog<String?>(
        context: context,
        builder: (dialogContext) => SimpleDialog(
          title: const Text('Choose folder'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Collection root'),
            ),
            for (final folder in folders)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, folder.id),
                child: Text(folder.name),
              ),
          ],
        ),
      );
    }
    if (!context.mounted) return;

    try {
      await cubit.moveSavedRequest(
        request.id,
        collectionId: collectionId == root ? null : collectionId,
        folderId: folderId,
        clearCollection: collectionId == root,
        clearFolder: folderId == null,
      );
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not move request: $error')),
        );
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<GraphqlWorkflowCubit, GraphqlWorkflowState>(
    builder: (context, state) {
      final cubit = context.read<GraphqlWorkflowCubit>();
      final workspace = context.watch<WorkspaceCubit>().state;
      final draft = state.active;
      final execution = state.executionFor(draft.id);
      _sync(
        draft.request.endpoint,
        draft.request.document,
        draft.request.variables,
        draft.request.headers,
        draft.request.extensions,
        draft.request.auth,
      );
      final analysis = GraphqlDocumentParser.analyze(draft.request.document);
      final selectedOperation = GraphqlDocumentParser.select(
        analysis,
        draft.request.operationName,
      );
      final subscriptionCubit = context.read<GraphqlSubscriptionCubit>();
      final subscription =
          subscriptionCubit.state[draft.id] ??
          const GraphqlSubscriptionTabState();
      final editor = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GraphQL Studio',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Wrap(
            spacing: 6,
            children: [
              for (var i = 0; i < state.tabs.length; i++)
                InputChip(
                  label: Text(
                    '${state.tabs[i].isDirty ? '* ' : ''}${state.tabs[i].title}',
                  ),
                  selected: i == state.activeIndex,
                  onPressed: () => cubit.selectTab(i),
                  deleteButtonTooltipMessage: 'Close GraphQL tab',
                  onDeleted: () => _closeTab(context, cubit, state.tabs[i]),
                ),
              ActionChip(label: const Text('+'), onPressed: cubit.newDraft),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _endpoint,
            onChanged: cubit.updateEndpoint,
            decoration: const InputDecoration(
              labelText: 'Endpoint',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: ValueKey<String>(draft.id),
            initialValue: draft.request.operationName,
            decoration: const InputDecoration(
              labelText: 'Operation',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final op in analysis.operations)
                DropdownMenuItem(value: op.name, child: Text(op.label)),
            ],
            onChanged: cubit.selectOperation,
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Use HTTP GET (queries only)'),
            value: draft.request.useGet,
            onChanged: cubit.updateUseGet,
          ),
          DropdownButtonFormField<AuthType>(
            key: ValueKey<String>('auth-${draft.id}'),
            initialValue: draft.request.auth.type,
            decoration: const InputDecoration(
              labelText: 'Authentication',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final type in AuthType.values)
                DropdownMenuItem(value: type, child: Text(type.name)),
            ],
            onChanged: (type) {
              if (type != null) {
                cubit.updateAuth(
                  RequestAuthModel(
                    type: type,
                    username: draft.request.auth.username,
                    passwordSecretRef: draft.request.auth.passwordSecretRef,
                    tokenSecretRef: draft.request.auth.tokenSecretRef,
                    apiKeyName: draft.request.auth.apiKeyName,
                    apiKeySecretRef: draft.request.auth.apiKeySecretRef,
                  ),
                );
              }
            },
          ),
          if (draft.request.auth.type == AuthType.basic)
            TextField(
              controller: _username,
              onChanged: (value) => cubit.updateAuth(
                RequestAuthModel(
                  type: draft.request.auth.type,
                  username: value,
                  passwordSecretRef: draft.request.auth.passwordSecretRef,
                ),
              ),
              decoration: const InputDecoration(
                labelText: 'Basic username',
                border: OutlineInputBorder(),
              ),
            ),
          if (draft.request.auth.type != AuthType.none)
            TextField(
              controller: _secretRef,
              onChanged: (value) => cubit.updateAuth(
                RequestAuthModel(
                  type: draft.request.auth.type,
                  username: draft.request.auth.username,
                  passwordSecretRef: draft.request.auth.type == AuthType.basic
                      ? value
                      : draft.request.auth.passwordSecretRef,
                  tokenSecretRef: draft.request.auth.type == AuthType.bearer
                      ? value
                      : draft.request.auth.tokenSecretRef,
                  apiKeyName: draft.request.auth.apiKeyName,
                  apiKeySecretRef:
                      draft.request.auth.type == AuthType.apiKeyHeader ||
                          draft.request.auth.type == AuthType.apiKeyQuery
                      ? value
                      : draft.request.auth.apiKeySecretRef,
                ),
              ),
              decoration: const InputDecoration(
                labelText: 'Secure reference (never the secret value)',
                border: OutlineInputBorder(),
              ),
            ),
          TextField(
            controller: _headers,
            minLines: 2,
            maxLines: 4,
            onChanged: (value) {
              try {
                final decoded = jsonDecode(value);
                if (decoded is Map) {
                  cubit.updateHeaders(
                    decoded.map(
                      (key, item) => MapEntry(key.toString(), item.toString()),
                    ),
                  );
                }
              } on FormatException {
                // Keep invalid JSON visible until corrected.
              }
            },
            decoration: const InputDecoration(
              labelText: 'Enabled headers JSON',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _extensions,
            minLines: 2,
            maxLines: 4,
            onChanged: (value) {
              try {
                final decoded = jsonDecode(value);
                if (decoded is Map) {
                  cubit.updateExtensions(decoded.cast<String, Object?>());
                }
              } on FormatException {
                // Keep invalid JSON visible until corrected.
              }
            },
            decoration: const InputDecoration(
              labelText: 'Extensions JSON',
              border: OutlineInputBorder(),
            ),
          ),
          if (analysis.errors.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                analysis.errors.join('\n'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            height: 260,
            child: TextField(
              controller: _document,
              maxLines: null,
              expands: true,
              onChanged: cubit.updateDocument,
              decoration: const InputDecoration(
                labelText: 'GraphQL document',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _variables,
            minLines: 3,
            maxLines: 6,
            onChanged: (value) {
              try {
                final decoded = jsonDecode(value);
                if (decoded is Map) {
                  cubit.updateVariables(decoded.cast<String, Object?>());
                }
              } on FormatException {
                // Keep the invalid editor text so the user can correct it.
              }
            },
            decoration: const InputDecoration(
              labelText: 'Variables JSON',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed:
                    selectedOperation?.type ==
                            GraphqlOperationType.subscription ||
                        execution.isActive
                    ? null
                    : cubit.executeActive,
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  selectedOperation?.type == GraphqlOperationType.subscription
                      ? 'Use Connect'
                      : execution.isActive
                      ? 'Executing'
                      : 'Execute',
                ),
              ),
              OutlinedButton.icon(
                onPressed: execution.isActive
                    ? () => cubit.cancelTab(draft.id)
                    : null,
                icon: const Icon(Icons.stop),
                label: const Text('Cancel'),
              ),
              OutlinedButton.icon(
                onPressed: () => _saveTab(context, cubit, draft),
                icon: const Icon(Icons.save_outlined),
                label: Text(
                  draft.savedRequestId == null ? 'Save as new' : 'Save',
                ),
              ),
              OutlinedButton.icon(
                key: const Key('open-graphql-schema-explorer'),
                onPressed: () =>
                    _openSchemaExplorer(context, draft.request, cubit),
                icon: const Icon(Icons.account_tree_outlined),
                label: const Text('Schema Explorer'),
              ),
            ],
          ),
        ],
      );
      final response =
          selectedOperation?.type == GraphqlOperationType.subscription
          ? GraphqlSubscriptionPanel(
              key: ValueKey<String>('subscription-${draft.id}'),
              tabId: draft.id,
              state: subscription,
              onConnect: (policy) => subscriptionCubit.connect(
                draft.id,
                draft.request,
                environmentId: draft.environmentId,
                reconnectPolicy: policy,
              ),
              onDisconnect: () => subscriptionCubit.disconnect(draft.id),
              onReconnect: () => subscriptionCubit.reconnect(draft.id),
              onStop: () => subscriptionCubit.stop(draft.id),
              onClear: () => subscriptionCubit.clear(draft.id),
            )
          : GraphqlResponsePanel(execution: execution);
      final saved = _SavedRequestPanel(
        requests: state.savedRequests,
        workspace: workspace,
        search: _search,
        onSearch: cubit.refreshSavedRequests,
        onOpen: cubit.openSavedRequest,
        onRename: (request) => _renameSavedRequest(context, cubit, request),
        onMove: (request) =>
            _moveSavedRequest(context, cubit, workspace, request),
        onReorder: cubit.reorderSavedRequest,
        onDuplicate: cubit.duplicateSavedRequest,
        onDelete: (request) => _deleteSavedRequest(context, cubit, request),
        busyIds: state.busySavedRequestIds,
      );
      final history = _HistoryPanel(
        entries: state.history,
        totalEntries: state.allHistory.length,
        query: state.historyQuery,
        outcome: state.historyOutcomeFilter,
        operationType: state.historyOperationTypeFilter,
        endpoint: state.historyEndpointFilter,
        endpoints: state.availableHistoryEndpoints,
        hasActiveFilters: state.hasActiveHistoryFilters,
        onSearch: cubit.setHistoryQuery,
        onOutcome: cubit.setHistoryOutcomeFilter,
        onOperationType: cubit.setHistoryOperationTypeFilter,
        onEndpoint: cubit.setHistoryEndpointFilter,
        onClearFilters: cubit.clearHistoryFilters,
        onReplay: cubit.replayHistory,
        onDelete: (entry) => cubit.deleteHistory(entry.id),
      );
      return MediaQuery.sizeOf(context).width < 900
          ? ListView(
              children: [
                editor,
                const Divider(),
                SizedBox(height: 320, child: response),
                const Divider(),
                SizedBox(height: 260, child: saved),
                const Divider(),
                SizedBox(
                  height: MediaQuery.sizeOf(context).width < 500 ? 420 : 312,
                  child: history,
                ),
              ],
            )
          : Row(
              children: [
                SizedBox(
                  width: 280,
                  child: Column(
                    children: [
                      Expanded(flex: 2, child: saved),
                      const Divider(),
                      Expanded(flex: 3, child: history),
                    ],
                  ),
                ),
                const VerticalDivider(),
                Expanded(child: SingleChildScrollView(child: editor)),
                const VerticalDivider(),
                Expanded(child: response),
              ],
            );
    },
  );
}

class _SavedRequestPanel extends StatelessWidget {
  const _SavedRequestPanel({
    required this.workspace,
    required this.requests,
    required this.search,
    required this.onSearch,
    required this.onOpen,
    required this.onRename,
    required this.onMove,
    required this.onReorder,
    required this.onDuplicate,
    required this.onDelete,
    required this.busyIds,
  });

  final WorkspaceState workspace;
  final List<GraphqlSavedRequest> requests;
  final TextEditingController search;
  final ValueChanged<String> onSearch;
  final ValueChanged<GraphqlSavedRequest> onOpen;
  final Future<void> Function(GraphqlSavedRequest) onRename;
  final Future<void> Function(GraphqlSavedRequest) onMove;
  final Future<void> Function(String id, int order) onReorder;
  final Future<void> Function(String id) onDuplicate;
  final Future<void> Function(GraphqlSavedRequest) onDelete;
  final Set<String> busyIds;

  String _collectionLabel(GraphqlSavedRequest request) {
    if (request.collectionId == null) return 'Workspace root';
    for (final collection in workspace.collections) {
      if (collection.id == request.collectionId) return collection.name;
    }
    return 'Collection ${request.collectionId}';
  }

  String _folderLabel(GraphqlSavedRequest request) {
    if (request.folderId == null) return 'Root folder';
    for (final folder in workspace.folders) {
      if (folder.id == request.folderId) return folder.name;
    }
    return 'Folder ${request.folderId}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Saved requests', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: search,
          onChanged: onSearch,
          decoration: const InputDecoration(
            isDense: true,
            prefixIcon: Icon(Icons.search),
            hintText: 'Search',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: ListView(
            children: [
              for (final request in requests)
                ListTile(
                  dense: true,
                  title: Text(request.name),
                  subtitle: Text(
                    '${request.request.endpoint}\n${_collectionLabel(request)} - ${_folderLabel(request)}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => onOpen(request),
                  trailing: PopupMenuButton<String>(
                    tooltip: 'Saved request actions',
                    enabled: !busyIds.contains(request.id),
                    onSelected: (action) =>
                        unawaited(_runAction(context, request, action)),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'open', child: Text('Open')),
                      const PopupMenuItem(
                        value: 'rename',
                        child: Text('Rename'),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Text('Duplicate'),
                      ),
                      const PopupMenuItem(value: 'move', child: Text('Move')),
                      PopupMenuItem(
                        value: 'up',
                        enabled: _locationIndex(request) > 0,
                        child: const Text('Move up'),
                      ),
                      PopupMenuItem(
                        value: 'down',
                        enabled:
                            _locationIndex(request) <
                            _locationCount(request) - 1,
                        child: const Text('Move down'),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  int _locationIndex(GraphqlSavedRequest request) => requests
      .where(
        (item) =>
            item.collectionId == request.collectionId &&
            item.folderId == request.folderId,
      )
      .toList()
      .indexWhere((item) => item.id == request.id);

  int _locationCount(GraphqlSavedRequest request) => requests
      .where(
        (item) =>
            item.collectionId == request.collectionId &&
            item.folderId == request.folderId,
      )
      .length;

  Future<void> _runAction(
    BuildContext context,
    GraphqlSavedRequest request,
    String action,
  ) async {
    try {
      switch (action) {
        case 'open':
          onOpen(request);
          return;
        case 'rename':
          await onRename(request);
          return;
        case 'duplicate':
          await onDuplicate(request.id);
          return;
        case 'move':
          await onMove(request);
          return;
        case 'up':
          await onReorder(request.id, _locationIndex(request) - 1);
          return;
        case 'down':
          await onReorder(request.id, _locationIndex(request) + 1);
          return;
        case 'delete':
          await onDelete(request);
          return;
      }
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved request operation failed: $error')),
        );
      }
    }
  }
}

class _HistoryPanel extends StatefulWidget {
  const _HistoryPanel({
    required this.entries,
    required this.totalEntries,
    required this.query,
    required this.outcome,
    required this.operationType,
    required this.endpoint,
    required this.endpoints,
    required this.hasActiveFilters,
    required this.onSearch,
    required this.onOutcome,
    required this.onOperationType,
    required this.onEndpoint,
    required this.onClearFilters,
    required this.onReplay,
    required this.onDelete,
  });

  final List<GraphqlHistoryEntry> entries;
  final int totalEntries;
  final String query;
  final GraphqlHistoryOutcomeFilter outcome;
  final GraphqlOperationType? operationType;
  final String? endpoint;
  final List<String> endpoints;
  final bool hasActiveFilters;
  final ValueChanged<String> onSearch;
  final ValueChanged<GraphqlHistoryOutcomeFilter> onOutcome;
  final ValueChanged<GraphqlOperationType?> onOperationType;
  final ValueChanged<String?> onEndpoint;
  final VoidCallback onClearFilters;
  final ValueChanged<GraphqlHistoryEntry> onReplay;
  final ValueChanged<GraphqlHistoryEntry> onDelete;

  @override
  State<_HistoryPanel> createState() => _HistoryPanelState();
}

class _HistoryPanelState extends State<_HistoryPanel> {
  final _search = TextEditingController();
  final Set<String> _comparisonIds = <String>{};

  @override
  void initState() {
    super.initState();
    _search.text = widget.query;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _HistoryPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final validIds = widget.entries.map((entry) => entry.id).toSet();
    _comparisonIds.removeWhere((id) => !validIds.contains(id));
    if (_search.text != widget.query) _search.text = widget.query;
  }

  void _toggleComparison(GraphqlHistoryEntry entry, bool selected) {
    setState(() {
      if (!selected) {
        _comparisonIds.remove(entry.id);
        return;
      }
      if (_comparisonIds.length == 2) {
        _comparisonIds.remove(_comparisonIds.first);
      }
      _comparisonIds.add(entry.id);
    });
  }

  Future<void> _showComparison() async {
    if (_comparisonIds.length != 2) return;

    final selected = _comparisonIds
        .map((id) => widget.entries.firstWhere((entry) => entry.id == id))
        .toList(growable: false);
    final size = MediaQuery.sizeOf(context);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: SizedBox(
          width: size.width * 0.9,
          height: size.height * 0.85,
          child: GraphqlHistoryComparisonView(
            before: selected[0],
            after: selected[1],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('GraphQL history', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 6),
      TextField(
        key: const Key('graphql-history-search'),
        controller: _search,
        onChanged: widget.onSearch,
        decoration: const InputDecoration(
          isDense: true,
          prefixIcon: Icon(Icons.search),
          hintText: 'Search history',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 4),
      LayoutBuilder(
        builder: (context, constraints) {
          final filters = <Widget>[
            SizedBox(
              width: constraints.maxWidth < 320 ? constraints.maxWidth : null,
              child: DropdownButton<GraphqlHistoryOutcomeFilter>(
                key: const Key('graphql-history-outcome-filter'),
                isExpanded: constraints.maxWidth < 320,
                value: widget.outcome,
                onChanged: (value) {
                  if (value != null) widget.onOutcome(value);
                },
                items: GraphqlHistoryOutcomeFilter.values
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(_outcomeLabel(value)),
                      ),
                    )
                    .toList(),
              ),
            ),
            SizedBox(
              width: constraints.maxWidth < 320 ? constraints.maxWidth : null,
              child: DropdownButton<GraphqlOperationType?>(
                key: const Key('graphql-history-operation-filter'),
                isExpanded: constraints.maxWidth < 320,
                value: widget.operationType,
                onChanged: widget.onOperationType,
                items: <DropdownMenuItem<GraphqlOperationType?>>[
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All operations'),
                  ),
                  ...GraphqlOperationType.values.map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value.name)),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: constraints.maxWidth < 500 ? constraints.maxWidth : null,
              child: DropdownButton<String?>(
                key: const Key('graphql-history-endpoint-filter'),
                isExpanded: constraints.maxWidth < 500,
                value: widget.endpoint,
                onChanged: widget.onEndpoint,
                items: <DropdownMenuItem<String?>>[
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All endpoints'),
                  ),
                  ...widget.endpoints.map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(
                        _safeEndpointLabel(value),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.hasActiveFilters)
              TextButton(
                key: const Key('graphql-history-clear-filters'),
                onPressed: widget.onClearFilters,
                child: const Text('Clear filters'),
              ),
            Text(
              'Showing ${widget.entries.length} of ${widget.totalEntries}',
              key: const Key('graphql-history-result-count'),
            ),
          ];
          return Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: filters,
          );
        },
      ),
      Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          FilledButton.tonalIcon(
            key: const Key('open-graphql-history-comparison'),
            onPressed: _comparisonIds.length == 2 ? _showComparison : null,
            icon: const Icon(Icons.compare_arrows),
            label: const Text('Compare'),
          ),
          Text('${_comparisonIds.length}/2 selected'),
          if (_comparisonIds.isNotEmpty)
            TextButton(
              onPressed: () => setState(_comparisonIds.clear),
              child: const Text('Clear'),
            ),
        ],
      ),
      const SizedBox(height: 4),
      Expanded(
        child: ListView(
          children: [
            for (final entry in widget.entries)
              ListTile(
                dense: true,
                leading: Checkbox(
                  value: _comparisonIds.contains(entry.id),
                  onChanged: (selected) =>
                      _toggleComparison(entry, selected ?? false),
                ),
                title: Text(entry.operationType.name),
                subtitle: Text(
                  '${entry.summary['statusCode'] ?? '-'} - ${entry.createdAt.toLocal()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => widget.onReplay(entry),
                trailing: IconButton(
                  tooltip: 'Delete history',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => widget.onDelete(entry),
                ),
              ),
          ],
        ),
      ),
    ],
  );

  static String _outcomeLabel(GraphqlHistoryOutcomeFilter value) =>
      switch (value) {
        GraphqlHistoryOutcomeFilter.all => 'All outcomes',
        GraphqlHistoryOutcomeFilter.success => 'Success',
        GraphqlHistoryOutcomeFilter.graphqlError => 'GraphQL error',
        GraphqlHistoryOutcomeFilter.transportFailure => 'Transport failure',
        GraphqlHistoryOutcomeFilter.cancelled => 'Cancelled',
      };

  static String _safeEndpointLabel(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return value.split('?').first;
    return uri.replace(query: '', fragment: '').toString();
  }
}
