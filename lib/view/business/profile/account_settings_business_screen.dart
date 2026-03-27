import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:posture_detector_app/common/dialogs/edit_name_dialog.dart';
import 'package:posture_detector_app/common/widgets/back_button.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/view/business/profile/business_change_password_screen.dart';
import 'package:posture_detector_app/provider/author.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/profile_info.dart';

class AccountSettingsBusinessScreen extends ConsumerStatefulWidget {
  const AccountSettingsBusinessScreen({super.key});

  @override
  ConsumerState<AccountSettingsBusinessScreen> createState() =>
      _AccountSettingsBusinessScreenState();
}

class _AccountSettingsBusinessScreenState
    extends ConsumerState<AccountSettingsBusinessScreen> {
  final _nameController = TextEditingController();
  final RxBool _isLoading = false.obs;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final profile = ref.watch(authorNotifierProvider).value;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        // EN: "Account Settings"
        title: Text(loc.accountSettings),
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.only(left: 20.w, top: 7.h),
          child: AppBackButton(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 24.h),
              ProfileInfo(
                // EN: name = "Name", edit = "Edit"
                title: loc.name,
                value: profile?.data.fullName ?? 'username',
                tailingText: loc.edit,
                iconData: Iconsax.edit,
                onTap: () {
                  showEditNameDialog(
                    context,
                    nameController: _nameController,
                    isLoading: _isLoading,
                    initialValue: profile?.data.fullName ?? '',
                    onSave: () async {
                      _isLoading.value = true;
                      final success = await ref
                          .read(authorNotifierProvider.notifier)
                          .updateName(_nameController.text.trim());
                      _isLoading.value = false;
                      if (success) {
                        _nameController.clear();
                        Get.back();
                      }
                    },
                  );
                },
              ),
              SizedBox(height: 24.h),
              Divider(color: AppColors.secondaryText.withValues(alpha: 0.2)),
              SizedBox(height: 24.h),
              ProfileInfo(
                // EN: "Email"
                title: loc.email,
                value: profile?.data.email ?? 'example@gmail.com',
                onTap: () {},
              ),
              SizedBox(height: 24.h),
              Divider(color: AppColors.secondaryText.withValues(alpha: 0.2)),
              SizedBox(height: 24.h),
              ProfileInfo(
                // EN: password = "Password", change = "Change"
                title: loc.password,
                value: '••••••••••••',
                tailingText: loc.change,
                iconData: Iconsax.edit,
                onTap: () {
                  Get.to(() => const BusinessChangePasswordScreen());
                },
              ),
              SizedBox(height: 24.h),
              Divider(color: AppColors.secondaryText.withValues(alpha: 0.2)),
            ],
          ),
        ),
      ),
    );
  }
}
