import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../core/network/dio_request_execution_service.dart';
import '../../../core/rest/request_safety_service.dart';
import '../../../core/rest/variable_resolution_service.dart';
import '../../../core/storage/local_workspace_repository.dart';
import '../../../shared/models/api_models.dart';

class RequestWorkflowState {
  const RequestWorkflowState({
    required this.tabs,
    this.activeIndex = 0,
    this.responses = const <String, ApiResponseModel>{},
    this.validationErrors = const <String>[],
    this.isSending = false,
    this.dirtyIds = const <String>{},
    this.sensitiveValues = const <String, Set<String>>{},
  });
  final List<ApiRequestModel> tabs;
  final int activeIndex;
  final Map<String, ApiResponseModel> responses;
  final List<String> validationErrors;
  final bool isSending;
  final Set<String> dirtyIds;
  final Map<String, Set<String>> sensitiveValues;
  ApiRequestModel get request => tabs[activeIndex];
  ApiResponseModel? get response => responses[request.id];
  bool get isDirty => dirtyIds.contains(request.id);
  bool get hasAnyDirty => dirtyIds.isNotEmpty;

  RequestWorkflowState copyWith({
    List<ApiRequestModel>? tabs,
    int? activeIndex,
    Map<String, ApiResponseModel>? responses,
    List<String>? validationErrors,
    bool? isSending,
    Set<String>? dirtyIds,
    Map<String, Set<String>>? sensitiveValues,
  }) => RequestWorkflowState(
    tabs: tabs ?? this.tabs,
    activeIndex: activeIndex ?? this.activeIndex,
    responses: responses ?? this.responses,
    validationErrors: validationErrors ?? this.validationErrors,
    isSending: isSending ?? this.isSending,
    dirtyIds: dirtyIds ?? this.dirtyIds,
    sensitiveValues: sensitiveValues ?? this.sensitiveValues,
  );
}

class RequestWorkflowCubit extends Cubit<RequestWorkflowState> {
  RequestWorkflowCubit(this._executor, this._repository)
    : super(RequestWorkflowState(tabs: <ApiRequestModel>[_newRequest()]));
  final DioRequestExecutionService _executor;
  final LocalWorkspaceRepository _repository;
  final _safety = RequestSafetyService();

  static ApiRequestModel _newRequest({String? collectionId, String? folderId}) {
    final now = DateTime.now();
    return ApiRequestModel(
      id: const Uuid().v4(),
      createdAt: now,
      updatedAt: now,
      name: 'Untitled request',
      url: '',
      method: HttpMethod.get,
      collectionId: collectionId,
      folderId: folderId,
      sortOrder: now.microsecondsSinceEpoch,
    );
  }

  Future<void> restoreDrafts() async {
    final drafts = await _repository.drafts();
    if (drafts.isNotEmpty && !isClosed) {
      emit(
        RequestWorkflowState(
          tabs: drafts,
          dirtyIds: drafts.map((item) => item.id).toSet(),
        ),
      );
    }
  }

  void updateUrl(String value) => _replace(url: value);
  void updateMethod(HttpMethod value) => _replace(method: value);
  void updateName(String value) => _replace(name: value);
  void updateHeaders(List<RequestHeaderModel> value) =>
      _replace(headers: value);
  void updateQueryParams(List<RequestQueryParamModel> value) =>
      _replace(queryParams: value);
  void updateBody(RequestBodyModel? value) =>
      _replace(body: value, replaceBody: true);
  void updateAuth(RequestAuthModel value) => _replace(auth: value);
  void updateSettings(RequestSettingsModel value) => _replace(settings: value);
  void assignLocation(String? collectionId, String? folderId) => _replace(
    collectionId: collectionId,
    folderId: folderId,
    replaceLocation: true,
  );

  Future<void> configureAuth(
    RequestAuthModel auth, {
    String? secretValue,
  }) async {
    final reference = switch (auth.type) {
      AuthType.bearer => auth.tokenSecretRef,
      AuthType.basic => auth.passwordSecretRef,
      AuthType.apiKeyHeader || AuthType.apiKeyQuery => auth.apiKeySecretRef,
      AuthType.none => null,
    };
    if (reference != null && secretValue != null && secretValue.isNotEmpty) {
      await _repository.saveSecret(reference, secretValue);
    }
    updateAuth(auth);
  }

  Future<void> saveResponseToken(String reference, String value) =>
      _repository.saveSecret(reference, value);

  void newRequest({String? collectionId, String? folderId}) {
    final request = _newRequest(collectionId: collectionId, folderId: folderId);
    emit(
      state.copyWith(
        tabs: <ApiRequestModel>[...state.tabs, request],
        activeIndex: state.tabs.length,
        dirtyIds: <String>{...state.dirtyIds, request.id},
        validationErrors: const <String>[],
      ),
    );
    unawaited(_repository.saveDraft(request));
  }

  void openRequest(ApiRequestModel request) {
    final existing = state.tabs.indexWhere((item) => item.id == request.id);
    if (existing >= 0) {
      emit(state.copyWith(activeIndex: existing));
    } else {
      emit(
        state.copyWith(
          tabs: <ApiRequestModel>[...state.tabs, request],
          activeIndex: state.tabs.length,
        ),
      );
    }
  }

  void selectTab(int index) {
    if (index >= 0 && index < state.tabs.length) {
      emit(
        state.copyWith(activeIndex: index, validationErrors: const <String>[]),
      );
    }
  }

  Future<void> closeActive({required bool discardChanges}) async {
    if (state.isDirty && !discardChanges) return;
    final request = state.request;
    final tabs = List<ApiRequestModel>.of(state.tabs)
      ..removeAt(state.activeIndex);
    final dirty = Set<String>.of(state.dirtyIds)..remove(request.id);
    await _repository.deleteDraft(request.id);
    if (tabs.isEmpty) tabs.add(_newRequest());
    emit(
      state.copyWith(
        tabs: tabs,
        activeIndex: state.activeIndex.clamp(0, tabs.length - 1),
        dirtyIds: dirty,
        isSending: false,
      ),
    );
  }

  Future<void> save() async {
    await _repository.saveRequest(state.request);
    await _repository.deleteDraft(state.request.id);
    final dirty = Set<String>.of(state.dirtyIds)..remove(state.request.id);
    emit(state.copyWith(dirtyIds: dirty));
  }

  Future<void> send({
    String? environmentId,
    int previewLimitBytes = 1024 * 1024,
  }) async {
    if (state.isSending) return;
    final source = state.request;
    var environment = const <String, String>{};
    var secretKeys = const <String>{};
    if (environmentId != null) {
      final resolved = await _repository.executionEnvironment(environmentId);
      environment = resolved.values;
      secretKeys = resolved.secretKeys;
    }
    final resolver = VariableResolutionService();
    final resolvedUrl = resolver.resolve(
      source.url,
      environment: environment,
      secretKeys: secretKeys,
    );
    final unresolved = <String>{...resolvedUrl.unresolved};
    String resolveValue(String value) {
      final result = resolver.resolve(
        value,
        environment: environment,
        secretKeys: secretKeys,
      );
      unresolved.addAll(result.unresolved);
      return result.value;
    }

    final executionRequest = ApiRequestModel(
      id: source.id,
      createdAt: source.createdAt,
      updatedAt: source.updatedAt,
      name: source.name,
      url: resolvedUrl.value,
      method: source.method,
      headers: source.headers
          .map(
            (item) => RequestHeaderModel(
              key: resolveValue(item.key),
              value: item.isSecret ? item.value : resolveValue(item.value),
              enabled: item.enabled,
              isSecret: item.isSecret,
              secretRef: item.secretRef,
            ),
          )
          .toList(),
      queryParams: source.queryParams
          .map(
            (item) => RequestQueryParamModel(
              key: resolveValue(item.key),
              value: resolveValue(item.value),
              enabled: item.enabled,
            ),
          )
          .toList(),
      body: source.body == null
          ? null
          : RequestBodyModel(
              type: source.body!.type,
              content: resolveValue(source.body!.content),
              contentType: source.body!.contentType,
              filePath: source.body!.filePath,
            ),
      auth: source.auth,
      settings: source.settings,
      collectionId: source.collectionId,
      folderId: source.folderId,
      sortOrder: source.sortOrder,
    );
    if (unresolved.isNotEmpty) {
      emit(
        state.copyWith(
          validationErrors: <String>[
            'Unresolved variables: ${unresolved.toList()..sort()}',
          ],
        ),
      );
      return;
    }
    final validation = _safety.validate(executionRequest);
    if (!validation.isValid) {
      emit(state.copyWith(validationErrors: validation.errors));
      return;
    }
    emit(state.copyWith(isSending: true, validationErrors: const <String>[]));
    final response = await _executor.execute(
      executionRequest,
      previewLimitBytes: previewLimitBytes,
    );
    final runtimeSensitive = <String>{
      ...await _repository.executionRequestSecrets(source),
      for (final key in secretKeys)
        if (environment[key]?.isNotEmpty == true) environment[key]!,
    };
    await _repository.recordHistory(
      source,
      response,
      sensitiveValues: runtimeSensitive,
    );
    if (!isClosed) {
      emit(
        state.copyWith(
          responses: <String, ApiResponseModel>{
            ...state.responses,
            state.request.id: response,
          },
          sensitiveValues: <String, Set<String>>{
            ...state.sensitiveValues,
            state.request.id: runtimeSensitive,
          },
          isSending: false,
        ),
      );
    }
  }

  void cancel() => _executor.cancel();

  void _replace({
    String? url,
    String? name,
    HttpMethod? method,
    List<RequestHeaderModel>? headers,
    List<RequestQueryParamModel>? queryParams,
    RequestBodyModel? body,
    bool replaceBody = false,
    RequestAuthModel? auth,
    RequestSettingsModel? settings,
    String? collectionId,
    String? folderId,
    bool replaceLocation = false,
  }) {
    final old = state.request;
    final updated = ApiRequestModel(
      id: old.id,
      createdAt: old.createdAt,
      updatedAt: DateTime.now(),
      name: name ?? old.name,
      url: url ?? old.url,
      method: method ?? old.method,
      headers: headers ?? old.headers,
      queryParams: queryParams ?? old.queryParams,
      body: replaceBody ? body : old.body,
      auth: auth ?? old.auth,
      settings: settings ?? old.settings,
      collectionId: replaceLocation ? collectionId : old.collectionId,
      folderId: replaceLocation ? folderId : old.folderId,
      sortOrder: old.sortOrder,
    );
    final tabs = List<ApiRequestModel>.of(state.tabs)
      ..[state.activeIndex] = updated;
    emit(
      state.copyWith(
        tabs: tabs,
        dirtyIds: <String>{...state.dirtyIds, old.id},
        validationErrors: const <String>[],
      ),
    );
    unawaited(_repository.saveDraft(updated));
  }
}
