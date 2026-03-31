import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/provider/cpe_home.dart';
import 'package:posture_detector_app/provider/author.dart';
import 'package:posture_detector_app/view/cpe/widgets/cpe_home_header.dart';
import 'package:posture_detector_app/view/cpe/widgets/patient_compliance_card.dart';

class HomeScreenCPE extends ConsumerWidget {
  const HomeScreenCPE({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final profile = ref.watch(authorNotifierProvider).value;
    final homeState = ref.watch(cpeHomeNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              if (profile != null)
                CpeHomeHeader(
                  userName: profile.data.fullName,
                  avatarUrl: profile.data.avatar?.toString() ?? '',
                )
              else
                SizedBox(height: 48.h),

              SizedBox(height: 24.h),
              Expanded(child: _buildBody(context, ref, homeState, loc)),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, CpeHomeState state, AppLocalizations loc) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              loc.somethingWentWrong,
              style: TextStyle(fontSize: 14.sp, color: Colors.red),
            ),
            SizedBox(height: 12.h),
            ElevatedButton(
              onPressed: () => ref.read(cpeHomeNotifierProvider.notifier).fetchAssessmentList(),
              child: Text(loc.retry),
            ),
          ],
        ),
      );
    }

    if (state.scanList.isEmpty) {
      return Center(
        child: Text(
          loc.noPatientsFound,
          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF8A8FA3)),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(cpeHomeNotifierProvider.notifier).fetchAssessmentList(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.scanList.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final scan = state.scanList[index];
          return GestureDetector(
            onTap: () => Get.toNamed(
              AppRoute.cpeAssessment,
              arguments: {
                'scan_id': scan.scanId,
                'assessment_id': scan.assessmentId,
                'name': scan.employeeName,
                'id': '${scan.employeeId}',
                'compliance': scan.compliance,
                'desk_location': scan.deskLocation,
                'risk_level': scan.riskLevel,
                'vas_score': scan.vasScore,
                'review_status': scan.reviewStatus,
              },
            ),
            child: PatientComplianceCard(scan: scan),
          );
        },
      ),
    );
  }
}
