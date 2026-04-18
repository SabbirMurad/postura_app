import 'dart:math';

/// Constants governing Step 3 ROSA scoring, autocapture, and luminance.
///
/// Thresholds are from the validated Python script — 100% ±1 congruence
/// on 71 photos against Cornell/Sonne 2011 reference scores.
/// Do NOT tune these values without re-running Python validation.
abstract final class RosaConstants {
  // ---------------------------------------------------------------------------
  // Tunable Scoring Thresholds — mirror of Python `T` dict
  // ---------------------------------------------------------------------------

  /// Knee angle neutral range (degrees).
  static const double kneeNeutralMin = 80;
  static const double kneeNeutralMax = 100;

  /// Legacy threshold — NOT referenced by the validated scorer.
  /// Kept to mirror Python `T` dict exactly.
  static const double kneeNoFloor = 110;

  /// Minimum likelihood for ankle/knee landmarks to be used in knee angle.
  static const double ankleMinVisibility = 0.50;

  /// Legacy thresholds — NOT referenced by the validated scorer.
  /// Kept to mirror Python `T` dict exactly.
  static const double trunkNeutralMin = 80;
  static const double trunkNeutralMax = 105;

  /// Legacy threshold — NOT referenced by the validated scorer.
  /// Kept to mirror Python `T` dict exactly.
  static const double shoulderShrugThreshold = 0.05;

  /// Legacy neck-flexion thresholds — NOT referenced by validated scorer.
  /// Validated monitor branching uses normalized offsets, not degrees.
  static const double neckFlexionMild = 15;
  static const double neckFlexionSevere = 35;

  /// Forward-head threshold (normalized `shoulder.x - ear.x`).
  static const double forwardHeadThreshold = 0.04;

  /// Wrist-extension thresholds (normalized `elbow.y - wrist.y`).
  static const double wristExtensionMild = 0.03;
  static const double wristExtensionSevere = 0.07;

  /// Mouse lateral reach threshold (normalized `|wrist.x - shoulder.x|`).
  /// Validated Python value — do NOT change without re-running 71-photo suite.
  static const double mouseReachThreshold = 0.18;

  /// Duration modifier added once inside chair score (>1 hr seated work).
  static const int durationModifier = 1;

  // ---------------------------------------------------------------------------
  // Hardcoded Python Constants — not tunable; must match Python literals
  // ---------------------------------------------------------------------------

  /// Seat height score = 3 when knee angle exceeds this (Python literal 130°).
  static const double kneeVeryHighThreshold = 130;

  /// Backrest score = 2 when trunk angle from vertical exceeds this
  /// (Python literal 28°).
  static const double backrestMaxAngleFromVertical = 28;

  /// Armrest score = 2 when `ear.y - shoulder.y` exceeds this gap
  /// (Python literal -0.06 — shoulder risen close to ear level).
  static const double armrestShrugGapThreshold = -0.06;

  /// Monitor score = 3 when head tilted back (`nose.y - ear.y`).
  static const double monitorHeadBackThreshold = 0.03;

  /// Monitor severe-flexion gate (`|ear.y - shoulder.y|`).
  static const double monitorSevereFlexionEarShoulderVert = 0.06;

  /// Monitor mild-flexion gate (`ear.y - nose.y`).
  static const double monitorMildFlexionNeckY = 0.04;

  /// Knee sanity ceiling — above this, `angle_between` is unreliable
  /// for a seated person; fall back to knee/hip vertical proxy.
  static const double kneeSanityMax = 160;

  /// Knee-hip proxy thresholds used inside the sanity-check fallback.
  static const double kneeProxyLowGap = -0.02;
  static const double kneeProxyHighGap = 0.15;
  static const double kneeProxyLowAngle = 70;
  static const double kneeProxyMidAngle = 92;
  static const double kneeProxyHighAngle = 115;

  // ---------------------------------------------------------------------------
  // Autocapture
  // ---------------------------------------------------------------------------

  static const double rollTolerance = 2.0;
  static const double pitchTolerance = 4.0;
  static const double sideViewTolerance = 3.0;
  static const Duration stabilityBuffer = Duration(milliseconds: 1500);
  static const Duration conditionTimeout = Duration(seconds: 30);

  // ---------------------------------------------------------------------------
  // Luminance
  // ---------------------------------------------------------------------------

  static const double minLuminance = 0.25;
  static const double maxLuminance = 0.85;
  static const int luminanceSampleStep = 20;

  // ---------------------------------------------------------------------------
  // Pre-computed
  // ---------------------------------------------------------------------------
  static const double twoPi = 2 * pi;
  static const double rad2deg = 180 / pi;

  // ---------------------------------------------------------------------------
  // ROSA Lookup Tables (Cornell/Sonne 2011) — exact Python mirror
  // ---------------------------------------------------------------------------

  /// TABLE A — chair section. Rows 2-8 (seat combined), cols 2-9 (arms combined).
  static const Map<int, Map<int, int>> tableA = {
    2: {2: 1, 3: 2, 4: 3, 5: 4, 6: 5, 7: 6, 8: 7, 9: 8},
    3: {2: 2, 3: 2, 4: 3, 5: 4, 6: 5, 7: 6, 8: 7, 9: 8},
    4: {2: 3, 3: 3, 4: 3, 5: 4, 6: 5, 7: 7, 8: 7, 9: 8},
    5: {2: 4, 3: 5, 4: 4, 5: 4, 6: 5, 7: 7, 8: 7, 9: 8},
    6: {2: 5, 3: 5, 4: 5, 5: 5, 6: 5, 7: 8, 8: 8, 9: 9},
    7: {2: 6, 3: 6, 4: 6, 5: 7, 6: 7, 7: 8, 8: 9, 9: 9},
    8: {2: 7, 3: 7, 4: 7, 5: 8, 6: 8, 7: 9, 8: 9, 9: 9},
  };

  /// TABLE B — monitor/phone. Rows 0-6, cols 0-7.
  static const Map<int, Map<int, int>> tableB = {
    0: {0: 1, 1: 1, 2: 1, 3: 2, 4: 3, 5: 4, 6: 5, 7: 6},
    1: {0: 1, 1: 1, 2: 2, 3: 2, 4: 3, 5: 4, 6: 5, 7: 6},
    2: {0: 1, 1: 2, 2: 2, 3: 3, 4: 3, 5: 4, 6: 6, 7: 7},
    3: {0: 2, 1: 2, 2: 3, 3: 3, 4: 4, 5: 5, 6: 6, 7: 8},
    4: {0: 3, 1: 3, 2: 4, 3: 4, 4: 5, 5: 6, 6: 7, 7: 8},
    5: {0: 4, 1: 4, 2: 5, 3: 5, 4: 6, 5: 7, 6: 8, 7: 9},
    6: {0: 5, 1: 5, 2: 6, 3: 7, 4: 8, 5: 8, 6: 9, 7: 9},
  };

  /// TABLE C — keyboard/mouse. Rows 0-7, cols 0-7.
  static const Map<int, Map<int, int>> tableC = {
    0: {0: 1, 1: 1, 2: 1, 3: 2, 4: 3, 5: 4, 6: 5, 7: 6},
    1: {0: 1, 1: 1, 2: 2, 3: 3, 4: 4, 5: 5, 6: 6, 7: 7},
    2: {0: 1, 1: 2, 2: 2, 3: 3, 4: 4, 5: 5, 6: 6, 7: 7},
    3: {0: 2, 1: 3, 2: 3, 3: 3, 4: 5, 5: 6, 6: 7, 7: 8},
    4: {0: 3, 1: 4, 2: 4, 3: 5, 4: 5, 5: 6, 6: 7, 7: 8},
    5: {0: 4, 1: 5, 2: 5, 3: 6, 4: 6, 5: 7, 6: 8, 7: 9},
    6: {0: 5, 1: 6, 2: 6, 3: 7, 4: 7, 5: 8, 6: 8, 7: 9},
    7: {0: 6, 1: 7, 2: 7, 3: 8, 4: 8, 5: 9, 6: 9, 7: 9},
  };

  /// TABLE D — peripherals. `max(row, col)` for rows/cols 1-9.
  static final Map<int, Map<int, int>> tableD = _generateMaxTable(1, 9);

  /// TABLE E — final ROSA. `max(row, col)` for rows/cols 1-10.
  static final Map<int, Map<int, int>> tableE = _generateMaxTable(1, 10);

  static Map<int, Map<int, int>> _generateMaxTable(int lo, int hi) {
    return {
      for (int r = lo; r <= hi; r++)
        r: {for (int c = lo; c <= hi; c++) c: r > c ? r : c},
    };
  }

  /// Safe table lookup — clamps row/col to the table's actual key range,
  /// matching Python `tlu()` exactly.
  static int lookupTable(Map<int, Map<int, int>> table, int row, int col) {
    final rowKeys = table.keys;
    int minRow = rowKeys.first;
    int maxRow = rowKeys.first;
    for (final k in rowKeys) {
      if (k < minRow) minRow = k;
      if (k > maxRow) maxRow = k;
    }
    final clampedRow = row.clamp(minRow, maxRow);
    final rowMap = table[clampedRow]!;

    final colKeys = rowMap.keys;
    int minCol = colKeys.first;
    int maxCol = colKeys.first;
    for (final k in colKeys) {
      if (k < minCol) minCol = k;
      if (k > maxCol) maxCol = k;
    }
    final clampedCol = col.clamp(minCol, maxCol);
    return rowMap[clampedCol]!;
  }
}
