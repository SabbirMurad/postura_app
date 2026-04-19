import 'dart:async';
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

import '../core/constants/rosa_constants.dart';

/// Wraps the device accelerometer to provide roll and pitch readings.
///
/// Uses a low-pass EMA filter (alpha=0.1) to smooth noisy sensor data.
class AccelerometerService {
  StreamSubscription<AccelerometerEvent>? _sub;

  double _roll = 0;
  double _pitch = 0;

  // Low-pass EMA filter state.
  double _filteredX = 0;
  double _filteredY = 0;
  double _filteredZ = 0;
  bool _initialized = false;

  static const double _alpha = 0.1; // EMA smoothing factor.

  /// Current roll in degrees (left/right tilt from vertical).
  double get roll => _roll;

  /// Current pitch in degrees (forward/backward tilt from vertical).
  double get pitch => _pitch;

  /// Whether the phone is held sufficiently vertical.
  bool get isVertical =>
      _roll.abs() < RosaConstants.rollTolerance &&
      _pitch.abs() < RosaConstants.pitchTolerance;

  /// Whether roll is within tolerance.
  bool get isRollOk => _roll.abs() < RosaConstants.rollTolerance;

  /// Whether pitch is within tolerance.
  bool get isPitchOk => _pitch.abs() < RosaConstants.pitchTolerance;

  /// Start listening to accelerometer events.
  void start() {
    _sub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 20), // ~50Hz
    ).listen(_onEvent);
  }

  void _onEvent(AccelerometerEvent event) {
    if (!_initialized) {
      _filteredX = event.x;
      _filteredY = event.y;
      _filteredZ = event.z;
      _initialized = true;
    } else {
      _filteredX = _alpha * event.x + (1 - _alpha) * _filteredX;
      _filteredY = _alpha * event.y + (1 - _alpha) * _filteredY;
      _filteredZ = _alpha * event.z + (1 - _alpha) * _filteredZ;
    }

    // Roll: rotation around the z-axis (left/right tilt).
    // Perfect portrait: y ≈ 9.8, z ≈ 0 → roll ≈ 0.
    _roll = atan2(_filteredX, _filteredY) * (180 / pi);

    // Pitch: forward/backward tilt.
    // Perfect vertical: pitch ≈ 0.
    _pitch =
        atan2(
          -_filteredZ,
          sqrt(_filteredX * _filteredX + _filteredY * _filteredY),
        ) *
        (180 / pi);
  }

  /// Stop and clean up.
  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
