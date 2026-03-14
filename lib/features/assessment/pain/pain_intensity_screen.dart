import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/controller/signup_controller.dart';

import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/common/widgets/slider_widget.dart';
import 'package:posture_detector_app/core/routes/app_routes.dart';

class BusinessPainIntensityScreen extends StatelessWidget {
  BusinessPainIntensityScreen({super.key});

  final SignupController signupController = Get.find<SignupController>();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                AppTopSection(
                  title: loc.painIntensity,
                  subtitle: loc.painIntensitySubtitle,
                ),
                SizedBox(height: 51.h),

                ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: 30.h),
                  shrinkWrap: true,
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 22.h);
                  },
                  itemCount: signupController.selectedRegion.length,
                  itemBuilder: (context, index) {
                    final region = signupController.selectedRegion[index];

                    return AppSliderWidget(
                      title: region,
                      sliderValue: signupController.getPainValueForRegion(
                        region,
                      ),
                    );
                  },
                ),

                SizedBox(height: 80.h),
                // AppSliderWidget(
                //   title: '${loc.neck}:',
                //   sliderValue: signupController.neckPain,
                // ),
                // SizedBox(height: 56.h),
                // AppSliderWidget(
                //   title: '${loc.upperBack}:',
                //   sliderValue: signupController.upperBack,
                // ),
                // SizedBox(height: 56.h),
                // AppSliderWidget(
                //   title: '${loc.wrist}:',
                //   sliderValue: signupController.wrists,
                // ),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 20.w),
          child: SizedBox(
            child: PrimaryButton(
              onTap: () {
                Get.toNamed(AppRoute.employeePainDurationScreen);
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
