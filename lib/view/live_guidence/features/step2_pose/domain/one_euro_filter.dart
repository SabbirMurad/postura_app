import '../../../core/constants/pose_constants.dart';

/// One Euro Filter — adaptive low-pass filter for real-time signal smoothing.
///
/// Smooths heavily when input is stable (still pose), responds quickly when
/// input changes fast (movement). Industry standard for human pose tracking.
///
/// Reference: http://cristal.univ-lille.fr/~casiez/1euro/
class OneEuroFilter {
  final double minCutoff;
  final double beta;
  final double dCutoff;

  double? _xPrev;
  double? _dxPrev;
  int? _tPrevMs;

  OneEuroFilter({
    this.minCutoff = PoseConstants.oneEuroMinCutoff,
    this.beta = PoseConstants.oneEuroBeta,
    this.dCutoff = PoseConstants.oneEuroDCutoff,
  });

  /// Filter a new value at timestamp [tMs] (milliseconds).
  double filter(int tMs, double x) {
    if (_xPrev == null) {
      _xPrev = x;
      _dxPrev = 0.0;
      _tPrevMs = tMs;
      return x;
    }

    final teSec = (tMs - _tPrevMs!) / 1000.0;
    if (teSec <= 0) return _xPrev!;

    // Derivative estimation with low-pass.
    final ad = _smoothingFactor(teSec, dCutoff);
    final dx = (x - _xPrev!) / teSec;
    final dxHat = ad * dx + (1 - ad) * _dxPrev!;

    // Adaptive cutoff based on speed of change.
    final cutoff = minCutoff + beta * dxHat.abs();
    final a = _smoothingFactor(teSec, cutoff);
    final xHat = a * x + (1 - a) * _xPrev!;

    _xPrev = xHat;
    _dxPrev = dxHat;
    _tPrevMs = tMs;
    return xHat;
  }

  double _smoothingFactor(double teSec, double cutoff) {
    final r = PoseConstants.twoPi * cutoff * teSec;
    return r / (r + 1);
  }

  /// Reset filter state (e.g., when landmark drops out).
  void reset() {
    _xPrev = null;
    _dxPrev = null;
    _tPrevMs = null;
  }
}
