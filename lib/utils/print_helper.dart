import 'package:flutter/foundation.dart';

/// Debug-only logger. No-ops in release builds so response bodies, tokens, and
/// other sensitive data never reach device logs (`debugPrint` still emits in
/// release otherwise).
void printLine(dynamic item) {
  if (!kDebugMode) return;
  debugPrint('<==========================>');
  debugPrint('');
  debugPrint(item?.toString());
  debugPrint('');
  debugPrint('<==========================>');
}
