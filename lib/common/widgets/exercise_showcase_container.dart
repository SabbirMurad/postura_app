import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';

import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'duration_container.dart';

class ExerciseShowCaseContainer extends StatelessWidget {
  final AssetGenImage? image;
  final String title;
  final String subtitle;
  final String duration;
  final String percentage;
  final String? badge;
  final String? videoUrl;

  // ✅ Additional fields from RecommendedSession
  final String? purpose;
  final String? musclesAddressed;
  final String? contraindications;
  final int? regionVas;
  final int? recommendedSets;
  final String? safetyNote;

  // ✅ NEW: Clinical Projection
  final String? clinicalProjectionText;
  final String? clinicalProjectionSource;

  const ExerciseShowCaseContainer({
    super.key,
    this.image,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.percentage,
    this.badge,
    this.videoUrl,
    this.purpose,
    this.musclesAddressed,
    this.contraindications,
    this.regionVas,
    this.recommendedSets,
    this.safetyNote,
    this.clinicalProjectionText,
    this.clinicalProjectionSource,
  });

  /// Get badge background color
  Color _getBadgeBgColor() {
    if (badge?.contains('Therapy Priority') ?? false) {
      return Color.fromRGBO(212, 49, 51, 1);
    } else if (badge?.contains('Maintenance') ?? false) {
      return Color.fromRGBO(49, 131, 68, 1);
    }
    return Color.fromRGBO(255, 243, 205, 1);
  }

  /// Get VAS color
  Color _getVasColor(int vas) {
    if (vas >= 7) return Colors.red;
    if (vas >= 5) return Colors.orange;
    return Colors.green;
  }

  /// ✅ Show full details modal with STATIC footer at bottom
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
            return Stack(
              children: [
                /// ✅ Scrollable content
                SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Header with close button
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

                        /// Exercise Image/Video
                        if (videoUrl != null || image != null)
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
                              child: videoUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: videoUrl!,
                                      fit: BoxFit.contain,
                                      placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                      errorWidget: (context, url, error) {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.image_not_supported,
                                                size: 40.sp,
                                              ),
                                              SizedBox(height: 8.h),
                                              Text(loc.imageNotAvailable),
                                            ],
                                          ),
                                        );
                                      },
                                    )
                                  : image!.image(fit: BoxFit.cover),
                            ),
                          ),

                        /// Badge
                        if (badge != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: _getBadgeBgColor(),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            margin: EdgeInsets.only(bottom: 16.h),
                            child: Text(
                              badge!,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),

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
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(74, 74, 74, 1),
                            height: 1.6,
                          ),
                        ),
                        SizedBox(height: 24.h),

                        /// Quick Stats
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Pain Level (VAS)
                              if (regionVas != null)
                                _buildQuickStatRow(
                                  icon: Icons.favorite_rounded,
                                  label: 'Pain Level (VAS)',
                                  value: regionVas.toString(),
                                  suffix: '/10',
                                  color: _getVasColor(regionVas!),
                                ),
                              if (regionVas != null) ...[
                                SizedBox(height: 12.h),
                                Divider(height: 1),
                                SizedBox(height: 12.h),
                              ],

                              /// Recommended Sets

                              /// Duration

                              /// Improvement Percentage
                              _buildQuickStatRow(
                                icon: Icons.trending_up_rounded,
                                label: 'Improvement',
                                value: percentage,
                                color: Colors.green,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),

                        /// Purpose Section
                        if (purpose != null && purpose!.isNotEmpty)
                          _buildDetailSection(
                            title: 'Purpose',
                            content: purpose!,
                            icon: Icons.info_rounded,
                          ),

                        /// Muscles Addressed Section
                        if (musclesAddressed != null &&
                            musclesAddressed!.isNotEmpty)
                          _buildDetailSection(
                            title: 'Muscles Addressed',
                            content: musclesAddressed!,
                            icon: Icons.fitness_center_rounded,
                          ),

                        /// Safety Note Section
                        if (safetyNote != null && safetyNote!.isNotEmpty)
                          _buildDetailSection(
                            title: 'Safety Note',
                            content: safetyNote!,
                            icon: Icons.health_and_safety_rounded,
                            backgroundColor: Color.fromRGBO(255, 243, 205, 1),
                            iconColor: Colors.orange,
                          ),

                        /// Contraindications Section
                        if (contraindications != null &&
                            contraindications!.isNotEmpty)
                          _buildDetailSection(
                            title: 'Contraindications',
                            content: contraindications!,
                            icon: Icons.dangerous_rounded,
                            backgroundColor: Color.fromRGBO(255, 228, 225, 1),
                            iconColor: Colors.red,
                          ),

                        /// ✅ Add bottom padding for footer
                        SizedBox(
                          height:
                              (clinicalProjectionText != null &&
                                  clinicalProjectionText!.isNotEmpty)
                              ? 140.h
                              : 20.h,
                        ),
                      ],
                    ),
                  ),
                ),

                /// ✅ STATIC FOOTER (Fixed at bottom - doesn't scroll)
              ],
            );
          },
        );
      },
    );
  }

  /// Helper: Build detail section
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
        color: backgroundColor ?? Color.fromRGBO(230, 245, 240, 1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: (backgroundColor ?? Color.fromRGBO(230, 245, 240, 1))
              .withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Section Title with Icon
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
          SizedBox(height: 12.h),

          /// Section Content
          Text(
            content,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: Color.fromRGBO(74, 74, 74, 1),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper: Build quick stat row
  Widget _buildQuickStatRow({
    required IconData icon,
    required String label,
    required String value,
    String suffix = '',
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: color ?? AppColors.primaryColor),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4.h),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: color ?? Colors.black87,
                      ),
                    ),
                    if (suffix.isNotEmpty)
                      TextSpan(
                        text: ' $suffix',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetailsModal(context),
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: AppColors.onBoardingSurface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Main content row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Exercise video/image
                  if (videoUrl != null || image != null)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: videoUrl != null
                            ? CachedNetworkImage(
                                imageUrl: videoUrl!,
                                width: 80.w,
                                height: 80.h,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: 80.w,
                                  height: 80.h,
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                                errorWidget: (context, url, error) {
                                  return Container(
                                    width: 80.w,
                                    height: 80.h,
                                    color: Colors.grey[300],
                                    child: Icon(Icons.image_not_supported),
                                  );
                                },
                              )
                            : image!.image(
                                width: 80.w,
                                height: 80.h,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  SizedBox(width: 12.w),

                  /// Content
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Title
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),

                        /// Subtitle/Description
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(74, 74, 74, 1),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 12.h),

                        /// Wrap in SingleChildScrollView to prevent overflow
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              DurationContainer(
                                icon: Icons.timeline_rounded,
                                content: percentage,
                              ),
                              SizedBox(width: 8.w),
                              if (badge != null)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getBadgeBgColor(),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Text(
                                    badge!,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                              /// VAS Indicator
                              if (regionVas != null)
                                Padding(
                                  padding: EdgeInsets.only(left: 8.w),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getVasColor(regionVas!),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Text(
                                      'VAS $regionVas',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
