import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/provider/cpe_assessment.dart';
import 'package:posture_detector_app/view/cpe/widgets/assessment_helpers.dart';

class PhotoSectionCPE extends StatelessWidget {
  final CpeAssessmentState state;
  const PhotoSectionCPE({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(AppLocalizations.of(context)!.photos),
        SizedBox(height: 10.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...state.photoItems.map(
                (item) => Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: PhotoThumbnailCPE(item: item),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PhotoThumbnailCPE extends StatelessWidget {
  final PhotoItem item;
  const PhotoThumbnailCPE({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: item.isRemote
              ? CachedNetworkImage(
                  imageUrl: item.remoteUrl!,
                  width: 90.w,
                  height: 100.h,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => SizedBox(
                    width: 90.w,
                    height: 100.h,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 90.w,
                    height: 100.h,
                    color: const Color(0xFFEEEEEE),
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.grey,
                      size: 28.sp,
                    ),
                  ),
                )
              : Image.file(
                  File(item.path),
                  width: 90.w,
                  height: 100.h,
                  fit: BoxFit.cover,
                ),
        ),
      ],
    );
  }
}
