import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/core/constants/app_text.dart';
import 'package:posture_detector_app/core/enums/user_type.dart';
import 'package:posture_detector_app/controller/signup_controller.dart';
import 'package:posture_detector_app/view/auth/signup/business/widgets/language_selected_card.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/data/helpers/app_helper.dart';

class SelectLanguageScreen extends StatelessWidget {
  SelectLanguageScreen({super.key});

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20.h),
              AppTopSection(
                title: loc.selectLanguage,
                subtitle: loc.selectLanguageSubtitle,
              ),
              SizedBox(height: 48.h),

              /// ------------------------------ Language Selected card ------------------------------ ///
              GestureDetector(
                onTap: () {
                  signupController.selectedLanguage.value = 'en';
                },
                child: LanguageSelectCard(
                  countryImage: Assets.icons.flags.flagEn.svg(
                    width: 26.w,
                    height: 17.h,
                    fit: BoxFit.cover,
                  ),
                  countryName: AppText.english,
                  controller: signupController,
                  selectedLan: 'en',
                ),
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () {
                  signupController.selectedLanguage.value = 'nl';
                },
                child: LanguageSelectCard(
                  countryImage: Assets.icons.flags.flagNl.svg(
                    width: 26.w,
                    height: 17.h,
                    fit: BoxFit.cover,
                  ),
                  countryName: AppText.dutch,
                  controller: signupController,
                  selectedLan: 'nl',
                ),
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () {
                  signupController.selectedLanguage.value = 'de';
                },
                child: LanguageSelectCard(
                  countryImage: Assets.icons.flags.flagDe.svg(
                    width: 26.w,
                    height: 17.h,
                    fit: BoxFit.cover,
                  ),
                  countryName: AppText.german,
                  controller: signupController,
                  selectedLan: 'de',
                ),
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () {
                  signupController.selectedLanguage.value = 'es';
                },
                child: LanguageSelectCard(
                  countryImage: Assets.icons.flags.flagEs.svg(
                    width: 26.w,
                    height: 17.h,
                    fit: BoxFit.cover,
                  ),
                  countryName: AppText.spanish,
                  controller: signupController,
                  selectedLan: 'es',
                ),
              ),
            ],
          ),
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
                    if (signupController.selectedLanguage.isEmpty) {
                      showCustomToast(text: loc.pleaseSelectLanguage);
                    }
                    if (signupController.selectedLanguage.isNotEmpty) {
                      if (signupController.userRole.value ==
                          Users.EMPLOYEE.name) {
                        Get.toNamed(AppRoute.companyCredential);
                      } else if (signupController.userRole.value ==
                          Users.PRIVATE.name) {
                        Get.toNamed(AppRoute.createAccountScreen);
                      }
                    }
                    final lang = signupController.selectedLanguage.value;
                    AppHelper.instance.setLanguage(lang);
                    Get.updateLocale(Locale(lang));
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
                SizedBox(height: 12.h),
                PrimaryButton(
                  onTap: () {
                    Get.back();
                  },
                  text: loc.backButton,
                  backgroundColor: AppColors.text.withValues(alpha: 0.1),
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
