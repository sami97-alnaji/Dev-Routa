import '../data/graphql_http_service.dart';
import '../data/graphql_repository.dart';
import '../domain/graphql_document_parser.dart';
import '../domain/graphql_models.dart';

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
    final response = await _http.execute(tabId, request);
    await _repository.record(
      draftId: tabId,
      workspaceId: workspaceId,
      type: operation.type,
      response: response,
    );
    return GraphqlExecutionResult(response: response, operation: operation);
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
