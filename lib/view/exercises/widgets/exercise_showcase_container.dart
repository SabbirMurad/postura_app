import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';

import 'package:posture_detector_app/constants/colors.dart';

class ExerciseShowCaseContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final String duration;
  final String sensitivityLabel; // 'Gentle' | 'Moderate' | 'Active'
  final String? videoUrl;

  // Session details
  final String? purpose;
  final String? musclesAddressed;
  final int? regionVas;
  final int? recommendedSets;
  final String? safetyNote;

  const ExerciseShowCaseContainer({
    super.key,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.sensitivityLabel,
    this.videoUrl,
    this.purpose,
    this.musclesAddressed,
    this.regionVas,
    this.recommendedSets,
    this.safetyNote,
  });

  Color _getVasColor(int vas) {
    if (vas >= 7) return Colors.red;
    if (vas >= 5) return Colors.orange;
    return Colors.green;
  }

  /// Sets recommendation per sensitivity level
  String _setsForLevel() {
    switch (sensitivityLabel) {
      case 'Active':
        return '4 sets × 12 reps';
      case 'Moderate':
        return '3 sets × 10 reps';
      default:
        return '2 sets × 8 reps';
    }
  }

  void _showDetailsModal(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      backgroundColor: AppColors.onBoardingSurface,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 24.w),
                        Text(
                          'Exercise Details',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.close, size: 26.sp),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    /// Video / image
                    if (videoUrl != null)
                      Container(
                        width: double.infinity,
                        height: 280.h,
                        margin: EdgeInsets.only(bottom: 24.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          color: Colors.grey[300],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: CachedNetworkImage(
                            imageUrl: videoUrl!,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_not_supported, size: 40.sp),
                                  SizedBox(height: 8.h),
                                  Text(loc.imageNotAvailable),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    /// Sensitivity badge
                    _SensitivityBadge(label: sensitivityLabel),
                    SizedBox(height: 16.h),

                    /// Title
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    /// Description
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF4A4A4A),
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    /// Your Programme (sets per sensitivity level)
                    _buildDetailSection(
                      title: 'Your programme',
                      content: _setsForLevel(),
                      icon: Icons.fitness_center_rounded,
                    ),

                    /// Why this helps (muscles addressed)
                    if (musclesAddressed != null && musclesAddressed!.isNotEmpty)
                      _buildDetailSection(
                        title: 'Why this helps',
                        content: musclesAddressed!,
                        icon: Icons.info_outline_rounded,
                      ),

                    /// Purpose / How to do it
                    if (purpose != null && purpose!.isNotEmpty)
                      _buildDetailSection(
                        title: 'How to do it',
                        content: purpose!,
                        icon: Icons.play_circle_outline_rounded,
                      ),

                    /// VAS indicator
                    if (regionVas != null)
                      Container(
                        padding: EdgeInsets.all(16.w),
                        margin: EdgeInsets.only(bottom: 16.h),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.favorite_rounded,
                              size: 20.sp,
                              color: _getVasColor(regionVas!),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                'Pain level (VAS): $regionVas / 10',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: _getVasColor(regionVas!),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    /// When to stop (safety note)
                    if (safetyNote != null && safetyNote!.isNotEmpty)
                      _buildDetailSection(
                        title: 'When to stop',
                        content: safetyNote!,
                        icon: Icons.stop_circle_outlined,
                        backgroundColor: const Color(0xFFFFF3CD),
                        iconColor: Colors.orange,
                      ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailSection({
    required String title,
    required String content,
    required IconData icon,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.secondaryText.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20.sp,
                color: iconColor ?? AppColors.primaryColor,
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF4A4A4A),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetailsModal(context),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.secondaryText.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Thumbnail
            if (videoUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: videoUrl!,
                  width: 72.w,
                  height: 72.h,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 72.w,
                    height: 72.h,
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 72.w,
                    height: 72.h,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
            SizedBox(width: 12.w),

            /// Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF4A4A4A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      _SensitivityBadge(label: sensitivityLabel, small: true),
                      SizedBox(width: 8.w),
                      if (regionVas != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getVasColor(regionVas!).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            'VAS $regionVas',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: _getVasColor(regionVas!),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sensitivity level badge — grey/neutral as per task_5 spec
class _SensitivityBadge extends StatelessWidget {
  final String label;
  final bool small;

  const _SensitivityBadge({required this.label, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8.w : 12.w,
        vertical: small ? 3.h : 5.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: small ? 11.sp : 12.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF555555),
        ),
      ),
    );
  }
}
