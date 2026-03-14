import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/controller/personal_profile_controller.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/core/constants/app_text.dart';
import 'package:posture_detector_app/controller/e_learning_controller.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/data/helpers/app_helper.dart';

class PersonalLanguageScreen extends StatelessWidget {
  const PersonalLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final PersonalProfileController personalProfileController = Get.find<PersonalProfileController>();

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
                  personalProfileController.selectedLanguage.value = 'en';
                },
                child: LanguageSelectCardProfile(
                  countryImage: Assets.icons.flags.flagEn.svg(
                    width: 26.w,
                    height: 17.h,
                    fit: BoxFit.cover,
                  ),
                  countryName: AppText.english,
                  controller: personalProfileController,
                  selectedLan: 'en',
                ),
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () {
                  personalProfileController.selectedLanguage.value = 'nl';
                },
                child: LanguageSelectCardProfile(
                  countryImage: Assets.icons.flags.flagNl.svg(
                    width: 26.w,
                    height: 17.h,
                    fit: BoxFit.cover,
                  ),
                  countryName: AppText.dutch,
                  controller: personalProfileController,
                  selectedLan: 'nl',
                ),
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () {
                  personalProfileController.selectedLanguage.value = 'de';
                },
                child: LanguageSelectCardProfile(
                  countryImage: Assets.icons.flags.flagDe.svg(
                    width: 26.w,
                    height: 17.h,
                    fit: BoxFit.cover,
                  ),
                  countryName: AppText.german,
                  controller: personalProfileController,
                  selectedLan: 'de',
                ),
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () {
                  personalProfileController.selectedLanguage.value = 'es';
                },
                child: LanguageSelectCardProfile(
                  countryImage: Assets.icons.flags.flagEs.svg(
                    width: 26.w,
                    height: 17.h,
                    fit: BoxFit.cover,
                  ),
                  countryName: AppText.spanish,
                  controller: personalProfileController,
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
                    final lang = personalProfileController.selectedLanguage.value;
                    AppHelper.instance.setLanguage(lang);
                    Get.updateLocale(Locale(lang));
                    if (Get.isRegistered<ELearningController>()) {
                      Get.find<ELearningController>().loadModulesForLocale(lang);
                    }
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
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class LanguageSelectCardProfile extends StatelessWidget {
  final SvgPicture countryImage;
  final String countryName;
  final PersonalProfileController controller;
  final String selectedLan;

  const LanguageSelectCardProfile({
    super.key,
    required this.countryImage,
    required this.countryName,
    required this.controller,
    required this.selectedLan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65.h,
      width: 335.w,
      decoration: BoxDecoration(
        color: AppColors.onBoardingSurface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Obx(() {
        return Center(
          child: ListTile(
            leading: countryImage,
            title: Text(
              countryName,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
            ),
            trailing: selectedLan == controller.selectedLanguage.value
                ? Container(
              width: 25.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor,
              ),
              child: Center(child: Icon(Icons.check, color: AppColors.surface)),
            )
                : null,
          ),
        );
      }),
    );
  }
}

