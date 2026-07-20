enum HttpMethod { get, post, put, patch, delete, head, options }

enum RequestBodyType {
  none,
  json,
  rawText,
  xml,
  html,
  formData,
  multipart,
  binary,
  urlEncoded,
}

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
    this.parentFolderId,
  });
  final String collectionId;
  final String name;
  final String? parentFolderId;
}

class RequestHeaderModel {
  const RequestHeaderModel({
    required this.key,
    required this.value,
    this.enabled = true,
    this.isSecret = false,
    this.secretRef,
  });
  final String key;
  final String value;
  final bool enabled;
  final bool isSecret;

  /// A secure-storage key. Secret values are never persisted in SQLite.
  final String? secretRef;
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
  const RequestBodyModel({
    required this.type,
    required this.content,
    this.contentType,
    this.filePath,
  });
  final RequestBodyType type;
  final String content;
  final String? contentType;
  final String? filePath;
}

class RequestAuthModel {
  const RequestAuthModel({
    this.type = AuthType.none,
    this.username = '',
    this.passwordSecretRef,
    this.tokenSecretRef,
    this.apiKeyName = '',
    this.apiKeySecretRef,
  });
  final AuthType type;
  final String username;
  final String? passwordSecretRef;
  final String? tokenSecretRef;
  final String apiKeyName;
  final String? apiKeySecretRef;
}

class RequestSettingsModel {
  const RequestSettingsModel({
    this.connectTimeoutMs = 15000,
    this.sendTimeoutMs = 30000,
    this.receiveTimeoutMs = 30000,
    this.followRedirects = true,
    this.maxRedirects = 5,
    this.verifyCertificates = true,
  });
  final int connectTimeoutMs;
  final int sendTimeoutMs;
  final int receiveTimeoutMs;
  final bool followRedirects;
  final int maxRedirects;
  final bool verifyCertificates;
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
    this.auth = const RequestAuthModel(),
    this.settings = const RequestSettingsModel(),
    this.collectionId,
    this.folderId,
    this.sortOrder = 0,
  });
  final String name;
  final String url;
  final HttpMethod method;
  final List<RequestHeaderModel> headers;
  final List<RequestQueryParamModel> queryParams;
  final RequestBodyModel? body;
  final AuthType authType;
  final RequestAuthModel auth;
  final RequestSettingsModel settings;
  final String? collectionId;
  final String? folderId;
  final int sortOrder;
}

class EnvironmentModel extends TimestampedEntity {
  const EnvironmentModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
    this.kind = EnvironmentKind.custom,
    this.workspaceId,
    this.isActive = false,
  });
  final String name;
  final EnvironmentKind kind;
  final String? workspaceId;
  final bool isActive;
}

enum EnvironmentKind { local, development, staging, production, custom }

class EnvironmentVariableModel {
  const EnvironmentVariableModel({
    this.id = '',
    this.environmentId = '',
    required this.key,
    required this.value,
    this.isSecret = false,
    this.secretRef,
    this.enabled = true,
    this.sortOrder = 0,
  });
  final String id;
  final String environmentId;
  final String key;
  final String value;
  final bool isSecret;
  final String? secretRef;
  final bool enabled;
  final int sortOrder;
}

class WorkspaceSettingsModel {
  const WorkspaceSettingsModel({
    this.historyRetentionDays = 30,
    this.historyMaximumCount = 1000,
    this.responsePreviewBytes = 1048576,
    this.productionStrictMode = true,
  });
  final int historyRetentionDays;
  final int historyMaximumCount;
  final int responsePreviewBytes;
  final bool productionStrictMode;
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
    this.errorCategory,
    this.cookies = const <String>[],
    this.isTruncated = false,
  });
  final int? statusCode;
  final String? statusMessage;
  final Map<String, String> headers;
  final String body;
  final int durationMs;
  final int sizeBytes;
  final DateTime timestamp;
  final String? error;
  final String? errorCategory;
  final List<String> cookies;
  final bool isTruncated;
}

class TokenCandidate {
  const TokenCandidate({required this.jsonPath, required this.maskedValue});
  final String jsonPath;
  final String maskedValue;
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
