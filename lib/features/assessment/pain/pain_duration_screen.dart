import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/controller/signup_controller.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/common/widgets/selectional_container.dart';
import 'package:posture_detector_app/core/routes/app_routes.dart';

class BusinessPainDurationScreen extends StatelessWidget {
  BusinessPainDurationScreen({super.key});

  final SignupController signupController = Get.find<SignupController>();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTopSection(
                title: loc.painDuration,
                subtitle: loc.painDurationSubtitle,
              ),
              SizedBox(height: 51.h),
              Obx(() {
                return Wrap(
                  children: List.generate(
                    signupController.painDuration.length,
                    (index) {
                      final title = signupController.painDuration[index];
                      final isSelected =
                          signupController.selectedPainDuration.value == title;

                      return GestureDetector(
                        onTap: () {
                          signupController.selectedPainDuration.value = title;
                        },
                        child: SelectionalContainer(
                          title: title,
                          selected: isSelected,
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      bottomSheet: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 20.w),
          child: SizedBox(
            child: PrimaryButton(
              onTap: () {
                if (signupController.selectedPainDuration.isEmpty) {
                  showCustomToast(text: loc.pleaseFillAllFields);
                  return;
                }
                Get.toNamed(AppRoute.employeeWorkPatternScreen);
              },
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
