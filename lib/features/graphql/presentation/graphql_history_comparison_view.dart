import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/diagnostics/history_comparison_service.dart';
import '../data/graphql_repository.dart';
import '../domain/graphql_history_comparison.dart';

enum GraphqlHistoryComparisonFilter { all, added, removed, changed }

class GraphqlHistoryComparisonView extends StatefulWidget {
  const GraphqlHistoryComparisonView({
    required this.before,
    required this.after,
    super.key,
  });

  final GraphqlHistoryEntry before;
  final GraphqlHistoryEntry after;

  @override
  State<GraphqlHistoryComparisonView> createState() =>
      _GraphqlHistoryComparisonViewState();
}

class _GraphqlHistoryComparisonViewState
    extends State<GraphqlHistoryComparisonView> {
  final _search = TextEditingController();
  GraphqlHistoryComparisonFilter _filter = GraphqlHistoryComparisonFilter.all;
  bool _swapped = false;

  GraphqlHistoryEntry get _before => _swapped ? widget.after : widget.before;

  GraphqlHistoryEntry get _after => _swapped ? widget.before : widget.after;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<ComparisonChange> _visibleChanges(GraphqlHistoryComparison comparison) {
    final source = switch (_filter) {
      GraphqlHistoryComparisonFilter.all => comparison.changes,
      GraphqlHistoryComparisonFilter.added => comparison.added,
      GraphqlHistoryComparisonFilter.removed => comparison.removed,
      GraphqlHistoryComparisonFilter.changed => comparison.changed,
    };
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return source;
    return source
        .where(
          (change) =>
              change.path.toLowerCase().contains(query) ||
              _displayValue(change.before).toLowerCase().contains(query) ||
              _displayValue(change.after).toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  Future<void> _copyExport() async {
    await Clipboard.setData(
      ClipboardData(
        text: GraphqlHistoryComparisonService.exportJson(_before, _after),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Safe comparison JSON copied.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final comparison = GraphqlHistoryComparisonService.compare(_before, _after);
    final visible = _visibleChanges(comparison);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'GraphQL history comparison',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              IconButton(
                key: const Key('graphql-history-comparison-swap'),
                tooltip: 'Swap before and after',
                onPressed: () => setState(() => _swapped = !_swapped),
                icon: const Icon(Icons.swap_horiz),
              ),
              IconButton(
                key: const Key('graphql-history-comparison-export'),
                tooltip: 'Copy safe comparison JSON',
                onPressed: _copyExport,
                icon: const Icon(Icons.copy_all_outlined),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HistoryIdentity(label: 'Before', entry: _before),
              _HistoryIdentity(label: 'After', entry: _after),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                key: const Key('graphql-comparison-filter-all'),
                label: Text('All (${comparison.changes.length})'),
                selected: _filter == GraphqlHistoryComparisonFilter.all,
                onSelected: (_) => setState(
                  () => _filter = GraphqlHistoryComparisonFilter.all,
                ),
              ),
              ChoiceChip(
                key: const Key('graphql-comparison-filter-added'),
                label: Text('Added (${comparison.added.length})'),
                selected: _filter == GraphqlHistoryComparisonFilter.added,
                onSelected: (_) => setState(
                  () => _filter = GraphqlHistoryComparisonFilter.added,
                ),
              ),
              ChoiceChip(
                key: const Key('graphql-comparison-filter-removed'),
                label: Text('Removed (${comparison.removed.length})'),
                selected: _filter == GraphqlHistoryComparisonFilter.removed,
                onSelected: (_) => setState(
                  () => _filter = GraphqlHistoryComparisonFilter.removed,
                ),
              ),
              ChoiceChip(
                key: const Key('graphql-comparison-filter-changed'),
                label: Text('Changed (${comparison.changed.length})'),
                selected: _filter == GraphqlHistoryComparisonFilter.changed,
                onSelected: (_) => setState(
                  () => _filter = GraphqlHistoryComparisonFilter.changed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            key: const Key('graphql-history-comparison-search'),
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              isDense: true,
              prefixIcon: Icon(Icons.search),
              labelText: 'Search path or safe value',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: visible.isEmpty
                ? const Center(child: Text('No matching differences.'))
                : ListView.separated(
                    itemCount: visible.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final change = visible[index];
                      return Card(
                        key: ValueKey<String>(
                          'graphql-history-change-${change.path}',
                        ),
                        child: ListTile(
                          leading: Icon(_iconFor(change)),
                          title: Text(change.path),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Text(
                                _kindFor(change),
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(height: 4),
                              const Text('Before'),
                              SelectableText(
                                _displayValue(change.before),
                                maxLines: 6,
                              ),
                              const SizedBox(height: 4),
                              const Text('After'),
                              SelectableText(
                                _displayValue(change.after),
                                maxLines: 6,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  static String _kindFor(ComparisonChange change) {
    if (change.before == null) return 'Added';
    if (change.after == null) return 'Removed';
    return 'Changed';
  }

  static IconData _iconFor(ComparisonChange change) {
    if (change.before == null) return Icons.add_circle_outline;
    if (change.after == null) return Icons.remove_circle_outline;
    return Icons.change_circle_outlined;
  }

  static String _displayValue(Object? value) {
    if (value == null) return 'null';
    if (value is String) return value;
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } on Object {
      return value.toString();
    }
  }
}

class _HistoryIdentity extends StatelessWidget {
  const _HistoryIdentity({required this.label, required this.entry});

  final String label;
  final GraphqlHistoryEntry entry;

  @override
  Widget build(BuildContext context) => Container(
    key: ValueKey<String>('graphql-history-identity-${label.toLowerCase()}'),
    constraints: const BoxConstraints(minWidth: 220),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        Text('${entry.operationType.name} آ· ${entry.id}'),
        Text(
          entry.createdAt.toLocal().toString(),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}
