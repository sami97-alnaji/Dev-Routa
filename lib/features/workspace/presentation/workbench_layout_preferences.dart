import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class WorkbenchLayoutSnapshot {
  const WorkbenchLayoutSnapshot({
    this.sidebarWidth = 252,
    this.sidebarCollapsed = false,
    this.requestEditorHeight = 292,
  });

  final double sidebarWidth;
  final bool sidebarCollapsed;
  final double requestEditorHeight;
}

/// Small local-only desktop preference store. Layout belongs to the device,
/// not a workspace record or a database migration.
class WorkbenchLayoutPreferences {
  static const _fileName = 'workbench-layout.json';

  static Future<WorkbenchLayoutSnapshot> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return const WorkbenchLayoutSnapshot();
      final raw = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return WorkbenchLayoutSnapshot(
        sidebarWidth: _clamp(raw['sidebarWidth'], 180, 420, 252),
        sidebarCollapsed: raw['sidebarCollapsed'] == true,
        requestEditorHeight: _clamp(raw['requestEditorHeight'], 180, 520, 292),
      );
    } on Object {
      return const WorkbenchLayoutSnapshot();
    }
  }

  static Future<void> save(WorkbenchLayoutSnapshot value) async {
    try {
      final file = await _file();
      await file.writeAsString(
        jsonEncode(<String, Object>{
          'sidebarWidth': value.sidebarWidth.clamp(180, 420),
          'sidebarCollapsed': value.sidebarCollapsed,
          'requestEditorHeight': value.requestEditorHeight.clamp(180, 520),
        }),
      );
    } on Object {
      // A workbench remains usable when a platform cannot persist local UI.
    }
  }

  static Future<File> _file() async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}${Platform.pathSeparator}$_fileName');
  }

  static double _clamp(Object? value, double min, double max, double fallback) {
    final number = value is num ? value.toDouble() : fallback;
    return number.clamp(min, max);
  }
}
