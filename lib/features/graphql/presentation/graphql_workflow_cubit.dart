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
    this.activeIndex = 0,
    this.activeOperationIds = const <String>{},
    this.activeSubscriptionIds = const <String>{},
    this.executions = const <String, GraphqlTabExecution>{},
  });

  final List<GraphqlDraft> tabs;
  final List<GraphqlSavedRequest> savedRequests;
  final int activeIndex;
  final Set<String> activeOperationIds;
  final Set<String> activeSubscriptionIds;
  final Map<String, GraphqlTabExecution> executions;
  GraphqlDraft get active => tabs[activeIndex];
  bool get isDirty => active.isDirty;
  bool get hasActiveWork =>
      activeOperationIds.contains(active.id) ||
      activeSubscriptionIds.contains(active.id);
  GraphqlTabExecution executionFor(String tabId) =>
      executions[tabId] ?? const GraphqlTabExecution();

  GraphqlWorkflowState copyWith({
    List<GraphqlDraft>? tabs,
    List<GraphqlSavedRequest>? savedRequests,
    int? activeIndex,
    Set<String>? activeOperationIds,
    Set<String>? activeSubscriptionIds,
    Map<String, GraphqlTabExecution>? executions,
  }) => GraphqlWorkflowState(
    tabs: tabs ?? this.tabs,
    savedRequests: savedRequests ?? this.savedRequests,
    activeIndex: activeIndex ?? this.activeIndex,
    activeOperationIds: activeOperationIds ?? this.activeOperationIds,
    activeSubscriptionIds: activeSubscriptionIds ?? this.activeSubscriptionIds,
    executions: executions ?? this.executions,
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
    return GraphqlDraft(
      id: _ids.v4(),
      workspaceId: workspaceId,
      title: 'Untitled GraphQL request',
      request: request ?? const GraphqlRequest(endpoint: '', document: ''),
      updatedAt: now,
    );
  }

  Future<void> restoreDrafts() async {
    final drafts = await _repository.drafts(workspaceId);
    final saved = await _repository.requests(workspaceId);
    if (isClosed) return;
    if (drafts.isEmpty) {
      emit(state.copyWith(savedRequests: saved));
      return;
    }
    final ordered = List<GraphqlDraft>.of(drafts)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final selected = ordered.indexWhere((item) => item.isActive);
    emit(
      state.copyWith(
        tabs: ordered,
        savedRequests: saved,
        activeIndex: selected < 0 ? 0 : selected,
      ),
    );
  }

  void newDraft({GraphqlRequest? request, String? savedRequestId}) {
    final draft = _newDraft(workspaceId, request: request);
    final tab = GraphqlDraft(
      id: draft.id,
      workspaceId: draft.workspaceId,
      title: draft.title,
      request: draft.request,
      updatedAt: draft.updatedAt,
      savedRequestId: savedRequestId,
      sortOrder: state.tabs.length,
    );
    _setTabs(<GraphqlDraft>[...state.tabs, tab], state.tabs.length);
  }

  void openSavedRequest(GraphqlSavedRequest saved) =>
      newDraft(request: saved.request, savedRequestId: saved.id);

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
    final current = state.active;
    if (current.isDirty && !discardChanges) return;
    await _repository.deleteDraft(current.id);
    final tabs = List<GraphqlDraft>.of(state.tabs)..removeAt(state.activeIndex);
    if (tabs.isEmpty) {
      tabs.add(_newDraft(workspaceId));
    }
    _setTabs(tabs, state.activeIndex.clamp(0, tabs.length - 1));
  }

  Future<void> closeOthers({required bool discardChanges}) async {
    if (!discardChanges &&
        state.tabs.any((tab) => tab.id != state.active.id && tab.isDirty)) {
      return;
    }
    for (final tab in state.tabs.where((item) => item.id != state.active.id)) {
      await _repository.deleteDraft(tab.id);
    }
    _setTabs(<GraphqlDraft>[state.active], 0);
  }

  Future<void> closeAll({required bool discardChanges}) async {
    if (!discardChanges && state.tabs.any((tab) => tab.isDirty)) {
      return;
    }
    for (final tab in state.tabs) {
      await _repository.deleteDraft(tab.id);
    }
    _setTabs(<GraphqlDraft>[_newDraft(workspaceId)], 0);
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
      );
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

  Future<GraphqlSavedRequest> saveActive({bool forceNew = false}) async {
    final current = state.active;
    final saved = await _repository.saveRequest(
      id: forceNew ? null : current.savedRequestId,
      workspaceId: current.workspaceId,
      name: current.title,
      request: current.request,
    );
    _replace(savedRequestId: saved.id, isDirty: false);
    await refreshSavedRequests();
    return saved;
  }

  Future<void> refreshSavedRequests([String query = '']) async {
    final saved = query.trim().isEmpty
        ? await _repository.requests(workspaceId)
        : await _repository.searchRequests(workspaceId, query);
    if (!isClosed) emit(state.copyWith(savedRequests: saved));
  }

  Future<void> deleteSavedRequest(String id) async {
    await _repository.deleteRequest(id);
    await refreshSavedRequests();
  }

  Future<void> duplicateSavedRequest(String id) async {
    await _repository.duplicateRequest(id);
    await refreshSavedRequests();
  }

  Future<void> renameSavedRequest(String id, String name) async {
    await _repository.renameRequest(id, name);
    await refreshSavedRequests();
  }

  void _replace({
    String? title,
    String? endpoint,
    String? document,
    String? operationName,
    Map<String, Object?>? variables,
    Map<String, String>? headers,
    Map<String, Object?>? extensions,
    RequestAuthModel? auth,
    RequestSettingsModel? settings,
    String? environmentId,
    String? savedRequestId,
    bool? isDirty,
  }) {
    final old = state.active;
    final updated = GraphqlDraft(
      id: old.id,
      workspaceId: old.workspaceId,
      title: title ?? old.title,
      updatedAt: DateTime.now(),
      savedRequestId: savedRequestId ?? old.savedRequestId,
      environmentId: environmentId ?? old.environmentId,
      sortOrder: old.sortOrder,
      isActive: old.isActive,
      isDirty: isDirty ?? true,
      request: GraphqlRequest(
        endpoint: endpoint ?? old.request.endpoint,
        document: document ?? old.request.document,
        operationName: operationName ?? old.request.operationName,
        variables: variables ?? old.request.variables,
        headers: headers ?? old.request.headers,
        extensions: extensions ?? old.request.extensions,
        useGet: old.request.useGet,
        auth: auth ?? old.request.auth,
        settings: settings ?? old.request.settings,
      ),
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
        ),
      );
    }
  }
}
