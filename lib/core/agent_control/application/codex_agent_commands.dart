import 'app_command.dart';

class AppCapabilitiesCommand implements AppCommand<Map<String, Object?>> {
  const AppCapabilitiesCommand();
  @override
  String get commandType => 'app.capabilities';
}

class GrpcHistorySearchCommand implements AppCommand<Map<String, Object?>> {
  const GrpcHistorySearchCommand();
  @override
  String get commandType => 'grpc.history.search';
}
