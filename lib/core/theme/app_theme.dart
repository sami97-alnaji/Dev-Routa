import 'package:flutter/material.dart';

abstract final class DevRouteColors {
  static const background = Color(0xFF171717);
  static const sidebar = Color(0xFF111111);
  static const panel = Color(0xFF1E1E1E);
  static const panelSecondary = Color(0xFF242424);
  static const hover = Color(0xFF2B2B2B);
  static const border = Color(0xFF343434);
  static const primaryText = Color(0xFFF2F2F2);
  static const secondaryText = Color(0xFFA8A8A8);
  static const accent = Color(0xFFFF6C37);
  static const success = Color(0xFF39B980);
}

abstract final class DevRouteSpacing {
  static const xs = 4.0, sm = 8.0, md = 12.0, lg = 16.0, xl = 24.0;
}

abstract final class AppTheme {
  static const _seed = DevRouteColors.accent;

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: DevRouteColors.background,
    cardTheme: const CardThemeData(
      margin: EdgeInsets.zero,
      color: DevRouteColors.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
    ),
    dividerColor: DevRouteColors.border,
    appBarTheme: const AppBarTheme(
      backgroundColor: DevRouteColors.panel,
      elevation: 0,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: DevRouteColors.panelSecondary,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
        borderSide: BorderSide(color: DevRouteColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
        borderSide: BorderSide(color: DevRouteColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
        borderSide: BorderSide(color: DevRouteColors.accent),
      ),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbVisibility: WidgetStatePropertyAll(true),
      thickness: WidgetStatePropertyAll(7),
      radius: Radius.circular(3),
      thumbColor: WidgetStatePropertyAll(DevRouteColors.border),
      trackColor: WidgetStatePropertyAll(DevRouteColors.panel),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 34),
        padding: const EdgeInsets.symmetric(horizontal: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 34),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        side: const BorderSide(color: DevRouteColors.border),
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      dividerColor: DevRouteColors.border,
      indicatorColor: DevRouteColors.accent,
      labelColor: DevRouteColors.primaryText,
      unselectedLabelColor: DevRouteColors.secondaryText,
      labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 13),
      bodySmall: TextStyle(fontSize: 12, color: DevRouteColors.secondaryText),
    ),
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: _seed),
  );
}
