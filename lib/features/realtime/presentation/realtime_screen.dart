import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../core/diagnostics/developer_diagnostics.dart';
import '../../../shared/models/api_models.dart';
import '../domain/realtime_models.dart';
import 'realtime_session_cubit.dart';

class RealtimeScreen extends StatefulWidget {
  const RealtimeScreen({super.key});
  @override
  State<RealtimeScreen> createState() => _RealtimeScreenState();
}

class _RealtimeScreenState extends State<RealtimeScreen> {
  final _url = TextEditingController(text: 'wss://echo.websocket.events');
  final _message = TextEditingController();
  RealtimeProtocolType _protocol = RealtimeProtocolType.webSocket;
  final List<RequestHeaderModel> _headers = <RequestHeaderModel>[];
  final List<RequestQueryParamModel> _params = <RequestQueryParamModel>[];
  String _filter = '';
  @override
  void dispose() {
    _url.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<RealtimeSessionCubit, RealtimeSessionState>(
        builder: (context, state) {
          final compact = MediaQuery.sizeOf(context).width < 700;
          return PopScope(
            canPop:
                state.status != RealtimeConnectionStatus.connected &&
                state.status != RealtimeConnectionStatus.connecting,
            onPopInvokedWithResult: (didPop, _) async {
              if (!didPop && mounted) {
                await _confirmDisconnect();
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Realtime',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                _connectionBar(context, state, compact),
                const SizedBox(height: 8),
                _configuration(context, state),
                const SizedBox(height: 8),
                _metrics(context, state),
                const SizedBox(height: 8),
                Expanded(child: _timeline(context, state)),
                if (_protocol == RealtimeProtocolType.webSocket)
                  _composer(context, state),
              ],
            ),
          );
        },
      );

  Widget _connectionBar(
    BuildContext context,
    RealtimeSessionState state,
    bool compact,
  ) {
    final active =
        state.status == RealtimeConnectionStatus.connected ||
        state.status == RealtimeConnectionStatus.connecting ||
        state.status == RealtimeConnectionStatus.reconnecting;
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        DropdownButton<RealtimeProtocolType>(
          value: _protocol,
          items: RealtimeProtocolType.values
              .map(
                (item) =>
                    DropdownMenuItem(value: item, child: Text(_label(item))),
              )
              .toList(),
          onChanged: active
              ? null
              : (value) => setState(() => _protocol = value!),
        ),
        SizedBox(
          width: compact ? MediaQuery.sizeOf(context).width - 40 : 460,
          child: TextField(
            controller: _url,
            enabled: !active,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: _protocol == RealtimeProtocolType.webSocket
                  ? 'ws:// or wss:// URL'
                  : 'http:// or https:// URL',
            ),
          ),
        ),
        FilledButton.icon(
          onPressed: active
              ? () => context.read<RealtimeSessionCubit>().disconnect()
              : _connect,
          icon: Icon(
            active ? Icons.stop_circle_outlined : Icons.power_settings_new,
          ),
          label: Text(active ? 'Disconnect' : 'Connect'),
        ),
        Text(
          _statusText(state.status),
          semanticsLabel: 'Connection status: ${_statusText(state.status)}',
        ),
        if (state.config != null)
          TextButton.icon(
            onPressed: () => context.read<RealtimeSessionCubit>().saveDraft(),
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save draft'),
          ),
        if (state.config != null)
          TextButton.icon(
            onPressed: () =>
                context.read<RealtimeSessionCubit>().saveConfiguration(),
            icon: const Icon(Icons.bookmark_outline),
            label: const Text('Save config'),
          ),
      ],
    );
  }

  Widget _configuration(
    BuildContext context,
    RealtimeSessionState state,
  ) => Card(
    child: ExpansionTile(
      title: const Text('Params, headers, and resolved preview'),
      subtitle: Text(
        '${_params.length} parameters • ${_headers.length} headers • secrets are masked',
      ),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      children: [
        Wrap(
          spacing: 8,
          children: [
            TextButton.icon(
              onPressed: state.status == RealtimeConnectionStatus.connected
                  ? null
                  : () => _addPair(context, header: false),
              icon: const Icon(Icons.add),
              label: const Text('Parameter'),
            ),
            TextButton.icon(
              onPressed: state.status == RealtimeConnectionStatus.connected
                  ? null
                  : () => _addPair(context, header: true),
              icon: const Icon(Icons.add),
              label: const Text('Header'),
            ),
          ],
        ),
        for (final item in _params)
          ListTile(
            dense: true,
            title: Text('${item.key} = ${item.value}'),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _params.remove(item)),
            ),
          ),
        for (final item in _headers)
          ListTile(
            dense: true,
            title: Text(item.key),
            subtitle: Text(item.isSecret ? '[REDACTED]' : item.value),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _headers.remove(item)),
            ),
          ),
        SelectableText(_preview()),
      ],
    ),
  );

  Widget _metrics(BuildContext context, RealtimeSessionState state) {
    final metrics = state.metrics;
    final diagnostics = DeveloperDiagnostics.forRealtime(state);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Wrap(
          spacing: 18,
          runSpacing: 6,
          children: [
            Text('In: ${metrics.bytesIn} B'),
            Text('Out: ${metrics.bytesOut} B'),
            Text('Reconnects: ${metrics.reconnectAttempts}'),
            Text(
              'Events retained: ${state.messages.length}/${state.config?.maxEvents ?? 500}',
            ),
            if (diagnostics.isNotEmpty)
              Tooltip(
                message: diagnostics
                    .map((item) => '${item.title}: ${item.detail}')
                    .join('\n'),
                child: const Icon(
                  Icons.info_outline,
                  semanticLabel: 'Diagnostics available',
                ),
              ),
            TextButton(
              onPressed: state.messages.isEmpty
                  ? null
                  : context.read<RealtimeSessionCubit>().clearMessages,
              child: const Text('Clear timeline'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeline(BuildContext context, RealtimeSessionState state) {
    final entries = state.messages
        .where(
          (item) =>
              _filter.isEmpty ||
              item.content.toLowerCase().contains(_filter.toLowerCase()) ||
              (item.eventName?.toLowerCase().contains(_filter.toLowerCase()) ??
                  false),
        )
        .toList();
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              onChanged: (value) => setState(() => _filter = value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search messages, event names, or content',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? const Center(
                    child: Text(
                      'Connect to inspect a bounded, sanitized event timeline.',
                    ),
                  )
                : ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final item = entries[index];
                      return ListTile(
                        leading: Icon(
                          item.direction == RealtimeMessageDirection.inbound
                              ? Icons.south_west
                              : item.direction ==
                                    RealtimeMessageDirection.outbound
                              ? Icons.north_east
                              : Icons.info_outline,
                        ),
                        title: Text(
                          '${item.payloadType.name}${item.eventName == null ? '' : ' • ${item.eventName}'}',
                        ),
                        subtitle: SelectableText(item.content, maxLines: 3),
                        trailing: Text(
                          '${item.sizeBytes} B\n${item.timestamp.toLocal().toString().substring(11, 19)}',
                          textAlign: TextAlign.right,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _composer(BuildContext context, RealtimeSessionState state) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: _message,
            minLines: 1,
            maxLines: 4,
            enabled: state.canSend,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Text or JSON message',
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: !state.canSend
              ? null
              : () async {
                  final cubit = context.read<RealtimeSessionCubit>();
                  final value = _message.text;
                  if (value.trim().isEmpty) {
                    return;
                  }
                  try {
                    if (_looksJson(value)) {
                      await cubit.sendJson(value);
                    } else {
                      await cubit.sendText(value);
                    }
                    _message.clear();
                  } catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(error.toString())));
                    }
                  }
                },
          child: const Text('Send'),
        ),
      ],
    ),
  );

  Future<void> _connect() => context.read<RealtimeSessionCubit>().connect(
    RealtimeSessionConfig(
      id: const Uuid().v4(),
      protocol: _protocol,
      url: _url.text.trim(),
      headers: List<RequestHeaderModel>.of(_headers),
      queryParams: List<RequestQueryParamModel>.of(_params),
      reconnectPolicy: const ReconnectPolicy(enabled: true),
    ),
  );
  Future<void> _confirmDisconnect() async {
    final cubit = context.read<RealtimeSessionCubit>();
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Disconnect active session?'),
            content: const Text('The active realtime session will stop.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep open'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Disconnect'),
              ),
            ],
          ),
        ) ??
        false;
    if (confirmed && context.mounted) {
      cubit.disconnect();
    }
  }

  Future<void> _addPair(BuildContext context, {required bool header}) async {
    final key = TextEditingController();
    final value = TextEditingController();
    final result = await showDialog<(String, String)?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${header ? 'header' : 'parameter'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: key,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: value,
              decoration: const InputDecoration(labelText: 'Value'),
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
    key.dispose();
    value.dispose();
    if (result == null || result.$1.isEmpty) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    setState(() {
      if (header) {
        _headers.add(
          RequestHeaderModel(
            key: result.$1,
            value: result.$2,
            isSecret: RegExp(
              r'authorization|api[-_ ]?key|token|cookie|password',
              caseSensitive: false,
            ).hasMatch(result.$1),
          ),
        );
      } else {
        _params.add(RequestQueryParamModel(key: result.$1, value: result.$2));
      }
    });
  }

  String _preview() {
    final uri = Uri.tryParse(_url.text);
    if (uri == null) {
      return 'Resolved preview unavailable until the URL is valid.';
    }
    return '${_protocol.name.toUpperCase()} ${uri.replace(queryParameters: {...uri.queryParameters, for (final item in _params) item.key: item.value})}\n${_headers.map((item) => '${item.key}: ${item.isSecret ? '[REDACTED]' : item.value}').join('\n')}';
  }

  static bool _looksJson(String value) {
    try {
      jsonDecode(value);
      return true;
    } catch (_) {
      return false;
    }
  }

  static String _label(RealtimeProtocolType type) => switch (type) {
    RealtimeProtocolType.webSocket => 'WebSocket',
    RealtimeProtocolType.sse => 'SSE',
    RealtimeProtocolType.httpStream => 'HTTP stream',
  };
  static String _statusText(RealtimeConnectionStatus status) =>
      switch (status) {
        RealtimeConnectionStatus.idle => 'Idle',
        RealtimeConnectionStatus.connecting => 'Connecting',
        RealtimeConnectionStatus.connected => 'Connected',
        RealtimeConnectionStatus.reconnecting => 'Reconnecting',
        RealtimeConnectionStatus.completed => 'Completed',
        RealtimeConnectionStatus.disconnected => 'Disconnected',
        RealtimeConnectionStatus.failed => 'Failed',
        RealtimeConnectionStatus.cancelled => 'Cancelled',
      };
}
