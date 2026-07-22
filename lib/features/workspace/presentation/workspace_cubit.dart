import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/storage/local_workspace_repository.dart';
import '../../../shared/models/api_models.dart';

class WorkspaceState {
  const WorkspaceState({
    this.workspaces = const <WorkspaceModel>[],
    this.collections = const <CollectionModel>[],
    this.folders = const <FolderModel>[],
    this.savedRequests = const <ApiRequestModel>[],
    this.environments = const <EnvironmentModel>[],
    this.environmentVariables = const <EnvironmentVariableModel>[],
    this.history = const <HistoryEntry>[],
    this.settings = const WorkspaceSettingsModel(),
    this.selectedWorkspaceId,
    this.selectedCollectionId,
    this.selectedEnvironmentId,
    this.search = '',
    this.loading = true,
  });
  final List<WorkspaceModel> workspaces;
  final List<CollectionModel> collections;
  final List<FolderModel> folders;
  final List<ApiRequestModel> savedRequests;
  final List<EnvironmentModel> environments;
  final List<EnvironmentVariableModel> environmentVariables;
  final List<HistoryEntry> history;
  final WorkspaceSettingsModel settings;
  final String? selectedWorkspaceId;
  final String? selectedCollectionId;
  final String? selectedEnvironmentId;
  final String search;
  final bool loading;

  WorkspaceState copyWith({
    List<WorkspaceModel>? workspaces,
    List<CollectionModel>? collections,
    List<FolderModel>? folders,
    List<ApiRequestModel>? savedRequests,
    List<EnvironmentModel>? environments,
    List<EnvironmentVariableModel>? environmentVariables,
    List<HistoryEntry>? history,
    WorkspaceSettingsModel? settings,
    String? selectedWorkspaceId,
    String? selectedCollectionId,
    String? selectedEnvironmentId,
    String? search,
    bool? loading,
    bool clearCollection = false,
    bool clearEnvironment = false,
  }) => WorkspaceState(
    workspaces: workspaces ?? this.workspaces,
    collections: collections ?? this.collections,
    folders: folders ?? this.folders,
    savedRequests: savedRequests ?? this.savedRequests,
    environments: environments ?? this.environments,
    environmentVariables: environmentVariables ?? this.environmentVariables,
    history: history ?? this.history,
    settings: settings ?? this.settings,
    selectedWorkspaceId: selectedWorkspaceId ?? this.selectedWorkspaceId,
    selectedCollectionId: clearCollection
        ? null
        : (selectedCollectionId ?? this.selectedCollectionId),
    selectedEnvironmentId: clearEnvironment
        ? null
        : (selectedEnvironmentId ?? this.selectedEnvironmentId),
    search: search ?? this.search,
    loading: loading ?? this.loading,
  );
}

class WorkspaceCubit extends Cubit<WorkspaceState> {
  WorkspaceCubit(this._repository) : super(const WorkspaceState());
  final LocalWorkspaceRepository _repository;

  Future<void> load({String? selected}) async {
    var workspaces = await _repository.workspaces();
    if (workspaces.isEmpty) {
      await _repository.createWorkspace('My workspace');
      workspaces = await _repository.workspaces();
    }
    final requested = selected ?? state.selectedWorkspaceId;
    final selectedId = workspaces.any((item) => item.id == requested)
        ? requested!
        : workspaces.first.id;
    final collections = await _repository.collections(
      selectedId,
      search: state.search,
    );
    final collectionId =
        collections.any((item) => item.id == state.selectedCollectionId)
        ? state.selectedCollectionId
        : null;
    final environments = await _repository.environments(selectedId);
    final environmentId =
        environments.any((item) => item.id == state.selectedEnvironmentId)
        ? state.selectedEnvironmentId
        : (environments.where((item) => item.isActive).firstOrNull?.id);
    emit(
      WorkspaceState(
        workspaces: workspaces,
        selectedWorkspaceId: selectedId,
        collections: collections,
        folders: collectionId == null
            ? const <FolderModel>[]
            : await _repository.folders(collectionId),
        savedRequests: await _repository.savedRequests(
          selectedId,
          search: state.search,
          collectionId: collectionId,
        ),
        selectedCollectionId: collectionId,
        environments: environments,
        selectedEnvironmentId: environmentId,
        environmentVariables: environmentId == null
            ? const <EnvironmentVariableModel>[]
            : await _repository.environmentVariables(environmentId),
        history: await _repository.history(search: state.search),
        settings: await _repository.workspaceSettings(selectedId),
        search: state.search,
        loading: false,
      ),
    );
  }

  Future<void> search(String value) async {
    emit(state.copyWith(search: value));
    await load();
  }

  Future<void> selectWorkspace(String id) => load(selected: id);
  Future<void> addWorkspace(String name) async {
    final created = await _repository.createWorkspace(name);
    await load(selected: created.id);
  }

  Future<void> renameWorkspace(String id, String name) async {
    await _repository.renameWorkspace(id, name);
    await load();
  }

  Future<void> removeWorkspace(String id) async {
    await _repository.deleteWorkspace(id);
    emit(const WorkspaceState());
    await load();
  }

  Future<void> addCollection(String name) async {
    await _repository.createCollection(state.selectedWorkspaceId!, name);
    await load();
  }

  Future<void> renameCollection(String id, String name) async {
    await _repository.renameCollection(id, name);
    await load();
  }

  Future<void> duplicateCollection(String id) async {
    await _repository.duplicateCollection(id);
    await load();
  }

  Future<void> reorderCollection(String id, int order) async {
    final items = List<CollectionModel>.of(state.collections);
    final current = items.indexWhere((item) => item.id == id);
    if (current < 0) return;
    final item = items.removeAt(current);
    items.insert(order.clamp(0, items.length), item);
    for (var index = 0; index < items.length; index++) {
      await _repository.reorderCollection(items[index].id, index);
    }
    await load();
  }

  Future<void> moveCollection(String id, String workspaceId) async {
    await _repository.moveCollection(id, workspaceId);
    await load();
  }

  Future<void> removeCollection(String id) async {
    await _repository.deleteCollection(id);
    emit(state.copyWith(clearCollection: true));
    await load();
  }

  Future<void> selectCollection(String id) async {
    emit(
      state.copyWith(
        selectedCollectionId: id,
        folders: await _repository.folders(id),
        savedRequests: await _repository.savedRequests(
          state.selectedWorkspaceId!,
          search: state.search,
          collectionId: id,
        ),
      ),
    );
  }

  Future<void> addFolder(String name, {String? parentId}) async {
    await _repository.createFolder(
      state.selectedCollectionId!,
      name,
      parentFolderId: parentId,
    );
    await selectCollection(state.selectedCollectionId!);
  }

  Future<void> renameFolder(String id, String name) async {
    await _repository.renameFolder(id, name);
    await selectCollection(state.selectedCollectionId!);
  }

  Future<void> removeFolder(String id) async {
    await _repository.deleteFolder(id);
    await selectCollection(state.selectedCollectionId!);
  }

  Future<void> reorderFolder(String id, int order) async {
    final items = List<FolderModel>.of(state.folders);
    final current = items.indexWhere((item) => item.id == id);
    if (current < 0) return;
    final item = items.removeAt(current);
    items.insert(order.clamp(0, items.length), item);
    for (var index = 0; index < items.length; index++) {
      await _repository.reorderFolder(items[index].id, index);
    }
    await selectCollection(state.selectedCollectionId!);
  }

  Future<void> moveFolder(String id, String collectionId) async {
    await _repository.moveFolder(id, collectionId);
    await load();
  }

  Future<void> duplicateSavedRequest(String id) async {
    await _repository.duplicateRequest(id);
    await load();
  }

  Future<void> removeSavedRequest(String id) async {
    await _repository.deleteRequest(id);
    await load();
  }

  Future<void> reorderSavedRequest(String id, int order) async {
    final items = List<ApiRequestModel>.of(state.savedRequests);
    final current = items.indexWhere((item) => item.id == id);
    if (current < 0) return;
    final item = items.removeAt(current);
    items.insert(order.clamp(0, items.length), item);
    for (var index = 0; index < items.length; index++) {
      await _repository.reorderRequest(items[index].id, index);
    }
    await load();
  }

  Future<List<FolderModel>> foldersForCollection(String collectionId) =>
      _repository.folders(collectionId);

  Future<void> addEnvironment(String name, EnvironmentKind kind) async {
    final created = await _repository.createEnvironment(
      state.selectedWorkspaceId!,
      name,
      kind,
    );
    await load();
    await selectEnvironment(created.id);
  }

  Future<void> renameEnvironment(String id, String name) async {
    await _repository.renameEnvironment(id, name);
    await load();
  }

  Future<void> duplicateEnvironment(String id) async {
    await _repository.duplicateEnvironment(id);
    await load();
  }

  Future<void> setEnvironment(String id) async {
    await _repository.setActiveEnvironment(state.selectedWorkspaceId!, id);
    await load();
    await selectEnvironment(id);
  }

  Future<void> selectEnvironment(String id) async {
    emit(
      state.copyWith(
        selectedEnvironmentId: id,
        environmentVariables: await _repository.environmentVariables(id),
      ),
    );
  }

  Future<void> removeEnvironment(String id) async {
    await _repository.deleteEnvironment(id);
    emit(state.copyWith(clearEnvironment: true));
    await load();
  }

  Future<void> saveVariable({
    String? id,
    required String key,
    required String value,
    required bool secret,
    bool enabled = true,
  }) async {
    await _repository.saveEnvironmentVariable(
      state.selectedEnvironmentId!,
      id: id,
      key: key,
      value: value,
      isSecret: secret,
      enabled: enabled,
    );
    await selectEnvironment(state.selectedEnvironmentId!);
  }

  Future<void> removeVariable(String id) async {
    await _repository.deleteEnvironmentVariable(id);
    await selectEnvironment(state.selectedEnvironmentId!);
  }

  Future<void> reorderVariable(String id, int order) async {
    final items = List<EnvironmentVariableModel>.of(state.environmentVariables);
    final current = items.indexWhere((item) => item.id == id);
    if (current < 0) return;
    final item = items.removeAt(current);
    items.insert(order.clamp(0, items.length), item);
    for (var index = 0; index < items.length; index++) {
      await _repository.reorderEnvironmentVariable(items[index].id, index);
    }
    await selectEnvironment(state.selectedEnvironmentId!);
  }

  Future<void> removeHistory(String id) async {
    await _repository.deleteHistory(id);
    await load();
  }

  Future<void> clearAllHistory() async {
    await _repository.clearHistory();
    await load();
  }

  Future<ApiRequestModel?> replayHistory(String id) =>
      _repository.replayHistory(id);
  Future<void> updateSettings(WorkspaceSettingsModel settings) async {
    await _repository.updateWorkspaceSettings(
      state.selectedWorkspaceId!,
      settings,
    );
    await _repository.applyHistoryRetention(settings);
    await load();
  }
}
