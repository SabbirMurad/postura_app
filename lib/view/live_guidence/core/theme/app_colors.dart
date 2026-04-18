import 'package:flutter/material.dart';

/// Centralized color system for Postura.
///
/// All colors used across the app are defined here.
/// To change a color, update it in ONE place — it reflects everywhere.
///
/// Usage:
///   AppColors.primaryGreen
///   AppColors.dark.background
///   AppColors.light.background
abstract final class AppColors {
  // ─────────────────────────────────────────────
  // Brand Colors (same in light & dark)
  // ─────────────────────────────────────────────
  static const Color primaryGreen = Color.fromARGB(255, 33, 128, 230);
  static const Color lightTeal = Color.fromARGB(255, 70, 141, 218);
  static const Color darkForest = Color(0xFF0C1A14);
  static const Color deepGreen = Color.fromARGB(255, 9, 102, 201);
  static const Color confirmGreen = Color.fromARGB(255, 33, 128, 230);
  static const Color successGreen = Color.fromARGB(255, 33, 128, 230);

  // ─────────────────────────────────────────────
  // Functional Colors (same in light & dark)
  // ─────────────────────────────────────────────
  static const Color error = Color(0xFFE53935);
  static const Color amber = Color(0xFFFFA726);

  // ─────────────────────────────────────────────
  // Mode-specific color sets
  // ─────────────────────────────────────────────
  static const AppColorSet dark = AppColorSet(
    background: Color(0xFF080A0D),
    surface: Color(0xFF0E1318),
    surfaceVariant: Color(0xFF1A1E24),
    cardBackground: Color(0x80000000), // black 50%
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xB3FFFFFF), // white 70%
    textTertiary: Color(0x8AFFFFFF), // white 54%
    textMuted: Color(0x4DFFFFFF), // white 30%
    textFaint: Color(0x1AFFFFFF), // white 10%
    border: Color(0x14FFFFFF), // white 8%
    divider: Color(0x1AFFFFFF), // white 10%
    overlay: Color(0xDD000000), // black 87%
    iconDefault: Color(0xFFFFFFFF),
    iconMuted: Color(0x61FFFFFF), // white 38%
    statusBarText: Color(0xB3FFFFFF),
    shimmer: Color(0x80FFFFFF),
  );

  static const AppColorSet light = AppColorSet(
    background: Color(0xFFF5F7F6),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFEEF1F0),
    cardBackground: Color(0xCCFFFFFF), // white 80%
    textPrimary: Color(0xFF0A0A0A),
    textSecondary: Color(0xB30A0A0A), // black 70%
    textTertiary: Color(0x8A0A0A0A), // black 54%
    textMuted: Color(0x4D0A0A0A), // black 30%
    textFaint: Color(0x1A0A0A0A), // black 10%
    border: Color(0x1A000000), // black 10%
    divider: Color(0x1A000000),
    overlay: Color(0xCCFFFFFF), // white 80%
    iconDefault: Color(0xFF1A1A1A),
    iconMuted: Color(0x61000000), // black 38%
    statusBarText: Color(0xB3000000),
    shimmer: Color(0x33000000),
  );
}

/// A set of colors that change between light and dark mode.
class AppColorSet {
  const AppColorSet({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.cardBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textMuted,
    required this.textFaint,
    required this.border,
    required this.divider,
    required this.overlay,
    required this.iconDefault,
    required this.iconMuted,
    required this.statusBarText,
    required this.shimmer,
  });

  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color cardBackground;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textMuted;
  final Color textFaint;
  final Color border;
  final Color divider;
  final Color overlay;
  final Color iconDefault;
  final Color iconMuted;
  final Color statusBarText;
  final Color shimmer;
}
