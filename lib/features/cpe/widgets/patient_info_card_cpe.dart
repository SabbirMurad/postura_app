import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/features/cpe/controller/assessment_controller_cpe.dart';
import 'package:posture_detector_app/features/cpe/widgets/assessment_helpers.dart';

class PatientInfoCardCPE extends StatelessWidget {
  final CPEAssessmentController controller;
  const PatientInfoCardCPE({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 14.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.patientName.value,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF202020),
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Assets.icons.auth.employeeId.svg(
                      width: 16.w,
                      height: 16.w,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF0078B5),
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      controller.patientId.value,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF4A4F65),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: statusBgColor(controller.decision.value),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: decisionSvgIcon(controller.decision.value, size: 20.w),
            ),
          ),
        ],
      ),
    );
  }
}

class DeskInfoSectionCPE extends StatelessWidget {
  final CPEAssessmentController controller;
  const DeskInfoSectionCPE({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(loc.deskInfo),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.deskIdLocation,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF4A4A4A),
                    ),
                  ),
                  Text(
                    loc.roleLabel,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF4A4A4A),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Assets.icons.workplace.desk.svg(
                        width: 16.w,
                        height: 16.w,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF0078B5),
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        controller.deskLocation.value,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF202020),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    controller.deskRole.value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF202020),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PainSymptomsSectionCPE extends StatelessWidget {
  final CPEAssessmentController controller;
  const PainSymptomsSectionCPE({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(loc.painAndSymptoms),
        SizedBox(height: 8.h),
        ...controller.painSymptoms.map(
          (symptom) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: PainCardCPE(symptom: symptom),
          ),
        ),
      ],
    );
  }
}

class PainCardCPE extends StatelessWidget {
  final PainSymptom symptom;
  const PainCardCPE({super.key, required this.symptom});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                symptom.area,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF202020),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                symptom.duration,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF4A4A4A),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${symptom.intensity}',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF202020),
                  height: 1,
                ),
              ),
              Text(
                loc.painIntensityLabel,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF4A4A4A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
