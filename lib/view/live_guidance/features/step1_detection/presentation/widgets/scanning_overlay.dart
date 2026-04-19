import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

class ScanningOverlay extends StatefulWidget {
  const ScanningOverlay({super.key, required this.onComplete, this.onRestart});
  final VoidCallback onComplete;
  final VoidCallback? onRestart;

  @override
  State<ScanningOverlay> createState() => _ScanningOverlayState();
}

class _ScanningOverlayState extends State<ScanningOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _scanLine, _pulse, _progress;
  bool _isDone = false;

  @override
  void initState() {
    super.initState();
    _scanLine = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _progress = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Defer animations to after the first frame so the widget tree
    // can build without competing for the same frame budget.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scanLine.repeat(reverse: true);
      _pulse.repeat(reverse: true);
      _progress.forward().then((_) {
        if (!mounted) return;
        _scanLine.stop();
        _pulse.stop();
        setState(() => _isDone = true);
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) widget.onComplete();
        });
      });
    });
  }

  @override
  void dispose() {
    _scanLine.dispose();
    _pulse.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Colors.black.withValues(alpha: 0.3)),

        if (widget.onRestart != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12.h,
            right: 14.w,
            child: GestureDetector(
              onTap: widget.onRestart,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.replay_rounded,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      'Rescan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        Center(
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.4, end: 1.0).animate(_pulse),
            child: Container(
              width: 260.w,
              height: 380.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: AppColors.lightTeal, width: 3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.r),
                child: Stack(
                  children: [
                    AnimatedBuilder(
                      animation: _scanLine,
                      builder: (_, child) {
                        return Transform.translate(
                          offset: Offset(0, _scanLine.value * 374.h),
                          child: child,
                        );
                      },
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppColors.lightTeal.withValues(alpha: 0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    ..._buildCorners(),
                  ],
                ),
              ),
            ),
          ),
        ),

        Positioned(
          left: 20.w,
          right: 20.w,
          bottom: MediaQuery.of(context).padding.bottom + 28.h,
          child: Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isDone
                    ? Row(
                        key: const ValueKey('done'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.lightTeal,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Scan Complete!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        key: const ValueKey('scanning'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.lightTeal,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Hold still, scanning your posture...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
              ),
              SizedBox(height: 14.h),
              AnimatedBuilder(
                animation: _progress,
                builder: (_, __) {
                  return Container(
                    height: 5.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.r),
                      color: Colors.white12,
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progress.value,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3.r),
                          gradient: LinearGradient(
                            colors: _isDone
                                ? [
                                    AppColors.confirmGreen,
                                    AppColors.successGreen,
                                  ]
                                : [AppColors.primaryGreen, AppColors.lightTeal],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 7.h),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isDone
                    ? Text(
                        key: const ValueKey('d'),
                        'Starting posture analysis...',
                        style: TextStyle(
                          color: AppColors.lightTeal,
                          fontSize: 11.sp,
                        ),
                      )
                    : Text(
                        key: const ValueKey('s'),
                        'Please stay in position for a moment',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11.sp,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCorners() {
    const color = AppColors.lightTeal;
    final len = 26.w;
    final t = 3.0;
    final o = 7.w;
    return [
      Positioned(
        top: o,
        left: o,
        child: _Corner(color: color, len: len, thickness: t),
      ),
      Positioned(
        top: o,
        right: o,
        child: Transform.flip(
          flipX: true,
          child: _Corner(color: color, len: len, thickness: t),
        ),
      ),
      Positioned(
        bottom: o,
        left: o,
        child: Transform.flip(
          flipY: true,
          child: _Corner(color: color, len: len, thickness: t),
        ),
      ),
      Positioned(
        bottom: o,
        right: o,
        child: Transform.flip(
          flipX: true,
          flipY: true,
          child: _Corner(color: color, len: len, thickness: t),
        ),
      ),
    ];
  }
}

class _Corner extends StatelessWidget {
  const _Corner({
    required this.color,
    required this.len,
    required this.thickness,
  });
  final Color color;
  final double len, thickness;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: len,
    height: len,
    child: CustomPaint(painter: _CornerPainter(color, thickness)),
  );
}

class _CornerPainter extends CustomPainter {
  _CornerPainter(this.color, this.thickness);
  final Color color;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), p);
    canvas.drawLine(Offset.zero, Offset(0, size.height), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
