import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../batch_scorer/presentation/screens/batch_scorer_screen.dart';
import '../../../image_test/image_test_screen.dart';

class SetupGuideOverlay extends StatelessWidget {
  const SetupGuideOverlay({super.key, required this.onDismiss});
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      color: c.overlay,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone_android_rounded,
                color: AppColors.lightTeal,
                size: 56.sp,
              ),
              SizedBox(height: 20.h),
              Text(
                'Setup Your Position',
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'Place your phone so the camera can see\nboth you and your screen.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 14.sp,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 28.h),
              Container(
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  color: c.surfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.lightTeal, width: 1),
                ),
                child: Column(
                  children: [
                    _GuideStep(
                      icon: Icons.videocam_rounded,
                      text: 'Point camera at your desk setup',
                      c: c,
                    ),
                    SizedBox(height: 14.h),
                    _GuideStep(
                      icon: Icons.person_rounded,
                      text: 'You should be visible in the frame',
                      c: c,
                    ),
                    SizedBox(height: 14.h),
                    _GuideStep(
                      icon: Icons.desktop_mac_rounded,
                      text: 'Your monitor/laptop should also be visible',
                      c: c,
                    ),
                    SizedBox(height: 14.h),
                    _GuideStep(
                      icon: Icons.straighten_rounded,
                      text: 'Keep phone 1-2 meters away from desk',
                      c: c,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28.h),
              Container(
                padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 20.w),
                decoration: BoxDecoration(
                  color: c.surfaceVariant.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SetupIcon(icon: Icons.phone_android, label: 'Phone', c: c),
                    Icon(Icons.arrow_forward, color: c.iconMuted, size: 20.sp),
                    _SetupIcon(icon: Icons.person, label: 'You', c: c),
                    Icon(Icons.add, color: c.iconMuted, size: 20.sp),
                    _SetupIcon(icon: Icons.desktop_mac, label: 'Screen', c: c),
                  ],
                ),
              ),
              SizedBox(height: 36.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onDismiss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.confirmGreen,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    "I'm Ready",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ImageTestScreen(),
                          ),
                        );
                      },
                      icon: Icon(Icons.image_search_rounded, size: 18.sp),
                      label: Text(
                        'Test with Image',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.lightTeal,
                        side: const BorderSide(color: AppColors.lightTeal),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onLongPress: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const BatchScorerScreen(),
                          ),
                        );
                      },
                      onPressed: () {
                        Fluttertoast.showToast(
                          msg: 'Long press to open Batch Scorer',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.TOP,
                          backgroundColor: AppColors.primaryGreen,
                          textColor: Colors.white,
                        );
                      },
                      icon: Icon(Icons.analytics_outlined, size: 18.sp),
                      label: Text(
                        'Batch Scorer',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.lightTeal,
                        side: const BorderSide(color: AppColors.lightTeal),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({required this.icon, required this.text, required this.c});
  final IconData icon;
  final String text;
  final AppColorSet c;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.lightTeal, size: 22.sp),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: c.textPrimary, fontSize: 13.sp),
          ),
        ),
      ],
    );
  }
}

class _SetupIcon extends StatelessWidget {
  const _SetupIcon({required this.icon, required this.label, required this.c});
  final IconData icon;
  final String label;
  final AppColorSet c;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.lightTeal, size: 28.sp),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(color: c.textTertiary, fontSize: 10.sp),
        ),
      ],
    );
  }
}
