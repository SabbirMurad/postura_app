import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
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
                        title: loc.ppDataCollectionTitle,
                        content: loc.ppDataCollectionContent,
                      ),
                      SizedBox(height: 20.h),
                      _PolicySection(
                        title: loc.ppHowWeUseTitle,
                        content: loc.ppHowWeUseContent,
                      ),
                      SizedBox(height: 20.h),
                      _PolicySection(
                        title: loc.ppDataStorageTitle,
                        content: loc.ppDataStorageContent,
                      ),
                      SizedBox(height: 20.h),
                      _PolicySection(
                        title: loc.ppYourRightsTitle,
                        content: loc.ppYourRightsContent,
                      ),
                      SizedBox(height: 20.h),
                      _PolicySection(
                        title: loc.ppDataSharingTitle,
                        content: loc.ppDataSharingContent,
                      ),
                      SizedBox(height: 20.h),
                      _PolicySection(
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
