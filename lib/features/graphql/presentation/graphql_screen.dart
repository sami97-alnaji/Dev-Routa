import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/models/api_models.dart';
import '../data/graphql_repository.dart';
import '../application/graphql_subscription_service.dart';
import '../domain/graphql_document_parser.dart';
import '../domain/graphql_models.dart';
import 'graphql_workflow_cubit.dart';

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

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<GraphqlWorkflowCubit, GraphqlWorkflowState>(
    builder: (context, state) {
      final cubit = context.read<GraphqlWorkflowCubit>();
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
                    '${state.tabs[i].isDirty ? '• ' : ''}${state.tabs[i].title}',
                  ),
                  selected: i == state.activeIndex,
                  onPressed: () => cubit.selectTab(i),
                  onDeleted: () => cubit.closeActive(discardChanges: true),
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
          Expanded(
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
          Row(
            children: [
              if (selectedOperation?.type == GraphqlOperationType.subscription)
                OutlinedButton.icon(
                  onPressed: subscription.isActive
                      ? () => subscriptionCubit.disconnect(draft.id)
                      : () =>
                            subscriptionCubit.connect(draft.id, draft.request),
                  icon: Icon(subscription.isActive ? Icons.stop : Icons.wifi),
                  label: Text(subscription.isActive ? 'Disconnect' : 'Connect'),
                ),
              if (selectedOperation?.type == GraphqlOperationType.subscription)
                const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: execution.isActive ? null : cubit.executeActive,
                icon: const Icon(Icons.play_arrow),
                label: Text(execution.isActive ? 'Executing' : 'Execute'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: execution.isActive
                    ? () => cubit.cancelTab(draft.id)
                    : null,
                icon: const Icon(Icons.stop),
                label: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => cubit.saveActive(),
                icon: const Icon(Icons.save_outlined),
                label: Text(
                  draft.savedRequestId == null ? 'Save as new' : 'Save',
                ),
              ),
            ],
          ),
          if (selectedOperation?.type == GraphqlOperationType.subscription)
            Text(
              'Subscription: ${subscription.phase.name} · events ${subscription.events.length} · dropped ${subscription.droppedEvents}',
            ),
        ],
      );
      final response = _ResponsePanel(execution: execution);
      final saved = _SavedRequestPanel(
        requests: state.savedRequests,
        search: _search,
        onSearch: cubit.refreshSavedRequests,
        onOpen: cubit.openSavedRequest,
        onDuplicate: cubit.duplicateSavedRequest,
        onDelete: cubit.deleteSavedRequest,
      );
      final history = _HistoryPanel(
        entries: state.history,
        onSearch: cubit.refreshHistory,
        onReplay: cubit.replayHistory,
        onDelete: (entry) => cubit.deleteHistory(entry.id),
      );
      return MediaQuery.sizeOf(context).width < 900
          ? Column(
              children: [
                Expanded(flex: 3, child: editor),
                const Divider(),
                Expanded(child: response),
                const Divider(),
                SizedBox(height: 180, child: saved),
                const Divider(),
                SizedBox(height: 180, child: history),
              ],
            )
          : Row(
              children: [
                SizedBox(
                  width: 280,
                  child: Column(
                    children: [
                      Expanded(child: saved),
                      const Divider(),
                      Expanded(child: history),
                    ],
                  ),
                ),
                const VerticalDivider(),
                Expanded(child: editor),
                const VerticalDivider(),
                Expanded(child: response),
              ],
            );
    },
  );
}

class _SavedRequestPanel extends StatelessWidget {
  const _SavedRequestPanel({
    required this.requests,
    required this.search,
    required this.onSearch,
    required this.onOpen,
    required this.onDuplicate,
    required this.onDelete,
  });
  final List<GraphqlSavedRequest> requests;
  final TextEditingController search;
  final ValueChanged<String> onSearch;
  final ValueChanged<GraphqlSavedRequest> onOpen;
  final ValueChanged<String> onDuplicate;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) => Column(
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
                  request.request.endpoint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => onOpen(request),
                trailing: PopupMenuButton<String>(
                  onSelected: (action) {
                    if (action == 'open') onOpen(request);
                    if (action == 'copy') onDuplicate(request.id);
                    if (action == 'delete') onDelete(request.id);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'open',
                      child: Text('Open in new tab'),
                    ),
                    PopupMenuItem(value: 'copy', child: Text('Duplicate')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

class _ResponsePanel extends StatelessWidget {
  const _ResponsePanel({required this.execution});
  final GraphqlTabExecution execution;
  @override
  Widget build(BuildContext context) {
    final response = execution.response;
    final body =
        response?.safeJson ??
        execution.failure?.message ??
        'Run a query to inspect data, errors, and extensions.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Response · ${execution.phase.name}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (response != null)
          Text(
            'HTTP ${response.statusCode ?? '-'} · ${response.duration.inMilliseconds} ms · ${response.sizeBytes} bytes',
          ),
        const SizedBox(height: 8),
        Expanded(child: SingleChildScrollView(child: SelectableText(body))),
      ],
    );
  }
}

class _HistoryPanel extends StatefulWidget {
  const _HistoryPanel({
    required this.entries,
    required this.onSearch,
    required this.onReplay,
    required this.onDelete,
  });
  final List<GraphqlHistoryEntry> entries;
  final ValueChanged<String> onSearch;
  final ValueChanged<GraphqlHistoryEntry> onReplay;
  final ValueChanged<GraphqlHistoryEntry> onDelete;
  @override
  State<_HistoryPanel> createState() => _HistoryPanelState();
}

class _HistoryPanelState extends State<_HistoryPanel> {
  final _search = TextEditingController();
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('GraphQL history', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 6),
      TextField(
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
      Expanded(
        child: ListView(
          children: [
            for (final entry in widget.entries)
              ListTile(
                dense: true,
                title: Text(entry.operationType.name),
                subtitle: Text(
                  '${entry.summary['statusCode'] ?? '-'} · ${entry.createdAt.toLocal()}',
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
}
