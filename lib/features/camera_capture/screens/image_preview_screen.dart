import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/core/routes/app_routes.dart';
import 'package:posture_detector_app/controller/signup_controller.dart';

import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/controller/image_capture_controller.dart';

class ImagePreviewScreen extends StatelessWidget {
  ImagePreviewScreen({super.key});

  final SignupController _signupController = Get.find<SignupController>();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final imagePath = Get.arguments['imagePath'];
    final type = Get.arguments['type'];

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 18.h),
                Text(
                  loc.photoPreview,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 18.h),

                // Image with loading overlay
                Obx(() {
                  return Stack(
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

                      // Loading overlay
                      if (_signupController.isLoadingAnalysis.value)
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
                                Text(
                                  loc.analyzingPosture,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16.sp,
                                    color: AppColors.surface,
                                  ),
                                ),
                                SizedBox(height: 3.h),
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
                  );
                }),

                SizedBox(height: 21.h),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        text: loc.retake,
                        textColor: AppColors.text,
                        backgroundColor: AppColors.blackDeemed,
                        onTap: () {
                          final imageController =
                              Get.find<ImageCaptureController>();
                          imageController.image.value = null;

                          _signupController.isLoading.value = false;

                          Get.back();
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Obx(() {
                        return PrimaryButton(
                          loading: _signupController.isLoading.value,
                          text: loc.continueButton,
                          textColor: AppColors.surface,
                          backgroundColor: AppColors.primaryColor,
                          onTap: () async {
                            // Disable taps while loading
                            if (!_signupController.isLoadingAnalysis.value) {
                              final res = await _signupController
                                  .poseAnalysisProcess(type);
                              if (res) {
                                Get.offAllNamed(AppRoute.outputScreenBusiness);
                              }
                            }
                          },
                        );
                      }),
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
