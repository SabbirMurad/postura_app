import 'dart:math';

import '../../step2_pose/domain/pose_landmark.dart';
import '../../../core/constants/rosa_constants.dart';

/// Pure math utilities for computing angles from pose landmarks.
///
/// All landmark coordinates are normalized (0.0–1.0).
abstract final class AngleCalculator {
  /// 3-point angle at [vertex] formed by [p1]-[vertex]-[p2], in degrees.
  ///
  /// Used for knee angle: hip–knee–ankle.
  static double angleBetween(
    PoseLandmark p1,
    PoseLandmark vertex,
    PoseLandmark p2,
  ) {
    final ax = p1.x - vertex.x;
    final ay = p1.y - vertex.y;
    final bx = p2.x - vertex.x;
    final by = p2.y - vertex.y;

    final dot = ax * bx + ay * by;
    final m1 = sqrt(ax * ax + ay * ay);
    final m2 = sqrt(bx * bx + by * by);
    if (m1 < 1e-6 || m2 < 1e-6) return 90.0;
    return acos((dot / (m1 * m2)).clamp(-1.0, 1.0)) * RosaConstants.rad2deg;
  }

  /// Trunk angle from vertical (degrees).
  ///
  /// Mirrors Python `trunk_angle_from_vertical`:
  ///   dx = |hip.x - shoulder.x|
  ///   dy = |hip.y - shoulder.y|
  ///   angle = atan2(dx, dy) in degrees
  ///
  /// 0° = perfectly upright (shoulder directly above hip).
  /// 28°+ = backrest issue per validated Python threshold.
  static double trunkAngleFromVertical(
    PoseLandmark shoulder,
    PoseLandmark hip,
  ) {
    final dx = (hip.x - shoulder.x).abs();
    final dy = (hip.y - shoulder.y).abs();
    if (dy < 1e-6) return 90.0;
    return atan2(dx, dy) * RosaConstants.rad2deg;
  }

  /// Neck flexion: ear_y − nose_y (normalized).
  ///
  /// Positive = ear below nose = looking down (flexed).
  static double neckFlexion(PoseLandmark ear, PoseLandmark nose) {
    return ear.y - nose.y;
  }

  /// Forward head: shoulder_x − ear_x (normalized, signed).
  ///
  /// Positive = ear forward of shoulder (turtle neck).
  static double forwardHead(PoseLandmark ear, PoseLandmark shoulder) {
    return shoulder.x - ear.x;
  }

  /// Wrist extension: elbow_y − wrist_y (normalized).
  ///
  /// Positive = wrist higher than elbow = extension.
  static double wristExtension(PoseLandmark elbow, PoseLandmark wrist) {
    return elbow.y - wrist.y;
  }

  /// Shoulder shrug: ear_y − shoulder_y (normalized).
  ///
  /// Matches Python: `gap = ear[1] - sh[1]`.
  /// More negative = normal (ear well above shoulder).
  /// Close to 0 or positive = shrug (shoulder risen toward ear).
  static double shoulderShrug(PoseLandmark ear, PoseLandmark shoulder) {
    return ear.y - shoulder.y;
  }

  /// Mouse reach: |wrist_x − shoulder_x| (normalized).
  static double mouseReach(PoseLandmark wrist, PoseLandmark shoulder) {
    return (wrist.x - shoulder.x).abs();
  }
}
