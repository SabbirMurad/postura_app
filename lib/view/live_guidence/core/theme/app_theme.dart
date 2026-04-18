import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// Builds light and dark [ThemeData] for Postura.
///
/// Usage:
///   theme: AppTheme.dark,
///   darkTheme: AppTheme.dark,
///   theme: AppTheme.light,
abstract final class AppTheme {
  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);
  static ThemeData get light => _build(AppColors.light, Brightness.light);

  static ThemeData _build(AppColorSet c, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'DMMono',

      // Colors.
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.primaryGreen,
        onPrimary: Colors.white,
        secondary: AppColors.lightTeal,
        onSecondary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        surface: c.surface,
        onSurface: c.textPrimary,
      ),

      scaffoldBackgroundColor: c.background,

      // AppBar.
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),

      // Cards.
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: c.border),
        ),
      ),

      // Dividers.
      dividerTheme: DividerThemeData(color: c.divider, thickness: 1),

      // Icons.
      iconTheme: IconThemeData(color: c.iconDefault),

      // Text.
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Syne',
          fontWeight: FontWeight.w800,
          color: c.textPrimary,
        ),
        bodyLarge: TextStyle(color: c.textPrimary),
        bodyMedium: TextStyle(color: c.textSecondary),
        bodySmall: TextStyle(color: c.textTertiary),
        labelSmall: TextStyle(
          color: c.textMuted,
          letterSpacing: 1.5,
          fontSize: 10,
        ),
      ),

      // Elevated buttons.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.confirmGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
