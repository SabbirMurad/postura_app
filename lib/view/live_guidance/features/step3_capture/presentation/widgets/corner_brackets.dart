import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// L-shape corner brackets overlay — static, positioned at all 4 corners.
class CornerBrackets extends StatelessWidget {
  const CornerBrackets({
    super.key,
    this.color,
    this.length = 30,
    this.width = 2.5,
  });

  final Color? color;
  final double length;
  final double width;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.lightTeal.withValues(alpha: 0.5);
    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Stack(
          children: [
            // Top-left.
            Positioned(
              left: 0,
              top: 0,
              child: _Corner(c, length, width, _CornerPos.topLeft),
            ),
            // Top-right.
            Positioned(
              right: 0,
              top: 0,
              child: _Corner(c, length, width, _CornerPos.topRight),
            ),
            // Bottom-left.
            Positioned(
              left: 0,
              bottom: 0,
              child: _Corner(c, length, width, _CornerPos.bottomLeft),
            ),
            // Bottom-right.
            Positioned(
              right: 0,
              bottom: 0,
              child: _Corner(c, length, width, _CornerPos.bottomRight),
            ),
          ],
        ),
      ),
    );
  }
}

enum _CornerPos { topLeft, topRight, bottomLeft, bottomRight }

class _Corner extends StatelessWidget {
  const _Corner(this.color, this.length, this.width, this.pos);
  final Color color;
  final double length;
  final double width;
  final _CornerPos pos;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: length,
      height: length,
      child: CustomPaint(painter: _CornerPainter(color, width, pos)),
    );
  }
}

class _CornerPainter extends CustomPainter {
  _CornerPainter(this.color, this.strokeWidth, this.pos);
  final Color color;
  final double strokeWidth;
  final _CornerPos pos;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    switch (pos) {
      case _CornerPos.topLeft:
        canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
        canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
      case _CornerPos.topRight:
        canvas.drawLine(Offset(size.width, 0), Offset.zero, paint);
        canvas.drawLine(
          Offset(size.width, 0),
          Offset(size.width, size.height),
          paint,
        );
      case _CornerPos.bottomLeft:
        canvas.drawLine(Offset(0, size.height), Offset.zero, paint);
        canvas.drawLine(
          Offset(0, size.height),
          Offset(size.width, size.height),
          paint,
        );
      case _CornerPos.bottomRight:
        canvas.drawLine(
          Offset(size.width, size.height),
          Offset(0, size.height),
          paint,
        );
        canvas.drawLine(
          Offset(size.width, size.height),
          Offset(size.width, 0),
          paint,
        );
    }
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}
