import 'package:flutter/widgets.dart';

import 'app.dart';
import 'core/storage/database_schema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();
  await database.customSelect('SELECT 1').get();
  runApp(DevRouteApp(database: database));
}
