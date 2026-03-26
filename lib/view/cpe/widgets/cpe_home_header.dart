import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
              loc.welcomeTitle,
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF8A8FA3),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        avatarUrl.isNotEmpty
            ? CircleAvatar(
                radius: 22.r,
                backgroundImage: NetworkImage(avatarUrl),
              )
            : CircleAvatar(
                radius: 22.r,
                backgroundColor: const Color(0xFF2563EB),
                child: Icon(Icons.person, color: Colors.white, size: 22.sp),
              ),
      ],
    );
  }
}
