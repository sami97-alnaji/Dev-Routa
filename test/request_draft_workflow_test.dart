import 'package:devroute_ai_studio/core/network/dio_request_execution_service.dart';
import 'package:devroute_ai_studio/core/storage/database_schema.dart';
import 'package:devroute_ai_studio/core/storage/local_workspace_repository.dart';
import 'package:devroute_ai_studio/features/requests/presentation/request_workflow_cubit.dart';
import 'package:devroute_ai_studio/shared/models/api_models.dart';
import 'package:devroute_ai_studio/shared/services/service_interfaces.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _Secrets implements SecureStorageService {
  final values = <String, String>{};
  @override
  Future<void> deleteSecret(String key) async => values.remove(key);
  @override
  Future<String?> readSecret(String key) async => values[key];
  @override
  Future<void> writeSecret(String key, String value) async =>
      values[key] = value;
}

void main() {
  test('multiple request drafts restore as independent dirty tabs', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = LocalWorkspaceRepository(database, _Secrets());
    final now = DateTime.now();
    await repository.saveDraft(
      ApiRequestModel(
        id: 'one',
        createdAt: now,
        updatedAt: now,
        name: 'One',
        url: 'https://one.test',
        method: HttpMethod.get,
      ),
    );
    await repository.saveDraft(
      ApiRequestModel(
        id: 'two',
        createdAt: now,
        updatedAt: now,
        name: 'Two',
        url: 'https://two.test',
        method: HttpMethod.post,
      ),
    );
    final cubit = RequestWorkflowCubit(
      DioRequestExecutionService(),
      repository,
    );
    await cubit.restoreDrafts();
    expect(cubit.state.tabs.map((item) => item.id), <String>['one', 'two']);
    expect(cubit.state.hasAnyDirty, isTrue);
    cubit.selectTab(1);
    expect(cubit.state.request.name, 'Two');
    await cubit.closeActive(discardChanges: true);
    expect(cubit.state.tabs, hasLength(1));
    await cubit.close();
    await database.close();
  });
}
