import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              // EN: privacyPolicy = "Privacy & Policy", privacyPolicySubtitle = "Please read our privacy policy carefully"
              AppTopSection(
                title: loc.privacyPolicy,
                subtitle: loc.privacyPolicySubtitle,
              ),
              SizedBox(height: 24.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PolicySection(
                        // EN: ppDataCollectionTitle = "Data Collection", ppDataCollectionContent = "We collect personal information..."
                        title: loc.ppDataCollectionTitle,
                        content: loc.ppDataCollectionContent,
                      ),
                      SizedBox(height: 20.h),
                      _PolicySection(
                        // EN: ppHowWeUseTitle = "How We Use Your Data", ppHowWeUseContent = "We use your data to..."
                        title: loc.ppHowWeUseTitle,
                        content: loc.ppHowWeUseContent,
                      ),
                      SizedBox(height: 20.h),
                      _PolicySection(
                        // EN: ppDataStorageTitle = "Data Storage", ppDataStorageContent = "Your data is stored securely..."
                        title: loc.ppDataStorageTitle,
                        content: loc.ppDataStorageContent,
                      ),
                      SizedBox(height: 20.h),
                      _PolicySection(
                        // EN: ppYourRightsTitle = "Your Rights", ppYourRightsContent = "You have the right to..."
                        title: loc.ppYourRightsTitle,
                        content: loc.ppYourRightsContent,
                      ),
                      SizedBox(height: 20.h),
                      _PolicySection(
                        // EN: ppDataSharingTitle = "Data Sharing", ppDataSharingContent = "We do not share your data..."
                        title: loc.ppDataSharingTitle,
                        content: loc.ppDataSharingContent,
                      ),
                      SizedBox(height: 20.h),
                      _PolicySection(
                        // EN: ppContactTitle = "Contact Us", ppContactContent = "If you have any questions..."
                        title: loc.ppContactTitle,
                        content: loc.ppContactContent,
                      ),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String content;

  const _PolicySection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          content,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.text.withValues(alpha: 0.7),
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
