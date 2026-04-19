import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const _green = Color.fromARGB(255, 33, 128, 230);
const _teal = Color.fromARGB(255, 70, 141, 218);
const _deepGreen = Color.fromARGB(255, 33, 128, 230);

/// Postura's signature spine orbit loader.
///
/// Center spine icon with rotating arcs, head pulse, and disc wave animation.
/// Reusable across the app wherever a loading state is needed.
class SpineOrbitLoader extends StatefulWidget {
  const SpineOrbitLoader({super.key, this.label});

  /// Optional label below the loader (e.g., "Processing image...").
  final String? label;

  @override
  State<SpineOrbitLoader> createState() => _SpineOrbitLoaderState();
}

class _SpineOrbitLoaderState extends State<SpineOrbitLoader>
    with TickerProviderStateMixin {
  late final AnimationController _arc1;
  late final AnimationController _arc2;
  late final AnimationController _headPulse;
  late final AnimationController _discWave;

  @override
  void initState() {
    super.initState();
    _arc1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _arc2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    _headPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _discWave = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _arc1.dispose();
    _arc2.dispose();
    _headPulse.dispose();
    _discWave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? const Color(0xE6101418) // 90% opaque dark — visible over images
        : const Color(0xE6080A0D);
    final labelColor = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : Colors.white.withValues(alpha: 0.45);

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _green.withValues(alpha: isDark ? 0.3 : 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 64.w,
            height: 64.w,
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _arc1,
                _arc2,
                _headPulse,
                _discWave,
              ]),
              builder: (context, _) {
                return CustomPaint(
                  painter: _SpineOrbitPainter(
                    arc1Angle: _arc1.value * 2 * pi,
                    arc2Angle: -_arc2.value * 2 * pi,
                    headPulse: _headPulse.value,
                    discWavePhase: _discWave.value,
                  ),
                );
              },
            ),
          ),
          if (widget.label != null) ...[
            SizedBox(height: 10.h),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                widget.label!,
                key: ValueKey(widget.label),
                style: TextStyle(
                  fontFamily: 'DMMono',
                  fontSize: 10.sp,
                  color: labelColor,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SpineOrbitPainter extends CustomPainter {
  _SpineOrbitPainter({
    required this.arc1Angle,
    required this.arc2Angle,
    required this.headPulse,
    required this.discWavePhase,
  });

  final double arc1Angle;
  final double arc2Angle;
  final double headPulse; // 0-1
  final double discWavePhase; // 0-1

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);

    // 1. Static outer ring — depth reference.
    canvas.drawCircle(
      center,
      32,
      Paint()
        ..color = _green.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // 2. Arc 1 — clockwise, 2px, gradient fade.
    _drawGradientArc(
      canvas,
      center,
      28,
      arc1Angle,
      pi * 0.7,
      _green,
      _green.withValues(alpha: 0.3),
      2.0,
    );

    // 3. Arc 2 — counter-clockwise, 1px, subtler.
    _drawGradientArc(
      canvas,
      center,
      30,
      arc2Angle,
      pi * 0.5,
      _teal.withValues(alpha: 0.4),
      _teal.withValues(alpha: 0.15),
      1.0,
    );

    // 4. Spine icon — head, spine line, vertebrae discs.
    _drawSpineIcon(canvas, cx, cy);
  }

  void _drawGradientArc(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
    Color startColor,
    Color endColor,
    double strokeWidth,
  ) {
    // Draw arc in small segments for gradient effect.
    const segments = 20;
    final segmentSweep = sweepAngle / segments;

    for (int i = 0; i < segments; i++) {
      final t = i / segments;
      final color = Color.lerp(startColor, endColor, t)!;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + i * segmentSweep,
        segmentSweep + 0.02, // Slight overlap to avoid gaps.
        false,
        paint,
      );
    }
  }

  void _drawSpineIcon(Canvas canvas, double cx, double cy) {
    // Head position — offset above center.
    final headY = cy - 14;

    // Head circle with pulse.
    final headOpacity = 0.4 + headPulse * 0.6;
    canvas.drawCircle(
      Offset(cx, headY),
      5,
      Paint()
        ..color = _teal.withValues(alpha: headOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(Offset(cx, headY), 2, Paint()..color = _teal);

    // Spine line — gradient.
    final spineTop = headY + 6;
    final spineBottom = cy + 14;
    final spinePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_teal, _deepGreen],
      ).createShader(Rect.fromLTWH(cx - 1, spineTop, 2, spineBottom - spineTop))
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, spineTop), Offset(cx, spineBottom), spinePaint);

    // Vertebrae discs — wave animation.
    const discCount = 3;
    const discWidth = 9.0;
    const discHeight = 2.5;
    final discOpacities = [1.0, 0.65, 0.35];

    for (int i = 0; i < discCount; i++) {
      final y = spineTop + 3 + i * 6.0;

      // Staggered wave: each disc 0.15 phase offset.
      final phase = (discWavePhase + i * 0.15) % 1.0;
      // scaleX oscillates 1.0 → 0.7 → 1.0.
      final wave = sin(phase * 2 * pi);
      final scaleX = 0.85 + 0.15 * wave;

      canvas.save();
      canvas.translate(cx, y);
      canvas.scale(scaleX, 1.0);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: discWidth,
            height: discHeight,
          ),
          const Radius.circular(1.5),
        ),
        Paint()..color = _teal.withValues(alpha: discOpacities[i]),
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SpineOrbitPainter old) => true;
}
