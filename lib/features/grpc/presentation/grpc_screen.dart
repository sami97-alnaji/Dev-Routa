import 'package:flutter/material.dart';

import '../../../core/widgets/devroute_desktop.dart';

/// gRPC workspace surface. Transport and descriptor services are injected by
/// the application layer; this screen keeps the current DevRoute shell while
/// providing a safe, typed-request-oriented starting point for the workflow.
class GrpcScreen extends StatefulWidget {
  const GrpcScreen({super.key});

  @override
  State<GrpcScreen> createState() => _GrpcScreenState();
}

class _GrpcScreenState extends State<GrpcScreen> {
  final _endpointController = TextEditingController();
  final _messageController = TextEditingController(text: '{\n  \n}');
  final _metadataController = TextEditingController(text: '{}');
  int _requestTab = 0;
  int _responseTab = 0;

  @override
  void dispose() {
    _endpointController.dispose();
    _messageController.dispose();
    _metadataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 900;
        final services = _surface(
          context,
          title: 'Services & methods',
          subtitle: 'Reflection or imported descriptors',
          child: const _GrpcEmptyState(
            icon: Icons.schema_outlined,
            title: 'No descriptors loaded',
            message:
                'Import a descriptor set or connect to server reflection to browse services.',
          ),
        );
        final request = _surface(
          context,
          title: 'Request',
          subtitle: 'Typed JSON message and metadata',
          child: _editor(),
        );
        final response = _surface(
          context,
          title: 'Response',
          subtitle: 'Messages, stream events, and replay history',
          child: _response(),
        );

        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'gRPC',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Chip(
                  avatar: Icon(Icons.circle, size: 10),
                  label: Text('No service selected'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Inspect descriptors, compose typed requests, and review stream events.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: narrow ? constraints.maxWidth : 360,
                  child: TextField(
                    controller: _endpointController,
                    decoration: const InputDecoration(
                      labelText: 'Endpoint',
                      hintText: 'localhost:50051',
                      prefixIcon: Icon(Icons.dns_outlined),
                    ),
                  ),
                ),
                const Chip(label: Text('Unary')),
                FilledButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Invoke'),
                ),
                OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text('Cancel'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (narrow) ...[
              SizedBox(height: 250, child: services),
              const SizedBox(height: 12),
              SizedBox(height: 330, child: request),
              const SizedBox(height: 12),
              SizedBox(height: 300, child: response),
            ] else
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(width: 260, child: services),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(child: request),
                                const SizedBox(width: 6),
                                Expanded(child: response),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
        return narrow ? SingleChildScrollView(child: content) : content;
      },
    );
  }

  Widget _surface(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return DevRoutePane(
      title: title,
      subtitle: subtitle,
      trailing: title == 'Services & methods'
          ? IconButton(onPressed: null, icon: const Icon(Icons.add, size: 18))
          : null,
      child: child,
    );
  }

  Widget _editor() {
    final controller = _requestTab == 0
        ? _messageController
        : _metadataController;
    return Column(
      children: [
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('Message')),
            ButtonSegment(value: 1, label: Text('Metadata')),
          ],
          selected: {_requestTab},
          onSelectionChanged: (value) =>
              setState(() => _requestTab = value.first),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: controller,
              expands: true,
              maxLines: null,
              minLines: null,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _response() => Column(
    children: [
      SegmentedButton<int>(
        segments: const [
          ButtonSegment(value: 0, label: Text('Response')),
          ButtonSegment(value: 1, label: Text('Stream events')),
          ButtonSegment(value: 2, label: Text('History')),
        ],
        selected: {_responseTab},
        onSelectionChanged: (value) =>
            setState(() => _responseTab = value.first),
      ),
      const Expanded(
        child: _GrpcEmptyState(
          icon: Icons.swap_calls,
          title: 'Ready for a gRPC call',
          message:
              'Select a discovered method to enable invocation and response inspection.',
        ),
      ),
    ],
  );
}

class _GrpcEmptyState extends StatelessWidget {
  const _GrpcEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 34),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
