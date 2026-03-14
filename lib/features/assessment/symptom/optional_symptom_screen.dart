import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/common/widgets/selectional_container.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/controller/signup_controller.dart';

import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/core/routes/app_routes.dart';

class BusinessOptionalSymptomScreen extends StatelessWidget {
  BusinessOptionalSymptomScreen({super.key});

  final SignupController signupController = Get.find<SignupController>();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTopSection(
                title: loc.optionalSymptom,
                subtitle: loc.optionalSymptomSubtitle,
                isSkip: true,
              ),

              SizedBox(height: 51.h),

              Obx(() {
                return Wrap(
                  children: List.generate(signupController.symptoms.length, (
                    index,
                  ) {
                    final title = signupController.symptoms[index];
                    final isSelected = signupController.selectedSymptom
                        .contains(title);

                    return GestureDetector(
                      onTap: () {
                        if (isSelected) {
                          signupController.selectedSymptom.remove(title);
                        } else {
                          signupController.selectedSymptom.add(title);
                        }
                      },
                      child: SelectionalContainer(
                        title: title,
                        selected: isSelected,
                      ),
                    );
                  }),
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
                Get.toNamed(AppRoute.cameraGuideScreen);
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
