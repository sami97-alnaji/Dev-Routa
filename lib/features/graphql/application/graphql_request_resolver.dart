import 'dart:convert';

import '../../../core/rest/variable_resolution_service.dart';
import '../../../shared/models/api_models.dart';
import '../../../shared/services/service_interfaces.dart';
import '../data/graphql_repository.dart';
import '../domain/graphql_models.dart';

/// Resolves a persisted GraphQL request immediately before it crosses a
/// network boundary. The returned request is runtime-only and must not be
/// saved in drafts, history, or state.
class GraphqlRequestResolver {
  GraphqlRequestResolver(
    this._repository, {
    SecureStorageService? secureStorage,
  }) : _secureStorage = secureStorage;

  final GraphqlRepository _repository;
  final SecureStorageService? _secureStorage;

  Future<ResolvedGraphqlRequest> resolve(
    GraphqlRequest request, {
    String? environmentId,
    Map<String, Object?> connectionInitPayload = const <String, Object?>{},
  }) async {
    final environment = environmentId == null || environmentId.isEmpty
        ? <String, String>{}
        : await _repository.executionEnvironment(environmentId);
    final secrets = <String>{};
    try {
      final resolver = VariableResolutionService();
      String resolveText(String value) {
        final result = resolver.resolve(value, environment: environment);
        if (!result.isValid) {
          throw GraphqlFailure(
            GraphqlFailureCategory.unresolvedVariable,
            'Unresolved environment variables: '
            '${[...result.unresolved, ...result.cycles].join(', ')}',
          );
        }
        for (final candidate in environment.values) {
          if (candidate.isNotEmpty && result.value.contains(candidate)) {
            secrets.add(candidate);
          }
        }
        return result.value;
      }

      Object? resolveValue(Object? value) => switch (value) {
        String text => resolveText(text),
        Map map => map.map(
          (key, item) => MapEntry(key.toString(), resolveValue(item)),
        ),
        List list => list.map(resolveValue).toList(growable: false),
        _ => value,
      };

      final headers = request.headers.map(
        (key, value) => MapEntry(key, resolveText(value)),
      );
      var endpoint = resolveText(request.endpoint);
      switch (request.auth.type) {
        case AuthType.bearer:
          headers['Authorization'] =
              'Bearer ${await _secret(request.auth.tokenSecretRef, secrets)}';
        case AuthType.basic:
          final password = await _secret(
            request.auth.passwordSecretRef,
            secrets,
          );
          headers['Authorization'] =
              'Basic ${base64Encode(utf8.encode('${request.auth.username}:$password'))}';
        case AuthType.apiKeyHeader:
          headers[request.auth.apiKeyName] = await _secret(
            request.auth.apiKeySecretRef,
            secrets,
          );
        case AuthType.apiKeyQuery:
          final uri = Uri.tryParse(endpoint);
          if (uri == null) {
            throw const GraphqlFailure(
              GraphqlFailureCategory.validation,
              'The GraphQL endpoint is invalid after resolution.',
            );
          }
          endpoint = uri
              .replace(
                queryParameters: <String, String>{
                  ...uri.queryParameters,
                  request.auth.apiKeyName: await _secret(
                    request.auth.apiKeySecretRef,
                    secrets,
                  ),
                },
              )
              .toString();
        case AuthType.none:
          break;
      }
      final resolved = GraphqlRequest(
        endpoint: endpoint,
        document: resolveText(request.document),
        operationName: request.operationName,
        variables: resolveValue(request.variables) as Map<String, Object?>,
        headers: headers,
        useGet: request.useGet,
        extensions: resolveValue(request.extensions) as Map<String, Object?>,
        auth: const RequestAuthModel(),
        settings: request.settings,
      );
      final payload =
          resolveValue(connectionInitPayload) as Map<String, Object?>;
      return ResolvedGraphqlRequest(
        request: resolved,
        connectionInitPayload: <String, Object?>{
          ...payload,
          if (headers.isNotEmpty) 'headers': headers,
        },
        runtimeSecrets: secrets,
      );
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

  Future<String> _secret(String? reference, Set<String> runtimeSecrets) async {
    if (reference == null || reference.isEmpty) {
      throw const GraphqlFailure(
        GraphqlFailureCategory.missingSecret,
        'A required secret reference is missing.',
      );
    }
    final value = await _secureStorage?.readSecret(reference);
    if (value == null || value.isEmpty) {
      throw const GraphqlFailure(
        GraphqlFailureCategory.missingSecret,
        'A required secret could not be resolved.',
      );
    }
    runtimeSecrets.add(value);
    return value;
  }
}

class ResolvedGraphqlRequest {
  const ResolvedGraphqlRequest({
    required this.request,
    required this.connectionInitPayload,
    required this.runtimeSecrets,
  });

  final GraphqlRequest request;
  final Map<String, Object?> connectionInitPayload;
  final Set<String> runtimeSecrets;
}
