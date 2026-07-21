import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../application/graphql_schema_cubit.dart';
import '../domain/graphql_models.dart';
import '../domain/graphql_operation_skeleton.dart';
import '../domain/graphql_schema_models.dart';

class GraphqlSchemaPanel extends StatefulWidget {
  const GraphqlSchemaPanel({
    required this.request,
    required this.onUseOperation,
    super.key,
  });

  final GraphqlRequest request;
  final ValueChanged<String> onUseOperation;

  @override
  State<GraphqlSchemaPanel> createState() => _GraphqlSchemaPanelState();
}

class _GraphqlSchemaPanelState extends State<GraphqlSchemaPanel> {
  final _search = TextEditingController();
  final Set<String> _comparisonIds = <String>{};
  String? _selectedTypeName;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<GraphqlSchemaType> _visibleTypes(GraphqlSchemaSnapshot snapshot) {
    final query = _search.text.trim().toLowerCase();
    final types =
        snapshot.types
            .where((type) => !type.name.startsWith('__'))
            .where((type) {
              if (query.isEmpty) return true;
              return type.name.toLowerCase().contains(query) ||
                  type.kind.toLowerCase().contains(query) ||
                  (type.description ?? '').toLowerCase().contains(query);
            })
            .toList(growable: false)
          ..sort((a, b) => a.name.compareTo(b.name));
    return types;
  }

  GraphqlSchemaType? _selectedType(
    GraphqlSchemaSnapshot snapshot,
    List<GraphqlSchemaType> visible,
  ) {
    for (final type in visible) {
      if (type.name == _selectedTypeName) return type;
    }
    for (final rootName in <String?>[
      snapshot.queryRoot,
      snapshot.mutationRoot,
      snapshot.subscriptionRoot,
    ]) {
      for (final type in visible) {
        if (type.name == rootName) return type;
      }
    }
    return visible.isEmpty ? null : visible.first;
  }

  String? _operationType(
    GraphqlSchemaSnapshot snapshot,
    GraphqlSchemaType type,
  ) {
    if (type.name == snapshot.queryRoot) return 'query';
    if (type.name == snapshot.mutationRoot) return 'mutation';
    if (type.name == snapshot.subscriptionRoot) return 'subscription';
    return null;
  }

  void _toggleComparison(String id, bool selected) {
    setState(() {
      if (!selected) {
        _comparisonIds.remove(id);
        return;
      }
      if (_comparisonIds.length == 2) {
        _comparisonIds.remove(_comparisonIds.first);
      }
      _comparisonIds.add(id);
    });
  }

  GraphqlSchemaDiff? _comparison(GraphqlSchemaState state) {
    if (_comparisonIds.length != 2) return null;
    final selected = <GraphqlSchemaSnapshot>[];
    for (final id in _comparisonIds) {
      for (final item in state.snapshots) {
        if (item.id == id) selected.add(item.snapshot);
      }
    }
    return selected.length == 2
        ? GraphqlSchemaTools.compare(selected[0], selected[1])
        : null;
  }

  Future<void> _deleteActive(
    BuildContext context,
    GraphqlSchemaState state,
  ) async {
    final active = state.active;
    if (active == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete schema snapshot?'),
        content: const Text(
          'The cached snapshot will be removed from this workspace.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<GraphqlSchemaCubit>().delete(active.id);
      _comparisonIds.remove(active.id);
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<GraphqlSchemaCubit, GraphqlSchemaState>(
    builder: (context, state) {
      final cubit = context.read<GraphqlSchemaCubit>();
      final active = state.active;
      final snapshot = active?.snapshot;
      final visibleTypes = snapshot == null
          ? const <GraphqlSchemaType>[]
          : _visibleTypes(snapshot);
      final selectedType = snapshot == null
          ? null
          : _selectedType(snapshot, visibleTypes);
      final comparison = _comparison(state);

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'GraphQL Schema Explorer',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                FilledButton.tonalIcon(
                  key: const Key('graphql-schema-fetch'),
                  onPressed: state.loading
                      ? null
                      : () => cubit.fetch(widget.request),
                  icon: state.loading
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_outlined),
                  label: const Text('Fetch introspection'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  key: const Key('graphql-schema-delete'),
                  tooltip: 'Delete active snapshot',
                  onPressed: active == null
                      ? null
                      : () => _deleteActive(context, state),
                  icon: const Icon(Icons.delete_outline),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  state.error!,
                  key: const Key('graphql-schema-error'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 8),
            if (state.snapshots.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No cached schema snapshots. Fetch introspection to create one.',
                  ),
                ),
              )
            else ...[
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 210),
                child: SingleChildScrollView(
                  key: const Key('graphql-schema-summary-scroll'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        key: ValueKey<String>(
                          'graphql-schema-snapshot-${state.activeId}',
                        ),
                        initialValue: state.activeId,
                        decoration: const InputDecoration(
                          isDense: true,
                          labelText: 'Cached snapshot',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (final item in state.snapshots)
                            DropdownMenuItem(
                              value: item.id,
                              child: Text(
                                '${item.snapshot.hash.substring(0, 8)} آ· ${item.createdAt.toLocal()}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (id) {
                          if (id != null) {
                            cubit.select(id);
                            setState(() => _selectedTypeName = null);
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final item in state.snapshots)
                            FilterChip(
                              key: ValueKey<String>(
                                'graphql-schema-compare-${item.id}',
                              ),
                              label: Text(item.snapshot.hash.substring(0, 8)),
                              selected: _comparisonIds.contains(item.id),
                              onSelected: (selected) =>
                                  _toggleComparison(item.id, selected),
                            ),
                        ],
                      ),
                      if (comparison != null) ...[
                        const SizedBox(height: 8),
                        _SchemaDiffSummary(diff: comparison),
                      ],
                      const SizedBox(height: 8),
                      if (snapshot != null)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            Chip(
                              label: Text('Types: ${snapshot.types.length}'),
                            ),
                            Chip(
                              label: Text(
                                'Query: ${snapshot.queryRoot ?? '-'}',
                              ),
                            ),
                            Chip(
                              label: Text(
                                'Mutation: ${snapshot.mutationRoot ?? '-'}',
                              ),
                            ),
                            Chip(
                              label: Text(
                                'Subscription: ${snapshot.subscriptionRoot ?? '-'}',
                              ),
                            ),
                            const Chip(label: Text('Cached / offline ready')),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final typeBrowser = Column(
                      children: [
                        TextField(
                          key: const Key('graphql-schema-search'),
                          controller: _search,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            isDense: true,
                            prefixIcon: Icon(Icons.search),
                            labelText: 'Search types',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView(
                            children: [
                              for (final type in visibleTypes)
                                ListTile(
                                  key: ValueKey<String>(
                                    'graphql-schema-type-${type.name}',
                                  ),
                                  selected: selectedType?.name == type.name,
                                  title: Text(type.name),
                                  subtitle: Text(type.kind),
                                  onTap: () => setState(
                                    () => _selectedTypeName = type.name,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );

                    final details = selectedType == null || snapshot == null
                        ? const Center(child: Text('Select a schema type.'))
                        : _SchemaTypeDetails(
                            type: selectedType,
                            operationType: _operationType(
                              snapshot,
                              selectedType,
                            ),
                            onUseOperation: widget.onUseOperation,
                          );

                    if (constraints.maxWidth < 800) {
                      return Column(
                        children: [
                          Expanded(flex: 2, child: typeBrowser),
                          const Divider(height: 1),
                          Expanded(flex: 3, child: details),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        SizedBox(width: 280, child: typeBrowser),
                        const VerticalDivider(),
                        Expanded(child: details),
                      ],
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}

class _SchemaTypeDetails extends StatelessWidget {
  const _SchemaTypeDetails({
    required this.type,
    required this.operationType,
    required this.onUseOperation,
  });

  final GraphqlSchemaType type;
  final String? operationType;
  final ValueChanged<String> onUseOperation;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(type.name, style: Theme.of(context).textTheme.titleLarge),
      Text(type.kind),
      if (type.description != null) ...[
        const SizedBox(height: 4),
        Text(type.description!),
      ],
      if (type.enumValues.isNotEmpty) ...[
        const SizedBox(height: 8),
        Text('Enum values: ${type.enumValues.join(', ')}'),
      ],
      if (type.interfaces.isNotEmpty) ...[
        const SizedBox(height: 8),
        Text('Interfaces: ${type.interfaces.join(', ')}'),
      ],
      const SizedBox(height: 8),
      Expanded(
        child: type.fields.isEmpty
            ? const Center(child: Text('No fields.'))
            : ListView.separated(
                itemCount: type.fields.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final field = type.fields[index];
                  return Card(
                    key: ValueKey<String>(
                      'graphql-schema-field-${type.name}-${field.name}',
                    ),
                    child: ListTile(
                      title: Text('${field.name}: ${field.type}'),
                      subtitle: Text(
                        [
                          if (field.description != null) field.description!,
                          if (field.args.isNotEmpty)
                            'Args: ${field.args.map((arg) => '${arg.name}: ${arg.type}').join(', ')}',
                          if (field.isDeprecated)
                            'Deprecated: ${field.deprecationReason ?? 'yes'}',
                        ].join('\n'),
                      ),
                      trailing: operationType == null
                          ? null
                          : FilledButton.tonal(
                              key: ValueKey<String>(
                                'graphql-schema-generate-${field.name}',
                              ),
                              onPressed: () {
                                final skeleton =
                                    GraphqlOperationSkeleton.generate(
                                      root: type,
                                      field: field,
                                      operationType: operationType!,
                                      operationName: _operationName(field.name),
                                    );
                                onUseOperation(skeleton);
                              },
                              child: const Text('Use operation'),
                            ),
                    ),
                  );
                },
              ),
      ),
    ],
  );

  static String _operationName(String fieldName) {
    if (fieldName.isEmpty) return 'GeneratedOperation';
    return 'Generated${fieldName[0].toUpperCase()}${fieldName.substring(1)}';
  }
}

class _SchemaDiffSummary extends StatelessWidget {
  const _SchemaDiffSummary({required this.diff});

  final GraphqlSchemaDiff diff;

  @override
  Widget build(BuildContext context) => Card(
    key: const Key('graphql-schema-diff-summary'),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        children: [
          Text(
            diff.classification,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Text('Added types: ${diff.addedTypes.length}'),
          Text('Removed types: ${diff.removedTypes.length}'),
          Text('Added fields: ${diff.addedFields.length}'),
          Text('Removed fields: ${diff.removedFields.length}'),
          Text('Changed fields: ${diff.changedFields.length}'),
        ],
      ),
    ),
  );
}
