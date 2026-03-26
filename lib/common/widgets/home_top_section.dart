import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';

class HomeTopSection extends StatelessWidget {
  final String name;
  final ImageProvider? image;

  const HomeTopSection({super.key, required this.name, this.image});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // EN: "Hi"
            Text(
              '${loc.hi} $name 👋',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            // EN: "Welcome Home"
            Text(
              loc.welcomeHome,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        if (image != null)
          CircleAvatar(radius: 22.r, backgroundImage: image)
        else
          CircleAvatar(
            radius: 22.r,
            backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
            child: Icon(
              Icons.person_rounded,
              size: 24.sp,
              color: AppColors.primaryColor,
            ),
          ),
      ],
    );
  }
}
