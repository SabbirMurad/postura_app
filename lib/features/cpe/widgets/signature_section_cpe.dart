import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/controller/assessment_controller_cpe.dart';
import 'package:posture_detector_app/features/cpe/widgets/assessment_helpers.dart';

class SignatureSectionCPE extends StatelessWidget {
  final CPEAssessmentController controller;
  const SignatureSectionCPE({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(AppLocalizations.of(context)!.addSignature),
        SizedBox(height: 10.h),
        Obx(() {
          final localPath = controller.signaturePath.value;
          final remoteUrl = controller.signatureRemoteUrl.value;
          final hasLocal = localPath.isNotEmpty;
          final hasRemote = remoteUrl.isNotEmpty;
          final hasAny = hasLocal || hasRemote;

          return GestureDetector(
            onTap: controller.initialReviewStatus.value == 'PENDING'
                ? controller.pickSignature
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: 120.h,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF3FF),
                borderRadius: BorderRadius.circular(16.r),
                border:
                    Border.all(color: const Color(0xFFBDD0FF), width: 1.5),
              ),
              child: hasAny
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: hasLocal
                              ? Image.file(
                                  File(localPath),
                                  width: double.infinity,
                                  height: 120.h,
                                  fit: BoxFit.contain,
                                )
                              : CachedNetworkImage(
                                  imageUrl: remoteUrl,
                                  width: double.infinity,
                                  height: 120.h,
                                  fit: BoxFit.contain,
                                  placeholder: (_, __) => const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: Colors.grey,
                                      size: 28.sp,
                                    ),
                                  ),
                                ),
                        ),
                        if (hasLocal)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: controller.removeSignature,
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 14.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.upload_rounded,
                            size: 26.sp,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          AppLocalizations.of(context)!.uploadSignature,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
            ),
          );
        }),
        SizedBox(height: 6.h),
        Obx(
          () => Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(controller.signaturePath.value.isNotEmpty || controller.signatureRemoteUrl.value.isNotEmpty) ? 1 : 0}/500',
              style: TextStyle(
                  fontSize: 11.sp, color: const Color(0xFF9E9E9E)),
            ),
          ),
        ),
      ],
    );
  }
}
