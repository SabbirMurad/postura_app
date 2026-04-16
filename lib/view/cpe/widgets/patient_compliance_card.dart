import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/provider/cpe_home.dart';

enum ComplianceStatus { excellent, good, moderate, low }

ComplianceStatus statusFromReview(String reviewStatus) {
  switch (reviewStatus) {
    case 'APPROVED':
      return ComplianceStatus.excellent;
    case 'PENDING':
      return ComplianceStatus.good;
    case 'FOLLOW_UP_REQUIRED':
      return ComplianceStatus.moderate;
    case 'NEED_CHANGE':
      return ComplianceStatus.low;
    default:
      return ComplianceStatus.good;
  }
}

class PatientComplianceCard extends StatelessWidget {
  final ScanItem scan;

  const PatientComplianceCard({super.key, required this.scan});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final status = statusFromReview(scan.reviewStatus);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.secondaryText.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scan.employeeName,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                SizedBox(height: 5.h),
                _InfoRow(
                  icon: Assets.icons.auth.employeeId.svg(
                    width: 16.w,
                    height: 16.w,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF0078B5),
                      BlendMode.srcIn,
                    ),
                  ),
                  label: '${scan.employeeId}',
                ),
                SizedBox(height: 5.h),
                _InfoRow(
                  icon: Assets.icons.workplace.desk.svg(
                    width: 16.w,
                    height: 16.w,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF0078B5),
                      BlendMode.srcIn,
                    ),
                  ),
                  label: scan.deskLocation,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${scan.compliance}%',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF202020),
                  height: 1,
                ),
              ),
              SizedBox(height: 2.h),
              // EN: "COMPLIANCE"
              Text(
                loc.complianceLabel,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A4A4A),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          SizedBox(width: 30.w),
          _StatusIcon(status: status),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final Widget icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF4A4F65),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final ComplianceStatus status;

  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    late SvgGenImage svgAsset;
    late Color bgColor;

    switch (status) {
      case ComplianceStatus.excellent:
        svgAsset = Assets.icons.status.approved;
        bgColor = const Color(0xFFF6FFF0);
        break;
      case ComplianceStatus.good:
        svgAsset = Assets.icons.status.pending;
        bgColor = const Color(0xFFEDEDED);
        break;
      case ComplianceStatus.moderate:
        svgAsset = Assets.icons.status.followupRequired;
        bgColor = const Color(0xFFDDF6FF);
        break;
      case ComplianceStatus.low:
        svgAsset = Assets.icons.status.needChanges;
        bgColor = const Color(0xFFFFF5D8);
        break;
    }

    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(9.w),
        child: svgAsset.svg(fit: BoxFit.contain),
      ),
    );
  }
}
