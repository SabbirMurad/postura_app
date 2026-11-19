import 'package:posture_detector_app/utils/l10n.dart';

String prettyDate(String? isoDate) {
  if (isoDate == null || isoDate.isEmpty) return '';
  try {
    return shortDate(DateTime.parse(isoDate).toLocal());
  } catch (_) {
    return isoDate;
  }
}

/// "18 Nov 2026, 2:42 PM" in the phone's local time zone, for an ISO timestamp
/// from the server. Returns '' when there is no date.
String prettyDateTime(String? isoDate) {
  if (isoDate == null || isoDate.isEmpty) return '';
  try {
    final dt = DateTime.parse(isoDate).toLocal();
    final minute = dt.minute.toString().padLeft(2, '0');
    // English keeps the 12-hour clock; German, Spanish and Dutch use 24 hours.
    final String time;
    if (l10n.localeName == 'en') {
      final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final period = dt.hour < 12 ? 'AM' : 'PM';
      time = '$hour12:$minute $period';
    } else {
      time = '${dt.hour.toString().padLeft(2, '0')}:$minute';
    }
    return '${shortDate(dt)}, $time';
  } catch (_) {
    return isoDate;
  }
}

/// "18 Nov 2026" in the selected language (day, short month name, year).
String shortDate(DateTime dt) {
  final day = dt.day.toString().padLeft(2, '0');
  return l10n.genDateDayMonthYear(day, _monthName(dt.month), dt.year.toString());
}

String _monthName(int month) {
  final months = [
    l10n.genMonthJan, l10n.genMonthFeb, l10n.genMonthMar, l10n.genMonthApr,
    l10n.genMonthMay, l10n.genMonthJun, l10n.genMonthJul, l10n.genMonthAug,
    l10n.genMonthSep, l10n.genMonthOct, l10n.genMonthNov, l10n.genMonthDec,
  ];
  return months[month - 1];
}
