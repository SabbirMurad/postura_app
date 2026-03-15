import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';

import 'package:posture_detector_app/view/cpe/screens/home_screen_cpe.dart';
import 'package:posture_detector_app/view/cpe/screens/setting_screen_cpe.dart';

class BottomNavCPE extends StatefulWidget {
  const BottomNavCPE({super.key});

  @override
  State<BottomNavCPE> createState() => _BottomNavCPEState();
}

class _BottomNavCPEState extends State<BottomNavCPE> {
  int currentIndex = 0;
  List<Widget> pages = [HomeScreenCPE(), SettingScreenCPE()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: AppColors.onBoardingSurface,
        unselectedItemColor: AppColors.text,
        type: BottomNavigationBarType.fixed,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        selectedItemColor: AppColors.primaryColor,
        unselectedFontSize: 13.sp,
        selectedFontSize: 13.sp,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
        items: [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 4.h, bottom: 5.h),
              child: Assets.icons.nav.home.svg(width: 24.h, height: 24.h),
            ),
            label: 'Home',
            activeIcon: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Assets.icons.nav.homeFilled.svg(
                width: 24.h,
                height: 24.h,
                colorFilter: ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
              ),
            ),
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 4.h, bottom: 5.h),
              child: Assets.icons.nav.settings.svg(width: 24.h, height: 24.h),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(top: 4.h, bottom: 5.h),
              child: Assets.icons.nav.settingsFilled.svg(
                width: 24.h,
                height: 24.h,
                colorFilter: ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
              ),
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
