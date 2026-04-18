import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/models/analysis/analysis_data_model.dart';
import 'package:posture_detector_app/provider/image_capture.dart';
import 'package:posture_detector_app/constants/app_text.dart';
import 'package:posture_detector_app/provider/report.dart';
import 'package:posture_detector_app/models/scan_type.dart';
import 'package:posture_detector_app/services/network/custom_http.dart';
import 'package:posture_detector_app/utils/print_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;

part 'assessment.g.dart';

class AssessmentState {
  final List<String> selectedRegions;
  final Map<String, int> painIntensity;
  final String selectedPainDuration;
  final List<String> selectedSymptoms;
  final String hourDeskPerDay;
  final String breakHabit;
  final String workPatternRole;
  final bool isSubmitting;
  final String mouseType;
  final String monitorDistance;
  final bool? canAdjustChairHeight;
  final bool? enoughLegRoom;
  final bool? chairHasLumbarSupport;
  final bool? feetRestingFlat;
  final bool? monitorDirectlyInFront;
  final bool? chairHasArmrests;

  const AssessmentState({
    this.selectedRegions = const [],
    this.painIntensity = const {},
    this.selectedPainDuration = '',
    this.selectedSymptoms = const [],
    this.hourDeskPerDay = '',
    this.breakHabit = '',
    this.workPatternRole = '',
    this.mouseType = '',
    this.monitorDistance = '',
    this.isSubmitting = false,
    this.canAdjustChairHeight,
    this.enoughLegRoom,
    this.chairHasLumbarSupport,
    this.feetRestingFlat,
    this.monitorDirectlyInFront,
    this.chairHasArmrests,
  });

  static const List<String> bodyRegions = [
    AppText.neck,
    AppText.elbow,
    AppText.upperBack,
    AppText.lowerBack,
    AppText.shoulder,
    AppText.wrist,
    AppText.knees,
    AppText.ankles,
    AppText.hipsGultes,
  ];

  static const List<String> painDurations = [
    AppText.lessThanWeek,
    AppText.week1To6,
    AppText.moreThan6Week,
    AppText.onOffForMonth,
  ];

  static const List<String> symptoms = [
    AppText.tingling,
    AppText.fatigue,
    AppText.endOfDayPain,
    AppText.stiffness,
    AppText.morningPain,
  ];

  AssessmentState copyWith({
    List<String>? selectedRegions,
    Map<String, int>? painIntensity,
    String? selectedPainDuration,
    List<String>? selectedSymptoms,
    String? hourDeskPerDay,
    String? breakHabit,
    String? workPatternRole,
    String? mouseType,
    String? monitorDistance,
    bool? isSubmitting,
    bool? canAdjustChairHeight,
    bool? enoughLegRoom,
    bool? chairHasLumbarSupport,
    bool? feetRestingFlat,
    bool? monitorDirectlyInFront,
    bool? chairHasArmrests,
  }) => AssessmentState(
    selectedRegions: selectedRegions ?? this.selectedRegions,
    painIntensity: painIntensity ?? this.painIntensity,
    selectedPainDuration: selectedPainDuration ?? this.selectedPainDuration,
    selectedSymptoms: selectedSymptoms ?? this.selectedSymptoms,
    hourDeskPerDay: hourDeskPerDay ?? this.hourDeskPerDay,
    breakHabit: breakHabit ?? this.breakHabit,
    workPatternRole: workPatternRole ?? this.workPatternRole,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    mouseType: mouseType ?? this.mouseType,
    monitorDistance: monitorDistance ?? this.monitorDistance,
    canAdjustChairHeight: canAdjustChairHeight ?? this.canAdjustChairHeight,
    enoughLegRoom: enoughLegRoom ?? this.enoughLegRoom,
    chairHasLumbarSupport: chairHasLumbarSupport ?? this.chairHasLumbarSupport,
    feetRestingFlat: feetRestingFlat ?? this.feetRestingFlat,
    monitorDirectlyInFront:
        monitorDirectlyInFront ?? this.monitorDirectlyInFront,
    chairHasArmrests: chairHasArmrests ?? this.chairHasArmrests,
  );
}

@Riverpod(keepAlive: true)
class AssessmentNotifier extends _$AssessmentNotifier {
  @override
  AssessmentState build() => const AssessmentState();

  void toggleRegion(String region) {
    final regions = List<String>.from(state.selectedRegions);
    final pain = Map<String, int>.from(state.painIntensity);
    if (regions.contains(region)) {
      regions.remove(region);
      pain.remove(region);
    } else {
      regions.add(region);
      pain[region] = 1;
    }
    state = state.copyWith(selectedRegions: regions, painIntensity: pain);
  }

  int getPainForRegion(String region) => state.painIntensity[region] ?? 1;

  void setPainForRegion(String region, int value) {
    final pain = Map<String, int>.from(state.painIntensity);
    pain[region] = value;
    state = state.copyWith(painIntensity: pain);
  }

  void setPainDuration(String duration) =>
      state = state.copyWith(selectedPainDuration: duration);

  void toggleSymptom(String symptom) {
    final symptoms = List<String>.from(state.selectedSymptoms);
    if (symptoms.contains(symptom)) {
      symptoms.remove(symptom);
    } else {
      symptoms.add(symptom);
    }
    state = state.copyWith(selectedSymptoms: symptoms);
  }

  void setHourDeskPerDay(String value) =>
      state = state.copyWith(hourDeskPerDay: value);

  void setBreakHabit(String value) => state = state.copyWith(breakHabit: value);

  void setWorkPatternRole(String value) =>
      state = state.copyWith(workPatternRole: value);

  void setMouseType(String value) => state = state.copyWith(mouseType: value);

  void setMonitorDistance(String value) =>
      state = state.copyWith(monitorDistance: value);

  void setCanAdjustChairHeight(bool value) =>
      state = state.copyWith(canAdjustChairHeight: value);

  void setEnoughLegRoom(bool value) =>
      state = state.copyWith(enoughLegRoom: value);

  void setChairHasLumbarSupport(bool value) =>
      state = state.copyWith(chairHasLumbarSupport: value);

  void setFeetRestingFlat(bool value) =>
      state = state.copyWith(feetRestingFlat: value);

  void setMonitorDirectlyInFront(bool value) =>
      state = state.copyWith(monitorDirectlyInFront: value);

  void setChairHasArmrests(bool value) =>
      state = state.copyWith(chairHasArmrests: value);

  /// Submits the assessment with the currently captured image.
  /// Returns true on success, false on failure.
  Future<bool> submitAnalysis(dynamic type) async {
    final capturedImage = ref.read(imageCaptureNotifierProvider);
    if (capturedImage == null) {
      showCustomToast(text: 'No image selected');
      return false;
    }

    state = state.copyWith(isSubmitting: true);

    try {
      final painIntensityMap = state.painIntensity.map(
        (k, v) => MapEntry(k, v.toInt()),
      );

      File imageFile = File(capturedImage.path);

      var multipartFile = await http.MultipartFile.fromPath(
        'captured_image',
        imageFile.path,
      );

      final response = await CustomHttp.multipart(
        endpoint: 'assessments/scan-analyse',
        method: CommonCustomMethods.POST,
        fields: {
          'scan_type':
              type == ScanType.primaryScan || type == ScanType.captureImage
              ? 'primary'
              : 'instant',
          'body_regions': jsonEncode(state.selectedRegions),
          'pain_intensity': jsonEncode(painIntensityMap),
          'duration_pattern': state.selectedPainDuration,
          'work_pattern': jsonEncode({
            'hours_at_desk': state.hourDeskPerDay,
            'break_habit': state.breakHabit,
            'device_usage': state.workPatternRole,
            'mouse_type': state.mouseType,
          }),
          'symptoms': jsonEncode(state.selectedSymptoms),
          'workstation': jsonEncode({
            'monitor_distance': state.monitorDistance,
            'can_adjust_chair_height': state.canAdjustChairHeight,
            'enough_leg_room': state.enoughLegRoom,
            'chair_has_lumbar_support': state.chairHasLumbarSupport,
            'feet_resting_flat': state.feetRestingFlat,
            'monitor_directly_in_front': state.monitorDirectlyInFront,
            'chair_has_armrests': state.chairHasArmrests,
          }),
        },
        files: [multipartFile],
      );

      print(response.status_code);
      
      if (response.ok) {
        printLine('Successfully processed analysis');
        final model = AnalysisDataModel.fromJson(response.data);

        ref.read(reportNotifierProvider.notifier).setData(model);

        state = state.copyWith(isSubmitting: false);
        return true;
      }

      showCustomToast(text: response.error ?? 'Failed to process analysis');
    } catch (e) {
      debugPrint('Assessment submitAnalysis error: $e');
      showCustomToast(text: 'An unexpected error occurred');
    }

    state = state.copyWith(isSubmitting: false);
    return false;
  }

  void reset() => state = const AssessmentState();
}
