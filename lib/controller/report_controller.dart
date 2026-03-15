import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/models/analysis/analysis_data_model.dart';
import 'package:posture_detector_app/data/services/api/onboarding_service.dart';

class ReportController extends GetxController {
  final OnboardingService _onboardingService = OnboardingService();

  Rxn<AnalysisDataModel> analysisData = Rxn<AnalysisDataModel>();
  RxBool isLoading = RxBool(false);
  RxBool isExportingPDF = RxBool(false);

  AppLocalizations get _loc => AppLocalizations.of(Get.context!)!;

  @override
  void onInit() {
    super.onInit();
    loadAnalysisData();
  }

  Future<void> saveAnalysisData(AnalysisDataModel data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = await compute(_encodeAnalysisData, data);
      await prefs.setString('cached_analysis_data', jsonString);
    } catch (e) {
      debugPrint('Error caching analysis data: $e');
    }
  }

  static String _encodeAnalysisData(AnalysisDataModel data) {
    return jsonEncode(data.toJson());
  }

  Future<void> loadAnalysisData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('cached_analysis_data');
      if (jsonString != null) {
        analysisData.value = await compute(_parseAnalysisData, jsonString);
      }
    } catch (e) {
      debugPrint('Error loading cached analysis data: $e');
    }
  }

  static AnalysisDataModel _parseAnalysisData(String jsonString) {
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return AnalysisDataModel.fromJson(jsonMap);
  }

  Future<void> fetchMyReports() async {
    try {
      isLoading.value = true;

      final response = await _onboardingService.fetchMyReports();

      if (response.data != null) {
        analysisData.value = response.data!;
        saveAnalysisData(response.data!);
        isLoading.value = false;
        return;
      } else {
        isLoading.value = false;
        showCustomToast(text: response.error ?? _loc.failedToFetchReports);
      }
    } catch (e) {
      isLoading.value = false;
      debugPrint('Fetch reports error: $e');
      showCustomToast(text: _loc.failedToFetchReports);
    }
  }

  Future<void> exportReportPDF() async {
    try {
      isExportingPDF.value = true;
      final pdfUrl = analysisData.value?.aiResult.pdfReportUrl;
      if (pdfUrl == null || pdfUrl.isEmpty) {
        isExportingPDF.value = false;
        showCustomToast(text: _loc.noPdfAvailable);
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final fileName = pdfUrl.split('/').last.split('?').first;
      final filePath = '${tempDir.path}/$fileName';

      await Dio().download(pdfUrl, filePath);
      isExportingPDF.value = false;

      await Share.shareXFiles([XFile(filePath)], text: _loc.yourReportPdf);
    } catch (e) {
      isExportingPDF.value = false;
      debugPrint('Export PDF error: $e');
      showCustomToast(text: _loc.somethingWentWrong);
    }
  }
}
