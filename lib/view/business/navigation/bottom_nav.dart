import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/view/business/equipment/equipment_screen.dart';
// import 'package:posture_detector_app/features/auth/signup/business/equipment_screen_business.dart';
// import 'package:posture_detector_app/features/auth/signup/business/exercise_screen_business.dart';
import 'package:posture_detector_app/view/business/home/home_screen_business.dart';
import 'package:posture_detector_app/view/business/profile/profile_screen.dart';
import 'package:posture_detector_app/view/business/scan/scan_business_screen.dart';
import 'package:posture_detector_app/view/business/exercises/exercise_screen.dart';

import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/constants/app_colors.dart';

class BottomNavBusiness extends StatefulWidget {
  const BottomNavBusiness({super.key});

  @override
  State<BottomNavBusiness> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNavBusiness> {
  int currentIndex = 0;
  List<Widget> pages = [
    HomeScreenBusiness(),
    ExerciseBusinessScreen(),
    EquipmentScreenBusiness(
      canSendListToCompany: false,
      dashboardButton: false,
      backButton: false,
    ),
    ScanBusinessScreen(),
    ProfileScreen(),
  ];

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
                colorFilter: ColorFilter.mode(
                  AppColors.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 4.h, bottom: 5.h),
              child: Assets.icons.nav.exercise.svg(width: 24.h, height: 24.h),
            ),
            label: 'Exercise',
            activeIcon: Padding(
              padding: EdgeInsets.only(top: 4.h, bottom: 5.h),
              child: Assets.icons.nav.exerciseFilled.svg(
                width: 24.h,
                height: 24.h,
                colorFilter: ColorFilter.mode(
                  AppColors.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 4.h, bottom: 5.h),
              child: Assets.icons.nav.equipment.svg(width: 24.h, height: 24.h),
            ),
            label: 'Equipment',
            activeIcon: Padding(
              padding: EdgeInsets.only(top: 4.h, bottom: 5.h),
              child: Assets.icons.nav.equipmentFill.svg(
                width: 24.h,
                height: 24.h,
                colorFilter: ColorFilter.mode(
                  AppColors.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 4.h, bottom: 5.h),
              child: Assets.icons.nav.cameraScan.svg(width: 24.h, height: 24.h),
            ),
            label: 'scan',
            activeIcon: Padding(
              padding: EdgeInsets.only(top: 4.h, bottom: 5.h),
              child: Assets.icons.nav.cameraScanFilled.svg(
                width: 24.h,
                height: 24.h,
                colorFilter: ColorFilter.mode(
                  AppColors.primaryColor,
                  BlendMode.srcIn,
                ),
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
                colorFilter: ColorFilter.mode(
                  AppColors.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            label: 'settings',
          ),
        ],
      ),
    );
  }
}
