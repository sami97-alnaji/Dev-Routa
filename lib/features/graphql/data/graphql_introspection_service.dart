import '../domain/graphql_models.dart';
import '../domain/graphql_schema_models.dart';
import 'graphql_http_service.dart';
import '../../../shared/models/api_models.dart';

class GraphqlIntrospectionService {
  GraphqlIntrospectionService(this._http);
  final GraphqlHttpService _http;

  static const query = r'''query DevRouteIntrospection {
    __schema {
      queryType { name }
      mutationType { name }
      subscriptionType { name }
      types {
        kind name description
        interfaces { kind name ofType { kind name ofType { kind name } } }
        enumValues(includeDeprecated: true) { name isDeprecated deprecationReason }
        fields(includeDeprecated: true) {
          name description isDeprecated deprecationReason
          args { name description defaultValue(type { kind name ofType { kind name } }) }
          type { kind name ofType { kind name ofType { kind name } } }
        }
      }
    }
  }''';

  Future<GraphqlSchemaSnapshot> fetch({
    required String endpoint,
    Map<String, String> headers = const <String, String>{},
    GraphqlRequest? request,
  }) async {
    final result = await _http.execute(
      'introspection',
      GraphqlRequest(
        endpoint: endpoint,
        document: query,
        headers: headers,
        auth: request?.auth ?? const RequestAuthModel(),
        settings: request?.settings ?? const RequestSettingsModel(),
      ),
    );
    if (result.errors.isNotEmpty && result.data == null) {
      throw const GraphqlFailure(
        GraphqlFailureCategory.introspectionDenied,
        'The server denied introspection.',
      );
    }
    return GraphqlSchemaTools.parse(<String, Object?>{'data': result.data});
  }
}
