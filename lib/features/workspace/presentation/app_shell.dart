import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/diagnostics/developer_diagnostics.dart';
import '../../../core/diagnostics/history_comparison_service.dart';
import '../../../core/rest/request_safety_service.dart';
import '../../../core/rest/safe_export_service.dart';
import '../../../core/rest/token_candidate_service.dart';
import '../../../core/rest/variable_resolution_service.dart';
import '../../../core/security/secret_masker.dart';
import '../../../core/storage/local_workspace_repository.dart';
import '../../../features/realtime/presentation/realtime_screen.dart';
import '../../../shared/models/api_models.dart';
import '../../requests/presentation/request_workflow_cubit.dart';
import 'workspace_cubit.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialSection = 0});
  final int initialSection;
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _selected = widget.initialSection;
  final _urlController = TextEditingController();
  String? _historyMethod;
  int? _historyMinimumStatus;
  final Set<String> _restComparison = <String>{};
  String _responseSearch = '';
  bool _rawResponse = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 900;
    final requestState = context.watch<RequestWorkflowCubit>().state;
    final body = Padding(padding: const EdgeInsets.all(16), child: _content());
    return PopScope(
      canPop: !requestState.hasAnyDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && requestState.hasAnyDirty) await _discardAndPop();
      },
      child: Scaffold(
        appBar: compact
            ? AppBar(title: const Text('DevRoute AI Studio'))
            : null,
        body: compact
            ? body
            : Row(
                children: [
                  NavigationRail(
                    extended: true,
                    selectedIndex: _selected,
                    onDestinationSelected: _select,
                    leading: const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'DevRoute',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.folder_outlined),
                        label: Text('Workspace'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.send_outlined),
                        label: Text('Requests'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.history),
                        label: Text('History'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.tune),
                        label: Text('Environments'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.settings_outlined),
                        label: Text('Settings'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.hub_outlined),
                        label: Text('Realtime'),
                      ),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: body),
                ],
              ),
        bottomNavigationBar: compact
            ? NavigationBar(
                selectedIndex: _selected,
                onDestinationSelected: _select,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.folder_outlined),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.send_outlined),
                    label: 'Request',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.history),
                    label: 'History',
                  ),
                  NavigationDestination(icon: Icon(Icons.tune), label: 'Env'),
                  NavigationDestination(
                    icon: Icon(Icons.settings_outlined),
                    label: 'Settings',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.hub_outlined),
                    label: 'Realtime',
                  ),
                ],
              )
            : null,
      ),
    );
  }

  void _select(int value) => setState(() => _selected = value);
  Widget _content() => switch (_selected) {
    0 => _workspace(),
    1 => _request(),
    2 => _history(),
    3 => _environments(),
    4 => _settings(),
    _ => const RealtimeScreen(),
  };

  Widget _workspace() => BlocBuilder<WorkspaceCubit, WorkspaceState>(
    builder: (context, state) {
      final cubit = context.read<WorkspaceCubit>();
      if (state.loading) {
        return const Center(child: CircularProgressIndicator());
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Workspace',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              DropdownButton<String>(
                value: state.selectedWorkspaceId,
                items: state.workspaces
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.id,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
                onChanged: (id) {
                  if (id != null) cubit.selectWorkspace(id);
                },
              ),
              IconButton(
                tooltip: 'New workspace',
                onPressed: () async {
                  final name = await _askName('New workspace');
                  if (name != null) cubit.addWorkspace(name);
                },
                icon: const Icon(Icons.add_business_outlined),
              ),
              IconButton(
                tooltip: 'Rename workspace',
                onPressed: state.selectedWorkspaceId == null
                    ? null
                    : () async {
                        final current = state.workspaces.firstWhere(
                          (item) => item.id == state.selectedWorkspaceId,
                        );
                        final name = await _askName(
                          'Rename workspace',
                          initial: current.name,
                        );
                        if (name != null) {
                          cubit.renameWorkspace(current.id, name);
                        }
                      },
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Delete workspace',
                onPressed: state.workspaces.length <= 1
                    ? null
                    : () async {
                        if (await _confirm(
                          'Delete workspace?',
                          'Collections, requests, environments, drafts, and their secret references will be removed.',
                        )) {
                          cubit.removeWorkspace(state.selectedWorkspaceId!);
                        }
                      },
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: cubit.search,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search collections, requests, URLs, and history',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: [
                Row(
                  children: [
                    Text(
                      'Collections',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () async {
                        final name = await _askName('New collection');
                        if (name != null) cubit.addCollection(name);
                      },
                      icon: const Icon(Icons.create_new_folder_outlined),
                      label: const Text('New'),
                    ),
                  ],
                ),
                for (final item in state.collections)
                  Card(
                    child: ListTile(
                      selected: item.id == state.selectedCollectionId,
                      leading: const Icon(Icons.folder_outlined),
                      title: Text(item.name),
                      onTap: () => cubit.selectCollection(item.id),
                      trailing: Wrap(
                        children: [
                          IconButton(
                            tooltip: 'Move up',
                            onPressed: state.collections.indexOf(item) == 0
                                ? null
                                : () => cubit.reorderCollection(
                                    item.id,
                                    state.collections.indexOf(item) - 1,
                                  ),
                            icon: const Icon(Icons.arrow_upward),
                          ),
                          IconButton(
                            tooltip: 'Move down',
                            onPressed:
                                state.collections.indexOf(item) ==
                                    state.collections.length - 1
                                ? null
                                : () => cubit.reorderCollection(
                                    item.id,
                                    state.collections.indexOf(item) + 1,
                                  ),
                            icon: const Icon(Icons.arrow_downward),
                          ),
                          IconButton(
                            tooltip: 'Move to workspace',
                            onPressed: () => _moveCollection(item),
                            icon: const Icon(Icons.drive_file_move_outline),
                          ),
                          IconButton(
                            tooltip: 'Duplicate collection',
                            onPressed: () => cubit.duplicateCollection(item.id),
                            icon: const Icon(Icons.copy_outlined),
                          ),
                          IconButton(
                            tooltip: 'Rename',
                            onPressed: () async {
                              final name = await _askName(
                                'Rename collection',
                                initial: item.name,
                              );
                              if (name != null) {
                                cubit.renameCollection(item.id, name);
                              }
                            },
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: 'Delete',
                            onPressed: () async {
                              if (await _confirm(
                                'Delete collection?',
                                'Its folders, requests, drafts, and secret references will be removed.',
                              )) {
                                cubit.removeCollection(item.id);
                              }
                            },
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (state.selectedCollectionId != null) ...[
                  const Divider(),
                  Row(
                    children: [
                      Text(
                        'Folders',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () async {
                          final name = await _askName('New folder');
                          if (name != null) cubit.addFolder(name);
                        },
                        icon: const Icon(Icons.create_new_folder_outlined),
                        label: const Text('Add folder'),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final folder in state.folders)
                        ActionChip(
                          avatar: Icon(
                            folder.parentFolderId == null
                                ? Icons.folder_outlined
                                : Icons.subdirectory_arrow_right,
                          ),
                          label: Text(folder.name),
                          onPressed: () => _folderActions(folder),
                        ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Text(
                        'Saved requests',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: () {
                          context.read<RequestWorkflowCubit>().newRequest(
                            collectionId: state.selectedCollectionId,
                          );
                          _select(1);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('New request'),
                      ),
                    ],
                  ),
                  if (state.savedRequests.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: Text('No matching saved requests.')),
                    ),
                  for (final request in state.savedRequests)
                    Card(
                      child: ListTile(
                        leading: Text(request.method.name.toUpperCase()),
                        title: Text(request.name),
                        subtitle: Text(request.url),
                        onTap: () {
                          context.read<RequestWorkflowCubit>().openRequest(
                            request,
                          );
                          _select(1);
                        },
                        trailing: Wrap(
                          children: [
                            IconButton(
                              tooltip: 'Move up',
                              onPressed:
                                  state.savedRequests.indexOf(request) == 0
                                  ? null
                                  : () => cubit.reorderSavedRequest(
                                      request.id,
                                      state.savedRequests.indexOf(request) - 1,
                                    ),
                              icon: const Icon(Icons.arrow_upward),
                            ),
                            IconButton(
                              tooltip: 'Move down',
                              onPressed:
                                  state.savedRequests.indexOf(request) ==
                                      state.savedRequests.length - 1
                                  ? null
                                  : () => cubit.reorderSavedRequest(
                                      request.id,
                                      state.savedRequests.indexOf(request) + 1,
                                    ),
                              icon: const Icon(Icons.arrow_downward),
                            ),
                            IconButton(
                              tooltip: 'Duplicate',
                              onPressed: () =>
                                  cubit.duplicateSavedRequest(request.id),
                              icon: const Icon(Icons.copy_outlined),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              onPressed: () async {
                                if (await _confirm(
                                  'Delete request?',
                                  'The saved request, draft, and its secret references will be removed.',
                                )) {
                                  cubit.removeSavedRequest(request.id);
                                }
                              },
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      );
    },
  );

  Widget _request() => BlocConsumer<RequestWorkflowCubit, RequestWorkflowState>(
    listener: (context, state) {
      if (state.validationErrors.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.validationErrors.join('\n'))),
        );
      }
    },
    builder: (context, state) {
      final cubit = context.read<RequestWorkflowCubit>();
      final sendingActiveRequest = state.isSendingRequest(state.request.id);
      final workspace = context.watch<WorkspaceCubit>().state;
      if (_urlController.text != state.request.url) {
        _urlController.value = TextEditingValue(
          text: state.request.url,
          selection: TextSelection.collapsed(offset: state.request.url.length),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (var i = 0; i < state.tabs.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InputChip(
                      selected: i == state.activeIndex,
                      label: Text(
                        '${state.tabs[i].name}${state.dirtyIds.contains(state.tabs[i].id) ? ' *' : ''}',
                      ),
                      onPressed: () => cubit.selectTab(i),
                      onDeleted: state.tabs.length == 1 && !state.isDirty
                          ? null
                          : () => _closeRequestTab(),
                    ),
                  ),
                IconButton(
                  tooltip: 'New request tab',
                  onPressed: () => cubit.newRequest(
                    collectionId: workspace.selectedCollectionId,
                  ),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 260,
                child: TextFormField(
                  key: ValueKey('${state.request.id}-name'),
                  initialValue: state.request.name,
                  onChanged: cubit.updateName,
                  decoration: const InputDecoration(
                    labelText: 'Request name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              DropdownButton<String?>(
                value: state.request.collectionId,
                hint: const Text('Collection'),
                items: <DropdownMenuItem<String?>>[
                  const DropdownMenuItem(
                    value: null,
                    child: Text('No collection'),
                  ),
                  ...workspace.collections.map(
                    (item) => DropdownMenuItem(
                      value: item.id,
                      child: Text(item.name),
                    ),
                  ),
                ],
                onChanged: (value) => cubit.assignLocation(value, null),
              ),
              DropdownButton<String?>(
                value: state.request.folderId,
                hint: const Text('Folder'),
                items: <DropdownMenuItem<String?>>[
                  const DropdownMenuItem(value: null, child: Text('No folder')),
                  ...workspace.folders.map(
                    (item) => DropdownMenuItem(
                      value: item.id,
                      child: Text(item.name),
                    ),
                  ),
                ],
                onChanged: state.request.collectionId == null
                    ? null
                    : (value) => cubit.assignLocation(
                        state.request.collectionId,
                        value,
                      ),
              ),
              TextButton.icon(
                onPressed: sendingActiveRequest ? null : cubit.save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save'),
              ),
              TextButton.icon(
                onPressed: _closeRequestTab,
                icon: const Icon(Icons.close),
                label: const Text('Close'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              DropdownButton<HttpMethod>(
                value: state.request.method,
                items: HttpMethod.values
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item.name.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: sendingActiveRequest
                    ? null
                    : (value) => cubit.updateMethod(value!),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _urlController,
                  enabled: !sendingActiveRequest,
                  onChanged: cubit.updateUrl,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'https://api.example.com/resource',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                onPressed: sendingActiveRequest
                    ? cubit.cancel
                    : () => _sendWithSafety(cubit, state, workspace),
                icon: Icon(
                  sendingActiveRequest
                      ? Icons.stop_circle_outlined
                      : Icons.send,
                ),
                label: Text(sendingActiveRequest ? 'Cancel' : 'Send'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _requestEditor(state, cubit, workspace),
          const SizedBox(height: 8),
          Expanded(
            child: state.response == null
                ? const Card(
                    child: Center(
                      child: Text(
                        'Configure and send a request. Drafts autosave locally.',
                      ),
                    ),
                  )
                : _response(
                    state.request,
                    state.response!,
                    state.sensitiveValues[state.request.id] ?? const <String>{},
                  ),
          ),
        ],
      );
    },
  );

  Widget _requestEditor(
    RequestWorkflowState state,
    RequestWorkflowCubit cubit,
    WorkspaceState workspace,
  ) => DefaultTabController(
    length: 6,
    child: Card(
      child: SizedBox(
        height: 250,
        child: Column(
          children: [
            const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Params'),
                Tab(text: 'Headers'),
                Tab(text: 'Auth'),
                Tab(text: 'Body'),
                Tab(text: 'Settings'),
                Tab(text: 'Resolved Preview'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _keyValueList(
                    title: 'Query parameters',
                    items: state.request.queryParams
                        .map((item) => (item.key, item.value, item.enabled))
                        .toList(),
                    onAdd: () async {
                      final pair = await _askPair('Add query parameter');
                      if (pair != null) {
                        cubit.updateQueryParams(<RequestQueryParamModel>[
                          ...state.request.queryParams,
                          RequestQueryParamModel(key: pair.$1, value: pair.$2),
                        ]);
                      }
                    },
                    onRemove: (index) {
                      final values = List<RequestQueryParamModel>.of(
                        state.request.queryParams,
                      )..removeAt(index);
                      cubit.updateQueryParams(values);
                    },
                    onToggle: (index, enabled) {
                      final values = List<RequestQueryParamModel>.of(
                        state.request.queryParams,
                      );
                      final old = values[index];
                      values[index] = RequestQueryParamModel(
                        key: old.key,
                        value: old.value,
                        enabled: enabled,
                      );
                      cubit.updateQueryParams(values);
                    },
                  ),
                  _keyValueList(
                    title: 'Headers',
                    items: state.request.headers
                        .map(
                          (item) => (
                            item.key,
                            item.isSecret ? '[SECRET]' : item.value,
                            item.enabled,
                          ),
                        )
                        .toList(),
                    onAdd: () => _addHeader(state, cubit),
                    onRemove: (index) {
                      final values = List<RequestHeaderModel>.of(
                        state.request.headers,
                      )..removeAt(index);
                      cubit.updateHeaders(values);
                    },
                    onToggle: (index, enabled) {
                      final values = List<RequestHeaderModel>.of(
                        state.request.headers,
                      );
                      final old = values[index];
                      values[index] = RequestHeaderModel(
                        key: old.key,
                        value: old.value,
                        enabled: enabled,
                        isSecret: old.isSecret,
                        secretRef: old.secretRef,
                      );
                      cubit.updateHeaders(values);
                    },
                  ),
                  _authEditor(state.request, cubit),
                  _bodyEditor(state.request, cubit),
                  _requestSettingsEditor(state.request, cubit),
                  _resolvedPreview(state.request, workspace),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _keyValueList({
    required String title,
    required List<(String, String, bool)> items,
    required VoidCallback onAdd,
    required void Function(int) onRemove,
    required void Function(int, bool) onToggle,
  }) => ListView(
    children: [
      ListTile(
        title: Text(title),
        trailing: TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: const Text('Add'),
        ),
      ),
      for (var i = 0; i < items.length; i++)
        ListTile(
          dense: true,
          leading: Checkbox(
            value: items[i].$3,
            onChanged: (value) => onToggle(i, value ?? true),
          ),
          title: Text(items[i].$1),
          subtitle: SelectableText(items[i].$2),
          trailing: IconButton(
            onPressed: () => onRemove(i),
            icon: const Icon(Icons.delete_outline),
          ),
        ),
    ],
  );

  Widget _authEditor(
    ApiRequestModel request,
    RequestWorkflowCubit cubit,
  ) => ListView(
    padding: const EdgeInsets.all(12),
    children: [
      DropdownButtonFormField<AuthType>(
        initialValue: request.auth.type,
        decoration: const InputDecoration(
          labelText: 'Authentication type',
          border: OutlineInputBorder(),
        ),
        items: AuthType.values
            .map(
              (item) => DropdownMenuItem(value: item, child: Text(item.name)),
            )
            .toList(),
        onChanged: (type) => _configureAuth(type!, request, cubit),
      ),
      const SizedBox(height: 12),
      Text(
        request.auth.type == AuthType.none
            ? 'No authentication is configured.'
            : 'Secret value is stored only in secure storage. Reference: ${request.auth.tokenSecretRef ?? request.auth.passwordSecretRef ?? request.auth.apiKeySecretRef ?? 'not configured'}',
      ),
    ],
  );

  Widget _bodyEditor(
    ApiRequestModel request,
    RequestWorkflowCubit cubit,
  ) => ListView(
    padding: const EdgeInsets.all(12),
    children: [
      DropdownButtonFormField<RequestBodyType>(
        initialValue: request.body?.type ?? RequestBodyType.none,
        decoration: const InputDecoration(
          labelText: 'Body type',
          border: OutlineInputBorder(),
        ),
        items: RequestBodyType.values
            .map(
              (item) => DropdownMenuItem(value: item, child: Text(item.name)),
            )
            .toList(),
        onChanged: (type) => cubit.updateBody(
          RequestBodyModel(
            type: type!,
            content: type == RequestBodyType.none
                ? ''
                : request.body?.content ?? '',
            filePath: request.body?.filePath,
          ),
        ),
      ),
      if (request.body != null &&
          request.body!.type != RequestBodyType.none) ...[
        const SizedBox(height: 10),
        TextFormField(
          key: ValueKey('${request.id}-${request.body!.type.name}'),
          initialValue: request.body!.content,
          minLines: 3,
          maxLines: 6,
          onChanged: (value) => cubit.updateBody(
            RequestBodyModel(
              type: request.body!.type,
              content: value,
              contentType: request.body!.contentType,
              filePath: request.body!.filePath,
            ),
          ),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText:
                request.body!.type == RequestBodyType.multipart ||
                    request.body!.type == RequestBodyType.formData
                ? 'Enter field metadata as JSON or key=value lines; file paths remain local metadata.'
                : request.body!.type == RequestBodyType.binary
                ? 'Local binary file path metadata'
                : 'Request body',
          ),
        ),
      ],
    ],
  );

  Widget _requestSettingsEditor(
    ApiRequestModel request,
    RequestWorkflowCubit cubit,
  ) => ListView(
    padding: const EdgeInsets.all(12),
    children: [
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SizedBox(
            width: 190,
            child: _numberField(
              'Connect timeout ms',
              request.settings.connectTimeoutMs,
              (value) => cubit.updateSettings(
                _settingsCopy(request.settings, connect: value),
              ),
            ),
          ),
          SizedBox(
            width: 190,
            child: _numberField(
              'Send timeout ms',
              request.settings.sendTimeoutMs,
              (value) => cubit.updateSettings(
                _settingsCopy(request.settings, send: value),
              ),
            ),
          ),
          SizedBox(
            width: 190,
            child: _numberField(
              'Receive timeout ms',
              request.settings.receiveTimeoutMs,
              (value) => cubit.updateSettings(
                _settingsCopy(request.settings, receive: value),
              ),
            ),
          ),
        ],
      ),
      SwitchListTile(
        title: const Text('Follow redirects'),
        value: request.settings.followRedirects,
        onChanged: (value) => cubit.updateSettings(
          _settingsCopy(request.settings, redirects: value),
        ),
      ),
      SwitchListTile(
        title: const Text('Verify TLS certificates'),
        subtitle: const Text(
          'Disabling verification is rejected by validation for HTTPS requests.',
        ),
        value: request.settings.verifyCertificates,
        onChanged: (value) => cubit.updateSettings(
          _settingsCopy(request.settings, verify: value),
        ),
      ),
    ],
  );

  RequestSettingsModel _settingsCopy(
    RequestSettingsModel old, {
    int? connect,
    int? send,
    int? receive,
    bool? redirects,
    bool? verify,
  }) => RequestSettingsModel(
    connectTimeoutMs: connect ?? old.connectTimeoutMs,
    sendTimeoutMs: send ?? old.sendTimeoutMs,
    receiveTimeoutMs: receive ?? old.receiveTimeoutMs,
    followRedirects: redirects ?? old.followRedirects,
    maxRedirects: old.maxRedirects,
    verifyCertificates: verify ?? old.verifyCertificates,
  );

  Widget _resolvedPreview(ApiRequestModel request, WorkspaceState workspace) {
    final environment = <String, String>{
      for (final item in workspace.environmentVariables.where(
        (item) => item.enabled,
      ))
        item.key: item.isSecret ? '[SECRET]' : item.value,
    };
    final result = VariableResolutionService().resolve(
      request.url,
      environment: environment,
      secretKeys: workspace.environmentVariables
          .where((item) => item.isSecret)
          .map((item) => item.key)
          .toSet(),
    );
    final uri = Uri.tryParse(result.value);
    final query = <String, String>{
      if (uri != null) ...uri.queryParameters,
      for (final item in request.queryParams.where((item) => item.enabled))
        item.key: VariableResolutionService()
            .resolve(item.value, environment: environment)
            .value,
    };
    final previewUrl =
        uri?.replace(queryParameters: query).toString() ?? result.value;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        SelectableText('${request.method.name.toUpperCase()} $previewUrl'),
        const SizedBox(height: 8),
        for (final header in request.headers.where((item) => item.enabled))
          SelectableText(
            '${header.key}: ${header.isSecret ? '[REDACTED]' : VariableResolutionService().resolve(header.value, environment: environment).value}',
          ),
        if (result.unresolved.isNotEmpty)
          Text(
            'Unresolved: ${result.unresolved.join(', ')}',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        if (result.cycles.isNotEmpty)
          Text(
            'Cycles: ${result.cycles.join(', ')}',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    );
  }

  Widget _response(
    ApiRequestModel request,
    ApiResponseModel response,
    Set<String> sensitiveValues,
  ) {
    final candidates = TokenCandidateService().find(response.body);
    final diagnostics = DeveloperDiagnostics.forRequest(request, response);
    final shownBody = _formattedBody(response.body, raw: _rawResponse);
    final filteredBody = _responseSearch.isEmpty
        ? shownBody
        : shownBody
              .split('\n')
              .where(
                (line) =>
                    line.toLowerCase().contains(_responseSearch.toLowerCase()),
              )
              .join('\n');
    return DefaultTabController(
      length: 5,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    response.error ??
                        '${response.statusCode ?? '—'} ${response.statusMessage ?? ''}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${response.durationMs} ms • ${response.sizeBytes} bytes${response.isTruncated ? ' • preview truncated' : ''}',
                  ),
                  IconButton(
                    tooltip: 'Safe copy',
                    onPressed: () => _copySafe(response.body, sensitiveValues),
                    icon: const Icon(Icons.copy_outlined),
                  ),
                  IconButton(
                    tooltip: 'Export sanitized response',
                    onPressed: () => _exportResponse(response, sensitiveValues),
                    icon: const Icon(Icons.download_outlined),
                  ),
                  if (candidates.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => _saveToken(response.body),
                      icon: const Icon(Icons.key_outlined),
                      label: const Text('Save token…'),
                    ),
                ],
              ),
            ),
            const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Body'),
                Tab(text: 'Headers'),
                Tab(text: 'Cookies'),
                Tab(text: 'Timeline'),
                Tab(text: 'Diagnostics'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                onChanged: (value) =>
                                    setState(() => _responseSearch = value),
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.search),
                                  hintText: 'Search response',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SegmentedButton<bool>(
                              segments: const [
                                ButtonSegment(
                                  value: false,
                                  label: Text('Pretty'),
                                ),
                                ButtonSegment(value: true, label: Text('Raw')),
                              ],
                              selected: <bool>{_rawResponse},
                              onSelectionChanged: (value) =>
                                  setState(() => _rawResponse = value.first),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(12),
                          child: SelectableText(response.error ?? filteredBody),
                        ),
                      ),
                    ],
                  ),
                  ListView(
                    children: response.headers.entries
                        .map(
                          (item) => ListTile(
                            title: Text(item.key),
                            subtitle: SelectableText(item.value),
                          ),
                        )
                        .toList(),
                  ),
                  ListView(
                    children: response.cookies.isEmpty
                        ? const [ListTile(title: Text('No response cookies.'))]
                        : response.cookies
                              .map(
                                (_) => const ListTile(
                                  title: Text('[REDACTED COOKIE]'),
                                ),
                              )
                              .toList(),
                  ),
                  ListView(
                    children: [
                      ListTile(
                        title: const Text('Started'),
                        subtitle: Text(response.timestamp.toLocal().toString()),
                      ),
                      ListTile(
                        title: const Text('Completed'),
                        subtitle: Text('${response.durationMs} ms'),
                      ),
                      ListTile(
                        title: const Text('Payload size'),
                        subtitle: Text('${response.sizeBytes} bytes'),
                      ),
                      if (response.isTruncated)
                        const ListTile(
                          title: Text('Preview bounded'),
                          subtitle: Text(
                            'The displayed body was truncated to protect memory.',
                          ),
                        ),
                    ],
                  ),
                  ListView(
                    children: diagnostics.isEmpty
                        ? const [ListTile(title: Text('No diagnostics.'))]
                        : diagnostics
                              .map(
                                (item) => ListTile(
                                  leading: Icon(
                                    item.kind == DiagnosticKind.observed
                                        ? Icons.fact_check_outlined
                                        : Icons.lightbulb_outline,
                                  ),
                                  title: Text(
                                    '${item.kind.name}: ${item.title}',
                                  ),
                                  subtitle: Text(item.detail),
                                ),
                              )
                              .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _history() => BlocBuilder<WorkspaceCubit, WorkspaceState>(
    builder: (context, state) {
      final cubit = context.read<WorkspaceCubit>();
      final filtered = state.history
          .where(
            (item) =>
                (_historyMethod == null || item.method == _historyMethod) &&
                (_historyMinimumStatus == null ||
                    (item.status ?? 0) >= _historyMinimumStatus!),
          )
          .toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'History',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(
                width: 280,
                child: TextField(
                  onChanged: cubit.search,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search history',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              DropdownButton<String?>(
                value: _historyMethod,
                hint: const Text('Any method'),
                items: <DropdownMenuItem<String?>>[
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Any method'),
                  ),
                  ...HttpMethod.values.map(
                    (item) => DropdownMenuItem(
                      value: item.name,
                      child: Text(item.name.toUpperCase()),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _historyMethod = value),
              ),
              DropdownButton<int?>(
                value: _historyMinimumStatus,
                hint: const Text('Any status'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Any status')),
                  DropdownMenuItem(value: 400, child: Text('Errors ≥400')),
                  DropdownMenuItem(value: 500, child: Text('Server ≥500')),
                ],
                onChanged: (value) =>
                    setState(() => _historyMinimumStatus = value),
              ),
              TextButton.icon(
                onPressed: state.history.isEmpty
                    ? null
                    : () async {
                        if (await _confirm(
                          'Clear all history?',
                          'This cannot be undone.',
                        )) {
                          cubit.clearAllHistory();
                        }
                      },
                icon: const Icon(Icons.delete_sweep_outlined),
                label: const Text('Clear all'),
              ),
              FilledButton.tonalIcon(
                onPressed: _restComparison.length == 2
                    ? () => _compareRestHistory(
                        filtered
                            .where((item) => _restComparison.contains(item.id))
                            .toList(),
                      )
                    : null,
                icon: const Icon(Icons.compare_arrows),
                label: const Text('Compare selected'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No matching history records.'))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return Card(
                        child: ListTile(
                          leading: Checkbox(
                            value: _restComparison.contains(item.id),
                            onChanged: (selected) => setState(() {
                              if (selected == true &&
                                  _restComparison.length < 2) {
                                _restComparison.add(item.id);
                              } else {
                                _restComparison.remove(item.id);
                              }
                            }),
                          ),
                          title: Text(
                            '${item.method.toUpperCase()} ${item.url}',
                          ),
                          subtitle: Text(
                            '${item.status ?? 'Error'} • ${item.durationMs} ms • ${item.createdAt.toLocal()}',
                          ),
                          onTap: () => _showHistory(item),
                          trailing: Wrap(
                            children: [
                              IconButton(
                                tooltip: 'Replay as new draft',
                                onPressed: () => _replayHistory(item.id),
                                icon: const Icon(Icons.replay_outlined),
                              ),
                              IconButton(
                                tooltip: 'Delete',
                                onPressed: () => cubit.removeHistory(item.id),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    },
  );

  Widget _environments() => BlocBuilder<WorkspaceCubit, WorkspaceState>(
    builder: (context, state) {
      final cubit = context.read<WorkspaceCubit>();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Environments',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              FilledButton.icon(
                onPressed: () async {
                  final name = await _askName('New environment');
                  if (name != null) {
                    cubit.addEnvironment(name, EnvironmentKind.custom);
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('New'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width < 700 ? 180 : 300,
                  child: ListView(
                    children: [
                      for (final item in state.environments)
                        Card(
                          child: ListTile(
                            selected: item.id == state.selectedEnvironmentId,
                            leading: Icon(
                              item.isActive
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                            ),
                            title: Text(item.name),
                            subtitle: Text(item.kind.name),
                            onTap: () => cubit.selectEnvironment(item.id),
                            trailing: PopupMenuButton<String>(
                              onSelected: (action) =>
                                  _environmentAction(action, item),
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'activate',
                                  child: Text('Activate'),
                                ),
                                PopupMenuItem(
                                  value: 'rename',
                                  child: Text('Rename'),
                                ),
                                PopupMenuItem(
                                  value: 'duplicate',
                                  child: Text('Duplicate'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const VerticalDivider(),
                Expanded(
                  child: state.selectedEnvironmentId == null
                      ? const Center(child: Text('Select an environment.'))
                      : Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Variables',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const Spacer(),
                                FilledButton.icon(
                                  onPressed: () => _editVariable(),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView(
                                children: [
                                  for (final variable
                                      in state.environmentVariables)
                                    Card(
                                      child: ListTile(
                                        leading: Checkbox(
                                          value: variable.enabled,
                                          onChanged: (value) =>
                                              cubit.saveVariable(
                                                id: variable.id,
                                                key: variable.key,
                                                value: variable.value,
                                                secret: variable.isSecret,
                                                enabled: value ?? true,
                                              ),
                                        ),
                                        title: Text(variable.key),
                                        subtitle: Text(
                                          variable.isSecret
                                              ? '[SECURE STORAGE REFERENCE]'
                                              : variable.value,
                                        ),
                                        onTap: () => _editVariable(variable),
                                        trailing: Wrap(
                                          children: [
                                            IconButton(
                                              tooltip: 'Move up',
                                              onPressed:
                                                  state.environmentVariables
                                                          .indexOf(variable) ==
                                                      0
                                                  ? null
                                                  : () => cubit.reorderVariable(
                                                      variable.id,
                                                      state.environmentVariables
                                                              .indexOf(
                                                                variable,
                                                              ) -
                                                          1,
                                                    ),
                                              icon: const Icon(
                                                Icons.arrow_upward,
                                              ),
                                            ),
                                            IconButton(
                                              tooltip: 'Move down',
                                              onPressed:
                                                  state.environmentVariables
                                                          .indexOf(variable) ==
                                                      state
                                                              .environmentVariables
                                                              .length -
                                                          1
                                                  ? null
                                                  : () => cubit.reorderVariable(
                                                      variable.id,
                                                      state.environmentVariables
                                                              .indexOf(
                                                                variable,
                                                              ) +
                                                          1,
                                                    ),
                                              icon: const Icon(
                                                Icons.arrow_downward,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () => cubit
                                                  .removeVariable(variable.id),
                                              icon: const Icon(
                                                Icons.delete_outline,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
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
    },
  );

  Widget _settings() => BlocBuilder<WorkspaceCubit, WorkspaceState>(
    builder: (context, state) {
      final cubit = context.read<WorkspaceCubit>();
      final settings = state.settings;
      return ListView(
        children: [
          Text(
            'Workspace settings',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _numberField(
                    'History retention days',
                    settings.historyRetentionDays,
                    (value) => cubit.updateSettings(
                      WorkspaceSettingsModel(
                        historyRetentionDays: value,
                        historyMaximumCount: settings.historyMaximumCount,
                        responsePreviewBytes: settings.responsePreviewBytes,
                        productionStrictMode: settings.productionStrictMode,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _numberField(
                    'Maximum history records',
                    settings.historyMaximumCount,
                    (value) => cubit.updateSettings(
                      WorkspaceSettingsModel(
                        historyRetentionDays: settings.historyRetentionDays,
                        historyMaximumCount: value,
                        responsePreviewBytes: settings.responsePreviewBytes,
                        productionStrictMode: settings.productionStrictMode,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _numberField(
                    'Response preview byte limit',
                    settings.responsePreviewBytes,
                    (value) => cubit.updateSettings(
                      WorkspaceSettingsModel(
                        historyRetentionDays: settings.historyRetentionDays,
                        historyMaximumCount: settings.historyMaximumCount,
                        responsePreviewBytes: value,
                        productionStrictMode: settings.productionStrictMode,
                      ),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Strict production confirmation'),
                    subtitle: const Text(
                      'Require confirmation for POST, PUT, PATCH, and DELETE in production environments.',
                    ),
                    value: settings.productionStrictMode,
                    onChanged: (value) => cubit.updateSettings(
                      WorkspaceSettingsModel(
                        historyRetentionDays: settings.historyRetentionDays,
                        historyMaximumCount: settings.historyMaximumCount,
                        responsePreviewBytes: settings.responsePreviewBytes,
                        productionStrictMode: value,
                      ),
                    ),
                  ),
                  const ListTile(
                    leading: Icon(Icons.lock_outline),
                    title: Text('TLS verification is on by default'),
                    subtitle: Text(
                      'HTTPS requests cannot silently disable certificate verification.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );

  Widget _numberField(String label, int value, ValueChanged<int> onSubmitted) =>
      TextFormField(
        key: ValueKey('$label-$value'),
        initialValue: value.toString(),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onFieldSubmitted: (text) {
          final parsed = int.tryParse(text);
          if (parsed != null && parsed > 0) onSubmitted(parsed);
        },
      );

  Future<void> _discardAndPop() async {
    final requestCubit = context.read<RequestWorkflowCubit>();
    if (await _confirm(
      'Discard unsaved changes?',
      'Drafts are stored locally, but this tab will close.',
    )) {
      await requestCubit.closeActive(discardChanges: true);
      if (mounted) {
        Navigator.of(context).maybePop();
      }
    }
  }

  Future<void> _closeRequestTab() async {
    final cubit = context.read<RequestWorkflowCubit>();
    if (!cubit.state.isDirty ||
        await _confirm(
          'Close request tab?',
          'Discard unsaved changes in this tab?',
        )) {
      await cubit.closeActive(discardChanges: true);
    }
  }

  Future<void> _moveCollection(CollectionModel collection) async {
    final state = context.read<WorkspaceCubit>().state;
    final targets = state.workspaces
        .where((item) => item.id != collection.workspaceId)
        .toList();
    if (targets.isEmpty) return;
    final target = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Move collection to workspace'),
        children: [
          for (final item in targets)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, item.id),
              child: Text(item.name),
            ),
        ],
      ),
    );
    if (target != null && mounted) {
      await context.read<WorkspaceCubit>().moveCollection(
        collection.id,
        target,
      );
    }
  }

  Future<void> _folderActions(FolderModel folder) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename'),
              onTap: () => Navigator.pop(context, 'rename'),
            ),
            ListTile(
              leading: const Icon(Icons.create_new_folder_outlined),
              title: const Text('Add child folder'),
              onTap: () => Navigator.pop(context, 'child'),
            ),
            ListTile(
              leading: const Icon(Icons.arrow_upward),
              title: const Text('Move up'),
              onTap: () => Navigator.pop(context, 'up'),
            ),
            ListTile(
              leading: const Icon(Icons.arrow_downward),
              title: const Text('Move down'),
              onTap: () => Navigator.pop(context, 'down'),
            ),
            ListTile(
              leading: const Icon(Icons.drive_file_move_outline),
              title: const Text('Move to collection'),
              onTap: () => Navigator.pop(context, 'move'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete'),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    final cubit = context.read<WorkspaceCubit>();
    final state = cubit.state;
    if (action == 'rename') {
      final name = await _askName('Rename folder', initial: folder.name);
      if (name != null) cubit.renameFolder(folder.id, name);
    }
    if (action == 'child') {
      final name = await _askName('New child folder');
      if (name != null) cubit.addFolder(name, parentId: folder.id);
    }
    if (action == 'up') {
      await cubit.reorderFolder(folder.id, state.folders.indexOf(folder) - 1);
    }
    if (action == 'down') {
      await cubit.reorderFolder(folder.id, state.folders.indexOf(folder) + 1);
    }
    if (action == 'move') {
      final targets = state.collections
          .where((item) => item.id != folder.collectionId)
          .toList();
      if (targets.isNotEmpty && mounted) {
        final target = await showDialog<String>(
          context: context,
          builder: (context) => SimpleDialog(
            title: const Text('Move folder to collection'),
            children: [
              for (final item in targets)
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, item.id),
                  child: Text(item.name),
                ),
            ],
          ),
        );
        if (target != null) await cubit.moveFolder(folder.id, target);
      }
    }
    if (action == 'delete' &&
        await _confirm(
          'Delete folder?',
          'Requests move to the collection root and child folders move up.',
        )) {
      cubit.removeFolder(folder.id);
    }
  }

  Future<void> _addHeader(
    RequestWorkflowState state,
    RequestWorkflowCubit cubit,
  ) async {
    final pair = await _askPair('Add header', allowSecret: true);
    if (pair == null) return;
    final secret = _isSensitive(pair.$1);
    cubit.updateHeaders(<RequestHeaderModel>[
      ...state.request.headers,
      RequestHeaderModel(key: pair.$1, value: pair.$2, isSecret: secret),
    ]);
  }

  Future<void> _configureAuth(
    AuthType type,
    ApiRequestModel request,
    RequestWorkflowCubit cubit,
  ) async {
    if (type == AuthType.none) {
      cubit.updateAuth(const RequestAuthModel());
      return;
    }
    final username = TextEditingController(text: request.auth.username);
    final keyName = TextEditingController(text: request.auth.apiKeyName);
    final secret = TextEditingController();
    final defaultRef = 'request.${request.id}.auth.${type.name}';
    final result = await showDialog<bool>(
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
              controller: secret,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Secret value',
                helperText: 'Saved to secure storage only after confirmation.',
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
            child: const Text('Save securely'),
          ),
        ],
      ),
    );
    if (result == true) {
      await cubit.configureAuth(
        RequestAuthModel(
          type: type,
          username: username.text,
          passwordSecretRef: type == AuthType.basic ? defaultRef : null,
          tokenSecretRef: type == AuthType.bearer ? defaultRef : null,
          apiKeyName: keyName.text,
          apiKeySecretRef:
              type == AuthType.apiKeyHeader || type == AuthType.apiKeyQuery
              ? defaultRef
              : null,
        ),
        secretValue: secret.text,
      );
    }
    _disposeAfterDialog(<TextEditingController>[username, keyName, secret]);
  }

  Future<void> _sendWithSafety(
    RequestWorkflowCubit cubit,
    RequestWorkflowState requestState,
    WorkspaceState workspace,
  ) async {
    final active = workspace.environments
        .where((item) => item.isActive)
        .firstOrNull;
    if (active != null &&
        RequestSafetyService().needsProductionConfirmation(
          environment: active.kind,
          method: requestState.request.method,
          strictMode: workspace.settings.productionStrictMode,
        )) {
      final host = Uri.tryParse(requestState.request.url)?.host ?? 'this host';
      if (!await _confirm(
        'Production request',
        'Confirm ${requestState.request.method.name.toUpperCase()} to $host.',
      )) {
        return;
      }
    }
    await cubit.send(
      environmentId: active?.id,
      previewLimitBytes: workspace.settings.responsePreviewBytes,
    );
    if (mounted) context.read<WorkspaceCubit>().load();
  }

  Future<void> _saveToken(String body) async {
    final requestCubit = context.read<RequestWorkflowCubit>();
    final values = TokenCandidateService().extract(body);
    if (values.isEmpty) return;
    var path = values.keys.first;
    final destination = TextEditingController(
      text: 'response.token.${DateTime.now().millisecondsSinceEpoch}',
    );
    var consent = false;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Save response token'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: path,
                items: values.keys
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(
                          '$item • ${SecretMasker.mask(values[item]!)}',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => path = value!,
              ),
              TextField(
                controller: destination,
                decoration: const InputDecoration(
                  labelText: 'Secure-storage destination',
                ),
              ),
              CheckboxListTile(
                value: consent,
                onChanged: (value) =>
                    setDialogState(() => consent = value ?? false),
                title: const Text(
                  'I explicitly approve saving this token to secure storage.',
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
              onPressed: consent ? () => Navigator.pop(context, true) : null,
              child: const Text('Save token'),
            ),
          ],
        ),
      ),
    );
    if (saved == true && destination.text.trim().isNotEmpty) {
      await requestCubit.saveResponseToken(
        destination.text.trim(),
        values[path]!,
      );
    }
    _disposeAfterDialog(<TextEditingController>[destination]);
  }

  Future<void> _replayHistory(String id) async {
    final request = await context.read<WorkspaceCubit>().replayHistory(id);
    if (request != null && mounted) {
      context.read<RequestWorkflowCubit>().openRequest(request);
      _select(1);
    }
  }

  Future<void> _showHistory(HistoryEntry item) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${item.method.toUpperCase()} ${item.status ?? 'Error'}'),
        content: SizedBox(
          width: 720,
          height: 520,
          child: DefaultTabController(
            length: 4,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Body'),
                    Tab(text: 'Headers'),
                    Tab(text: 'Timeline'),
                    Tab(text: 'Diagnostics'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      SingleChildScrollView(
                        child: SelectableText(
                          item.snapshot['body']?.toString() ?? '',
                        ),
                      ),
                      SingleChildScrollView(
                        child: SelectableText(
                          const JsonEncoder.withIndent(
                            '  ',
                          ).convert(<String, Object?>{
                            'request': item.snapshot['requestHeaders'],
                            'response': item.snapshot['responseHeaders'],
                            'cookies': item.snapshot['cookies'],
                          }),
                        ),
                      ),
                      ListView(
                        children: [
                          ListTile(
                            title: const Text('Recorded'),
                            subtitle: Text(item.createdAt.toLocal().toString()),
                          ),
                          ListTile(
                            title: const Text('Duration'),
                            subtitle: Text('${item.durationMs} ms'),
                          ),
                          ListTile(
                            title: const Text('Size'),
                            subtitle: Text(
                              '${item.snapshot['sizeBytes'] ?? 0} bytes',
                            ),
                          ),
                        ],
                      ),
                      ListView(
                        children: [
                          ListTile(
                            title: Text(
                              item.snapshot['category']?.toString() ??
                                  'No failure category',
                            ),
                            subtitle: Text(
                              item.snapshot['error']?.toString() ??
                                  'No recorded error.',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _copySafe(jsonEncode(item.snapshot)),
            icon: const Icon(Icons.copy_outlined),
            label: const Text('Copy sanitized JSON'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _replayHistory(item.id);
            },
            icon: const Icon(Icons.replay_outlined),
            label: const Text('Replay'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _compareRestHistory(List<HistoryEntry> entries) async {
    if (entries.length != 2) return;
    final before = entries[0];
    final after = entries[1];
    final changes = <ComparisonChange>[
      ...HistoryComparisonService.compareValues(
        <String, Object?>{
          'status': before.status,
          'timingMs': before.durationMs,
          'sizeBytes': before.snapshot['sizeBytes'],
          'headers': before.snapshot['responseHeaders'],
        },
        <String, Object?>{
          'status': after.status,
          'timingMs': after.durationMs,
          'sizeBytes': after.snapshot['sizeBytes'],
          'headers': after.snapshot['responseHeaders'],
        },
      ),
      ...HistoryComparisonService.compareJsonText(
        before.snapshot['body']?.toString() ?? '',
        after.snapshot['body']?.toString() ?? '',
      ).map(
        (item) => ComparisonChange(
          'body${item.path.substring(1)}',
          item.before,
          item.after,
        ),
      ),
    ];
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('REST history comparison'),
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

  Future<void> _environmentAction(String action, EnvironmentModel item) async {
    final cubit = context.read<WorkspaceCubit>();
    if (action == 'activate') await cubit.setEnvironment(item.id);
    if (action == 'duplicate') await cubit.duplicateEnvironment(item.id);
    if (action == 'rename') {
      final name = await _askName('Rename environment', initial: item.name);
      if (name != null) cubit.renameEnvironment(item.id, name);
    }
    if (action == 'delete' &&
        await _confirm(
          'Delete environment?',
          'Variables and owned secure-storage references will be removed.',
        )) {
      cubit.removeEnvironment(item.id);
    }
  }

  Future<void> _editVariable([EnvironmentVariableModel? variable]) async {
    final key = TextEditingController(text: variable?.key ?? '');
    final value = TextEditingController(text: variable?.value ?? '');
    var secret = variable?.isSecret ?? false;
    var enabled = variable?.enabled ?? true;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(variable == null ? 'Add variable' : 'Edit variable'),
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
                  labelText: secret && variable != null
                      ? 'New secret value (leave blank to keep current)'
                      : 'Value',
                ),
              ),
              SwitchListTile(
                value: secret,
                onChanged: (value) => setDialogState(() => secret = value),
                title: const Text('Secret'),
              ),
              SwitchListTile(
                value: enabled,
                onChanged: (value) => setDialogState(() => enabled = value),
                title: const Text('Enabled'),
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
    if (saved == true && key.text.trim().isNotEmpty && mounted) {
      await context.read<WorkspaceCubit>().saveVariable(
        id: variable?.id,
        key: key.text.trim(),
        value: value.text,
        secret: secret,
        enabled: enabled,
      );
    }
    _disposeAfterDialog(<TextEditingController>[key, value]);
  }

  Future<String?> _askName(String title, {String initial = ''}) async {
    final controller = TextEditingController(text: initial);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    _disposeAfterDialog(<TextEditingController>[controller]);
    return value == null || value.isEmpty ? null : value;
  }

  Future<(String, String)?> _askPair(
    String title, {
    bool allowSecret = false,
  }) async {
    final key = TextEditingController();
    final value = TextEditingController();
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: key,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: value,
              decoration: const InputDecoration(
                labelText: 'Value',
                border: OutlineInputBorder(),
              ),
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
    _disposeAfterDialog(<TextEditingController>[key, value]);
    return result == null || result.$1.isEmpty ? null : result;
  }

  bool _isSensitive(String value) => RegExp(
    r'authorization|api[-_ ]?key|token|cookie|password',
    caseSensitive: false,
  ).hasMatch(value);
  String _formattedBody(String body, {required bool raw}) {
    if (raw) return body;
    try {
      return const JsonEncoder.withIndent('  ').convert(jsonDecode(body));
    } catch (_) {
      return body;
    }
  }

  Future<void> _copySafe(
    String value, [
    Set<String> sensitiveValues = const <String>{},
  ]) async {
    await Clipboard.setData(
      ClipboardData(
        text: SafeExportService().sanitizedText(value, sensitiveValues),
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sanitized content copied.')),
      );
    }
  }

  Future<void> _exportResponse(
    ApiResponseModel response,
    Set<String> sensitiveValues,
  ) async {
    final file = await SafeExportService().exportResponse(
      response,
      sensitiveValues: sensitiveValues,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sanitized response exported to ${file.path}')),
      );
    }
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

  void _disposeAfterDialog(List<TextEditingController> controllers) {
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 400), () {
        for (final controller in controllers) {
          controller.dispose();
        }
      }),
    );
  }
}
