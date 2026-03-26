import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/common/widgets/back_button.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/core/enums/user_type.dart';
import 'package:posture_detector_app/controller/signup_controller.dart';
import 'package:posture_detector_app/view/auth/signup/widgets/user_type_card.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';

class SelectUserLoginScreen extends StatelessWidget {
  SelectUserLoginScreen({super.key});

  final SignupController signupController = Get.find<SignupController>();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: true,
        top: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: AppBackButton(),
              ),
            ),
            SizedBox(height: 17.h),
            Text(
              // EN: "Choose Your Mode"
              loc.chooseModeTitle,
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12.h),
            Text(
              // EN: "ISO-aligned ergonomic assessment and recommendations"
              loc.chooseModeSubtitle,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.text.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 29.h),
            GestureDetector(
              onTap: () {
                signupController.userRole.value = Users.EMPLOYEE.name;
              },
              child: UserTypeCard(
                image: Assets.icons.auth.business.svg(),
                // EN: business = "Business", businessTitle = "Companies, HR, Admin, Desk Workers"
                title: loc.business,
                subtitle: loc.businessTitle,
                controller: signupController,
                userType: Users.EMPLOYEE,
              ),
            ),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () {
                signupController.userRole.value = Users.CPE.name;
              },
              child: UserTypeCard(
                image: Assets.icons.auth.cpe.svg(),
                // EN: cpe = "CPE", ergonomistCpe = "Ergonomist / CPE"
                title: AppLocalizations.of(context)!.cpe,
                subtitle: AppLocalizations.of(context)!.ergonomistCpe,
                controller: signupController,
                userType: Users.CPE,
              ),
            ),
          ],
        ),
      ),
      bottomSheet: SafeArea(
        child: SizedBox(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PrimaryButton(
                  onTap: () {
                    if (signupController.userRole.isEmpty) {
                      // EN: "Please select a user mode"
                      showCustomToast(text: loc.pleaseSelectUserMode);
                    }
                    if (signupController.userRole.isNotEmpty) {
                      Get.toNamed(AppRoute.loginScreen);
                    }
                  },
                  // EN: "Continue"
                  text: loc.continueButton,
                  backgroundColor: AppColors.primaryColor,
                  textColor: AppColors.surface,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                SizedBox(height: 12.h),
                PrimaryButton(
                  onTap: () {
                    Get.back();
                  },
                  // EN: "Back"
                  text: loc.backButton,
                  backgroundColor: AppColors.greyDeemed,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                SizedBox(height: 25.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
