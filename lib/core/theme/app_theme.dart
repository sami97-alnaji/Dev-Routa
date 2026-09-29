import 'package:flutter/material.dart';

/// Presentation-only appearance preference for the desktop workbench.
abstract final class DevRouteAppearance {
  static final mode = ValueNotifier<ThemeMode>(ThemeMode.system);
}

/// Compact developer-tool tokens. The application keeps Material for behavior,
/// while its visual defaults are deliberately closer to a native workbench.
abstract final class AppTheme {
  static const accent = Color(0xFF6E8CFF);
  static const live = Color(0xFF36C58A);
  static const danger = Color(0xFFE76A76);

  static ThemeData get dark => _create(
    Brightness.dark,
    scaffold: const Color(0xFF111318),
    surface: const Color(0xFF181B22),
    field: const Color(0xFF20242D),
    outline: const Color(0xFF343A46),
    onSurface: const Color(0xFFE7EAF0),
  );

  static ThemeData get light => _create(
    Brightness.light,
    scaffold: const Color(0xFFF5F6F8),
    surface: const Color(0xFFFCFCFD),
    field: const Color(0xFFF0F2F5),
    outline: const Color(0xFFD5D9E1),
    onSurface: const Color(0xFF1B1F27),
  );

  static ThemeData _create(
    Brightness brightness, {
    required Color scaffold,
    required Color surface,
    required Color field,
    required Color outline,
    required Color onSurface,
  }) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
      surface: surface,
      onSurface: onSurface,
      error: danger,
      outline: outline,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      // Keep controls dense enough for a tool that is used all day.  The
      // surrounding workbench supplies hierarchy, not oversized M3 spacing.
      visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
      fontFamily: 'Segoe UI',
    );
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide(color: outline),
    );
    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          letterSpacing: -.2,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        labelSmall: base.textTheme.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: .25,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 40,
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
          side: BorderSide(color: outline),
        ),
      ),
      dividerTheme: DividerThemeData(color: outline, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: field,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: accent, width: 1.4),
        ),
        errorBorder: border.copyWith(
          borderSide: const BorderSide(color: danger),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 32),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 32),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          side: BorderSide(color: outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(30, 30),
          padding: const EdgeInsets.all(6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        dense: true,
        minVerticalPadding: 0,
        horizontalTitleGap: 9,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.onSurface,
        unselectedLabelColor: scheme.onSurfaceVariant,
        indicatorColor: accent,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
        dividerColor: outline,
      ),
      chipTheme: base.chipTheme.copyWith(
        side: BorderSide(color: outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        labelStyle: const TextStyle(fontSize: 12),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? field : const Color(0xFF2B303A),
        contentTextStyle: TextStyle(color: dark ? onSurface : Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
    );
  }
}
