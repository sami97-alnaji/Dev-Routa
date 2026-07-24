import '../data/graphql_http_service.dart';
import '../data/graphql_repository.dart';
import '../domain/graphql_document_parser.dart';
import '../domain/graphql_models.dart';
import 'graphql_request_resolver.dart';

/// Application boundary for HTTP GraphQL execution.  UI code never owns a
/// Dio client, a cancellation token, response parsing, or history writes.
class GraphqlExecutionService {
  GraphqlExecutionService(
    this._http,
    this._repository, {
    GraphqlRequestResolver? resolver,
  }) : _resolver = resolver ?? GraphqlRequestResolver(_repository);

  final GraphqlHttpService _http;
  final GraphqlRepository _repository;
  final GraphqlRequestResolver _resolver;

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
    try {
      final resolved = await _resolver.resolve(
        request,
        environmentId: environmentId,
      );
      final response = await _http.execute(tabId, resolved.request);
      await _repository.record(
        draftId: tabId,
        workspaceId: workspaceId,
        type: operation.type,
        response: response,
        request: request,
        operationName: operation.name,
      );
      return GraphqlExecutionResult(response: response, operation: operation);
    } on GraphqlFailure catch (failure) {
      if (_shouldRecordFailure(failure)) {
        await _repository.recordFailure(
          draftId: tabId,
          workspaceId: workspaceId,
          type: operation.type,
          failure: failure,
          request: request,
          operationName: operation.name,
        );
      }
      rethrow;
    } on StateError catch (error) {
      throw GraphqlFailure(
        GraphqlFailureCategory.missingSecret,
        error.message,
        cause: error,
      );
    }
  }

  void cancel(String tabId) => _http.cancel(tabId);

  bool _shouldRecordFailure(GraphqlFailure failure) =>
      switch (failure.category) {
        GraphqlFailureCategory.cancelled ||
        GraphqlFailureCategory.timeout ||
        GraphqlFailureCategory.network ||
        GraphqlFailureCategory.tls ||
        GraphqlFailureCategory.http ||
        GraphqlFailureCategory.malformedResponse ||
        GraphqlFailureCategory.protocol ||
        GraphqlFailureCategory.unknown => true,
        _ => false,
      };
}

class GraphqlExecutionResult {
  const GraphqlExecutionResult({
    required this.response,
    required this.operation,
  });

  final GraphqlResponse response;
  final GraphqlOperation operation;
}
