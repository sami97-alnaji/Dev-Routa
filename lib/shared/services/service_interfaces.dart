import '../models/api_models.dart';

abstract interface class RequestExecutionService {
  Future<ApiResponseModel> execute(ApiRequestModel request);
}

abstract interface class WebSocketConnectionService {
  Stream<String> connect(String url);
  Future<void> send(String message);
  Future<void> disconnect();
}

abstract interface class LocalDatabaseService {
  Future<void> initialize();
  Future<void> clearHistory({String? workspaceId});
}

abstract interface class SecureStorageService {
  Future<void> writeSecret(String key, String value);
  Future<String?> readSecret(String key);
  Future<void> deleteSecret(String key);
}

abstract interface class AiAssistantService {
  Future<AiAnalysisModel> analyze(
    ApiResponseModel response, {
    required bool consentGranted,
  });
}

abstract interface class EnvironmentVariableResolver {
  String resolve(String value, EnvironmentModel? environment);
}

abstract interface class RequestHistoryService {
  Future<void> record(ApiRequestModel request, ApiResponseModel response);
  Future<void> clearAll();
}
