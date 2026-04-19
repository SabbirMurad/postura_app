import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../step2_pose/domain/pose_result.dart';
import '../../../step2_pose/presentation/widgets/landmark_overlay.dart';
import '../../domain/rosa_score.dart';
import '../widgets/rosa_score_card.dart';

/// ROSA result screen — shows score, annotated image, breakdown.
///
/// Staggered reveal animations:
/// 1. Score number scales with spring bounce (0.6s)
/// 2. Risk badge fades in (0.4s delay)
/// 3. Photo slides up from bottom (0.5s, 0.3s delay)
/// 4. Breakdown rows stagger in (0.1s apart)
/// 5. Retake button fades in last (0.8s delay)
class ReviewScreen extends StatefulWidget {
  const ReviewScreen({
    super.key,
    required this.rosaScore,
    required this.imagePath,
    required this.poseResult,
    required this.onRetake,
  });

  final RosaScore rosaScore;
  final String imagePath;
  final PoseResult poseResult;
  final VoidCallback onRetake;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen>
    with TickerProviderStateMixin {
  late final AnimationController _photoCtrl;
  late final AnimationController _buttonCtrl;

  @override
  void initState() {
    super.initState();

    _photoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _buttonCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Stagger: photo at 0.3s, button at 0.8s.
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _photoCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _buttonCtrl.forward();
    });
  }

  @override
  void dispose() {
    _photoCtrl.dispose();
    _buttonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable content — full screen.
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 80.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ROSA SCORE',
                    style: TextStyle(
                      color: AppColors.lightTeal,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'DMMono',
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  RosaScoreCard(score: widget.rosaScore),
                  SizedBox(height: 20.h),
                  AnimatedBuilder(
                    animation: _photoCtrl,
                    builder: (_, child) {
                      final t = CurvedAnimation(
                        parent: _photoCtrl,
                        curve: Curves.easeOut,
                      ).value;
                      return Opacity(
                        opacity: t,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - t)),
                          child: child,
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Image (or dark placeholder if storage Option C deleted it).
                            if (widget.imagePath.isNotEmpty)
                              Image.file(
                                File(widget.imagePath),
                                fit: BoxFit.cover,
                              )
                            else
                              Container(
                                color: c.surface,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.privacy_tip_outlined,
                                        color: AppColors.lightTeal,
                                        size: 40.sp,
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        'Image not stored',
                                        style: TextStyle(
                                          color: c.textSecondary,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (widget.poseResult.landmarks.isNotEmpty)
                              LandmarkOverlay(
                                landmarks: widget.poseResult.landmarks,
                                isStable: true,
                              ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: AppColors.successGreen.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),

            // Retake button — floating at bottom over scroll content.
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: 14.h,
              child: FadeTransition(
                opacity: _buttonCtrl,
                child: GestureDetector(
                  onTap: widget.onRetake,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Text(
                        'Retake photo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
