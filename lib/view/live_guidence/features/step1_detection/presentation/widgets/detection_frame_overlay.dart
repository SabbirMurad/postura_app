import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class DetectionFrameOverlay extends StatefulWidget {
  const DetectionFrameOverlay({super.key, this.detected = false});
  final bool detected;

  @override
  State<DetectionFrameOverlay> createState() => _DetectionFrameOverlayState();
}

class _DetectionFrameOverlayState extends State<DetectionFrameOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _pulse, _scanLine;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _scanLine = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    _scanLine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.detected
        ? AppColors.successGreen
        : AppColors.lightTeal;
    final padding = EdgeInsets.only(
      left: 22.w,
      right: 22.w,
      top: MediaQuery.of(context).padding.top + 55.h,
      bottom: MediaQuery.of(context).padding.bottom + 200.h,
    );

    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedBuilder(
            animation: Listenable.merge([_pulse, _scanLine]),
            builder: (context, _) {
              final opacity = widget.detected
                  ? 0.8
                  : 0.3 + (_pulse.value * 0.4);
              return Stack(
                children: [
                  CustomPaint(
                    painter: _FramePainter(
                      color: color.withValues(alpha: opacity),
                      cornerLength: 40,
                      strokeWidth: 3,
                    ),
                    size: Size.infinite,
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: _scanLine.value * (constraints.maxHeight - 4),
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            color.withValues(alpha: 0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _FramePainter extends CustomPainter {
  _FramePainter({
    required this.color,
    required this.cornerLength,
    required this.strokeWidth,
  });
  final Color color;
  final double cornerLength, strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(cornerLength, 0), p);
    canvas.drawLine(Offset.zero, Offset(0, cornerLength), p);
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width - cornerLength, 0),
      p,
    );
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), p);
    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerLength, size.height),
      p,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - cornerLength),
      p,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - cornerLength, size.height),
      p,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - cornerLength),
      p,
    );
  }

  @override
  bool shouldRepaint(_FramePainter old) => old.color != color;
}
