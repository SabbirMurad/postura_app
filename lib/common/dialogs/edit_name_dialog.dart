import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/custom_text_field.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';

void showEditNameDialog(
  BuildContext context, {
  required TextEditingController nameController,
  required RxBool isLoading,
  required VoidCallback onSave,
  String? initialValue,
}) {
  final loc = AppLocalizations.of(context)!;

  if (initialValue != null) {
    nameController.text = initialValue;
  }

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.onBoardingSurface,
        // EN: "Full Name"
        title: Text(
          loc.fullName,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14.sp,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // EN: "This name must match your Government ID"
            Text(
              loc.govtId,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.secondaryText,
              ),
            ),
            SizedBox(height: 8.h),
            CustomTextField(
              controller: nameController,
              maxLength: 32,
              showLimit: true,
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    onTap: () {
                      Get.back();
                    },
                    // EN: "Cancel"
                    text: loc.cancel,
                    backgroundColor: AppColors.greyDeemed,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Obx(() {
                    return PrimaryButton(
                      // EN: "Save"
                      text: loc.save,
                      backgroundColor: AppColors.primaryColor,
                      textColor: AppColors.onBoardingSurface,
                      onTap: onSave,
                      loading: isLoading.value,
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
      );
    },
  );
}
