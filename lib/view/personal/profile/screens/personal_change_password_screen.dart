import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/controller/personal_change_password_controller.dart';
import 'package:posture_detector_app/common/widgets/custom_text_field.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';

class PersonalChangePasswordScreen extends StatelessWidget {
  PersonalChangePasswordScreen({super.key});

  final PersonalChangePasswordController changePassController = Get.put(
    PersonalChangePasswordController(),
  );
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.updatePassword),
        backgroundColor: AppColors.surface,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Get.back();
            changePassController.clearAll();
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.surface,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 25.h),
                CustomTextField(
                  hintText: loc.currentPassword,
                  controller: changePassController.currentPassController,
                  isPassword: true,
                  validator: (value) {
                    if (value.length < 8) {
                      return 'password should be 8 character';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 24.h),

                CustomTextField(
                  hintText: loc.newPassword,
                  controller: changePassController.newPassController,
                  isPassword: true,
                  validator: (value) {
                    if (value.length < 8) {
                      return 'password should be 8 character';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 24.h),
                CustomTextField(
                  hintText: loc.confirmPassword,
                  controller: changePassController.confirmPassController,
                  isPassword: true,
                  validator: (value) {
                    if (value.length < 8) {
                      return 'password should be 8 character';
                    }
                    return null;
                  },
                ),
                Spacer(),
                SafeArea(
                  bottom: true,
                  child: Obx(() {
                    return PrimaryButton(
                      text: loc.update,
                      loading: changePassController.isLoading.value,
                      textStyle: TextStyle(
                        color: AppColors.surface,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          if (changePassController.newPassController.text
                                  .toString() ==
                              changePassController.confirmPassController.text
                                  .toString()) {
                            changePassController.changePassword();
                          } else {
                            showCustomToast(text: loc.passwordNotMatched);
                          }
                        }
                      },
                      backgroundColor: AppColors.primaryColor,
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
