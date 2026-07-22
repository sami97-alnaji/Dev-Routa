import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/models/api_models.dart';
import '../application/graphql_execution_service.dart';
import '../data/graphql_repository.dart';
import '../domain/graphql_models.dart';

class GraphqlWorkflowState {
  const GraphqlWorkflowState({
    required this.tabs,
    this.savedRequests = const <GraphqlSavedRequest>[],
    this.history = const <GraphqlHistoryEntry>[],
    this.activeIndex = 0,
    this.activeOperationIds = const <String>{},
    this.activeSubscriptionIds = const <String>{},
    this.executions = const <String, GraphqlTabExecution>{},
    this.busySavedRequestIds = const <String>{},
    this.savedRequestError,
  });

  final List<GraphqlDraft> tabs;
  final List<GraphqlSavedRequest> savedRequests;
  final List<GraphqlHistoryEntry> history;
  final int activeIndex;
  final Set<String> activeOperationIds;
  final Set<String> activeSubscriptionIds;
  final Map<String, GraphqlTabExecution> executions;
  final Set<String> busySavedRequestIds;
  final String? savedRequestError;
  GraphqlDraft get active => tabs[activeIndex];
  bool get isDirty => active.isDirty;
  bool get hasAnyDirty => tabs.any((tab) => tab.isDirty);
  bool get hasActiveWork =>
      activeOperationIds.contains(active.id) ||
      activeSubscriptionIds.contains(active.id);
  GraphqlTabExecution executionFor(String tabId) =>
      executions[tabId] ?? const GraphqlTabExecution();

  GraphqlWorkflowState copyWith({
    List<GraphqlDraft>? tabs,
    List<GraphqlSavedRequest>? savedRequests,
    List<GraphqlHistoryEntry>? history,
    int? activeIndex,
    Set<String>? activeOperationIds,
    Set<String>? activeSubscriptionIds,
    Map<String, GraphqlTabExecution>? executions,
    Set<String>? busySavedRequestIds,
    String? savedRequestError,
  }) => GraphqlWorkflowState(
    tabs: tabs ?? this.tabs,
    savedRequests: savedRequests ?? this.savedRequests,
    history: history ?? this.history,
    activeIndex: activeIndex ?? this.activeIndex,
    activeOperationIds: activeOperationIds ?? this.activeOperationIds,
    activeSubscriptionIds: activeSubscriptionIds ?? this.activeSubscriptionIds,
    executions: executions ?? this.executions,
    busySavedRequestIds: busySavedRequestIds ?? this.busySavedRequestIds,
    savedRequestError: savedRequestError,
  );
}

enum GraphqlExecutionPhase {
  idle,
  validating,
  resolving,
  sending,
  success,
  partialSuccess,
  graphqlFailure,
  transportFailure,
  cancelled,
}

class GraphqlTabExecution {
  const GraphqlTabExecution({
    this.phase = GraphqlExecutionPhase.idle,
    this.id,
    this.response,
    this.failure,
    this.duration,
  });
  final GraphqlExecutionPhase phase;
  final String? id;
  final GraphqlResponse? response;
  final GraphqlFailure? failure;
  final Duration? duration;
  bool get isActive => switch (phase) {
    GraphqlExecutionPhase.validating ||
    GraphqlExecutionPhase.resolving ||
    GraphqlExecutionPhase.sending => true,
    _ => false,
  };
}

class GraphqlWorkflowCubit extends Cubit<GraphqlWorkflowState> {
  GraphqlWorkflowCubit(
    this._repository,
    this._execution, {
    required this.workspaceId,
  }) : super(
         GraphqlWorkflowState(tabs: <GraphqlDraft>[_newDraft(workspaceId)]),
       );

  final GraphqlRepository _repository;
  final GraphqlExecutionService _execution;
  final String workspaceId;
  static const _ids = Uuid();

  static GraphqlDraft _newDraft(String workspaceId, {GraphqlRequest? request}) {
    final now = DateTime.now();
    final value = request ?? const GraphqlRequest(endpoint: '', document: '');
    return GraphqlDraft(
      id: _ids.v4(),
      workspaceId: workspaceId,
      title: 'Untitled GraphQL request',
      request: value,
      updatedAt: now,
      isDirty: false,
      baselineFingerprint: GraphqlDraft.fingerprint(value, null),
    );
  }

  Future<void> restoreDrafts() async {
    final tabsAtStart = state.tabs;
    final drafts = await _repository.drafts(workspaceId);
    final saved = await _repository.requests(workspaceId);
    final history = await _repository.history(workspaceId);
    if (isClosed) return;
    // AppShell starts restoration asynchronously. Do not let its stale result
    // overwrite a tab the user has already edited or saved.
    if (!identical(state.tabs, tabsAtStart)) {
      emit(state.copyWith(savedRequests: saved, history: history));
      return;
    }
    if (drafts.isEmpty) {
      emit(state.copyWith(savedRequests: saved, history: history));
      return;
    }
    final ordered = List<GraphqlDraft>.of(drafts)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final selected = ordered.indexWhere((item) => item.isActive);
    emit(
      state.copyWith(
        tabs: ordered,
        savedRequests: saved,
        history: history,
        activeIndex: selected < 0 ? 0 : selected,
      ),
    );
  }

  void newDraft({
    GraphqlRequest? request,
    String? savedRequestId,
    String? title,
  }) {
    final draft = _newDraft(workspaceId, request: request);
    final tab = GraphqlDraft(
      id: draft.id,
      workspaceId: draft.workspaceId,
      title: title ?? draft.title,
      request: draft.request,
      updatedAt: draft.updatedAt,
      savedRequestId: savedRequestId,
      sortOrder: state.tabs.length,
      isDirty: false,
      baselineFingerprint: GraphqlDraft.fingerprint(draft.request, null),
    );
    _setTabs(<GraphqlDraft>[...state.tabs, tab], state.tabs.length);
  }

  void openSavedRequest(GraphqlSavedRequest saved) {
    final existing = state.tabs.indexWhere(
      (tab) => tab.savedRequestId == saved.id,
    );
    if (existing >= 0) {
      selectTab(existing);
      return;
    }
    newDraft(
      request: saved.request,
      savedRequestId: saved.id,
      title: saved.name,
    );
  }

  /// A saved request is always opened separately; replacing a dirty tab is a
  /// silent data-loss path, so callers use [openSavedRequest] instead.

  void duplicateActive() {
    final source = state.active;
    final copy = GraphqlDraft(
      id: _ids.v4(),
      workspaceId: source.workspaceId,
      title: '${source.title} copy',
      request: source.request,
      updatedAt: DateTime.now(),
      savedRequestId: source.savedRequestId,
      environmentId: source.environmentId,
      sortOrder: state.tabs.length,
    );
    _setTabs(<GraphqlDraft>[...state.tabs, copy], state.tabs.length);
  }

  void selectTab(int index) {
    if (index >= 0 && index < state.tabs.length) {
      _setTabs(state.tabs, index);
    }
  }

  Future<void> closeActive({required bool discardChanges}) async {
    await closeTab(state.active.id, discardChanges: discardChanges);
  }

  Future<void> closeOthers({required bool discardChanges}) async {
    final active = state.active.id;
    if (!discardChanges &&
        state.tabs.any((tab) => tab.id != active && tab.isDirty)) {
      return;
    }
    for (final tab in state.tabs.where((item) => item.id != active)) {
      _execution.cancel(tab.id);
      await _repository.deleteDraft(tab.id);
      _removeTabRuntimeState(tab.id);
    }
    _setTabs(<GraphqlDraft>[state.active], 0);
  }

  Future<void> closeAll({required bool discardChanges}) async {
    if (!discardChanges && state.tabs.any((tab) => tab.isDirty)) {
      return;
    }
    for (final tab in state.tabs) {
      _execution.cancel(tab.id);
      await _repository.deleteDraft(tab.id);
      _removeTabRuntimeState(tab.id);
    }
    _setTabs(<GraphqlDraft>[_newDraft(workspaceId)], 0);
  }

  Future<void> closeTab(String tabId, {required bool discardChanges}) async {
    final index = state.tabs.indexWhere((tab) => tab.id == tabId);
    if (index < 0) return;
    final tab = state.tabs[index];
    if (tab.isDirty && !discardChanges) return;
    _execution.cancel(tab.id);
    await _repository.deleteDraft(tab.id);
    _removeTabRuntimeState(tab.id);
    final tabs = List<GraphqlDraft>.of(state.tabs)..removeAt(index);
    final nextIndex = tabs.isEmpty
        ? 0
        : index < state.activeIndex
        ? state.activeIndex - 1
        : state.activeIndex;
    if (tabs.isEmpty) {
      tabs.add(_newDraft(workspaceId));
    }
    _setTabs(tabs, nextIndex.clamp(0, tabs.length - 1));
  }

  void renameActive(String title) => _replace(title: title.trim());
  void updateEndpoint(String endpoint) => _replace(endpoint: endpoint);
  void updateDocument(String document) => _replace(document: document);
  void selectOperation(String? operationName) =>
      _replace(operationName: operationName);
  void updateVariables(Map<String, Object?> variables) =>
      _replace(variables: variables);
  void updateHeaders(Map<String, String> headers) => _replace(headers: headers);
  void updateExtensions(Map<String, Object?> extensions) =>
      _replace(extensions: extensions);
  void updateUseGet(bool useGet) => _replace(useGet: useGet);
  void updateAuth(RequestAuthModel auth) => _replace(auth: auth);
  void updateSettings(RequestSettingsModel settings) =>
      _replace(settings: settings);
  void selectEnvironment(String? environmentId) =>
      _replace(environmentId: environmentId);

  void setActiveOperation(bool active) => _setActivity(
    state.activeOperationIds,
    state.active.id,
    active,
    subscription: false,
  );
  void setActiveSubscription(bool active) => _setActivity(
    state.activeSubscriptionIds,
    state.active.id,
    active,
    subscription: true,
  );

  Future<void> executeActive() async {
    final tab = state.active;
    final executionId = _ids.v4();
    _setExecution(
      tab.id,
      GraphqlTabExecution(
        phase: GraphqlExecutionPhase.validating,
        id: executionId,
      ),
    );
    await Future<void>.delayed(Duration.zero);
    if (isClosed || state.executionFor(tab.id).id != executionId) return;
    _setExecution(
      tab.id,
      GraphqlTabExecution(
        phase: GraphqlExecutionPhase.sending,
        id: executionId,
      ),
    );
    setActiveOperationFor(tab.id, true);
    try {
      final result = await _execution.execute(
        tabId: tab.id,
        workspaceId: tab.workspaceId,
        request: tab.request,
        environmentId: tab.environmentId,
      );
      await refreshHistory();
      if (isClosed || state.executionFor(tab.id).id != executionId) return;
      _setExecution(
        tab.id,
        GraphqlTabExecution(
          id: executionId,
          phase: result.response.hasPartialData
              ? GraphqlExecutionPhase.partialSuccess
              : result.response.errors.isNotEmpty
              ? GraphqlExecutionPhase.graphqlFailure
              : GraphqlExecutionPhase.success,
          response: result.response,
          duration: result.response.duration,
        ),
      );
    } on GraphqlFailure catch (failure) {
      if (isClosed || state.executionFor(tab.id).id != executionId) return;
      _setExecution(
        tab.id,
        GraphqlTabExecution(
          id: executionId,
          phase: failure.category == GraphqlFailureCategory.cancelled
              ? GraphqlExecutionPhase.cancelled
              : failure.category == GraphqlFailureCategory.graphql
              ? GraphqlExecutionPhase.graphqlFailure
              : GraphqlExecutionPhase.transportFailure,
          failure: failure,
        ),
      );
    } finally {
      if (!isClosed) setActiveOperationFor(tab.id, false);
    }
  }

  void cancelTab(String tabId) => _execution.cancel(tabId);

  void setActiveOperationFor(String tabId, bool active) => _setActivity(
    state.activeOperationIds,
    tabId,
    active,
    subscription: false,
  );

  void _setExecution(String tabId, GraphqlTabExecution execution) {
    final executions = Map<String, GraphqlTabExecution>.of(state.executions)
      ..[tabId] = execution;
    emit(state.copyWith(executions: executions));
  }

  Future<GraphqlSavedRequest> saveActive({bool forceNew = false}) =>
      saveTab(state.active.id, forceNew: forceNew);

  Future<GraphqlSavedRequest> saveTab(
    String tabId, {
    bool forceNew = false,
    String? name,
  }) async {
    final index = state.tabs.indexWhere((tab) => tab.id == tabId);
    if (index < 0) throw StateError('GraphQL tab $tabId was not found.');
    final current = state.tabs[index];
    final saved = await _repository.saveRequest(
      id: forceNew ? null : current.savedRequestId,
      workspaceId: current.workspaceId,
      name: name ?? current.title,
      request: current.request,
    );
    final clean = GraphqlDraft(
      id: current.id,
      workspaceId: current.workspaceId,
      title: saved.name,
      request: current.request,
      updatedAt: DateTime.now(),
      savedRequestId: saved.id,
      environmentId: current.environmentId,
      sortOrder: current.sortOrder,
      isActive: current.isActive,
      isDirty: false,
      baselineFingerprint: GraphqlDraft.fingerprint(
        current.request,
        current.environmentId,
      ),
    );
    final tabs = List<GraphqlDraft>.of(state.tabs)..[index] = clean;
    _setTabs(tabs, state.activeIndex);
    await refreshSavedRequests();
    return saved;
  }

  Future<void> reorderSavedRequest(String id, int order) async {
    await _runSavedRequestOperation(id, () async {
      await _repository.reorderRequest(id, order);
      await refreshSavedRequests();
    });
  }

  Future<void> moveSavedRequest(
    String id, {
    String? collectionId,
    String? folderId,
    bool clearCollection = false,
    bool clearFolder = false,
  }) async {
    await _runSavedRequestOperation(id, () async {
      await _repository.moveRequest(
        id,
        collectionId: collectionId,
        folderId: folderId,
        clearCollection: clearCollection,
        clearFolder: clearFolder,
      );
      await refreshSavedRequests();
    });
  }

  Future<void> refreshSavedRequests([String query = '']) async {
    final saved = query.trim().isEmpty
        ? await _repository.requests(workspaceId)
        : await _repository.searchRequests(workspaceId, query);
    if (!isClosed) emit(state.copyWith(savedRequests: saved));
  }

  Future<void> refreshHistory([String query = '']) async {
    final entries = await _repository.history(workspaceId, query: query);
    if (!isClosed) emit(state.copyWith(history: entries));
  }

  Future<void> deleteHistory(String id) async {
    await _repository.deleteHistory(id);
    await refreshHistory();
  }

  void replayHistory(GraphqlHistoryEntry entry) {
    final request = entry.summary['request'];
    if (request is! Map) return;
    final variables =
        (request['variables'] as Map? ?? const <Object?, Object?>{}).map(
          (key, value) => MapEntry(key.toString(), value),
        );
    final extensions =
        (request['extensions'] as Map? ?? const <Object?, Object?>{}).map(
          (key, value) => MapEntry(key.toString(), value),
        );
    final headers = (request['headers'] as Map? ?? const <Object?, Object?>{})
        .map((key, value) => MapEntry(key.toString(), value.toString()));
    newDraft(
      request: GraphqlRequest(
        endpoint: request['endpoint']?.toString() ?? '',
        document: request['document']?.toString() ?? '',
        operationName: request['operationName']?.toString(),
        variables: variables,
        extensions: extensions,
        headers: headers,
        useGet: request['useGet'] == true,
      ),
    );
  }

  Future<void> deleteSavedRequest(String id) async {
    await _runSavedRequestOperation(id, () async {
      await _repository.deleteRequest(id);
      final tabs = state.tabs
          .map(
            (tab) => tab.savedRequestId == id
                ? _copyTab(tab, clearSavedRequest: true, isDirty: true)
                : tab,
          )
          .toList(growable: false);
      _setTabs(tabs, state.activeIndex);
      await refreshSavedRequests();
    });
  }

  Future<void> duplicateSavedRequest(String id) async {
    await _runSavedRequestOperation(id, () async {
      await _repository.duplicateRequest(id);
      await refreshSavedRequests();
    });
  }

  Future<void> renameSavedRequest(String id, String name) async {
    await _runSavedRequestOperation(id, () async {
      final saved = await _repository.renameRequest(id, name);
      final tabs = state.tabs
          .map(
            (tab) => tab.savedRequestId == id
                ? _copyTab(tab, title: saved.name, isDirty: tab.isDirty)
                : tab,
          )
          .toList(growable: false);
      _setTabs(tabs, state.activeIndex);
      await refreshSavedRequests();
    });
  }

  void _replace({
    String? title,
    String? endpoint,
    String? document,
    String? operationName,
    Map<String, Object?>? variables,
    Map<String, String>? headers,
    Map<String, Object?>? extensions,
    bool? useGet,
    RequestAuthModel? auth,
    RequestSettingsModel? settings,
    String? environmentId,
    String? savedRequestId,
    bool? isDirty,
  }) {
    final old = state.active;
    final request = GraphqlRequest(
      endpoint: endpoint ?? old.request.endpoint,
      document: document ?? old.request.document,
      operationName: operationName ?? old.request.operationName,
      variables: variables ?? old.request.variables,
      headers: headers ?? old.request.headers,
      extensions: extensions ?? old.request.extensions,
      useGet: useGet ?? old.request.useGet,
      auth: auth ?? old.request.auth,
      settings: settings ?? old.request.settings,
    );
    final selectedEnvironment = environmentId ?? old.environmentId;
    final fingerprint = GraphqlDraft.fingerprint(request, selectedEnvironment);
    final updated = GraphqlDraft(
      id: old.id,
      workspaceId: old.workspaceId,
      title: title ?? old.title,
      updatedAt: DateTime.now(),
      savedRequestId: savedRequestId ?? old.savedRequestId,
      environmentId: selectedEnvironment,
      sortOrder: old.sortOrder,
      isActive: old.isActive,
      isDirty: isDirty ?? fingerprint != old.baselineFingerprint,
      baselineFingerprint: isDirty == false
          ? fingerprint
          : old.baselineFingerprint,
      request: request,
    );
    final tabs = List<GraphqlDraft>.of(state.tabs)
      ..[state.activeIndex] = updated;
    _setTabs(tabs, state.activeIndex);
  }

  void _setActivity(
    Set<String> source,
    String id,
    bool active, {
    required bool subscription,
  }) {
    final updated = Set<String>.of(source);
    active ? updated.add(id) : updated.remove(id);
    emit(
      subscription
          ? state.copyWith(activeSubscriptionIds: updated)
          : state.copyWith(activeOperationIds: updated),
    );
  }

  void _removeTabRuntimeState(String tabId) {
    final executions = Map<String, GraphqlTabExecution>.of(state.executions)
      ..remove(tabId);
    emit(
      state.copyWith(
        executions: executions,
        activeOperationIds: Set<String>.of(state.activeOperationIds)
          ..remove(tabId),
        activeSubscriptionIds: Set<String>.of(state.activeSubscriptionIds)
          ..remove(tabId),
      ),
    );
  }

  Future<void> _runSavedRequestOperation(
    String id,
    Future<void> Function() operation,
  ) async {
    if (state.busySavedRequestIds.contains(id)) return;
    emit(
      state.copyWith(
        busySavedRequestIds: <String>{...state.busySavedRequestIds, id},
      ),
    );
    try {
      await operation();
      if (!isClosed) emit(state.copyWith(savedRequestError: null));
    } on Object catch (error) {
      if (!isClosed) emit(state.copyWith(savedRequestError: error.toString()));
      rethrow;
    } finally {
      if (!isClosed) {
        emit(
          state.copyWith(
            busySavedRequestIds: Set<String>.of(state.busySavedRequestIds)
              ..remove(id),
          ),
        );
      }
    }
  }

  void _setTabs(List<GraphqlDraft> source, int activeIndex) {
    final tabs = <GraphqlDraft>[];
    for (var index = 0; index < source.length; index++) {
      final item = source[index];
      tabs.add(
        GraphqlDraft(
          id: item.id,
          workspaceId: item.workspaceId,
          title: item.title,
          request: item.request,
          updatedAt: item.updatedAt,
          savedRequestId: item.savedRequestId,
          environmentId: item.environmentId,
          sortOrder: index,
          isActive: index == activeIndex,
          isDirty: item.isDirty,
          baselineFingerprint: item.baselineFingerprint,
        ),
      );
    }
    emit(state.copyWith(tabs: tabs, activeIndex: activeIndex));
    for (final tab in tabs) {
      unawaited(
        _repository.saveDraft(
          id: tab.id,
          workspaceId: tab.workspaceId,
          title: tab.title,
          request: tab.request,
          savedRequestId: tab.savedRequestId,
          environmentId: tab.environmentId,
          sortOrder: tab.sortOrder,
          isActive: tab.isActive,
          isDirty: tab.isDirty,
          baselineFingerprint: tab.baselineFingerprint,
        ),
      );
    }
  }

  GraphqlDraft _copyTab(
    GraphqlDraft tab, {
    String? title,
    String? savedRequestId,
    bool clearSavedRequest = false,
    bool? isDirty,
  }) => GraphqlDraft(
    id: tab.id,
    workspaceId: tab.workspaceId,
    title: title ?? tab.title,
    request: tab.request,
    updatedAt: DateTime.now(),
    savedRequestId: clearSavedRequest
        ? null
        : savedRequestId ?? tab.savedRequestId,
    environmentId: tab.environmentId,
    sortOrder: tab.sortOrder,
    isActive: tab.isActive,
    isDirty: isDirty ?? tab.isDirty,
    baselineFingerprint: tab.baselineFingerprint,
  );
}
