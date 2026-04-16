import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/provider/cpe_assessment.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF202020),
      ),
    );
  }
}

Widget decisionSvgIcon(ReviewDecision decision, {required double size}) {
  switch (decision) {
    case ReviewDecision.approved:
      return Assets.icons.status.approved.svg(width: size, height: size);
    case ReviewDecision.followUpRequired:
      return Assets.icons.status.followupRequired.svg(
        width: size,
        height: size,
      );
    case ReviewDecision.needChanges:
      return Assets.icons.status.needChanges.svg(width: size, height: size);
    case ReviewDecision.pending:
      return Assets.icons.status.pending.svg(width: size, height: size);
  }
}

Color statusBgColor(ReviewDecision decision) {
  switch (decision) {
    case ReviewDecision.approved:
      return const Color(0xFFF6FFF0);
    case ReviewDecision.followUpRequired:
      return const Color(0xFFDDF6FF);
    case ReviewDecision.needChanges:
      return const Color(0xFFFFF5D8);
    case ReviewDecision.pending:
      return const Color(0xFFEDEDED);
  }
}

BoxDecoration cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12.r),
    border: Border.all(color: AppColors.secondaryText.withValues(alpha: 0.15)),
  );
}
