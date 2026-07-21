import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/graphql_repository.dart';
import '../domain/graphql_models.dart';
import '../domain/graphql_schema_models.dart';

typedef GraphqlSchemaFetcher =
    Future<GraphqlSchemaSnapshot> Function(GraphqlRequest request);

class GraphqlSchemaState {
  const GraphqlSchemaState({
    this.loading = false,
    this.snapshots = const <GraphqlStoredSchemaSnapshot>[],
    this.activeId,
    this.error,
  });

  final bool loading;
  final List<GraphqlStoredSchemaSnapshot> snapshots;
  final String? activeId;
  final String? error;

  GraphqlStoredSchemaSnapshot? get active {
    for (final item in snapshots) {
      if (item.id == activeId) return item;
    }
    return snapshots.isEmpty ? null : snapshots.first;
  }
}

class GraphqlSchemaCubit extends Cubit<GraphqlSchemaState> {
  GraphqlSchemaCubit(
    this._repository, {
    required this.workspaceId,
    required GraphqlSchemaFetcher fetcher,
  }) : _fetcher = fetcher,
       super(const GraphqlSchemaState());

  final GraphqlRepository _repository;
  final GraphqlSchemaFetcher _fetcher;
  final String workspaceId;

  Future<void> load({String? preferredId}) async {
    emit(
      GraphqlSchemaState(
        loading: true,
        snapshots: state.snapshots,
        activeId: state.activeId,
      ),
    );
    try {
      final snapshots = await _repository.schemaSnapshots(workspaceId);
      final requested = preferredId ?? state.activeId;
      final activeId = snapshots.any((item) => item.id == requested)
          ? requested
          : snapshots.isEmpty
          ? null
          : snapshots.first.id;
      emit(GraphqlSchemaState(snapshots: snapshots, activeId: activeId));
    } on Object catch (error) {
      emit(
        GraphqlSchemaState(
          snapshots: state.snapshots,
          activeId: state.activeId,
          error: error.toString(),
        ),
      );
    }
  }

  Future<void> fetch(GraphqlRequest request) async {
    if (request.endpoint.trim().isEmpty) {
      emit(
        GraphqlSchemaState(
          snapshots: state.snapshots,
          activeId: state.activeId,
          error: 'Enter a GraphQL endpoint before fetching the schema.',
        ),
      );
      return;
    }

    emit(
      GraphqlSchemaState(
        loading: true,
        snapshots: state.snapshots,
        activeId: state.activeId,
      ),
    );

    try {
      final snapshot = await _fetcher(request);
      final stored = await _repository.saveSchemaSnapshot(
        workspaceId: workspaceId,
        endpoint: request.endpoint,
        snapshot: snapshot,
      );
      final snapshots = await _repository.schemaSnapshots(workspaceId);
      emit(GraphqlSchemaState(snapshots: snapshots, activeId: stored.id));
    } on GraphqlFailure catch (failure) {
      emit(
        GraphqlSchemaState(
          snapshots: state.snapshots,
          activeId: state.activeId,
          error: '${failure.category.name}: ${failure.message}',
        ),
      );
    } on Object catch (error) {
      emit(
        GraphqlSchemaState(
          snapshots: state.snapshots,
          activeId: state.activeId,
          error: error.toString(),
        ),
      );
    }
  }

  void select(String id) {
    if (!state.snapshots.any((item) => item.id == id)) return;
    emit(GraphqlSchemaState(snapshots: state.snapshots, activeId: id));
  }

  Future<void> delete(String id) async {
    await _repository.deleteSchemaSnapshot(id);
    await load();
  }
}
