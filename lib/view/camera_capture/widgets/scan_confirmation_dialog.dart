import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/core/constants/app_text.dart';

void showScanConfirmationDialog(
  BuildContext context, {
  required Widget icon,
  required String title,
  required String content,
  required VoidCallback onCancel,
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.onBoardingSurface,
      icon: icon,
      title: Center(
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      content: Text(
        content,
        textAlign: TextAlign.center,
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                height: 48.h,
                onTap: onCancel,
                text: AppText.cancel,
                backgroundColor: AppColors.greyDeemed,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: PrimaryButton(
                onTap: onConfirm,
                height: 48.h,
                text: AppText.yesSure,
                backgroundColor: AppColors.primaryColor,
                textColor: AppColors.onBoardingSurface,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
