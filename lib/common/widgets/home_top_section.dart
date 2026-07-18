import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:posture_detector_app/common/widgets/network_hashed_image_viewer.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';

import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/models/media/image.dart';

class HomeTopSection extends StatelessWidget {
  final String name;
  final ImageModel? image;

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
              loc.welcomeToPostura,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
            ),
          ],
        ),

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            color: Colors.grey[200],
            border: Border.all(
              color: AppColors.secondaryText.withValues(alpha: 0.15),
            ),
          ),
          width: 48.w,
          height: 48.w,
          child: image == null
              ? Center(
                  child: SvgPicture.asset(
                    Assets.icons.auth.user.path,
                    width: 24.w,
                    height: 24.w,
                    color: AppColors.primaryColor,
                  ),
                )
              : NetworkHashedImageViewer(
                  image: image!,
                  width: 28.w,
                  height: 28.w,
                  fit: BoxFit.cover,
                ),
        ),
      ],
    );
  }
}
