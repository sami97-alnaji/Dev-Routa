import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/graphql_http_service.dart';
import '../domain/graphql_document_parser.dart';
import '../domain/graphql_models.dart';
import 'graphql_workflow_cubit.dart';

class GraphqlScreen extends StatefulWidget {
  const GraphqlScreen({super.key});
  @override
  State<GraphqlScreen> createState() => _GraphqlScreenState();
}

class _GraphqlScreenState extends State<GraphqlScreen> {
  final _endpoint = TextEditingController(text: 'https://example.com/graphql');
  final _document = TextEditingController(text: 'query Example { __typename }');
  final _variables = TextEditingController(text: '{}');
  final _service = GraphqlHttpService();
  String? _operation;
  String _result = 'Run a query to inspect data, errors, and extensions.';
  bool _running = false;

  @override
  void dispose() {
    _endpoint.dispose();
    _document.dispose();
    _variables.dispose();
    super.dispose();
  }

  Future<void> _execute() async {
    Map<String, Object?> variables;
    try {
      final decoded = jsonDecode(_variables.text);
      if (decoded is! Map) {
        throw const FormatException('Variables root must be an object.');
      }
      variables = decoded.cast<String, Object?>();
    } on FormatException catch (error) {
      setState(() => _result = 'Variables JSON error: ${error.message}');
      return;
    }
    setState(() => _running = true);
    try {
      final response = await _service.execute(
        'graphql-editor',
        GraphqlRequest(
          endpoint: _endpoint.text.trim(),
          document: _document.text,
          operationName: _operation,
          variables: variables,
        ),
      );
      if (mounted) {
        setState(
          () => _result = const JsonEncoder.withIndent(
            '  ',
          ).convert(jsonDecode(response.safeJson)),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _result = 'Execution error: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _running = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final workflow = context.watch<GraphqlWorkflowCubit>();
    final draft = workflow.state.active;
    if (_endpoint.text != draft.request.endpoint) {
      _endpoint.text = draft.request.endpoint;
    }
    if (_document.text != draft.request.document) {
      _document.text = draft.request.document;
    }
    if (_variables.text != jsonEncode(draft.request.variables)) {
      _variables.text = jsonEncode(draft.request.variables);
    }
    _operation = draft.request.operationName;
    final analysis = GraphqlDocumentParser.analyze(_document.text);
    final compact = MediaQuery.sizeOf(context).width < 900;
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
            for (var index = 0; index < workflow.state.tabs.length; index++)
              InputChip(
                label: Text(
                  '${workflow.state.tabs[index].isDirty ? '• ' : ''}${workflow.state.tabs[index].title}',
                ),
                selected: index == workflow.state.activeIndex,
                onPressed: () => workflow.selectTab(index),
                onDeleted: () => workflow.closeActive(discardChanges: true),
              ),
            ActionChip(label: const Text('+'), onPressed: workflow.newDraft),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _endpoint,
          onChanged: workflow.updateEndpoint,
          decoration: const InputDecoration(
            labelText: 'Endpoint',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _operation,
          decoration: const InputDecoration(
            labelText: 'Operation',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final op in analysis.operations)
              DropdownMenuItem(value: op.name, child: Text(op.label)),
          ],
          onChanged: (value) {
            workflow.selectOperation(value);
            setState(() => _operation = value);
          },
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
            onChanged: (value) {
              workflow.updateDocument(value);
              setState(() {});
            },
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
          onChanged: (value) {
            try {
              final decoded = jsonDecode(value);
              if (decoded is Map) {
                workflow.updateVariables(decoded.cast<String, Object?>());
              }
            } on FormatException {
              // Retain invalid draft text so the editor can show the error.
            }
          },
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Variables JSON',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton.icon(
              onPressed: _running ? null : _execute,
              icon: const Icon(Icons.play_arrow),
              label: Text(_running ? 'Executing' : 'Execute'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: _running
                  ? () => _service.cancel('graphql-editor')
                  : null,
              icon: const Icon(Icons.stop),
              label: const Text('Cancel'),
            ),
          ],
        ),
      ],
    );
    final response = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Response', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Expanded(child: SingleChildScrollView(child: SelectableText(_result))),
      ],
    );
    return compact
        ? Column(
            children: [
              Expanded(flex: 3, child: editor),
              const Divider(),
              Expanded(flex: 2, child: response),
            ],
          )
        : Row(
            children: [
              Expanded(child: editor),
              const VerticalDivider(),
              Expanded(child: response),
            ],
          );
  }
}
