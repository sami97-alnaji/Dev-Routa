import '../../shared/services/service_interfaces.dart';
import 'database_schema.dart';

class DriftLocalDatabaseService implements LocalDatabaseService {
  DriftLocalDatabaseService(this._database);

  final AppDatabase _database;

  @override
  Future<void> clearHistory({String? workspaceId}) async {
    // Workspace filtering is added once requests are joined to collections.
    await _database.delete(_database.requestHistory).go();
    await _database.delete(_database.responseSnapshots).go();
  }

  @override
  Future<void> initialize() async {
    await _database.customSelect('SELECT 1').get();
  }
}
