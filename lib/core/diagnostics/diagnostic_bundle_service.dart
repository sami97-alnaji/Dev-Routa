import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../security/secret_masker.dart';

abstract final class DiagnosticBundleService {
  static String sanitizedJson(Map<String, Object?> data) =>
      SecretMasker.redactText(const JsonEncoder.withIndent('  ').convert(data));

  static String sanitizedJsonLines(Iterable<Map<String, Object?>> records) =>
      records
          .map((item) => SecretMasker.redactText(jsonEncode(item)))
          .join('\n');

  static Future<File> export(
    Map<String, Object?> data, {
    String name = 'devroute-diagnostics.json',
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(path.join(directory.path, name));
    return file.writeAsString(sanitizedJson(data), flush: true);
  }

  static Future<File> exportText(String data, {required String name}) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(path.join(directory.path, name));
    return file.writeAsString(SecretMasker.redactText(data), flush: true);
  }
}
