import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:posture_detector_app/models/analysis/analysis_report.dart';
import 'package:posture_detector_app/services/network/custom_http.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/main.dart';

part 'report.g.dart';

class ReportState {
  final AnalysisReport? analysisReport;
  final bool isLoading;

  const ReportState({
    this.analysisReport,
    this.isLoading = false,
  });

  ReportState copyWith({
    AnalysisReport? analysisReport,
    bool clearData = false,
    bool? isLoading,
  }) => ReportState(
    analysisReport: clearData ? null : (analysisReport ?? this.analysisReport),
    isLoading: isLoading ?? this.isLoading,
  );
}

@Riverpod(keepAlive: true)
class ReportNotifier extends _$ReportNotifier {
  AppLocalizations get _loc =>
      AppLocalizations.of(scaffoldMessengerKey.currentContext!)!;

  bool isLoading = true;

  @override
  ReportState build() {
    _loadCachedData();
    return const ReportState();
  }

  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('cached_analysis_data');
      if (jsonString != null) {
        final data = await compute(_parseAnalysisReport, jsonString);
        state = state.copyWith(analysisReport: data);
      }
    } catch (e) {
      debugPrint('Error loading cached analysis data: $e');
    }
  }

  Future<void> saveData(AnalysisReport data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = await compute(_encodeAnalysisReport, data);
      await prefs.setString('cached_analysis_data', jsonString);
    } catch (e) {
      debugPrint('Error caching analysis data: $e');
    }
  }

  void setData(AnalysisReport data) {
    state = state.copyWith(analysisReport: data);
    saveData(data);
  }

  void clearData() {
    state = state.copyWith(clearData: true);
  }

  Future<void> fetchMyReports() async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await CustomHttp.get(endpoint: 'assessments/my-reports');

      if (response.ok) {
        final model = AnalysisReport.fromJson(response.data);
        state = state.copyWith(analysisReport: model, isLoading: false);
        saveData(model);
        return;
      }

      state = state.copyWith(isLoading: false);
      // EN: "Failed to fetch reports"
      showCustomToast(text: response.error ?? _loc.failedToFetchReports);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint('Fetch reports error: $e');
      // EN: "Failed to fetch reports"
      showCustomToast(text: _loc.failedToFetchReports);
    }
  }
}

String _encodeAnalysisReport(AnalysisReport data) {
  return jsonEncode(data.toJson());
}

AnalysisReport _parseAnalysisReport(String jsonString) {
  final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
  return AnalysisReport.fromJson(jsonMap);
}
