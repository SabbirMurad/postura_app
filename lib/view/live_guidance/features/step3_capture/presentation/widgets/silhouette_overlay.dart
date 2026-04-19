import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Enterprise-style seated person silhouette outline.
///
/// Drawn with CustomPainter — shows desk, monitor, and seated figure
/// as a positioning guide overlay on the camera view.
class SilhouetteOverlay extends StatelessWidget {
  const SilhouetteOverlay({super.key, this.opacity = 0.15});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _SilhouettePainter(opacity: opacity),
      ),
    );
  }
}

class _SilhouettePainter extends CustomPainter {
  _SilhouettePainter({required this.opacity});

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.45;
    final cy = size.height * 0.45;
    final scale = min(size.width, size.height) / 400;

    final paint = Paint()
      ..color = AppColors.lightTeal.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * scale
      ..strokeCap = StrokeCap.round;

    // Head.
    canvas.drawCircle(Offset(cx, cy - 70 * scale), 18 * scale, paint);

    // Neck.
    canvas.drawLine(
      Offset(cx, cy - 52 * scale),
      Offset(cx, cy - 40 * scale),
      paint,
    );

    // Shoulders.
    canvas.drawLine(
      Offset(cx - 35 * scale, cy - 40 * scale),
      Offset(cx + 35 * scale, cy - 40 * scale),
      paint,
    );

    // Torso.
    canvas.drawLine(
      Offset(cx, cy - 40 * scale),
      Offset(cx, cy + 20 * scale),
      paint,
    );

    // Arms (keyboard position).
    // Left arm.
    canvas.drawLine(
      Offset(cx - 35 * scale, cy - 40 * scale),
      Offset(cx - 40 * scale, cy - 5 * scale),
      paint,
    );
    canvas.drawLine(
      Offset(cx - 40 * scale, cy - 5 * scale),
      Offset(cx - 20 * scale, cy + 5 * scale),
      paint,
    );
    // Right arm.
    canvas.drawLine(
      Offset(cx + 35 * scale, cy - 40 * scale),
      Offset(cx + 40 * scale, cy - 5 * scale),
      paint,
    );
    canvas.drawLine(
      Offset(cx + 40 * scale, cy - 5 * scale),
      Offset(cx + 20 * scale, cy + 5 * scale),
      paint,
    );

    // Hips.
    canvas.drawLine(
      Offset(cx - 25 * scale, cy + 20 * scale),
      Offset(cx + 25 * scale, cy + 20 * scale),
      paint,
    );

    // Thighs (seated).
    canvas.drawLine(
      Offset(cx - 25 * scale, cy + 20 * scale),
      Offset(cx - 30 * scale, cy + 55 * scale),
      paint,
    );
    canvas.drawLine(
      Offset(cx + 25 * scale, cy + 20 * scale),
      Offset(cx + 30 * scale, cy + 55 * scale),
      paint,
    );

    // Lower legs.
    canvas.drawLine(
      Offset(cx - 30 * scale, cy + 55 * scale),
      Offset(cx - 30 * scale, cy + 95 * scale),
      paint,
    );
    canvas.drawLine(
      Offset(cx + 30 * scale, cy + 55 * scale),
      Offset(cx + 30 * scale, cy + 95 * scale),
      paint,
    );

    // Desk.
    final deskPaint = Paint()
      ..color = AppColors.lightTeal.withValues(alpha: opacity * 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * scale;

    canvas.drawLine(
      Offset(cx - 60 * scale, cy + 5 * scale),
      Offset(cx + 80 * scale, cy + 5 * scale),
      deskPaint,
    );

    // Monitor.
    final monitorRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx + 55 * scale, cy - 30 * scale),
        width: 45 * scale,
        height: 35 * scale,
      ),
      Radius.circular(3 * scale),
    );
    canvas.drawRRect(monitorRect, paint);

    // Monitor stand.
    canvas.drawLine(
      Offset(cx + 55 * scale, cy - 12 * scale),
      Offset(cx + 55 * scale, cy + 5 * scale),
      paint,
    );
  }

  @override
  bool shouldRepaint(_SilhouettePainter old) => opacity != old.opacity;
}
