import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'package:posture_detector_app/services/network/custom_http.dart';

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
            : Column(
                children: [
                  ...modules!.map((module) {
                    return Text(
                      module['title'],
                      style: TextStyle(fontSize: 16.sp),
                    );
                  }).toList(),
                ],
              ),
      ),
    );
  }
}
