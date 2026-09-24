import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/common/widgets/app_top_section.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/provider/author.dart';
import 'package:posture_detector_app/view/auth/signup/waiting_company_response.dart';

/// Confirms the OTP sent to a new employee's email right after sign-up
/// (see EmployeeWorkDetailScreen), before they're sent to wait for company
/// approval. Mirrors ConfirmCodeForgotScreen's layout; kept separate because
/// it talks to a different pair of endpoints (verify-email / resend-
/// verification-code, keyed by user_id — not verify-reset-code, keyed by
/// email + a reset secret).
class EmployeeVerifyEmailScreen extends ConsumerStatefulWidget {
  const EmployeeVerifyEmailScreen({super.key});

  @override
  ConsumerState<EmployeeVerifyEmailScreen> createState() =>
      _EmployeeVerifyEmailScreenState();
}

class _EmployeeVerifyEmailScreenState
    extends ConsumerState<EmployeeVerifyEmailScreen> {
  static const _resendCooldownSeconds = 60;

  String _otp = '';
  bool _loading = false;
  bool _resending = false;
  int _resendCooldown = _resendCooldownSeconds;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  // Purely a UX nicety (the resend button reflects the same 60s window the
  // backend already enforces) — the server is the actual source of truth on
  // whether a resend is allowed.
  void _startCooldown() {
    setState(() => _resendCooldown = _resendCooldownSeconds);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown <= 1) {
        timer.cancel();
        setState(() => _resendCooldown = 0);
      } else {
        setState(() => _resendCooldown -= 1);
      }
    });
  }

  Future<void> _confirmCode() async {
    if (_otp.length != 6) return;
    setState(() => _loading = true);
    final ok = await ref
        .read(authorNotifierProvider.notifier)
        .verifySignupEmail(_otp);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WaitingCompanyResponse()),
      );
    }
  }

  Future<void> _resend() async {
    if (_resendCooldown > 0 || _resending) return;
    setState(() => _resending = true);
    await ref.read(authorNotifierProvider.notifier).resendOtp();
    if (!mounted) return;
    setState(() => _resending = false);
    _startCooldown();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTopSection(
                  title: loc.confirmEmail,
                  subtitle: loc.weSend6digitCode,
                ),
                SizedBox(height: 28.h),
                Text(
                  loc.enterOTP,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16.h),
                OtpTextField(
                  numberOfFields: 6,
                  cursorColor: AppColors.text,
                  fillColor: AppColors.surface,
                  filled: true,
                  focusedBorderColor: AppColors.primaryColor,
                  enabledBorderColor: AppColors.border,
                  showFieldAsBox: true,
                  borderRadius: BorderRadius.circular(12.r),
                  fieldWidth: 52.w,
                  borderWidth: 1.5,
                  fieldHeight: 56.w,
                  textStyle: TextStyle(
                    color: AppColors.text,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  onCodeChanged: (String code) => _otp = code,
                  onSubmit: (String verificationCode) {
                    _otp = verificationCode;
                    _confirmCode();
                  },
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      loc.donGetCode,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextButton(
                      onPressed: _resendCooldown > 0 || _resending
                          ? null
                          : _resend,
                      child: Text(
                        _resendCooldown > 0
                            ? '${loc.resendCode} (${_resendCooldown}s)'
                            : loc.resendCode,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          decoration: _resendCooldown > 0
                              ? TextDecoration.none
                              : TextDecoration.underline,
                          color: _resendCooldown > 0
                              ? AppColors.text.withValues(alpha: 0.4)
                              : AppColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: PrimaryButton(
          loading: _loading,
          text: loc.confirmCode,
          onTap: _confirmCode,
          backgroundColor: AppColors.primaryColor,
          textStyle: TextStyle(
            color: AppColors.surface,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
