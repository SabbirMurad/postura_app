import 'dart:math';
import 'package:flutter/material.dart';
import 'package:posture_detector_app/main.dart';
import 'package:posture_detector_app/utils/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Light Nudges V2 Service
/// Handles progression-based nudges after Module 1 quiz completion
class LightNudgesService {
  static final LightNudgesService instance = LightNudgesService._internal();
  factory LightNudgesService() => instance;
  LightNudgesService._internal();

  // SharedPreferences keys
  static const String _keyNudgesActivated = 'nudges_activated';
  static const String _keyLastWednesdayNudge = 'last_wednesday_nudge';
  static const String _keyLastSaturdayNudge = 'last_saturday_nudge';
  static const String _keyLastAppOpen = 'last_app_open';

  final Random _random = Random();

  /// Check if nudges should be shown and display if conditions are met
  Future<void> checkAndShowNudge({
    required bool courseComplete,
    required int highestModuleIndex,
  }) async {
    // Don't show if course is complete
    if (courseComplete) return;

    final prefs = await SharedPreferences.getInstance();

    // Check if nudges are activated
    final nudgesActivated = prefs.getBool(_keyNudgesActivated) ?? false;
    if (!nudgesActivated) return;

    // Check if user has been inactive for more than 7 days
    final lastOpen = prefs.getInt(_keyLastAppOpen) ?? 0;

    // Update last app open timestamp AFTER reading the previous value
    await prefs.setInt(_keyLastAppOpen, DateTime.now().millisecondsSinceEpoch);
    final daysSinceLastOpen = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(lastOpen))
        .inDays;

    if (daysSinceLastOpen > 7) return;

    // Check if current time matches a nudge slot
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentWeekday = now.weekday;

    // Wednesday = 3, Saturday = 6
    bool isWednesdaySlot = currentWeekday == 3 && currentHour == 10;
    bool isSaturdaySlot = currentWeekday == 6 && currentHour == 10;

    if (!isWednesdaySlot && !isSaturdaySlot) return;

    // Check if nudge already shown this week for this slot
    if (isWednesdaySlot) {
      final lastWednesday = prefs.getString(_keyLastWednesdayNudge) ?? '';
      if (_isSameWeek(lastWednesday, now)) return;
    }

    if (isSaturdaySlot) {
      final lastSaturday = prefs.getString(_keyLastSaturdayNudge) ?? '';
      if (_isSameWeek(lastSaturday, now)) return;
    }

    // All conditions met - show nudge
    final nudgeText = _getNudgeText(highestModuleIndex);
    _showNudgeBanner(nudgeText);

    // Update last shown timestamp
    final dateKey = _getWeekKey(now);
    if (isWednesdaySlot) {
      await prefs.setString(_keyLastWednesdayNudge, dateKey);
    } else if (isSaturdaySlot) {
      await prefs.setString(_keyLastSaturdayNudge, dateKey);
    }
  }

  /// Activate nudges after Module 1 quiz completion
  Future<void> activateNudges() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNudgesActivated, true);
    debugPrint('Light Nudges V2 activated');
  }

  /// Check if nudges are activated
  Future<bool> areNudgesActivated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNudgesActivated) ?? false;
  }

  /// Get appropriate nudge text based on highest module index
  String _getNudgeText(int highestModuleIndex) {
    final nudges = _getNudgesForModule(highestModuleIndex);
    return nudges[_random.nextInt(nudges.length)];
  }

  /// Get nudge messages for a specific module index
  List<String> _getNudgesForModule(int moduleIndex) {
    switch (moduleIndex) {
      case 0: // Module 1 started
        return [l10n.genNudgeModule1a, l10n.genNudgeModule1b];
      case 1: // Module 2 started
        return [l10n.genNudgeModule2a, l10n.genNudgeModule2b];
      case 2: // Module 3 started
        return [l10n.genNudgeModule3a, l10n.genNudgeModule3b];
      case 3: // Module 4 started
        return [l10n.genNudgeModule4a, l10n.genNudgeModule4b];
      case 4: // Module 5 started
        return [l10n.genNudgeModule5a, l10n.genNudgeModule5b];
      case 5: // Module 6 started
        return [l10n.genNudgeModule6a, l10n.genNudgeModule6b];
      case 6: // Module 7 started
        return [l10n.genNudgeModule7a, l10n.genNudgeModule7b];
      default:
        return [l10n.genNudgeModule1a];
    }
  }

  /// Show in-app nudge banner
  void _showNudgeBanner(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.lightbulb_outline,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 30),
        backgroundColor: Colors.blue.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        dismissDirection: DismissDirection.horizontal,
        animation: const AlwaysStoppedAnimation(1),
      ),
    );
  }

  /// Check if two date strings represent the same calendar week
  bool _isSameWeek(String dateKey, DateTime currentDate) {
    if (dateKey.isEmpty) return false;

    try {
      final parts = dateKey.split('-');
      if (parts.length != 2) return false;

      final year = int.parse(parts[0]);
      final week = int.parse(parts[1]);

      final currentWeek = _getWeekNumber(currentDate);
      final currentYear = currentDate.year;

      return year == currentYear && week == currentWeek;
    } catch (e) {
      return false;
    }
  }

  /// Get week key in format "YYYY-WW"
  String _getWeekKey(DateTime date) {
    final weekNumber = _getWeekNumber(date);
    return '${date.year}-$weekNumber';
  }

  /// Calculate ISO week number
  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay + firstDayOfYear.weekday) / 7).ceil();
  }

  /// Reset nudges (for testing or user request)
  Future<void> resetNudges() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyNudgesActivated);
    await prefs.remove(_keyLastWednesdayNudge);
    await prefs.remove(_keyLastSaturdayNudge);
    debugPrint('Light Nudges V2 reset');
  }
}
