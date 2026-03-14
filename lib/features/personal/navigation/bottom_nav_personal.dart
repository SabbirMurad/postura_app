import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/features/personal/home/screens/home_screen_personal.dart';
import 'package:posture_detector_app/features/personal/profile/screens/profile_screen_personal.dart';
import 'package:posture_detector_app/features/personal/scan/screens/scan_personal_screen.dart';

import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/features/personal/exercises/screens/exercise_personal_screen.dart';

class BottomNavPersonal extends StatefulWidget {
  const BottomNavPersonal({super.key});

  @override
  State<BottomNavPersonal> createState() => _BottomNavPersonalState();
}

class _BottomNavPersonalState extends State<BottomNavPersonal> {
  int currentIndex = 0;
  List<Widget> pages = [
    HomeScreenPersonal(),
    ExercisePersonalScreen(),
    ScanPersonalScreen(),
    ProfileScreenPersonal(),
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
              child: Assets.icons.nav.homeFilled.svg(width: 24.h, height: 24.h),
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
                width: 25.h,
                height: 25.h,
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
              ),
            ),
            label: 'settings',
          ),
        ],
      ),
    );
  }
}
