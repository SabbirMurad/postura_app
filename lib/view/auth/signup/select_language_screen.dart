import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/constants/app_text.dart';
import 'package:posture_detector_app/view/auth/signup/widgets/language_selected_card.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/helpers/app_helper.dart';
import 'package:posture_detector_app/provider/locale_provider.dart';
import 'package:posture_detector_app/provider/signup.dart';

class SelectLanguageScreen extends ConsumerWidget {
  const SelectLanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final selectedLanguage = ref.watch(signupNotifierProvider).language;
    final notifier = ref.read(signupNotifierProvider.notifier);

    void selectLanguage(String lang) {
      notifier.setLanguage(lang);
    }

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
                // EN: selectLanguage = "Select Language", selectLanguageSubtitle = "Select your preferred language"
                title: loc.selectLanguage,
                subtitle: loc.selectLanguageSubtitle,
              ),
              SizedBox(height: 48.h),

              GestureDetector(
                onTap: () => selectLanguage('en'),
                child: LanguageSelectCard(
                  countryImage: Assets.icons.flags.flagEn.svg(
                    width: 26.w,
                    height: 17.h,
                    fit: BoxFit.cover,
                  ),
                  countryName: AppText.english,
                  selectedLanguage: selectedLanguage,
                  selectedLan: 'en',
                ),
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () => selectLanguage('nl'),
                child: LanguageSelectCard(
                  countryImage: Assets.icons.flags.flagNl.svg(
                    width: 26.w,
                    height: 17.h,
                    fit: BoxFit.cover,
                  ),
                  countryName: AppText.dutch,
                  selectedLanguage: selectedLanguage,
                  selectedLan: 'nl',
                ),
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () => selectLanguage('de'),
                child: LanguageSelectCard(
                  countryImage: Assets.icons.flags.flagDe.svg(
                    width: 26.w,
                    height: 17.h,
                    fit: BoxFit.cover,
                  ),
                  countryName: AppText.german,
                  selectedLanguage: selectedLanguage,
                  selectedLan: 'de',
                ),
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () => selectLanguage('es'),
                child: LanguageSelectCard(
                  countryImage: Assets.icons.flags.flagEs.svg(
                    width: 26.w,
                    height: 17.h,
                    fit: BoxFit.cover,
                  ),
                  countryName: AppText.spanish,
                  selectedLanguage: selectedLanguage,
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
                    if (selectedLanguage.isEmpty) {
                      // EN: "Please select a language"
                      showCustomToast(text: loc.pleaseSelectLanguage);
                      return;
                    }
                    AppHelper.instance.setLanguage(selectedLanguage);
                    ref.read(localeProvider.notifier).state = Locale(selectedLanguage);
                    context.push(AppRoute.companyCredential);
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
                SizedBox(height: 12.h),
                PrimaryButton(
                  onTap: () {
                    context.pop();
                  },
                  // EN: "Back"
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
