import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/controller/signup_controller.dart';

class LanguageSelectCard extends StatelessWidget {
  final SvgPicture countryImage;
  final String countryName;
  final SignupController controller;
  final String selectedLan;

  const LanguageSelectCard({
    super.key,
    required this.countryImage,
    required this.countryName,
    required this.controller,
    required this.selectedLan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65.h,
      width: 335.w,
      decoration: BoxDecoration(
        color: AppColors.onBoardingSurface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Obx(() {
        return Center(
          child: ListTile(
            leading: countryImage,
            title: Text(
              countryName,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
            ),
            trailing: selectedLan == controller.selectedLanguage.value
                ? Container(
              width: 25.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor,
              ),
              child: Center(child: Icon(Icons.check, color: AppColors.surface)),
            )
                : null,
          ),
        );
      }),
    );
  }
}
