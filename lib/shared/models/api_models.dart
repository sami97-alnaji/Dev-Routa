enum HttpMethod { get, post, put, patch, delete, head, options }

enum RequestBodyType { none, json, rawText, formData, urlEncoded }

enum AuthType { none, bearer, basic, apiKeyHeader, apiKeyQuery }

class TimestampedEntity {
  const TimestampedEntity({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class WorkspaceModel extends TimestampedEntity {
  const WorkspaceModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
  });
  final String name;
}

class CollectionModel extends TimestampedEntity {
  const CollectionModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.workspaceId,
    required this.name,
  });
  final String workspaceId;
  final String name;
}

class FolderModel extends TimestampedEntity {
  const FolderModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.collectionId,
    required this.name,
  });
  final String collectionId;
  final String name;
}

class RequestHeaderModel {
  const RequestHeaderModel({
    required this.key,
    required this.value,
    this.enabled = true,
    this.isSecret = false,
  });
  final String key;
  final String value;
  final bool enabled;
  final bool isSecret;
}

class RequestQueryParamModel {
  const RequestQueryParamModel({
    required this.key,
    required this.value,
    this.enabled = true,
  });
  final String key;
  final String value;
  final bool enabled;
}

class RequestBodyModel {
  const RequestBodyModel({required this.type, required this.content});
  final RequestBodyType type;
  final String content;
}

class ApiRequestModel extends TimestampedEntity {
  const ApiRequestModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
    required this.url,
    required this.method,
    this.headers = const [],
    this.queryParams = const [],
    this.body,
    this.authType = AuthType.none,
  });
  final String name;
  final String url;
  final HttpMethod method;
  final List<RequestHeaderModel> headers;
  final List<RequestQueryParamModel> queryParams;
  final RequestBodyModel? body;
  final AuthType authType;
}

class EnvironmentModel extends TimestampedEntity {
  const EnvironmentModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
  });
  final String name;
}

class EnvironmentVariableModel {
  const EnvironmentVariableModel({
    required this.key,
    required this.value,
    this.isSecret = false,
    this.secretRef,
  });
  final String key;
  final String value;
  final bool isSecret;
  final String? secretRef;
}

class ApiResponseModel {
  const ApiResponseModel({
    required this.statusCode,
    required this.statusMessage,
    required this.headers,
    required this.body,
    required this.durationMs,
    required this.sizeBytes,
    required this.timestamp,
    this.error,
  });
  final int? statusCode;
  final String? statusMessage;
  final Map<String, String> headers;
  final String body;
  final int durationMs;
  final int sizeBytes;
  final DateTime timestamp;
  final String? error;
}

class ResponseSnapshotModel extends TimestampedEntity {
  const ResponseSnapshotModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.requestId,
    required this.response,
  });
  final String requestId;
  final ApiResponseModel response;
}

class RequestHistoryModel extends TimestampedEntity {
  const RequestHistoryModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.requestId,
    required this.responseSnapshotId,
  });
  final String requestId;
  final String responseSnapshotId;
}

class WebSocketSessionModel extends TimestampedEntity {
  const WebSocketSessionModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.url,
  });
  final String url;
}

class AiAnalysisModel extends TimestampedEntity {
  const AiAnalysisModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.summary,
    required this.consentGranted,
  });
  final String summary;
  final bool consentGranted;
}
