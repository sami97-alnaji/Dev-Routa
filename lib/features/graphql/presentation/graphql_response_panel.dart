import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/graphql_models.dart';
import 'graphql_workflow_cubit.dart';

enum GraphqlResponseView { data, errors, extensions, raw, headers, diagnostics }

class GraphqlResponsePanel extends StatefulWidget {
  const GraphqlResponsePanel({required this.execution, super.key});

  final GraphqlTabExecution execution;

  @override
  State<GraphqlResponsePanel> createState() => _GraphqlResponsePanelState();
}

class _GraphqlResponsePanelState extends State<GraphqlResponsePanel> {
  final _search = TextEditingController();
  GraphqlResponseView _view = GraphqlResponseView.data;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GraphqlResponsePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.execution.id != widget.execution.id) {
      _search.clear();
      _view = GraphqlResponseView.data;
    }
  }

  Future<void> _copyVisibleText() async {
    final text = _visibleText();
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Safe response view copied.')));
  }

  String _visibleText() {
    final response = widget.execution.response;
    final failure = widget.execution.failure;

    if (response == null) {
      if (failure == null) {
        return 'Run a query to inspect data, errors, extensions, headers, and diagnostics.';
      }
      return _pretty(<String, Object?>{
        'category': failure.category.name,
        'message': failure.message,
      });
    }

    return switch (_view) {
      GraphqlResponseView.data => _pretty(response.data),
      GraphqlResponseView.errors => _pretty(
        response.errors.map((error) => error.toJson()).toList(growable: false),
      ),
      GraphqlResponseView.extensions => _pretty(response.extensions),
      GraphqlResponseView.raw => _prettyRaw(
        response.rawPreview.isEmpty ? response.safeJson : response.rawPreview,
      ),
      GraphqlResponseView.headers => _pretty(response.headers),
      GraphqlResponseView.diagnostics => _diagnosticsText(response, failure),
    };
  }

  String _filteredVisibleText() {
    final text = _visibleText();
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty || text.toLowerCase().contains(query)) return text;
    return 'No matches in ${_view.name}.';
  }

  @override
  Widget build(BuildContext context) {
    final execution = widget.execution;
    final response = execution.response;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Response آ· ${execution.phase.name}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            IconButton(
              key: const Key('graphql-response-copy'),
              tooltip: 'Copy safe visible response',
              onPressed: _copyVisibleText,
              icon: const Icon(Icons.copy_outlined),
            ),
          ],
        ),
        if (response != null)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              Chip(label: Text('HTTP ${response.statusCode ?? '-'}')),
              Chip(label: Text(response.completion.name)),
              Chip(label: Text('${response.duration.inMilliseconds} ms')),
              Chip(label: Text('${response.sizeBytes} bytes')),
              if (response.truncated)
                const Chip(
                  key: Key('graphql-response-truncated'),
                  label: Text('Preview truncated'),
                ),
            ],
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _viewChip(
              GraphqlResponseView.data,
              'Data',
              const Key('graphql-response-tab-data'),
            ),
            _viewChip(
              GraphqlResponseView.errors,
              'Errors (${response?.errors.length ?? 0})',
              const Key('graphql-response-tab-errors'),
            ),
            _viewChip(
              GraphqlResponseView.extensions,
              'Extensions',
              const Key('graphql-response-tab-extensions'),
            ),
            _viewChip(
              GraphqlResponseView.raw,
              'Raw',
              const Key('graphql-response-tab-raw'),
            ),
            _viewChip(
              GraphqlResponseView.headers,
              'Headers',
              const Key('graphql-response-tab-headers'),
            ),
            _viewChip(
              GraphqlResponseView.diagnostics,
              'Diagnostics',
              const Key('graphql-response-tab-diagnostics'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('graphql-response-search'),
          controller: _search,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            isDense: true,
            prefixIcon: const Icon(Icons.search),
            labelText: 'Search ${_view.name}',
            suffixIcon: _search.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      _search.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.clear),
                  ),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                _filteredVisibleText(),
                key: const Key('graphql-response-visible-text'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _viewChip(GraphqlResponseView value, String label, Key key) =>
      ChoiceChip(
        key: key,
        label: Text(label),
        selected: _view == value,
        onSelected: (_) => setState(() {
          _view = value;
          _search.clear();
        }),
      );

  static String _diagnosticsText(
    GraphqlResponse response,
    GraphqlFailure? failure,
  ) {
    final facts = <String>[
      'Observed facts',
      '- Completion: ${response.completion.name}',
      '- HTTP status: ${response.statusCode ?? 'unavailable'}',
      '- Duration: ${response.duration.inMilliseconds} ms',
      '- Original response size: ${response.sizeBytes} bytes',
      '- Response headers: ${response.headers.length}',
      '- GraphQL errors: ${response.errors.length}',
      '- Preview truncated: ${response.truncated}',
    ];

    if (response.hasPartialData) {
      facts.add('- Partial data and GraphQL errors were returned together.');
    }
    if (response.errors.isNotEmpty) {
      for (var index = 0; index < response.errors.length; index++) {
        final error = response.errors[index];
        facts.add('- Error ${index + 1}: ${error.message}');
        if (error.locations.isNotEmpty) {
          facts.add(
            '  Locations: ${error.locations.map((item) => '${item.line}:${item.column}').join(', ')}',
          );
        }
        if (error.path.isNotEmpty) {
          facts.add(
            '  Path: ${error.path.map((item) => item.value).join('.')}',
          );
        }
      }
    }
    if (failure != null) {
      facts.add('- Failure category: ${failure.category.name}');
      facts.add('- Failure message: ${failure.message}');
    }

    return facts.join('\n');
  }

  static String _prettyRaw(String value) {
    try {
      return _pretty(jsonDecode(value));
    } on FormatException {
      return value;
    }
  }

  static String _pretty(Object? value) {
    if (value == null) return 'null';
    if (value is String) return value;
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } on Object {
      return value.toString();
    }
  }
}
