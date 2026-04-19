import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/pose_landmark.dart';

/// Reusable CustomPainter that renders pose landmarks, skeleton lines,
/// and angle arcs (neck + trunk) on top of the camera preview.
class LandmarkOverlay extends StatelessWidget {
  const LandmarkOverlay({
    super.key,
    required this.landmarks,
    this.isStable = false,
    this.imageWidth = 720,
    this.imageHeight = 1280,
  });

  final List<PoseLandmark> landmarks;
  final bool isStable;

  /// Camera image dimensions (after rotation).
  /// Used to compute BoxFit.cover offset for proper coordinate mapping.
  final int imageWidth;
  final int imageHeight;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomPaint(
        painter: _LandmarkPainter(
          landmarks: landmarks,
          isStable: isStable,
          imageWidth: imageWidth,
          imageHeight: imageHeight,
        ),
        size: Size.infinite,
      ),
    );
  }
}

/// Skeleton connection definitions.
const _skeletonConnections = <(BodyPart, BodyPart)>[
  (BodyPart.ear, BodyPart.shoulder),
  (BodyPart.shoulder, BodyPart.elbow),
  (BodyPart.elbow, BodyPart.wrist),
  (BodyPart.shoulder, BodyPart.hip),
  (BodyPart.hip, BodyPart.knee),
  (BodyPart.knee, BodyPart.ankle),
];

class _LandmarkPainter extends CustomPainter {
  _LandmarkPainter({
    required this.landmarks,
    required this.isStable,
    required this.imageWidth,
    required this.imageHeight,
  });

  final List<PoseLandmark> landmarks;
  final bool isStable;
  final int imageWidth;
  final int imageHeight;

  /// Map normalized landmark (0-1) to canvas position,
  /// accounting for BoxFit.cover crop offset.
  Offset _toCanvas(double nx, double ny, Size canvasSize) {
    // BoxFit.cover: scale to fill, crop overflow.
    final imageAspect = imageWidth / imageHeight;
    final canvasAspect = canvasSize.width / canvasSize.height;

    double scale, offsetX, offsetY;
    if (canvasAspect > imageAspect) {
      // Canvas wider — image scaled to width, top/bottom cropped.
      scale = canvasSize.width / imageWidth;
      offsetX = 0;
      offsetY = (canvasSize.height - imageHeight * scale) / 2;
    } else {
      // Canvas taller — image scaled to height, left/right cropped.
      scale = canvasSize.height / imageHeight;
      offsetX = (canvasSize.width - imageWidth * scale) / 2;
      offsetY = 0;
    }

    return Offset(
      offsetX + nx * imageWidth * scale,
      offsetY + ny * imageHeight * scale,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (landmarks.isEmpty) return;

    final byPart = <BodyPart, PoseLandmark>{};
    for (final lm in landmarks) {
      byPart[lm.part] = lm;
    }

    final lineOpacity = isStable ? 0.70 : 0.55;

    // 1. Draw skeleton lines (behind everything).
    for (final (from, to) in _skeletonConnections) {
      final a = byPart[from];
      final b = byPart[to];
      if (a == null || b == null) continue;

      final bothReliable = a.isReliable && b.isReliable;
      final paint = Paint()
        ..color = Colors.white.withValues(
          alpha: bothReliable ? lineOpacity : 0.2,
        )
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        _toCanvas(a.x, a.y, size),
        _toCanvas(b.x, b.y, size),
        paint,
      );
    }

    // 2. Draw angle arcs.
    _drawAngleArc(
      canvas,
      size,
      byPart,
      BodyPart.ear,
      BodyPart.shoulder,
      'neck',
    );
    _drawAngleArc(
      canvas,
      size,
      byPart,
      BodyPart.shoulder,
      BodyPart.hip,
      'trunk',
    );

    // 3. Draw landmark dots on top.
    for (final lm in landmarks) {
      final pos = _toCanvas(lm.x, lm.y, size);

      if (lm.isReliable) {
        canvas.drawCircle(
          pos,
          5.5,
          Paint()..color = AppColors.deepGreen.withValues(alpha: 0.8),
        );
        canvas.drawCircle(pos, 3.0, Paint()..color = AppColors.lightTeal);
      } else {
        canvas.drawCircle(
          pos,
          3.0,
          Paint()..color = AppColors.lightTeal.withValues(alpha: 0.25),
        );
      }
    }
  }

  /// Draw an angle arc between two landmarks relative to vertical.
  void _drawAngleArc(
    Canvas canvas,
    Size size,
    Map<BodyPart, PoseLandmark> byPart,
    BodyPart topPart,
    BodyPart bottomPart,
    String label,
  ) {
    final top = byPart[topPart];
    final bottom = byPart[bottomPart];
    if (top == null || bottom == null) return;
    if (!top.isReliable || !bottom.isReliable) return;

    final topPos = _toCanvas(top.x, top.y, size);
    final bottomPos = _toCanvas(bottom.x, bottom.y, size);

    // Angle from vertical (straight up = 0°).
    final dx = topPos.dx - bottomPos.dx;
    final dy = topPos.dy - bottomPos.dy;
    final angleFromVertical = atan2(dx.abs(), dy.abs()) * 180 / pi;
    final angleDegrees = angleFromVertical.round();

    // Arc parameters.
    const arcRadius = 28.0;
    final arcCenter = bottomPos;

    // Sweep from vertical (-pi/2) to the line angle.
    final lineAngle = atan2(dy, dx);
    final verticalAngle = -pi / 2; // Straight up.
    var startAngle = verticalAngle;
    var sweepAngle = lineAngle - verticalAngle;

    // Normalize sweep to smallest arc.
    if (sweepAngle > pi) sweepAngle -= 2 * pi;
    if (sweepAngle < -pi) sweepAngle += 2 * pi;

    // Draw arc.
    final arcPaint = Paint()
      ..color = AppColors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: arcCenter, radius: arcRadius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );

    // Draw angle text.
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$angleDegrees°',
        style: TextStyle(
          color: AppColors.amber,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black.withValues(alpha: 0.8), blurRadius: 3),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Position text near the arc.
    final midAngle = startAngle + sweepAngle / 2;
    final textOffset = Offset(
      arcCenter.dx + (arcRadius + 12) * cos(midAngle) - textPainter.width / 2,
      arcCenter.dy + (arcRadius + 12) * sin(midAngle) - textPainter.height / 2,
    );
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(_LandmarkPainter old) => true;
}
