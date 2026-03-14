import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:posture_detector_app/controller/business_profile_controller.dart';
import 'package:posture_detector_app/controller/personal_profile_controller.dart';

import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'image_uploader.dart';

class ProfileInfoContainer extends StatelessWidget {
  final String userName;
  final String role;
  final String image;
  final PersonalProfileController? controller;
  final BusinessProfileController? businessController;

  const ProfileInfoContainer({
    super.key,
    required this.userName,
    required this.role,
    required this.image,
    this.controller,
    this.businessController,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        width: 335.w,
        height: 210.h,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          color: AppColors.onBoardingSurface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() {
              final currentImage =
                  controller?.profileInfo.value?.data.avatar ??
                  businessController?.profileInfo.value?.data.avatar;

              return ImageUploaderVOne(
                currentImage: currentImage,
                defaultImage: currentImage ?? Assets.icons.auth.user.path,
                onImageSelected: (file) {
                  if (controller != null) {
                    controller!.selectedImage.value = file;
                    controller!.updateImage();
                  } else if (businessController != null) {
                    businessController!.selectedImage.value = file;
                    businessController!.updateImage();
                  }
                },
              );
            }),

            SizedBox(height: 12.h),
            Text(
              userName,
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6.h),
            Text(
              role,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
