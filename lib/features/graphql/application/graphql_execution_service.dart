import '../data/graphql_http_service.dart';
import '../data/graphql_repository.dart';
import '../domain/graphql_document_parser.dart';
import '../domain/graphql_models.dart';
import '../../../core/rest/variable_resolution_service.dart';

/// Application boundary for HTTP GraphQL execution.  UI code never owns a
/// Dio client, a cancellation token, response parsing, or history writes.
class GraphqlExecutionService {
  GraphqlExecutionService(this._http, this._repository);

  final GraphqlHttpService _http;
  final GraphqlRepository _repository;

  Future<GraphqlExecutionResult> execute({
    required String tabId,
    required String workspaceId,
    required GraphqlRequest request,
    String? environmentId,
  }) async {
    final analysis = GraphqlDocumentParser.analyze(request.document);
    final operation = GraphqlDocumentParser.select(
      analysis,
      request.operationName,
    );
    if (!analysis.isValid || operation == null) {
      throw GraphqlFailure(
        GraphqlFailureCategory.validation,
        analysis.errors.isEmpty
            ? 'Select an operation before execution.'
            : analysis.errors.join('\n'),
      );
    }
    if (operation.type == GraphqlOperationType.subscription) {
      throw const GraphqlFailure(
        GraphqlFailureCategory.validation,
        'Subscriptions must use the subscription transport.',
      );
    }
    final environment = <String, String>{};
    try {
      if (environmentId != null && environmentId.isNotEmpty) {
        environment.addAll(
          await _repository.executionEnvironment(environmentId),
        );
      }
      final resolved = _resolveRequest(request, environment);
      final response = await _http.execute(tabId, resolved);
      await _repository.record(
        draftId: tabId,
        workspaceId: workspaceId,
        type: operation.type,
        response: response,
        request: request,
        operationName: operation.name,
      );
      return GraphqlExecutionResult(response: response, operation: operation);
    } on StateError catch (error) {
      throw GraphqlFailure(
        GraphqlFailureCategory.missingSecret,
        error.message,
        cause: error,
      );
    } finally {
      environment.clear();
    }
  }

  GraphqlRequest _resolveRequest(
    GraphqlRequest request,
    Map<String, String> environment,
  ) {
    final resolver = VariableResolutionService();
    String resolve(String value) {
      final result = resolver.resolve(value, environment: environment);
      if (!result.isValid) {
        throw GraphqlFailure(
          GraphqlFailureCategory.unresolvedVariable,
          'Unresolved environment variables: ${[...result.unresolved, ...result.cycles].join(', ')}',
        );
      }
      return result.value;
    }

    Object? resolveValue(Object? value) => switch (value) {
      String text => resolve(text),
      Map map => map.map(
        (key, item) => MapEntry(key.toString(), resolveValue(item)),
      ),
      List list => list.map(resolveValue).toList(growable: false),
      _ => value,
    };

    return GraphqlRequest(
      endpoint: resolve(request.endpoint),
      document: resolve(request.document),
      operationName: request.operationName,
      variables: resolveValue(request.variables) as Map<String, Object?>,
      headers: request.headers.map(
        (key, value) => MapEntry(key, resolve(value)),
      ),
      useGet: request.useGet,
      extensions: resolveValue(request.extensions) as Map<String, Object?>,
      auth: request.auth,
      settings: request.settings,
    );
  }

  void cancel(String tabId) => _http.cancel(tabId);
}

class GraphqlExecutionResult {
  const GraphqlExecutionResult({
    required this.response,
    required this.operation,
  });

  final GraphqlResponse response;
  final GraphqlOperation operation;
}
