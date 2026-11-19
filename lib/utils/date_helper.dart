String prettyDate(String? isoDate) {
  if (isoDate == null || isoDate.isEmpty) return '';
  try {
    final dt = DateTime.parse(isoDate).toLocal();
    final day = dt.day.toString().padLeft(2, '0');
    final month = _monthName(dt.month);
    final year = dt.year;
    return '$day $month $year';
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
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '${prettyDate(isoDate)}, $hour12:$minute $period';
  } catch (_) {
    return isoDate;
  }
}

String _monthName(int month) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return months[month - 1];
}
