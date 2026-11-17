import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Deletes cached files the app no longer needs.
///
/// The capture screen writes each posture photo to the cache
/// (`posture_photos/`), uploads use a compressed copy written to the same
/// place, and shared PDF reports are written there too. Nothing removed them,
/// so posture photos stayed on the device indefinitely.
///
/// Anything in the app's cache or temp directory that has not been modified
/// for [maxAge] is removed. Both are locations the OS may clear at any time,
/// so nothing there is relied on to exist.
class CacheCleaner {
  const CacheCleaner._();

  static const Duration maxAge = Duration(days: 30);

  /// Best-effort and silent: a file that cannot be read or deleted is skipped.
  /// Not awaited at startup, so it never delays the first frame.
  static Future<void> purgeOldFiles() async {
    final cutoff = DateTime.now().subtract(maxAge);

    // Android: both are the app cache dir. iOS: Library/Caches and tmp/ (the
    // native capture engine writes posture photos under tmp/).
    final roots = <String>{};
    try {
      roots.add((await getTemporaryDirectory()).path);
    } catch (_) {}
    try {
      roots.add(Directory.systemTemp.path);
    } catch (_) {}

    var removed = 0;
    for (final root in roots) {
      removed += await _purge(Directory(root), cutoff);
    }

    if (removed > 0) {
      debugPrint('CacheCleaner: removed $removed cached file(s) older than ${maxAge.inDays} days');
    }
  }

  static Future<int> _purge(Directory root, DateTime cutoff) async {
    var removed = 0;
    try {
      if (!await root.exists()) return 0;

      await for (final entity in root.list(recursive: true, followLinks: false)) {
        if (entity is! File) continue;
        try {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoff)) {
            await entity.delete();
            removed++;
          }
        } catch (_) {
          // In use, already gone, or not ours to delete: skip it.
        }
      }
    } catch (_) {
      // Listing failed part-way; whatever was removed so far stays removed.
    }
    return removed;
  }
}
