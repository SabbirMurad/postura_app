import '../../../core/constants/detection_constants.dart';

/// Sliding window that tracks the last [DetectionConstants.windowSize]
/// frame results and checks whether the confirmation threshold is met.
class RollingWindow {
  final List<bool> _results = [];

  /// Add the latest per-frame result (true = both objects detected).
  void add(bool result) {
    _results.add(result);
    if (_results.length > DetectionConstants.windowSize) {
      _results.removeAt(0);
    }
  }

  /// Whether the confirmation threshold (5/6) has been reached.
  bool get isConfirmed {
    if (_results.length < DetectionConstants.requiredPositives) return false;
    final positives = _results.where((r) => r).length;
    return positives >= DetectionConstants.requiredPositives;
  }

  /// Whether at least one recent frame had a partial or full detection,
  /// but the window is not yet confirmed.
  bool get hasPartialActivity {
    if (_results.isEmpty) return false;
    return _results.any((r) => r) && !isConfirmed;
  }

  /// Clear all stored results (e.g. on sustained detection dropout).
  void reset() => _results.clear();

  /// Number of results currently in the window.
  int get length => _results.length;
}
