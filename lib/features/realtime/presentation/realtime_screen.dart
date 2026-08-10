import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../core/ai/consent_ai_service.dart';
import '../../../core/diagnostics/developer_diagnostics.dart';
import '../../../core/diagnostics/diagnostic_bundle_service.dart';
import '../../../core/diagnostics/history_comparison_service.dart';
import '../../../core/security/secret_masker.dart';
import '../../../shared/models/api_models.dart';
import '../../workspace/presentation/workspace_cubit.dart';
import '../data/realtime_repository.dart';
import '../domain/realtime_models.dart';
import 'realtime_session_cubit.dart';

class RealtimeScreen extends StatefulWidget {
  const RealtimeScreen({super.key});
  @override
  State<RealtimeScreen> createState() => _RealtimeScreenState();
}

class _RealtimeTab {
  _RealtimeTab(this.cubit, {RealtimeSessionConfig? config, this.owned = true})
    : id = config?.id ?? const Uuid().v4(),
      url = TextEditingController(text: config?.url ?? ''),
      name = TextEditingController(text: config?.name ?? 'Realtime request'),
      message = TextEditingController(),
      body = TextEditingController(text: config?.body?.content ?? ''),
      binaryPath = TextEditingController(),
      protocol = config?.protocol ?? RealtimeProtocolType.webSocket,
      method = config?.method ?? HttpMethod.get,
      streamMode = config?.streamMode ?? HttpStreamMode.raw,
      headers = List<RequestHeaderModel>.of(config?.headers ?? const []),
      params = List<RequestQueryParamModel>.of(config?.queryParams ?? const []),
      auth = config?.auth ?? const RequestAuthModel(),
      subprotocols = List<String>.of(config?.subprotocols ?? const []),
      reconnect = config?.reconnectPolicy.enabled ?? true,
      maxAttempts = config?.reconnectPolicy.maxAttempts ?? 3,
      timeoutSeconds = config?.connectionTimeout.inSeconds ?? 15,
      maxEvents = config?.maxEvents ?? 500,
      production = config?.productionEnvironment ?? false;
  final String id;
  final RealtimeSessionCubit cubit;
  final bool owned;
  final TextEditingController url;
  final TextEditingController name;
  final TextEditingController message;
  final TextEditingController body;
  final TextEditingController binaryPath;
  RealtimeProtocolType protocol;
  HttpMethod method;
  HttpStreamMode streamMode;
  List<RequestHeaderModel> headers;
  List<RequestQueryParamModel> params;
  RequestAuthModel auth;
  List<String> subprotocols;
  bool reconnect;
  int maxAttempts;
  int timeoutSeconds;
  int maxEvents;
  bool production;
  bool dirty = false;
  String search = '';
  RealtimeMessageDirection? direction;

  RealtimeSessionConfig config() => RealtimeSessionConfig(
    id: id,
    protocol: protocol,
    url: url.text.trim(),
    name: name.text.trim().isEmpty ? 'Realtime request' : name.text.trim(),
    method: method,
    headers: List<RequestHeaderModel>.of(headers),
    queryParams: List<RequestQueryParamModel>.of(params),
    body: body.text.isEmpty
        ? null
        : RequestBodyModel(
            type: RequestBodyType.rawText,
            content: body.text,
            contentType: streamMode == HttpStreamMode.ndjson
                ? 'application/x-ndjson; charset=utf-8'
                : 'text/plain; charset=utf-8',
          ),
    auth: auth,
    subprotocols: List<String>.of(subprotocols),
    connectionTimeout: Duration(seconds: timeoutSeconds),
    reconnectPolicy: ReconnectPolicy(
      enabled: reconnect,
      maxAttempts: maxAttempts,
    ),
    maxEvents: maxEvents,
    streamMode: streamMode,
    productionEnvironment: production,
  );

  void dispose() {
    url.dispose();
    name.dispose();
    message.dispose();
    body.dispose();
    binaryPath.dispose();
  }
}

class _RealtimeScreenState extends State<RealtimeScreen>
    with WidgetsBindingObserver {
  final List<_RealtimeTab> _tabs = [];
  var _active = 0;
  var _section = 0;
  var _initialized = false;
  String _historySearch = '';
  RealtimeProtocolType? _historyProtocol;
  String? _historyStatus;
  String? _historyFailure;
  int? _historyAgeDays;
  List<RealtimeHistoryEntry> _history = const [];
  bool _historyLoading = false;
  final Set<String> _comparison = <String>{};
  AiConsentOptions _aiOptions = const AiConsentOptions();
  AiAnalysisAction _aiAction = AiAnalysisAction.summarizeRealtimeSession;
  AiPayloadPreview? _aiPreview;
  String? _aiResult;
  AiCancellationToken? _aiCancellation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _tabs.add(_RealtimeTab(context.read<RealtimeSessionCubit>(), owned: false));
    unawaited(_loadAiPreferences());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final tab in _tabs) {
      tab.dispose();
      if (tab.owned) tab.cubit.close();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      for (final tab in _tabs.where((item) => _isActive(item.cubit.state))) {
        unawaited(tab.cubit.disconnect());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_tabs.isEmpty) return const SizedBox.shrink();
    final tab = _tabs[_active];
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.keyN, control: true):
            _NewRealtimeTabIntent(),
        SingleActivator(LogicalKeyboardKey.keyW, control: true):
            _CloseRealtimeTabIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _NewRealtimeTabIntent: CallbackAction<_NewRealtimeTabIntent>(
            onInvoke: (_) {
              _newTab();
              return null;
            },
          ),
          _CloseRealtimeTabIntent: CallbackAction<_CloseRealtimeTabIntent>(
            onInvoke: (_) {
              _closeTab(_active);
              return null;
            },
          ),
        },
        child: BlocProvider.value(
          value: tab.cubit,
          child: BlocBuilder<RealtimeSessionCubit, RealtimeSessionState>(
            builder: (context, state) => PopScope(
              canPop: !_isActive(state) && !state.isDirty && !tab.dirty,
              onPopInvokedWithResult: (didPop, _) async {
                if (!didPop) await _confirmCloseOrDisconnect(tab, state);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _titleAndSections(context),
                  _sessionTabs(context),
                  const SizedBox(height: 8),
                  Expanded(
                    child: switch (_section) {
                      0 => _session(context, tab, state),
                      1 => _saved(context),
                      2 => _historyView(context),
                      _ => _intelligence(context, state),
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _titleAndSections(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final selector = SegmentedButton<int>(
        segments: const [
          ButtonSegment(
            value: 0,
            label: Text('Session'),
            icon: Icon(Icons.bolt),
          ),
          ButtonSegment(
            value: 1,
            label: Text('Saved'),
            icon: Icon(Icons.bookmarks_outlined),
          ),
          ButtonSegment(
            value: 2,
            label: Text('History'),
            icon: Icon(Icons.history),
          ),
          ButtonSegment(
            value: 3,
            label: Text('Intelligence'),
            icon: Icon(Icons.psychology_outlined),
          ),
        ],
        selected: {_section},
        onSelectionChanged: (value) {
          setState(() => _section = value.single);
          if (value.single == 2) _loadHistory();
        },
      );
      if (constraints.maxWidth < 850) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Realtime', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: selector,
            ),
          ],
        );
      }
      return Row(
        children: [
          Text('Realtime', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(width: 16),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: selector,
              ),
            ),
          ),
        ],
      );
    },
  );

  Widget _sessionTabs(BuildContext context) => SizedBox(
    height: 48,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        for (var index = 0; index < _tabs.length; index++)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InputChip(
              selected: index == _active,
              label: Text(_tabs[index].name.text),
              avatar: Icon(_icon(_tabs[index].protocol), size: 18),
              onPressed: () => setState(() => _active = index),
              onDeleted: _tabs.length == 1 ? null : () => _closeTab(index),
            ),
          ),
        IconButton(
          tooltip: 'New independent session (Ctrl+N)',
          onPressed: _newTab,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    ),
  );

  Widget _session(
    BuildContext context,
    _RealtimeTab tab,
    RealtimeSessionState state,
  ) {
    final compact = MediaQuery.sizeOf(context).width < 720;
    if (compact) {
      return ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          _connectionBar(context, tab, state, true),
          const SizedBox(height: 8),
          _configuration(context, tab, state),
          const SizedBox(height: 8),
          _metrics(context, state),
          const SizedBox(height: 8),
          SizedBox(height: 360, child: _timeline(context, tab, state)),
          if (tab.protocol == RealtimeProtocolType.webSocket)
            _composer(context, tab, state),
        ],
      );
    }
    return Column(
      children: [
        _connectionBar(context, tab, state, false),
        const SizedBox(height: 8),
        _configuration(context, tab, state),
        const SizedBox(height: 8),
        _metrics(context, state),
        const SizedBox(height: 8),
        Expanded(child: _timeline(context, tab, state)),
        if (tab.protocol == RealtimeProtocolType.webSocket)
          _composer(context, tab, state),
      ],
    );
  }

  Widget _connectionBar(
    BuildContext context,
    _RealtimeTab tab,
    RealtimeSessionState state,
    bool compact,
  ) {
    final active = _isActive(state);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        DropdownButton<RealtimeProtocolType>(
          value: tab.protocol,
          items: RealtimeProtocolType.values
              .map(
                (item) =>
                    DropdownMenuItem(value: item, child: Text(_label(item))),
              )
              .toList(),
          onChanged: active
              ? null
              : (value) => setState(() {
                  tab.protocol = value!;
                  tab.dirty = true;
                }),
        ),
        SizedBox(
          width: compact ? MediaQuery.sizeOf(context).width - 42 : 440,
          child: TextField(
            key: const Key('realtime-url'),
            controller: tab.url,
            enabled: !active,
            onChanged: (_) => setState(() => tab.dirty = true),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: tab.protocol == RealtimeProtocolType.webSocket
                  ? 'ws:// or wss:// URL'
                  : 'http:// or https:// URL',
            ),
          ),
        ),
        FilledButton.icon(
          key: const Key('realtime-connect'),
          onPressed: active ? tab.cubit.disconnect : () => _connect(tab),
          icon: Icon(
            active ? Icons.stop_circle_outlined : Icons.power_settings_new,
          ),
          label: Text(active ? 'Disconnect' : 'Connect'),
        ),
        if (state.status == RealtimeConnectionStatus.failed ||
            state.status == RealtimeConnectionStatus.completed)
          OutlinedButton.icon(
            onPressed: tab.cubit.reconnect,
            icon: const Icon(Icons.refresh),
            label: const Text('Reconnect'),
          ),
        Text(
          _statusText(state.status),
          semanticsLabel: 'Connection status: ${_statusText(state.status)}',
        ),
        TextButton.icon(
          onPressed: () async {
            tab.cubit.updateConfig(_configWithWorkspace(tab));
            await tab.cubit.saveDraft();
            setState(() => tab.dirty = false);
            if (mounted) _notice('Realtime draft saved locally.');
          },
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save draft'),
        ),
        TextButton.icon(
          onPressed: () async {
            tab.cubit.updateConfig(_configWithWorkspace(tab));
            await tab.cubit.saveConfiguration();
            setState(() => tab.dirty = false);
            if (mounted) _notice('Realtime configuration saved locally.');
          },
          icon: const Icon(Icons.bookmark_outline),
          label: const Text('Save config'),
        ),
      ],
    );
  }

  Widget _configuration(
    BuildContext context,
    _RealtimeTab tab,
    RealtimeSessionState state,
  ) => Card(
    child: ExpansionTile(
      title: const Text(
        'Params, Auth, Headers, Body, Settings, Resolved Preview',
      ),
      subtitle: Text(
        '${tab.params.length} params • ${tab.headers.length} headers • secrets masked',
      ),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      children: [
        TextField(
          controller: tab.name,
          enabled: !_isActive(state),
          onChanged: (_) => setState(() => tab.dirty = true),
          decoration: const InputDecoration(labelText: 'Configuration name'),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _isActive(state)
                  ? null
                  : () => _addPair(tab, header: false),
              icon: const Icon(Icons.add),
              label: const Text('Parameter'),
            ),
            TextButton.icon(
              onPressed: _isActive(state)
                  ? null
                  : () => _addPair(tab, header: true),
              icon: const Icon(Icons.add),
              label: const Text('Header'),
            ),
            DropdownButton<AuthType>(
              value: tab.auth.type,
              items: AuthType.values
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text('Auth: ${item.name}'),
                    ),
                  )
                  .toList(),
              onChanged: _isActive(state)
                  ? null
                  : (value) => _editAuth(tab, value!),
            ),
            if (tab.protocol == RealtimeProtocolType.httpStream)
              DropdownButton<HttpMethod>(
                value: tab.method,
                items: HttpMethod.values
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item.name.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: _isActive(state)
                    ? null
                    : (value) => setState(() {
                        tab.method = value!;
                        tab.dirty = true;
                      }),
              ),
            if (tab.protocol == RealtimeProtocolType.httpStream)
              DropdownButton<HttpStreamMode>(
                value: tab.streamMode,
                items: HttpStreamMode.values
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text('View: ${item.name}'),
                      ),
                    )
                    .toList(),
                onChanged: _isActive(state)
                    ? null
                    : (value) => setState(() {
                        tab.streamMode = value!;
                        tab.dirty = true;
                      }),
              ),
            FilterChip(
              label: const Text('Production'),
              selected: tab.production,
              onSelected: _isActive(state)
                  ? null
                  : (value) => setState(() {
                      tab.production = value;
                      tab.dirty = true;
                    }),
            ),
            FilterChip(
              label: const Text('Auto reconnect'),
              selected: tab.reconnect,
              onSelected: _isActive(state)
                  ? null
                  : (value) => setState(() {
                      tab.reconnect = value;
                      tab.dirty = true;
                    }),
            ),
            DropdownButton<int>(
              value: tab.maxEvents,
              items: const [100, 500, 1000]
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text('$item events'),
                    ),
                  )
                  .toList(),
              onChanged: _isActive(state)
                  ? null
                  : (value) => setState(() {
                      tab.maxEvents = value!;
                      tab.dirty = true;
                    }),
            ),
          ],
        ),
        for (final item in tab.params)
          ListTile(
            dense: true,
            title: Text('${item.key} = ${item.value}'),
            leading: Checkbox(
              value: item.enabled,
              onChanged: (value) => setState(() {
                final index = tab.params.indexOf(item);
                tab.params[index] = RequestQueryParamModel(
                  key: item.key,
                  value: item.value,
                  enabled: value ?? true,
                );
                tab.dirty = true;
              }),
            ),
            trailing: IconButton(
              onPressed: () => setState(() {
                tab.params.remove(item);
                tab.dirty = true;
              }),
              icon: const Icon(Icons.close),
            ),
          ),
        for (final item in tab.headers)
          ListTile(
            dense: true,
            title: Text(item.key),
            subtitle: Text(
              item.isSecret ? '[REDACTED secure reference]' : item.value,
            ),
            leading: Checkbox(
              value: item.enabled,
              onChanged: (value) => setState(() {
                final index = tab.headers.indexOf(item);
                tab.headers[index] = RequestHeaderModel(
                  key: item.key,
                  value: item.value,
                  enabled: value ?? true,
                  isSecret: item.isSecret,
                  secretRef: item.secretRef,
                );
                tab.dirty = true;
              }),
            ),
            trailing: IconButton(
              onPressed: () => setState(() {
                tab.headers.remove(item);
                tab.dirty = true;
              }),
              icon: const Icon(Icons.close),
            ),
          ),
        if (tab.protocol == RealtimeProtocolType.httpStream)
          TextField(
            controller: tab.body,
            minLines: 2,
            maxLines: 5,
            enabled: !_isActive(state),
            onChanged: (_) => setState(() => tab.dirty = true),
            decoration: const InputDecoration(
              labelText: 'Streaming request body',
              border: OutlineInputBorder(),
            ),
          ),
        if (tab.protocol == RealtimeProtocolType.webSocket)
          TextButton.icon(
            onPressed: _isActive(state) ? null : () => _editSubprotocols(tab),
            icon: const Icon(Icons.tune),
            label: Text(
              'Subprotocols: ${tab.subprotocols.isEmpty ? 'none' : tab.subprotocols.join(', ')}',
            ),
          ),
        const Divider(),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Resolved Preview',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        SelectableText(_preview(tab)),
      ],
    ),
  );

  Widget _metrics(BuildContext context, RealtimeSessionState state) {
    final diagnostics = DeveloperDiagnostics.forRealtime(state);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Wrap(
          spacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('In: ${state.metrics.bytesIn} B'),
            Text('Out: ${state.metrics.bytesOut} B'),
            Text('Reconnects: ${state.metrics.reconnectAttempts}'),
            Text(
              'Events: ${state.messages.length}/${state.config?.maxEvents ?? 500}',
            ),
            if (state.droppedMessages > 0)
              Text('Dropped by retention: ${state.droppedMessages}'),
            if (diagnostics.isNotEmpty)
              Tooltip(
                message: diagnostics
                    .map(
                      (item) =>
                          '${item.kind.name}: ${item.title} — ${item.detail}',
                    )
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
            TextButton.icon(
              onPressed: state.messages.isEmpty
                  ? null
                  : () => _copyTimeline(state),
              icon: const Icon(Icons.copy_outlined),
              label: const Text('Copy sanitized'),
            ),
            TextButton.icon(
              onPressed: state.config == null
                  ? null
                  : () => _exportDiagnosticBundle(state),
              icon: const Icon(Icons.download_outlined),
              label: const Text('Export diagnostics'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeline(
    BuildContext context,
    _RealtimeTab tab,
    RealtimeSessionState state,
  ) {
    final entries = state.messages.where((item) {
      final matchesDirection =
          tab.direction == null || item.direction == tab.direction;
      final query = tab.search.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          item.content.toLowerCase().contains(query) ||
          (item.eventName?.toLowerCase().contains(query) ?? false) ||
          (item.eventId?.toLowerCase().contains(query) ?? false) ||
          item.timestamp.toLocal().toString().toLowerCase().contains(query);
      return matchesDirection && matchesSearch;
    }).toList();
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => setState(() => tab.search = value),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search event, id, time, or content',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<RealtimeMessageDirection?>(
                  value: tab.direction,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All directions'),
                    ),
                    ...RealtimeMessageDirection.values.map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item.name)),
                    ),
                  ],
                  onChanged: (value) => setState(() => tab.direction = value),
                ),
              ],
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
                    key: const Key('realtime-timeline'),
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
                          '${item.sequence} • ${item.payloadType.name}${item.eventName == null ? '' : ' • ${item.eventName}'}${item.eventId == null ? '' : ' • id=${item.eventId}'}',
                        ),
                        subtitle: SelectableText(item.content, maxLines: 6),
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

  Widget _composer(
    BuildContext context,
    _RealtimeTab tab,
    RealtimeSessionState state,
  ) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            key: const Key('realtime-message'),
            controller: tab.message,
            minLines: 1,
            maxLines: 4,
            enabled: state.canSend,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Text or formatted JSON message',
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          key: const Key('realtime-send'),
          onPressed: !state.canSend
              ? null
              : () async {
                  final value = tab.message.text;
                  if (value.trim().isEmpty) return;
                  if (_looksJson(value)) {
                    await tab.cubit.sendJson(value);
                  } else {
                    await tab.cubit.sendText(value);
                  }
                  tab.message.clear();
                },
          child: const Text('Send'),
        ),
        IconButton(
          tooltip: 'Send binary file by local path',
          onPressed: !state.canSend ? null : () => _sendBinary(tab),
          icon: const Icon(Icons.attach_file),
        ),
      ],
    ),
  );

  Widget _saved(BuildContext context) =>
      FutureBuilder<List<List<RealtimeSessionConfig>>>(
        future: Future.wait([
          _tabs.first.cubit.configurations(
            context.read<WorkspaceCubit>().state.selectedWorkspaceId ?? '',
          ),
          _tabs.first.cubit.drafts(
            context.read<WorkspaceCubit>().state.selectedWorkspaceId ?? '',
          ),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final configs = snapshot.data![0];
          final drafts = snapshot.data![1];
          if (configs.isEmpty && drafts.isEmpty) {
            return const Center(
              child: Text('No saved realtime configurations or drafts yet.'),
            );
          }
          return ListView(
            children: [
              const ListTile(title: Text('Saved configurations')),
              for (final item in configs) _savedTile(item, draft: false),
              const Divider(),
              const ListTile(title: Text('Drafts')),
              for (final item in drafts) _savedTile(item, draft: true),
            ],
          );
        },
      );

  Widget _savedTile(
    RealtimeSessionConfig config, {
    required bool draft,
  }) => ListTile(
    leading: Icon(_icon(config.protocol)),
    title: Text(config.name),
    subtitle: Text(
      '${config.protocol.name} • ${SecretMasker.redactText(config.url)}${draft ? ' • draft' : ''}',
    ),
    trailing: Wrap(
      children: [
        FilledButton.tonal(
          onPressed: () => _newTab(config),
          child: const Text('Open as new tab'),
        ),
        IconButton(
          tooltip: draft ? 'Delete draft' : 'Delete configuration',
          onPressed: () async {
            final confirmed = await _confirm(
              draft ? 'Delete realtime draft?' : 'Delete configuration?',
              'This local item will be removed.',
            );
            if (!confirmed) return;
            if (draft) {
              await _tabs.first.cubit.deleteDraft(config.id);
            } else {
              await _tabs.first.cubit.deleteConfiguration(config.id);
            }
            if (mounted) setState(() {});
          },
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    ),
  );

  Widget _historyView(BuildContext context) => Column(
    children: [
      Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 300,
            child: TextField(
              onChanged: (value) => _historySearch = value,
              onSubmitted: (_) => _loadHistory(),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Search history',
              ),
            ),
          ),
          DropdownButton<RealtimeProtocolType?>(
            value: _historyProtocol,
            items: [
              const DropdownMenuItem(value: null, child: Text('All protocols')),
              ...RealtimeProtocolType.values.map(
                (item) =>
                    DropdownMenuItem(value: item, child: Text(_label(item))),
              ),
            ],
            onChanged: (value) {
              setState(() => _historyProtocol = value);
              _loadHistory();
            },
          ),
          DropdownButton<String?>(
            value: _historyStatus,
            items: [
              const DropdownMenuItem(value: null, child: Text('Any status')),
              ...RealtimeConnectionStatus.values.map(
                (item) =>
                    DropdownMenuItem(value: item.name, child: Text(item.name)),
              ),
            ],
            onChanged: (value) {
              setState(() => _historyStatus = value);
              _loadHistory();
            },
          ),
          DropdownButton<String?>(
            value: _historyFailure,
            items: const [
              DropdownMenuItem(value: null, child: Text('Any failure')),
              DropdownMenuItem(value: 'network', child: Text('Network')),
              DropdownMenuItem(value: 'timeout', child: Text('Timeout')),
              DropdownMenuItem(
                value: 'configuration',
                child: Text('Configuration'),
              ),
            ],
            onChanged: (value) {
              setState(() => _historyFailure = value);
              _loadHistory();
            },
          ),
          DropdownButton<int?>(
            value: _historyAgeDays,
            items: const [
              DropdownMenuItem(value: null, child: Text('Any date')),
              DropdownMenuItem(value: 1, child: Text('Last 24 hours')),
              DropdownMenuItem(value: 7, child: Text('Last 7 days')),
              DropdownMenuItem(value: 30, child: Text('Last 30 days')),
            ],
            onChanged: (value) {
              setState(() => _historyAgeDays = value);
              _loadHistory();
            },
          ),
          FilledButton.tonalIcon(
            onPressed: _loadHistory,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
          FilledButton.tonalIcon(
            onPressed: _comparison.length == 2 ? _showComparison : null,
            icon: const Icon(Icons.compare_arrows),
            label: const Text('Compare selected'),
          ),
          TextButton.icon(
            onPressed: _editRetention,
            icon: const Icon(Icons.auto_delete_outlined),
            label: const Text('Retention'),
          ),
          TextButton(
            onPressed: _history.isEmpty ? null : _clearHistory,
            child: const Text('Clear history'),
          ),
        ],
      ),
      Expanded(
        child: _historyLoading
            ? const Center(child: CircularProgressIndicator())
            : _history.isEmpty
            ? const Center(
                child: Text('No realtime history matches the filters.'),
              )
            : ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final item = _history[index];
                  return ListTile(
                    leading: Checkbox(
                      value: _comparison.contains(item.id),
                      onChanged: (value) => setState(() {
                        if (value == true && _comparison.length < 2) {
                          _comparison.add(item.id);
                        } else {
                          _comparison.remove(item.id);
                        }
                      }),
                    ),
                    title: Text(
                      '${item.protocol.name} • ${item.status}${item.pinned ? ' • pinned' : ''}',
                    ),
                    subtitle: Text(
                      '${item.summary['name'] ?? ''}\n${item.createdAt.toLocal()}${item.tags.isEmpty ? '' : ' • ${item.tags.join(', ')}'}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) => _historyAction(value, item),
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'reopen',
                          child: Text('Reopen as new draft'),
                        ),
                        PopupMenuItem(
                          value: 'metadata',
                          child: Text('Pin, tags, notes'),
                        ),
                        PopupMenuItem(
                          value: 'copy',
                          child: Text('Copy sanitized JSON'),
                        ),
                        PopupMenuItem(
                          value: 'export',
                          child: Text('Export sanitized JSON'),
                        ),
                        PopupMenuItem(
                          value: 'exportJsonl',
                          child: Text('Export events as JSONL'),
                        ),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  );
                },
              ),
      ),
    ],
  );

  Widget _intelligence(BuildContext context, RealtimeSessionState state) {
    final diagnostics = DeveloperDiagnostics.forRealtime(state);
    final source = <String, Object?>{
      'action': _aiAction.name,
      'status': state.status.name,
      'failure': state.failure?.message,
      'headers': state.config?.headers
          .map(
            (item) =>
                '${item.key}: ${item.isSecret ? '[REDACTED]' : item.value}',
          )
          .toList(),
      'body': state.config?.body?.content,
      'events': state.messages.map((item) => item.content).toList(),
      'history': _history.map((item) => item.summary).toList(),
    };
    return ListView(
      children: [
        Text(
          'Local diagnostics',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (diagnostics.isEmpty)
          const ListTile(
            title: Text(
              'No local diagnostic findings for the current session.',
            ),
          ),
        for (final item in diagnostics)
          ListTile(
            leading: Icon(
              item.kind == DiagnosticKind.observed
                  ? Icons.fact_check_outlined
                  : Icons.lightbulb_outline,
            ),
            title: Text('${item.kind.name}: ${item.title}'),
            subtitle: SelectableText(item.detail),
          ),
        const Divider(),
        SwitchListTile(
          value: _aiOptions.granted,
          onChanged: (value) => _setAiOptions(
            AiConsentOptions(
              granted: value,
              includeBodies: _aiOptions.includeBodies,
              includeHeaders: _aiOptions.includeHeaders,
              includeHistory: _aiOptions.includeHistory,
              includeEvents: _aiOptions.includeEvents,
            ),
          ),
          title: const Text('Explicit external AI consent'),
          subtitle: const Text(
            'Disabled by default. Nothing is sent automatically; this demo uses the deterministic fake provider.',
          ),
        ),
        Wrap(
          spacing: 8,
          children: [
            _consentChip(
              'Bodies',
              _aiOptions.includeBodies,
              (value) => _setAiIncludes(body: value),
            ),
            _consentChip(
              'Headers',
              _aiOptions.includeHeaders,
              (value) => _setAiIncludes(headers: value),
            ),
            _consentChip(
              'History',
              _aiOptions.includeHistory,
              (value) => _setAiIncludes(history: value),
            ),
            _consentChip(
              'Events',
              _aiOptions.includeEvents,
              (value) => _setAiIncludes(events: value),
            ),
          ],
        ),
        DropdownButton<AiAnalysisAction>(
          value: _aiAction,
          items: AiAnalysisAction.values
              .map(
                (item) => DropdownMenuItem(value: item, child: Text(item.name)),
              )
              .toList(),
          onChanged: (value) => setState(() => _aiAction = value!),
        ),
        Wrap(
          spacing: 8,
          children: [
            FilledButton.tonal(
              onPressed: () => setState(() {
                _aiPreview = ConsentAiService.preview(
                  options: _aiOptions,
                  source: source,
                );
                _aiResult = null;
              }),
              child: const Text('Build exact redacted preview'),
            ),
            FilledButton(
              onPressed: _aiOptions.granted && _aiPreview != null
                  ? () async {
                      final token = AiCancellationToken();
                      _aiCancellation = token;
                      try {
                        final result = await ConsentAiService.analyze(
                          options: _aiOptions,
                          source: source,
                          provider: FakeAiProvider(),
                          cancellationToken: token,
                        );
                        if (mounted && !token.isCancelled) {
                          setState(() => _aiResult = result);
                        }
                      } catch (error) {
                        if (mounted && !token.isCancelled) {
                          _notice(SecretMasker.redactText(error.toString()));
                        }
                      } finally {
                        if (identical(_aiCancellation, token)) {
                          _aiCancellation = null;
                        }
                      }
                    }
                  : null,
              child: const Text('Approve and analyze'),
            ),
            TextButton(
              onPressed: () => setState(() {
                _aiCancellation?.cancel();
                _aiPreview = null;
                _aiResult = null;
              }),
              child: const Text('Cancel'),
            ),
          ],
        ),
        if (_aiPreview != null)
          SelectableText(
            const JsonEncoder.withIndent('  ').convert(_aiPreview!.payload),
          ),
        if (_aiResult != null)
          ListTile(
            title: const Text('AI suggestion (never auto-applied)'),
            subtitle: SelectableText(_aiResult!),
          ),
      ],
    );
  }

  FilterChip _consentChip(
    String label,
    bool value,
    ValueChanged<bool> changed,
  ) => FilterChip(
    label: Text('Include $label'),
    selected: value,
    onSelected: _aiOptions.granted ? changed : null,
  );

  Future<void> _connect(_RealtimeTab tab) async {
    final config = _configWithWorkspace(tab);
    final uri = Uri.tryParse(config.url);
    final valid =
        uri != null &&
        ((config.protocol == RealtimeProtocolType.webSocket &&
                {'ws', 'wss'}.contains(uri.scheme)) ||
            (config.protocol != RealtimeProtocolType.webSocket &&
                {'http', 'https'}.contains(uri.scheme)));
    if (!valid) {
      _notice('Enter a complete URL with the correct protocol.');
      return;
    }
    if (config.productionEnvironment &&
        config.protocol == RealtimeProtocolType.httpStream &&
        {
          HttpMethod.post,
          HttpMethod.put,
          HttpMethod.patch,
          HttpMethod.delete,
        }.contains(config.method)) {
      final confirmed = await _confirm(
        'Production streaming request',
        'This mutating request targets a production environment. Continue?',
      );
      if (!confirmed) return;
    }
    await tab.cubit.connect(config);
  }

  RealtimeSessionConfig _configWithWorkspace(_RealtimeTab tab) {
    final workspace = context.read<WorkspaceCubit>().state;
    final variables = workspace.environmentVariables
        .where((item) => item.enabled && !item.isSecret)
        .fold(<String, String>{}, (map, item) => map..[item.key] = item.value);
    final secretRefs = workspace.environmentVariables
        .where(
          (item) => item.enabled && item.isSecret && item.secretRef != null,
        )
        .fold(
          <String, String>{},
          (map, item) => map..[item.key] = item.secretRef!,
        );
    tab.cubit.updateEnvironmentVariables(variables, secretRefs);
    final selectedEnvironment = workspace.environments
        .where((item) => item.id == workspace.selectedEnvironmentId)
        .firstOrNull;
    return tab.config().copyWith(
      workspaceId: workspace.selectedWorkspaceId,
      collectionId: workspace.selectedCollectionId,
      environmentId: workspace.selectedEnvironmentId,
      productionEnvironment:
          tab.production ||
          selectedEnvironment?.kind == EnvironmentKind.production,
    );
  }

  void _newTab([RealtimeSessionConfig? config]) {
    final sibling = _tabs.first.cubit.createSibling();
    setState(() {
      _tabs.add(_RealtimeTab(sibling, config: config));
      _active = _tabs.length - 1;
      _section = 0;
    });
  }

  Future<void> _closeTab(int index) async {
    if (_tabs.length == 1) return;
    final tab = _tabs[index];
    if (_isActive(tab.cubit.state) || tab.cubit.state.isDirty || tab.dirty) {
      final confirmed = await _confirm(
        'Close realtime tab?',
        'The active or unsaved session will be disconnected and closed.',
      );
      if (!confirmed) return;
    }
    await tab.cubit.disconnect();
    if (tab.owned) await tab.cubit.close();
    tab.dispose();
    if (!mounted) return;
    setState(() {
      _tabs.removeAt(index);
      if (_active >= _tabs.length) _active = _tabs.length - 1;
    });
  }

  Future<void> _confirmCloseOrDisconnect(
    _RealtimeTab tab,
    RealtimeSessionState state,
  ) async {
    final confirmed = await _confirm(
      'Leave realtime session?',
      'Disconnect the active session and discard unsaved changes?',
    );
    if (confirmed) await tab.cubit.disconnect();
  }

  Future<void> _addPair(_RealtimeTab tab, {required bool header}) async {
    final key = TextEditingController();
    final value = TextEditingController();
    var secret = false;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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
                obscureText: secret,
                decoration: InputDecoration(
                  labelText: secret ? 'Secure-storage reference' : 'Value',
                ),
              ),
              if (header)
                SwitchListTile(
                  value: secret,
                  onChanged: (item) => setDialogState(() => secret = item),
                  title: const Text('Secret reference'),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
    if (result == true && key.text.trim().isNotEmpty && mounted) {
      setState(() {
        if (header) {
          tab.headers.add(
            RequestHeaderModel(
              key: key.text.trim(),
              value: secret ? '' : value.text,
              isSecret: secret,
              secretRef: secret ? value.text.trim() : null,
            ),
          );
        } else {
          tab.params.add(
            RequestQueryParamModel(key: key.text.trim(), value: value.text),
          );
        }
        tab.dirty = true;
      });
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
    key.dispose();
    value.dispose();
  }

  void _editAuth(_RealtimeTab tab, AuthType type) async {
    if (type == AuthType.none) {
      setState(() {
        tab.auth = const RequestAuthModel();
        tab.dirty = true;
      });
      return;
    }
    final username = TextEditingController();
    final reference = TextEditingController();
    final keyName = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Configure ${type.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (type == AuthType.basic)
              TextField(
                controller: username,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
            if (type == AuthType.apiKeyHeader || type == AuthType.apiKeyQuery)
              TextField(
                controller: keyName,
                decoration: const InputDecoration(labelText: 'API key name'),
              ),
            TextField(
              controller: reference,
              decoration: const InputDecoration(
                labelText: 'Secure-storage reference',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved == true && mounted) {
      setState(
        () => tab.auth = RequestAuthModel(
          type: type,
          username: username.text,
          passwordSecretRef: type == AuthType.basic ? reference.text : null,
          tokenSecretRef: type == AuthType.bearer ? reference.text : null,
          apiKeyName: keyName.text,
          apiKeySecretRef:
              type == AuthType.apiKeyHeader || type == AuthType.apiKeyQuery
              ? reference.text
              : null,
        ),
      );
      tab.dirty = true;
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
    username.dispose();
    reference.dispose();
    keyName.dispose();
  }

  Future<void> _editSubprotocols(_RealtimeTab tab) async {
    final controller = TextEditingController(text: tab.subprotocols.join(', '));
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('WebSocket subprotocols'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'graphql-ws, chat'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved == true && mounted) {
      setState(
        () => tab.subprotocols = controller.text
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList(),
      );
      tab.dirty = true;
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
    controller.dispose();
  }

  Future<void> _sendBinary(_RealtimeTab tab) async {
    final sent = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send binary file'),
        content: TextField(
          controller: tab.binaryPath,
          decoration: const InputDecoration(labelText: 'Local file path'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send'),
          ),
        ],
      ),
    );
    if (sent == true && tab.binaryPath.text.isNotEmpty) {
      await tab.cubit.sendBinary(await File(tab.binaryPath.text).readAsBytes());
    }
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;
    setState(() => _historyLoading = true);
    final items = await _tabs.first.cubit.history(
      filter: RealtimeHistoryFilter(
        workspaceId:
            context.read<WorkspaceCubit>().state.selectedWorkspaceId ?? '',
        protocol: _historyProtocol,
        status: _historyStatus,
        failureCategory: _historyFailure,
        from: _historyAgeDays == null
            ? null
            : DateTime.now().subtract(Duration(days: _historyAgeDays!)),
        search: _historySearch,
      ),
    );
    if (mounted) {
      setState(() {
        _history = items;
        _historyLoading = false;
        _comparison.removeWhere((id) => !items.any((item) => item.id == id));
      });
    }
  }

  Future<void> _historyAction(String action, RealtimeHistoryEntry item) async {
    if (action == 'reopen') {
      final config = await _tabs.first.cubit.reopenHistory(item.id);
      if (config != null) _newTab(config);
    }
    if (action == 'copy') {
      await Clipboard.setData(
        ClipboardData(
          text: DiagnosticBundleService.sanitizedJson(item.summary),
        ),
      );
      if (mounted) _notice('Sanitized history copied.');
    }
    if (action == 'export') {
      final file = await DiagnosticBundleService.export(
        item.summary,
        name: 'devroute-realtime-${item.id}.json',
      );
      if (mounted) _notice('Sanitized history exported to ${file.path}');
    }
    if (action == 'exportJsonl') {
      final events = (item.summary['events'] as List?) ?? const <Object?>[];
      final data = DiagnosticBundleService.sanitizedJsonLines(
        events.whereType<Map>().map((value) => value.cast<String, Object?>()),
      );
      final file = await DiagnosticBundleService.exportText(
        data,
        name: 'devroute-realtime-${item.id}-events.jsonl',
      );
      if (mounted) _notice('Sanitized event export written to ${file.path}');
    }
    if (action == 'delete') {
      await _tabs.first.cubit.deleteHistory(item.id);
      await _loadHistory();
    }
    if (action == 'metadata') await _editMetadata(item);
  }

  Future<void> _editMetadata(RealtimeHistoryEntry item) async {
    final tags = TextEditingController(text: item.tags.join(', '));
    final notes = TextEditingController(text: item.notes);
    var pinned = item.pinned;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('History metadata'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                value: pinned,
                onChanged: (value) => setDialogState(() => pinned = value),
                title: const Text('Pinned'),
              ),
              TextField(
                controller: tags,
                decoration: const InputDecoration(
                  labelText: 'Tags, comma separated',
                ),
              ),
              TextField(
                controller: notes,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Local notes'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (saved == true) {
      await _tabs.first.cubit.updateHistoryMetadata(
        item.id,
        pinned: pinned,
        tags: tags.text
            .split(',')
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toList(),
        notes: SecretMasker.redactText(notes.text),
      );
      await _loadHistory();
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
    tags.dispose();
    notes.dispose();
  }

  Future<void> _showComparison() async {
    final selected = _history
        .where((item) => _comparison.contains(item.id))
        .toList();
    if (selected.length != 2) return;
    final changes = HistoryComparisonService.compareRealtime(
      selected[0],
      selected[1],
    );
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Realtime session comparison'),
        content: SizedBox(
          width: 760,
          height: 500,
          child: changes.isEmpty
              ? const Center(child: Text('No differences.'))
              : ListView(
                  children: changes
                      .map(
                        (item) => ListTile(
                          title: Text(item.path),
                          subtitle: SelectableText(
                            '${item.before}  →  ${item.after}',
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearHistory() async {
    final workspaceId = context
        .read<WorkspaceCubit>()
        .state
        .selectedWorkspaceId;
    if (await _confirm(
      'Clear realtime history?',
      'All sanitized realtime session history will be removed.',
    )) {
      await _tabs.first.cubit.clearHistory(workspaceId: workspaceId);
      await _loadHistory();
    }
  }

  Future<void> _copyTimeline(RealtimeSessionState state) async {
    final value = DiagnosticBundleService.sanitizedJsonLines(
      state.messages.map(
        (item) => <String, Object?>{
          'sequence': item.sequence,
          'direction': item.direction.name,
          'type': item.payloadType.name,
          'content': item.content,
          'event': item.eventName,
          'id': item.eventId,
          'time': item.timestamp.toIso8601String(),
        },
      ),
    );
    await Clipboard.setData(ClipboardData(text: value));
    if (mounted) _notice('Sanitized JSONL timeline copied.');
  }

  Future<void> _exportDiagnosticBundle(RealtimeSessionState state) async {
    final diagnostics = DeveloperDiagnostics.forRealtime(state);
    final file = await DiagnosticBundleService.export(<String, Object?>{
      'protocol': state.config?.protocol.name,
      'url': state.config?.url,
      'status': state.status.name,
      'metrics': <String, Object?>{
        'bytesIn': state.metrics.bytesIn,
        'bytesOut': state.metrics.bytesOut,
        'reconnectAttempts': state.metrics.reconnectAttempts,
        'durationMs': state.metrics.duration?.inMilliseconds,
      },
      'failure': state.failure?.message,
      'diagnostics': diagnostics
          .map(
            (item) => <String, Object?>{
              'kind': item.kind.name,
              'title': item.title,
              'detail': item.detail,
            },
          )
          .toList(),
      'events': state.messages
          .map(
            (item) => <String, Object?>{
              'sequence': item.sequence,
              'direction': item.direction.name,
              'type': item.payloadType.name,
              'content': item.content,
            },
          )
          .toList(),
    }, name: 'devroute-realtime-diagnostics.json');
    if (mounted) {
      _notice('Sanitized diagnostic bundle exported to ${file.path}');
    }
  }

  void _setAiIncludes({
    bool? body,
    bool? headers,
    bool? history,
    bool? events,
  }) => _setAiOptions(
    AiConsentOptions(
      granted: _aiOptions.granted,
      includeBodies: body ?? _aiOptions.includeBodies,
      includeHeaders: headers ?? _aiOptions.includeHeaders,
      includeHistory: history ?? _aiOptions.includeHistory,
      includeEvents: events ?? _aiOptions.includeEvents,
    ),
  );

  Future<void> _loadAiPreferences() async {
    final options = await _tabs.first.cubit.aiPreferences();
    if (mounted) setState(() => _aiOptions = options);
  }

  void _setAiOptions(AiConsentOptions options) {
    setState(() {
      _aiOptions = options;
      _aiPreview = null;
      _aiResult = null;
    });
    unawaited(_tabs.first.cubit.saveAiPreferences(options));
  }

  Future<void> _editRetention() async {
    final workspaceId =
        context.read<WorkspaceCubit>().state.selectedWorkspaceId ?? '';
    final current = await _tabs.first.cubit.retention(workspaceId);
    if (!mounted) return;
    final days = TextEditingController(text: current.days.toString());
    final maximum = TextEditingController(
      text: current.maximumCount.toString(),
    );
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Realtime history retention'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: days,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Maximum age in days',
              ),
            ),
            TextField(
              controller: maximum,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Maximum sessions'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    final parsedDays = int.tryParse(days.text);
    final parsedMaximum = int.tryParse(maximum.text);
    if (saved == true &&
        parsedDays != null &&
        parsedDays > 0 &&
        parsedMaximum != null &&
        parsedMaximum > 0) {
      await _tabs.first.cubit.saveRetention(
        workspaceId,
        days: parsedDays,
        maximumCount: parsedMaximum,
      );
      await _loadHistory();
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
    days.dispose();
    maximum.dispose();
  }

  String _preview(_RealtimeTab tab) {
    final uri = Uri.tryParse(tab.url.text);
    if (uri == null) {
      return 'Resolved preview unavailable until the URL is valid.';
    }
    final query = {
      ...uri.queryParameters,
      for (final item in tab.params.where((item) => item.enabled))
        item.key: item.value,
    };
    return '${tab.protocol.name.toUpperCase()} ${SecretMasker.redactText(uri.replace(queryParameters: query).toString())}\n${tab.headers.where((item) => item.enabled).map((item) => '${item.key}: ${item.isSecret ? '[REDACTED]' : SecretMasker.redactText(item.value)}').join('\n')}\nAuth: ${tab.auth.type.name}${tab.body.text.isEmpty ? '' : '\nBody: ${SecretMasker.redactText(tab.body.text)}'}';
  }

  Future<bool> _confirm(String title, String message) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ) ??
      false;
  void _notice(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
  static bool _isActive(RealtimeSessionState state) => {
    RealtimeConnectionStatus.connecting,
    RealtimeConnectionStatus.connected,
    RealtimeConnectionStatus.reconnecting,
  }.contains(state.status);
  static bool _looksJson(String value) {
    try {
      jsonDecode(value);
      return true;
    } catch (_) {
      return false;
    }
  }

  static IconData _icon(RealtimeProtocolType type) => switch (type) {
    RealtimeProtocolType.webSocket => Icons.swap_horiz,
    RealtimeProtocolType.sse => Icons.sensors,
    RealtimeProtocolType.httpStream => Icons.stream,
  };
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

class _NewRealtimeTabIntent extends Intent {
  const _NewRealtimeTabIntent();
}

class _CloseRealtimeTabIntent extends Intent {
  const _CloseRealtimeTabIntent();
}
