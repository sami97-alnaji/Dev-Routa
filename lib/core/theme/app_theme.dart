import 'package:flutter/material.dart';

abstract final class AppTheme {
  /// The DevRoute palette keeps the workspace visually quiet so live traffic,
  /// errors, and the primary action are immediately recognisable.
  static const accent = Color(0xFF7AA7FF);
  static const live = Color(0xFF45D6A0);
  static const danger = Color(0xFFFF8B8B);
  static const _night = Color(0xFF0B0D12);
  static const _nightSurface = Color(0xFF141821);
  static const _nightElevated = Color(0xFF1B202B);
  static const _day = Color(0xFFF5F6F8);
  static const _daySurface = Color(0xFFFFFFFF);

  static ThemeData get dark => _theme(
    brightness: Brightness.dark,
    scheme: const ColorScheme.dark(
      primary: accent,
      onPrimary: Color(0xFF06152F),
      secondary: Color(0xFFB6C7FF),
      onSecondary: Color(0xFF101A32),
      error: danger,
      onError: Color(0xFF370003),
      surface: _nightSurface,
      onSurface: Color(0xFFF1F3F8),
      surfaceContainerHighest: _nightElevated,
      outline: Color(0xFF3E4655),
    ),
    scaffold: _night,
    surface: _nightSurface,
    elevated: _nightElevated,
  );

  static ThemeData get light => _theme(
    brightness: Brightness.light,
    scheme: const ColorScheme.light(
      primary: Color(0xFF1956B8),
      onPrimary: Colors.white,
      secondary: Color(0xFF315DAD),
      onSecondary: Colors.white,
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      surface: _daySurface,
      onSurface: Color(0xFF171A21),
      surfaceContainerHighest: Color(0xFFE7EAF0),
      outline: Color(0xFF737887),
    ),
    scaffold: _day,
    surface: _daySurface,
    elevated: const Color(0xFFF0F2F6),
  );

  static ThemeData _theme({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color scaffold,
    required Color surface,
    required Color elevated,
  }) {
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      visualDensity: VisualDensity.standard,
    );
    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displaySmall: base.textTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -1.1,
        ),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.7,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.15,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: isDark ? 0.5 : 0.7),
        space: 1,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: elevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        useIndicator: true,
        indicatorColor: scheme.primary.withValues(alpha: isDark ? 0.23 : 0.12),
        selectedIconTheme: IconThemeData(color: scheme.primary),
        selectedLabelTextStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: surface,
        indicatorColor: scheme.primary.withValues(alpha: isDark ? 0.23 : 0.12),
        labelTextStyle: WidgetStatePropertyAll(
          base.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.7)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: elevated,
        contentTextStyle: TextStyle(color: scheme.onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
