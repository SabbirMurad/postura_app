import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';

/// Pre-camera instruction screen — "How to Take the Photo".
///
/// Static screen, no animations. Dark background, amber banner,
/// worker + photographer instructions, green CTA button.
class InstructionScreen extends StatelessWidget {
  const InstructionScreen({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),

              // Amber banner.
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: AppColors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.amber.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.amber,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Another person must take this photo',
                        style: TextStyle(
                          color: AppColors.amber,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              // Title.
              Text(
                'How to Take the Photo',
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: 28.h),

              // Worker section.
              _SectionLabel(label: 'WORKER', color: AppColors.lightTeal),
              SizedBox(height: 12.h),
              _InstructionItem(
                number: 1,
                text: 'Sit exactly as you normally work',
              ),
              _InstructionItem(
                number: 2,
                text: 'Place hands on keyboard or mouse',
              ),
              _InstructionItem(
                number: 3,
                text: 'Look at your screen naturally',
              ),
              _InstructionItem(
                number: 4,
                text: 'Maintain your natural posture',
              ),

              SizedBox(height: 28.h),

              // Photographer section.
              _SectionLabel(label: 'PHOTOGRAPHER', color: AppColors.amber),
              SizedBox(height: 12.h),
              _InstructionItem(
                number: 1,
                text: 'Stand at 90\u00B0 side, 1.5\u20131.8m away',
              ),
              _InstructionItem(
                number: 2,
                text: 'Worker + monitor both in frame',
              ),
              _InstructionItem(
                number: 3,
                text: 'Hold phone upright \u2014 not tilted',
              ),
              _InstructionItem(
                number: 4,
                text: 'App takes photo automatically',
              ),

              const Spacer(),

              // CTA button.
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: onStart,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Center(
                      child: Text(
                        'Start Photo Capture',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        fontFamily: 'DMMono',
      ),
    );
  }
}

class _InstructionItem extends StatelessWidget {
  const _InstructionItem({required this.number, required this.text});
  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22.w,
            height: 22.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryGreen.withValues(alpha: 0.2),
              border: Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.4),
              ),
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  color: AppColors.lightTeal,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Text(
                text,
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 14.sp,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
