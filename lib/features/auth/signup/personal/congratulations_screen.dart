import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/core/routes/app_routes.dart';

import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';

class CongratulationsScreen extends StatelessWidget {
  const CongratulationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        // crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Assets.images.general.congrats.image(width: 172.w, height: 162.h),
          ),
          SizedBox(height: 30.h),
          Text(
            loc.congrats,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 24.sp,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            loc.yourAccountCreated,
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 24.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      bottomSheet: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: PrimaryButton(
          leading: Assets.icons.general.instantScan.svg(
            color: AppColors.onBoardingSurface,
          ),
          text: loc.startCapturing,
          backgroundColor: AppColors.primaryColor,
          textColor: AppColors.onBoardingSurface,
          onTap: () {
            Get.offAllNamed(AppRoute.employeeSelectBodyRegion);
          },
        ),
      ),
    );
  }
}
