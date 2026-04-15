import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/common/widgets/custom_text_field.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'package:posture_detector_app/services/network/custom_http.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/provider/signup.dart';
import 'package:posture_detector_app/routes.dart';

class CompanyCredentialScreen extends ConsumerStatefulWidget {
  const CompanyCredentialScreen({super.key});

  @override
  ConsumerState<CompanyCredentialScreen> createState() =>
      _CompanyCredentialScreenState();
}

class _CompanyCredentialScreenState
    extends ConsumerState<CompanyCredentialScreen> {
  final _companyCodeController = TextEditingController();

  @override
  void dispose() {
    _companyCodeController.dispose();
    super.dispose();
  }

  bool _loading = false;

  Future<void> _checkCompanyCode(AppLocalizations loc) async {
    final code = _companyCodeController.text.trim();
    if (code.isEmpty) {
      // EN: "Please enter company code"
      showCustomToast(text: loc.pleaseEnterCompanyCode);
      return;
    }

    setState(() {
      _loading = true;
    });

    final response = await CustomHttp.post(
      endpoint: 'auth/validate-company-code',
      body: {'company_code': code},
      needAuth: false,
    );

    if (response.ok) {
      ref.read(signupNotifierProvider.notifier).setCompanyCode(code);
      context.push(AppRoute.employeeCredential);
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

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
                controller: _companyCodeController,
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
                  onTap: () => _checkCompanyCode(loc),
                  // EN: "Continue"
                  text: loc.continueButton,
                  loading: _loading,
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
