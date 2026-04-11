import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'package:posture_detector_app/services/network/custom_http.dart';
import 'package:posture_detector_app/utils/date_helper.dart';
import 'package:posture_detector_app/view/e_learning/data/e_learning_module_data.dart';
import 'package:url_launcher/url_launcher.dart';

class CertificateDetailsScreen extends StatefulWidget {
  const CertificateDetailsScreen({super.key});

  @override
  State<CertificateDetailsScreen> createState() =>
      _CertificateDetailsScreenState();
}

class _CertificateDetailsScreenState extends State<CertificateDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _loadCertificate();
  }

  List<Map<String, dynamic>> modules = [];
  Map<String, dynamic>? certificate;

  Future<void> _loadCertificate() async {
    final response = await CustomHttp.get(
      endpoint: 'elearning/pdf-export-data',
    );

    if (!response.ok) {
      showCustomToast(text: response.error ?? 'Something went wrong');
      return;
    }

    List<Map<String, dynamic>> module_data = [];

    for (var module in response.data['modules']) {
      module_data.add(module);
    }

    setState(() {
      modules = module_data;
      certificate = response.data['certificate'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.surface,
        child: (modules.isEmpty || certificate == null)
            ? Center(
                child: SizedBox(
                  width: 36.w,
                  height: 36.w,
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                ),
              )
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SafeArea(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 44.w,
                                height: 44.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryColor.withValues(
                                    alpha: 0.15,
                                  ),
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: AppColors.text,
                                  size: 18.sp,
                                ),
                              ),
                            ),
                            Spacer(flex: 2),
                            Text(
                              'Certificate',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Spacer(flex: 3),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            certificate!['company_name'],
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: AppColors.text,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name: ',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            certificate!['user_name'],
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: AppColors.text,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID: ',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            certificate!['employee_id'],
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: AppColors.text,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 36.h),
                      ...modules.map((module) {
                        final locale = Localizations.localeOf(
                          context,
                        ).languageCode;
                        final serverTitle = module['title'] as String? ?? '';
                        final moduleNumber = int.tryParse(
                          serverTitle.replaceAll(RegExp(r'[^0-9]'), ''),
                        );
                        final realName = moduleNumber != null
                            ? ELearningModuleData.getModuleNameById(
                                locale,
                                moduleNumber,
                              )
                            : null;
                        return Container(
                          margin: EdgeInsets.only(bottom: 18.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      serverTitle,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                    if (realName != null)
                                      Text(
                                        realName,
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          color: AppColors.text,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Passed On',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                  Text(
                                    prettyDate(module['completion_date']),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColors.text,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      SizedBox(height: 48.h),
                      Text(
                        'Certificate ID',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      Text(
                        certificate!['certificate_id'],
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Issued on',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              Text(
                                prettyDate(certificate!['issue_date']),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Valid Until',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              Text(
                                prettyDate(certificate!['valid_until']),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 48.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              launchUrl(
                                mode: LaunchMode.externalApplication,
                                Uri.parse(certificate!['pdf_url']),
                              );
                            },
                            behavior: HitTestBehavior.translucent,
                            child: Container(
                              height: 44.w,
                              width: 224.w,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.download_rounded,
                                    color: Colors.white,
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 12.w),
                                  Text(
                                    'Download',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 72.h),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
