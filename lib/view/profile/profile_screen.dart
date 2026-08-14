import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/provider/author.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/dialogs/logout_confirm_dialog.dart';
import 'package:posture_detector_app/common/widgets/profile_info_container.dart';
import 'package:posture_detector_app/common/widgets/settings_container.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final profile = ref.watch(authorNotifierProvider).value;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileInfoContainer(
                  userName: profile?.fullName ?? 'username',
                  role: profile?.role ?? 'role',
                ),
                SizedBox(height: 12.h),
                SettingsContainer(
                  iconData: Assets.icons.auth.person.path,
                  // EN: "Account Settings"
                  title: loc.accountSettings,
                  onTap: () {
                    context.push(AppRoute.businessAccountSettings);
                  },
                ),
                SizedBox(height: 12.h),
                SettingsContainer(
                  iconData: Assets.icons.general.notification.path,
                  // EN: "Notifications"
                  title: loc.notifications,
                  onTap: () {
                    // TODO: Implement notifications navigation
                  },
                ),
                SizedBox(height: 12.h),
                SettingsContainer(
                  iconData: Assets.icons.general.learning.path,
                  // EN: "E-Learning"
                  title: loc.elearning,
                  onTap: () {
                    context.push(AppRoute.elearning);
                  },
                ),
                SizedBox(height: 12.h),
                SettingsContainer(
                  iconData: Assets.icons.general.language.path,
                  // EN: "Language"
                  title: loc.language,
                  onTap: () {
                    context.push(AppRoute.businessLanguage);
                  },
                ),
                SizedBox(height: 12.h),
                SettingsContainer(
                  iconData: Assets.icons.general.policy.path,
                  // EN: "Privacy & Policy"
                  title: loc.privacyPolicy,
                  onTap: () {
                    context.push(AppRoute.privacyPolicy);
                  },
                ),
                SizedBox(height: 12.h),
                SettingsContainer(
                  iconData: Assets.icons.general.logout.path,
                  // EN: "Logout"
                  title: loc.logout,
                  onTap: () {
                    showLogoutConfirmDialog(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
