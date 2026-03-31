import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/provider/image_capture.dart';
import 'package:posture_detector_app/constants/app_text.dart';
import 'package:posture_detector_app/provider/report.dart';
import 'package:posture_detector_app/models/scan_type.dart';
import 'package:posture_detector_app/services/api/onboarding_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'assessment.g.dart';

class AssessmentState {
  final List<String> selectedRegions;
  final Map<String, double> painIntensity;
  final String selectedPainDuration;
  final List<String> selectedSymptoms;
  final String hourDeskPerDay;
  final String breakHabit;
  final String workPatternRole;
  final bool isSubmitting;

  const AssessmentState({
    this.selectedRegions = const [],
    this.painIntensity = const {},
    this.selectedPainDuration = '',
    this.selectedSymptoms = const [],
    this.hourDeskPerDay = '',
    this.breakHabit = '',
    this.workPatternRole = '',
    this.isSubmitting = false,
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
    Map<String, double>? painIntensity,
    String? selectedPainDuration,
    List<String>? selectedSymptoms,
    String? hourDeskPerDay,
    String? breakHabit,
    String? workPatternRole,
    bool? isSubmitting,
  }) => AssessmentState(
    selectedRegions: selectedRegions ?? this.selectedRegions,
    painIntensity: painIntensity ?? this.painIntensity,
    selectedPainDuration: selectedPainDuration ?? this.selectedPainDuration,
    selectedSymptoms: selectedSymptoms ?? this.selectedSymptoms,
    hourDeskPerDay: hourDeskPerDay ?? this.hourDeskPerDay,
    breakHabit: breakHabit ?? this.breakHabit,
    workPatternRole: workPatternRole ?? this.workPatternRole,
    isSubmitting: isSubmitting ?? this.isSubmitting,
  );
}

@Riverpod(keepAlive: true)
class AssessmentNotifier extends _$AssessmentNotifier {
  @override
  AssessmentState build() => const AssessmentState();

  void toggleRegion(String region) {
    final regions = List<String>.from(state.selectedRegions);
    final pain = Map<String, double>.from(state.painIntensity);
    if (regions.contains(region)) {
      regions.remove(region);
      pain.remove(region);
    } else {
      regions.add(region);
      pain[region] = 1.0;
    }
    state = state.copyWith(selectedRegions: regions, painIntensity: pain);
  }

  double getPainForRegion(String region) =>
      state.painIntensity[region] ?? 1.0;

  void setPainForRegion(String region, double value) {
    final pain = Map<String, double>.from(state.painIntensity);
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

  void setBreakHabit(String value) =>
      state = state.copyWith(breakHabit: value);

  void setWorkPatternRole(String value) =>
      state = state.copyWith(workPatternRole: value);

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

      final response = await OnboardingService().onboardingFlow(
        scan_type: type == ScanType.primaryScan || type == ScanType.captureImage
            ? 'primary'
            : 'instant',
        image: File(capturedImage.path),
        bodyRegions: state.selectedRegions,
        painIntensity: painIntensityMap,
        durationPattern: state.selectedPainDuration,
        workHabits: {
          'hours_at_desk': state.hourDeskPerDay,
          'break_habit': state.breakHabit,
          'device_usage': state.workPatternRole,
        },
        symptoms: state.selectedSymptoms,
      );

      if (response.data != null) {
        ref.read(reportNotifierProvider.notifier).setData(response.data!);

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
