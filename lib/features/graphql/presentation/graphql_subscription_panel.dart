import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/security/secret_masker.dart';
import '../application/graphql_subscription_service.dart';

typedef GraphqlSubscriptionConnect =
    Future<void> Function(GraphqlReconnectPolicy policy);

class GraphqlSubscriptionPanel extends StatefulWidget {
  const GraphqlSubscriptionPanel({
    required this.tabId,
    required this.state,
    required this.onConnect,
    required this.onDisconnect,
    required this.onReconnect,
    required this.onStop,
    required this.onClear,
    super.key,
  });

  final String tabId;
  final GraphqlSubscriptionTabState state;
  final GraphqlSubscriptionConnect onConnect;
  final Future<void> Function() onDisconnect;
  final Future<void> Function() onReconnect;
  final VoidCallback onStop;
  final VoidCallback onClear;

  @override
  State<GraphqlSubscriptionPanel> createState() =>
      _GraphqlSubscriptionPanelState();
}

class _GraphqlSubscriptionPanelState extends State<GraphqlSubscriptionPanel> {
  final _search = TextEditingController();

  bool _autoReconnect = false;
  bool _autoResubscribe = false;
  bool _errorsOnly = false;
  bool _paused = false;
  bool _busy = false;
  int _maxAttempts = 3;
  List<GraphqlTimelineEvent> _pausedEvents = const <GraphqlTimelineEvent>[];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GraphqlSubscriptionPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabId != widget.tabId) {
      _search.clear();
      _autoReconnect = false;
      _autoResubscribe = false;
      _errorsOnly = false;
      _paused = false;
      _busy = false;
      _maxAttempts = 3;
      _pausedEvents = const <GraphqlTimelineEvent>[];
    }
  }

  GraphqlReconnectPolicy get _policy => GraphqlReconnectPolicy(
    enabled: _autoReconnect,
    resubscribe: _autoResubscribe,
    maxAttempts: _maxAttempts,
  );

  List<GraphqlTimelineEvent> get _visibleEvents {
    final source = _paused ? _pausedEvents : widget.state.events;
    final query = _search.text.trim().toLowerCase();

    return source
        .where((event) {
          if (_errorsOnly && event.errors.isEmpty) return false;
          if (query.isEmpty) return true;
          return _safeEventText(event).toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copyTimeline() async {
    final safeJson = SecretMasker.redactText(
      const JsonEncoder.withIndent(
        '  ',
      ).convert(_visibleEvents.map(_eventJson).toList(growable: false)),
    );
    await Clipboard.setData(ClipboardData(text: safeJson));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Safe subscription timeline copied.')),
    );
  }

  void _togglePause(bool value) {
    setState(() {
      _paused = value;
      _pausedEvents = value
          ? List<GraphqlTimelineEvent>.unmodifiable(widget.state.events)
          : const <GraphqlTimelineEvent>[];
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final visibleEvents = _visibleEvents;
    final canReconnect = state.phase != GraphqlSubscriptionPhase.idle && !_busy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Subscription',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            IconButton(
              key: const Key('graphql-subscription-copy-timeline'),
              tooltip: 'Copy safe visible timeline',
              onPressed: visibleEvents.isEmpty ? null : _copyTimeline,
              icon: const Icon(Icons.copy_all_outlined),
            ),
          ],
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            Chip(label: Text('State: ${state.phase.name}')),
            Chip(label: Text('Events: ${state.events.length}')),
            Chip(label: Text('Dropped: ${state.droppedEvents}')),
            Chip(label: Text('Reconnects: ${state.reconnectAttempts}')),
            if (state.connectedAt != null)
              Chip(label: Text('Connected: ${state.connectedAt!.toLocal()}')),
          ],
        ),
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${state.error!.category.name}: ${state.error!.message}',
              key: const Key('graphql-subscription-error'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              key: const Key('graphql-subscription-connect-toggle'),
              onPressed: _busy
                  ? null
                  : state.isActive
                  ? () => _run(widget.onDisconnect)
                  : () => _run(() => widget.onConnect(_policy)),
              icon: Icon(state.isActive ? Icons.stop : Icons.wifi),
              label: Text(state.isActive ? 'Disconnect' : 'Connect'),
            ),
            OutlinedButton.icon(
              key: const Key('graphql-subscription-reconnect'),
              onPressed: canReconnect ? () => _run(widget.onReconnect) : null,
              icon: const Icon(Icons.refresh),
              label: const Text('Reconnect'),
            ),
            OutlinedButton.icon(
              key: const Key('graphql-subscription-stop'),
              onPressed: state.isActive && !_busy ? widget.onStop : null,
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text('Stop operation'),
            ),
            OutlinedButton.icon(
              key: const Key('graphql-subscription-clear'),
              onPressed: state.events.isEmpty ? null : widget.onClear,
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear timeline'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 210,
              child: SwitchListTile.adaptive(
                key: const Key('graphql-subscription-auto-reconnect'),
                contentPadding: EdgeInsets.zero,
                title: const Text('Auto reconnect'),
                value: _autoReconnect,
                onChanged: state.isActive
                    ? null
                    : (value) => setState(() {
                        _autoReconnect = value;
                        if (!value) _autoResubscribe = false;
                      }),
              ),
            ),
            SizedBox(
              width: 210,
              child: SwitchListTile.adaptive(
                key: const Key('graphql-subscription-auto-resubscribe'),
                contentPadding: EdgeInsets.zero,
                title: const Text('Auto resubscribe'),
                value: _autoResubscribe,
                onChanged: !_autoReconnect || state.isActive
                    ? null
                    : (value) => setState(() => _autoResubscribe = value),
              ),
            ),
            SizedBox(
              width: 180,
              child: DropdownButtonFormField<int>(
                key: const Key('graphql-subscription-max-attempts'),
                initialValue: _maxAttempts,
                decoration: const InputDecoration(
                  isDense: true,
                  labelText: 'Max attempts',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final value in const <int>[1, 2, 3, 4, 5])
                    DropdownMenuItem(value: value, child: Text('$value')),
                ],
                onChanged: !_autoReconnect || state.isActive
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _maxAttempts = value);
                        }
                      },
              ),
            ),
          ],
        ),
        const Divider(),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 280,
              child: TextField(
                key: const Key('graphql-subscription-search'),
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  isDense: true,
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Search safe event data',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            FilterChip(
              key: const Key('graphql-subscription-errors-only'),
              label: const Text('Errors only'),
              selected: _errorsOnly,
              onSelected: (value) => setState(() => _errorsOnly = value),
            ),
            FilterChip(
              key: const Key('graphql-subscription-pause-rendering'),
              label: const Text('Pause rendering'),
              selected: _paused,
              onSelected: _togglePause,
            ),
            if (_paused)
              const Text('Transport remains active while rendering is paused.'),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: visibleEvents.isEmpty
              ? Center(
                  child: Text(
                    state.events.isEmpty
                        ? 'Connect a subscription to receive events.'
                        : 'No matching timeline events.',
                  ),
                )
              : ListView.separated(
                  itemCount: visibleEvents.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final event = visibleEvents[index];
                    return Card(
                      key: ValueKey<String>(
                        'graphql-subscription-event-${event.sequence}',
                      ),
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${event.sequence}')),
                        title: Text(
                          '#${event.sequence} · ${event.receivedAt.toLocal()}',
                        ),
                        subtitle: SelectableText(
                          _safeEventText(event),
                          maxLines: 12,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  static Map<String, Object?> _eventJson(GraphqlTimelineEvent event) =>
      <String, Object?>{
        'sequence': event.sequence,
        'receivedAt': event.receivedAt.toUtc().toIso8601String(),
        'data': _sanitizeValue(event.data),
        if (event.errors.isNotEmpty)
          'errors': event.errors
              .map((error) => _sanitizeValue(error.toJson()))
              .toList(growable: false),
        if (event.extensions != null)
          'extensions': _sanitizeValue(event.extensions),
      };

  static Object? _sanitizeValue(Object? value, {String? key}) {
    if (key != null && _isSensitiveKey(key)) {
      return '[REDACTED]';
    }
    if (value is Map) {
      return value.map(
        (itemKey, itemValue) => MapEntry(
          itemKey.toString(),
          _sanitizeValue(itemValue, key: itemKey.toString()),
        ),
      );
    }
    if (value is Iterable) {
      return value.map((item) => _sanitizeValue(item)).toList(growable: false);
    }
    return value;
  }

  static bool _isSensitiveKey(String key) => RegExp(
    r'authorization|api[-_ ]?key|access[-_ ]?token|refresh[-_ ]?token|token|cookie|password|secret',
    caseSensitive: false,
  ).hasMatch(key);

  static String _safeEventText(GraphqlTimelineEvent event) =>
      SecretMasker.redactText(
        const JsonEncoder.withIndent('  ').convert(_eventJson(event)),
      );
}
