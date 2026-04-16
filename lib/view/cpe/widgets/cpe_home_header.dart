import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';

class CpeHomeHeader extends StatelessWidget {
  final String userName;
  final String avatarUrl;

  const CpeHomeHeader({
    super.key,
    required this.userName,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // EN: "Hi"
                Text(
                  '${loc.hi} $userName ',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const Text('👋', style: TextStyle(fontSize: 20)),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              // EN: "Stand Tall, Feel Great"
              loc.welcomeToPostura,
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF8A8FA3),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            color: Colors.grey[200],
            image: avatarUrl.isNotEmpty
                ? DecorationImage(image: CachedNetworkImageProvider(avatarUrl))
                : null,
            border: Border.all(
              color: AppColors.secondaryText.withValues(alpha: 0.15),
            ),
          ),
          width: 48.w,
          height: 48.w,
          child: avatarUrl.isEmpty
              ? Center(
                  child: SvgPicture.asset(
                    Assets.icons.auth.user.path,
                    width: 24.w,
                    height: 24.w,
                    color: AppColors.primaryColor,
                  ),
                )
              : null,
        ),
      ],
    );
  }
}
