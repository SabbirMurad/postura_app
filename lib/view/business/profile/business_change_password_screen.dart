import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';

import 'package:posture_detector_app/common/widgets/custom_text_field.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'package:posture_detector_app/provider/author.dart';

class BusinessChangePasswordScreen extends ConsumerStatefulWidget {
  const BusinessChangePasswordScreen({super.key});

  @override
  ConsumerState<BusinessChangePasswordScreen> createState() =>
      _BusinessChangePasswordScreenState();
}

class _BusinessChangePasswordScreenState
    extends ConsumerState<BusinessChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _submit(AppLocalizations loc) async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPassController.text != _confirmPassController.text) {
      showCustomToast(text: loc.passwordNotMatched);
      return;
    }

    setState(() => _loading = true);

    final success = await ref
        .read(authorNotifierProvider.notifier)
        .changePassword(
          currentPassword: _currentPassController.text.trim(),
          newPassword: _newPassController.text.trim(),
          confirmPassword: _confirmPassController.text.trim(),
        );

    setState(() => _loading = false);

    if (success) {
      _currentPassController.clear();
      _newPassController.clear();
      _confirmPassController.clear();
      showCustomToast(
        text: loc.passwordChangedSuccessfully,
        toastType: ToastTypesInfo(ToastTypes.success),
      );
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.updatePassword),
        backgroundColor: AppColors.surface,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
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
                  controller: _currentPassController,
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
                  controller: _newPassController,
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
                  controller: _confirmPassController,
                  isPassword: true,
                  validator: (value) {
                    if (value.length < 8) {
                      return 'password should be 8 character';
                    }
                    return null;
                  },
                ),

                const Spacer(),

                SafeArea(
                  bottom: true,
                  child: PrimaryButton(
                    text: loc.update,
                    loading: _loading,
                    textStyle: TextStyle(
                      color: AppColors.surface,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    onTap: () => _submit(loc),
                    backgroundColor: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
