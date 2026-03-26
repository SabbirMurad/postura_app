import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/common/widgets/custom_text_field.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/controller/signup_controller.dart';
import 'package:posture_detector_app/data/services/network/custom_http.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/routes.dart';

class CompanyCredentialScreen extends StatelessWidget {
  CompanyCredentialScreen({super.key});

  final SignupController signupController = Get.find<SignupController>();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    Future<void> _checkCompanyCode(code) async {
      final response = await CustomHttp.post(
        endpoint: 'auth/validate-company-code',
        body: {'company_code': code},
        needAuth: false,
      );

      if (response.ok) {
        Get.toNamed(AppRoute.employeeCredential);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              AppTopSection(
                // EN: companyLogin = "Company Login", companyLoginSubtitle = "Enter your company code to continue"
                title: loc.signUp,
                subtitle: loc.companyLoginSubtitle,
              ),

              SizedBox(height: 28.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  // EN: "Enter your company code"
                  loc.enterYourCompanyCode,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              CustomTextField(
                prefixIcon: null,
                filled: true,
                filColor: AppColors.onBoardingSurface,
                controller: signupController.companyCodeController,
                // EN: "e.g. COMPANY-123"
                hintText: loc.enterYourCompanyCodeHint,
                keyboardType: TextInputType.text,
              ),
            ],
          ),
        ),
      ),
      bottomSheet: SafeArea(
        child: SizedBox(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PrimaryButton(
                  onTap: () {
                    if (signupController.companyCodeController.text.isEmpty) {
                      // EN: "Please enter company code"
                      showCustomToast(text: loc.pleaseEnterCompanyCode);
                      return;
                    }

                    _checkCompanyCode(
                      signupController.companyCodeController.text,
                    );
                  },
                  // EN: "Continue"
                  text: loc.continueButton,
                  backgroundColor: AppColors.primaryColor,
                  textStyle: TextStyle(
                    color: AppColors.surface,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      // EN: "I don't have a code →"
                      loc.iDonHaveCode,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        // EN: "Contact Administrator"
                        loc.contactAdministration,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
