import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/provider/assessment.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/provider/image_capture.dart';

class ImagePreviewScreen extends ConsumerWidget {
  const ImagePreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final imagePath = Get.arguments['imagePath'];
    final type = Get.arguments['type'];
    final isSubmitting = ref.watch(
      assessmentNotifierProvider.select((s) => s.isSubmitting),
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 18.h),
                // EN: "Photo Preview"
                Text(
                  loc.photoPreview,
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 18.h),

                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.file(
                        File(imagePath),
                        width: 334.w,
                        height: 568.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (isSubmitting)
                      Container(
                        width: 334.w,
                        height: 568.h,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  AppColors.primaryColor,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              // EN: "Analyzing your posture..."
                              Text(
                                loc.analyzingPosture,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16.sp,
                                  color: AppColors.surface,
                                ),
                              ),
                              SizedBox(height: 3.h),
                              // EN: "ISO 9241 standard"
                              Text(
                                loc.iso9241,
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.sp,
                                  color: AppColors.surface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 21.h),

                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        // EN: "Retake"
                        text: loc.retake,
                        textColor: AppColors.text,
                        backgroundColor: AppColors.blackDeemed,
                        onTap: () {
                          ref.read(imageCaptureNotifierProvider.notifier).clear();
                          Get.back();
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: PrimaryButton(
                        loading: isSubmitting,
                        // EN: "Continue"
                        text: loc.continueButton,
                        textColor: AppColors.surface,
                        backgroundColor: AppColors.primaryColor,
                        onTap: () async {
                          if (!isSubmitting) {
                            final success = await ref
                                .read(assessmentNotifierProvider.notifier)
                                .submitAnalysis(type);
                            if (success) {
                              Get.offAllNamed(AppRoute.outputScreenBusiness);
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
