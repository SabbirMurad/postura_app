import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/constants/app_text.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';

void showStartScanAlert(
  BuildContext context, {
  required VoidCallback onConfirm,
  VoidCallback? onCancel,
}) {
  final loc = AppLocalizations.of(context)!;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.onBoardingSurface,
      icon: Assets.icons.nav.cameraScan.svg(height: 46.h, width: 46.w),
      title: Center(
        child: Text(
          loc.startScan,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
        ),
      ),
      content: Text(
        loc.startScanInfo,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  height: 48.h,
                  onTap: () {
                    Navigator.of(context).pop();
                    onCancel?.call();
                  },
                  text: AppText.cancel,
                  backgroundColor: AppColors.greyDeemed,
                  textColor: AppColors.text,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: PrimaryButton(
                  onTap: onConfirm,
                  height: 48.h,
                  text: AppText.yesSure,
                  backgroundColor: AppColors.primaryColor,
                  textColor: AppColors.surface,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
