import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/graphql_repository.dart';
import '../domain/graphql_document_parser.dart';
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
  final _search = TextEditingController();

  @override
  void dispose() {
    _endpoint.dispose();
    _document.dispose();
    _variables.dispose();
    _search.dispose();
    super.dispose();
  }

  void _sync(String endpoint, String document, Map<String, Object?> variables) {
    if (_endpoint.text != endpoint) _endpoint.text = endpoint;
    if (_document.text != document) _document.text = document;
    final encoded = const JsonEncoder().convert(variables);
    if (_variables.text != encoded) _variables.text = encoded;
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
      );
      final analysis = GraphqlDocumentParser.analyze(draft.request.document);
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
      return MediaQuery.sizeOf(context).width < 900
          ? Column(
              children: [
                Expanded(flex: 3, child: editor),
                const Divider(),
                Expanded(child: response),
                const Divider(),
                SizedBox(height: 180, child: saved),
              ],
            )
          : Row(
              children: [
                SizedBox(width: 240, child: saved),
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
