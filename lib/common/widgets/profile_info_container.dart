import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/constants/colors.dart';
import 'package:posture_detector_app/provider/author.dart';
import 'image_uploader.dart';

class ProfileInfoContainer extends ConsumerWidget {
  final String userName;
  final String role;

  const ProfileInfoContainer({
    super.key,
    required this.userName,
    required this.role,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentImage = ref.watch(authorNotifierProvider).value?.data.avatar;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ImageUploaderVOne(
            currentImage: currentImage,
            defaultImage: currentImage ?? Assets.icons.auth.user.path,
            onImageSelected: (file) {
              ref.read(authorNotifierProvider.notifier).updateImage(file);
            },
            height: 136.w,
          ),
          SizedBox(height: 12.h),
          Text(
            userName,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6.h),
          Text(
            role,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
