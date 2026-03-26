import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/core/constants/app_text.dart';
import 'package:posture_detector_app/controller/signup_controller.dart';

import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/selectional_container.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/routes.dart';

class SelectBodyRegionScreen extends StatelessWidget {
  SelectBodyRegionScreen({super.key});

  final SignupController signupController = Get.find<SignupController>();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                // EN: "Body Region"
                AppTopSection(
                  title: loc.bodyRegionTitle,
                  subtitle: AppText.bodyRegionSubtitle,
                ),
                SizedBox(height: 52.h),
                Obx(
                  () => Wrap(
                    children: List.generate(
                      signupController.bodyRegionList.length,
                      (index) {
                        final title = signupController.bodyRegionList[index];
                        final isSelected = signupController.selectedRegion
                            .contains(title);

                        return GestureDetector(
                          onTap: () {
                            if (isSelected) {
                              signupController.selectedRegion.remove(title);
                            } else {
                              signupController.selectedRegion.add(title);
                            }
                          },
                          child: SelectionalContainer(
                            title: title,
                            selected: isSelected,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 100.h), // Add padding for bottomSheet
              ],
            ),
          ),
        ),
      ),
      bottomSheet: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 20.h),
          child: SizedBox(
            child: PrimaryButton(
              onTap: () {
                if (signupController.selectedRegion.isEmpty) {
                  // EN: "Please select a body region"
                  showCustomToast(text: loc.pleaseSelectBodyRegion);
                } else {
                  Get.toNamed(AppRoute.employeePainIntensityScreen);
                }
              },
              // EN: "Continue"
              text: loc.continueButton,
              backgroundColor: AppColors.primaryColor,
              textStyle: TextStyle(
                color: AppColors.surface,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
        ),
      ),
    );
  }
}
