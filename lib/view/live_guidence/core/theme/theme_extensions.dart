import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Extension on BuildContext for easy access to Postura colors.
///
/// Usage:
///   context.colors.background
///   context.colors.textPrimary
///   context.isDark
extension PosturaTheme on BuildContext {
  /// Current mode-specific color set (light or dark).
  AppColorSet get colors => Theme.of(this).brightness == Brightness.dark
      ? AppColors.dark
      : AppColors.light;

  /// Whether the current theme is dark mode.
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
