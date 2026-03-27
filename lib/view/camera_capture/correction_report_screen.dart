import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/provider/report.dart';

import 'package:posture_detector_app/common/widgets/bottom_button.dart';
import 'package:posture_detector_app/common/widgets/expansion_container.dart';

class CorrectionReportScreenBusiness extends ConsumerWidget {
  const CorrectionReportScreenBusiness({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportState = ref.watch(reportNotifierProvider);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      // ✅ extendBody: true দিয়ে body কে bottomSheet এর পিছনে extend করুন
      extendBody: true,
      body: SafeArea(
        // ✅ bottom: false দিয়ে bottom safe area disable করুন
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20.h),
                // EN: miniIsoCorrection = "Mini ISO Correction", miniIsoCorrectionSubtitle = "Here are some corrections based on ISO 9241 standards"
                AppTopSection(
                  title: loc.miniIsoCorrection,
                  subtitle: loc.miniIsoCorrectionSubtitle,
                ),

                SizedBox(height: 14.h),

                // ✅ ListView কে removed করা হয়েছে, শুধু Column রাখা
                Builder(
                  builder: (context) {
                  final corrections = reportState.analysisData
                      ?.aiResult
                      .corrections;

                  return Column(
                    children: List.generate(corrections?.length ?? 0, (index) {
                      final correctReport = corrections?[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: ExpansionContainer(
                          title: correctReport?.title ?? 'title',
                          leading: '',
                          content: correctReport?.description ?? 'description',
                        ),
                      );
                    }),
                  );
                  },
                ),

                // ✅ Bottom button এর জন্য space (padding)
                SizedBox(height: 90.h),
              ],
            ),
          ),
        ),
      ),
      // ✅ bottomSheet: Padding এবং SafeArea দিয়ে wrap করুন
      bottomSheet: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 20.h),
          child: BottomButton(
            // EN: "View Exercise"
            title: loc.viewExercise,
            onTap: () {
              Get.toNamed(AppRoute.exerciseBusiness);
            },
          ),
        ),
      ),
    );
  }
}
