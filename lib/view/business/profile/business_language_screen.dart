import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/core/constants/app_text.dart';
import 'package:posture_detector_app/controller/e_learning_controller.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/helpers/app_helper.dart';

class BusinessLanguageScreen extends StatefulWidget {
  const BusinessLanguageScreen({super.key});

  @override
  State<BusinessLanguageScreen> createState() => _BusinessLanguageScreenState();
}

class _BusinessLanguageScreenState extends State<BusinessLanguageScreen> {
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final saved = await AppHelper.instance.getLanguage();
    if (saved != null && mounted) {
      setState(() => _selectedLanguage = saved);
    }
  }

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
              // EN: selectLanguage = "Select Language", selectLanguageSubtitle = "Select your preferred language"
              AppTopSection(
                title: loc.selectLanguage,
                subtitle: loc.selectLanguageSubtitle,
              ),
              SizedBox(height: 48.h),

              GestureDetector(
                onTap: () => setState(() => _selectedLanguage = 'en'),
                child: LanguageSelectCard(
                  countryImage: Assets.icons.flags.flagEn.svg(
                    width: 26.w,
                    height: 17.h,
                    fit: BoxFit.cover,
                  ),
                  countryName: AppText.english,
                  selectedLanguage: _selectedLanguage,
                  value: 'en',
                ),
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () => setState(() => _selectedLanguage = 'nl'),
                child: LanguageSelectCard(
                  countryImage: Assets.icons.flags.flagNl.svg(
                    width: 26.w,
                    height: 17.h,
                    fit: BoxFit.cover,
                  ),
                  countryName: AppText.dutch,
                  selectedLanguage: _selectedLanguage,
                  value: 'nl',
                ),
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () => setState(() => _selectedLanguage = 'de'),
                child: LanguageSelectCard(
                  countryImage: Assets.icons.flags.flagDe.svg(
                    width: 26.w,
                    height: 17.h,
                    fit: BoxFit.cover,
                  ),
                  countryName: AppText.german,
                  selectedLanguage: _selectedLanguage,
                  value: 'de',
                ),
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () => setState(() => _selectedLanguage = 'es'),
                child: LanguageSelectCard(
                  countryImage: Assets.icons.flags.flagEs.svg(
                    width: 26.w,
                    height: 17.h,
                    fit: BoxFit.cover,
                  ),
                  countryName: AppText.spanish,
                  selectedLanguage: _selectedLanguage,
                  value: 'es',
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButton(
                onTap: () {
                  AppHelper.instance.setLanguage(_selectedLanguage);
                  Get.updateLocale(Locale(_selectedLanguage));
                  if (Get.isRegistered<ELearningController>()) {
                    Get.find<ELearningController>().loadModulesForLocale(_selectedLanguage);
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
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}

class LanguageSelectCard extends StatelessWidget {
  final SvgPicture countryImage;
  final String countryName;
  final String selectedLanguage;
  final String value;

  const LanguageSelectCard({
    super.key,
    required this.countryImage,
    required this.countryName,
    required this.selectedLanguage,
    required this.value,
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
      child: Center(
        child: ListTile(
          leading: countryImage,
          title: Text(
            countryName,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
          ),
          trailing: value == selectedLanguage
              ? Container(
                  width: 25.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryColor,
                  ),
                  child: Center(
                    child: Icon(Icons.check, color: AppColors.surface),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
