import 'dart:collection';
import 'dart:math';

import '../../../core/constants/pose_constants.dart';
import 'one_euro_filter.dart';
import 'pose_landmark.dart';

/// Manages One Euro filters for all 8 landmarks × 2 axes (16 filters total).
/// Also tracks rolling stddev for stability detection.
class LandmarkSmoother {
  /// One Euro filter per landmark per axis: [BodyPart index][0=x, 1=y].
  final Map<BodyPart, List<OneEuroFilter>> _filters = {};

  /// Rolling window of recent positions for stddev calculation.
  final Map<BodyPart, Queue<(double x, double y)>> _history = {};

  LandmarkSmoother() {
    for (final part in BodyPart.values) {
      _filters[part] = [OneEuroFilter(), OneEuroFilter()];
      _history[part] = Queue();
    }
  }

  /// Smooth a list of raw landmarks and return smoothed versions.
  /// Resets filter for any landmark that drops below confidence threshold.
  List<PoseLandmark> smooth(List<PoseLandmark> raw, int timestampMs) {
    final smoothed = <PoseLandmark>[];

    for (final landmark in raw) {
      final filters = _filters[landmark.part]!;
      final history = _history[landmark.part]!;

      if (!landmark.isReliable) {
        // Reset filters when confidence drops — prevents stale state.
        filters[0].reset();
        filters[1].reset();
        history.clear();
        smoothed.add(landmark);
        continue;
      }

      // Apply One Euro filter to x and y independently.
      final sx = filters[0].filter(timestampMs, landmark.x);
      final sy = filters[1].filter(timestampMs, landmark.y);

      // Track history for stability detection.
      history.addLast((sx, sy));
      while (history.length > PoseConstants.stabilityWindow) {
        history.removeFirst();
      }

      smoothed.add(landmark.copyWith(x: sx, y: sy));
    }

    return smoothed;
  }

  /// Whether the pose is stable (low stddev across recent frames).
  ///
  /// Requires at least 6/8 landmarks to have enough history AND be within
  /// stddev threshold. Matches the 6/8 reliable threshold used elsewhere
  /// — a fresh smoother (e.g., Step 3's new detector) reaches stability
  /// in ~10 frames instead of being blocked by any single bad landmark.
  bool get isStable {
    int stableCount = 0;
    for (final part in BodyPart.values) {
      final history = _history[part]!;
      if (history.length < PoseConstants.stabilityWindow) continue;
      if (_computeStdDev(history) <= PoseConstants.stabilityStdDevThreshold) {
        stableCount++;
      }
    }
    return stableCount >= 6;
  }

  /// Compute combined stddev of x and y over the history window.
  double _computeStdDev(Queue<(double, double)> history) {
    if (history.isEmpty) return double.infinity;

    double sumX = 0, sumY = 0;
    for (final (x, y) in history) {
      sumX += x;
      sumY += y;
    }
    final meanX = sumX / history.length;
    final meanY = sumY / history.length;

    double varX = 0, varY = 0;
    for (final (x, y) in history) {
      varX += (x - meanX) * (x - meanX);
      varY += (y - meanY) * (y - meanY);
    }
    varX /= history.length;
    varY /= history.length;

    return sqrt(varX + varY);
  }

  /// Reset all filters and history.
  void reset() {
    for (final part in BodyPart.values) {
      _filters[part]![0].reset();
      _filters[part]![1].reset();
      _history[part]!.clear();
    }
  }
}
