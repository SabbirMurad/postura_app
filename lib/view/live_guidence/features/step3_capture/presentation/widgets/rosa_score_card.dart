import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../domain/rosa_score.dart';

/// Displays the ROSA final score with breakdown bars.
///
/// Staggered reveal animation on first build:
/// - Score number scales 0→1 with spring bounce (0.6s)
/// - Risk badge fades in (0.4s delay)
/// - Breakdown rows stagger in (0.1s apart)
/// - Bars animate width 0→final (0.6s ease-out)
class RosaScoreCard extends StatefulWidget {
  const RosaScoreCard({super.key, required this.score});

  final RosaScore score;

  @override
  State<RosaScoreCard> createState() => _RosaScoreCardState();
}

class _RosaScoreCardState extends State<RosaScoreCard>
    with TickerProviderStateMixin {
  late final AnimationController _scoreCtrl;
  late final AnimationController _barCtrl;
  late final Animation<double> _scoreScale;

  @override
  void initState() {
    super.initState();
    _scoreCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scoreScale = CurvedAnimation(parent: _scoreCtrl, curve: Curves.elasticOut);

    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Start animations.
    _scoreCtrl.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _barCtrl.forward();
    });
  }

  @override
  void dispose() {
    _scoreCtrl.dispose();
    _barCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final score = widget.score;
    final riskColor = _riskColor(score.finalScore);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Score header.
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ScaleTransition(
              scale: _scoreScale,
              child: Text(
                '${score.finalScore}',
                style: TextStyle(
                  color: riskColor,
                  fontSize: 56.sp,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Syne',
                  height: 1.0,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 8.h, left: 2.w),
              child: Text(
                '/ 10',
                style: TextStyle(
                  color: c.textMuted,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Spacer(),
            _RiskBadge(
              label: score.riskLevel,
              color: riskColor,
              delay: const Duration(milliseconds: 400),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          _riskDescription(score.finalScore),
          style: TextStyle(color: c.textTertiary, fontSize: 12.sp),
        ),

        SizedBox(height: 20.h),

        // Label.
        Text(
          'SCORE BREAKDOWN',
          style: TextStyle(
            color: c.textMuted,
            fontSize: 10.sp,
            fontFamily: 'DMMono',
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 12.h),

        // Breakdown rows.
        _BreakdownRow(
          label: 'Chair',
          value: score.chairScore,
          maxValue: 9,
          color: _barColor(score.chairScore),
          animation: _barCtrl,
          delay: 0.0,
        ),
        SizedBox(height: 8.h),
        _BreakdownRow(
          label: 'Monitor',
          value: score.monitorScore,
          maxValue: 3,
          color: _barColor(score.monitorScore),
          animation: _barCtrl,
          delay: 0.1,
        ),
        SizedBox(height: 8.h),
        _BreakdownRow(
          label: 'Keyboard',
          value: score.keyboardScore,
          maxValue: 3,
          color: _barColor(score.keyboardScore),
          animation: _barCtrl,
          delay: 0.2,
        ),
        SizedBox(height: 8.h),
        _BreakdownRow(
          label: 'Mouse',
          value: score.mouseScore,
          maxValue: 3,
          color: _barColor(score.mouseScore),
          animation: _barCtrl,
          delay: 0.3,
        ),
        SizedBox(height: 8.h),
        _BreakdownRow(
          label: 'Peripherals',
          value: score.peripheralScore,
          maxValue: 9,
          color: _barColor(score.peripheralScore),
          animation: _barCtrl,
          delay: 0.4,
        ),
        SizedBox(height: 8.h),
        _BreakdownRow(
          label: 'Final',
          value: score.finalScore,
          maxValue: 10,
          color: riskColor,
          animation: _barCtrl,
          delay: 0.5,
          bold: true,
        ),
      ],
    );
  }

  Color _riskColor(int score) {
    if (score <= 2) return AppColors.successGreen;
    if (score <= 4) return AppColors.amber;
    if (score <= 6) return AppColors.error;
    return const Color(0xFFD32F2F);
  }

  Color _barColor(int score) {
    if (score <= 1) return AppColors.successGreen;
    if (score <= 2) return AppColors.lightTeal;
    if (score <= 3) return AppColors.amber;
    return AppColors.error;
  }

  String _riskDescription(int score) {
    if (score <= 2) return 'Low risk — posture looks good';
    if (score <= 4) return 'Medium risk — investigate';
    if (score <= 6) return 'High risk — changes needed soon';
    return 'Very high risk — immediate action required';
  }
}

class _RiskBadge extends StatefulWidget {
  const _RiskBadge({
    required this.label,
    required this.color,
    required this.delay,
  });
  final String label;
  final Color color;
  final Duration delay;

  @override
  State<_RiskBadge> createState() => _RiskBadgeState();
}

class _RiskBadgeState extends State<_RiskBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: widget.color),
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            color: widget.color,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
    required this.animation,
    required this.delay,
    this.bold = false,
  });

  final String label;
  final int value;
  final int maxValue;
  final Color color;
  final AnimationController animation;
  final double delay;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fraction = value / maxValue;

    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        // Stagger: delay portion of animation.
        final t = ((animation.value - delay) / (1.0 - delay)).clamp(0.0, 1.0);
        final barWidth = fraction * t;
        final opacity = t;

        return Opacity(
          opacity: opacity,
          child: Row(
            children: [
              SizedBox(
                width: 90.w,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  softWrap: false,
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 13.sp,
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: c.border,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: barWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              SizedBox(
                width: 24.w,
                child: Text(
                  '$value',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: color,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DMMono',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
