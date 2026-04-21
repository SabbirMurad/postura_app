import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:posture_detector_app/services/network/custom_http.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/main.dart';
import 'package:posture_detector_app/models/analysis/analysis_data_model.dart';

part 'report.g.dart';

class ReportState {
  final AnalysisDataModel? analysisData;
  final bool isLoading;

  const ReportState({
    this.analysisData,
    this.isLoading = false,
  });

  ReportState copyWith({
    AnalysisDataModel? analysisData,
    bool clearData = false,
    bool? isLoading,
  }) => ReportState(
    analysisData: clearData ? null : (analysisData ?? this.analysisData),
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
        final data = await compute(_parseAnalysisData, jsonString);
        state = state.copyWith(analysisData: data);
      }
    } catch (e) {
      debugPrint('Error loading cached analysis data: $e');
    }
  }

  Future<void> saveData(AnalysisDataModel data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = await compute(_encodeAnalysisData, data);
      await prefs.setString('cached_analysis_data', jsonString);
    } catch (e) {
      debugPrint('Error caching analysis data: $e');
    }
  }

  void setData(AnalysisDataModel data) {
    state = state.copyWith(analysisData: data);
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
        final model = AnalysisDataModel.fromJson(response.data);
        state = state.copyWith(analysisData: model, isLoading: false);
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

String _encodeAnalysisData(AnalysisDataModel data) {
  return jsonEncode(data.toJson());
}

AnalysisDataModel _parseAnalysisData(String jsonString) {
  final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
  return AnalysisDataModel.fromJson(jsonMap);
}
