import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/models/analysis/analysis_report.dart';
import 'package:posture_detector_app/provider/report.dart';
import 'package:posture_detector_app/models/scan_type.dart';
import 'package:posture_detector_app/services/network/custom_http.dart';
import 'package:posture_detector_app/utils/print_helper.dart';
import 'package:posture_detector_app/view/live_guidance/features/step3_capture/domain/capture_questionnaire.dart';
import 'package:posture_detector_app/view/live_guidance/features/step3_capture/domain/rosa_score.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;

part 'assessment.g.dart';

class WorkPattern {
  final String hoursAtDeskPerDay;
  final String breakHabit;
  final String deviceUsage;
  final String mouseType;

  const WorkPattern({
    this.hoursAtDeskPerDay = '',
    this.breakHabit = '',
    this.deviceUsage = '',
    this.mouseType = '',
  });

  WorkPattern copyWith({
    String? hoursAtDeskPerDay,
    String? breakHabit,
    String? deviceUsage,
    String? mouseType,
  }) => WorkPattern(
    hoursAtDeskPerDay: hoursAtDeskPerDay ?? this.hoursAtDeskPerDay,
    breakHabit: breakHabit ?? this.breakHabit,
    deviceUsage: deviceUsage ?? this.deviceUsage,
    mouseType: mouseType ?? this.mouseType,
  );
}

class WorkStation {
  final String monitorDistance;
  final bool? canAdjustChairHeight;
  final bool? enoughLegRoom;
  final bool? chairHasLumbarSupport;
  final bool? feetRestingFlat;
  final bool? monitorDirectlyInFront;
  final bool? chairHasArmrests;

  const WorkStation({
    this.monitorDistance = '',
    this.canAdjustChairHeight,
    this.enoughLegRoom,
    this.chairHasLumbarSupport,
    this.feetRestingFlat,
    this.monitorDirectlyInFront,
    this.chairHasArmrests,
  });

  WorkStation copyWith({
    String? monitorDistance,
    bool? canAdjustChairHeight,
    bool? enoughLegRoom,
    bool? chairHasLumbarSupport,
    bool? feetRestingFlat,
    bool? monitorDirectlyInFront,
    bool? chairHasArmrests,
  }) => WorkStation(
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

class AssessmentState {
  final Set<BodyRegion> selectedBodyRegions;
  final Map<BodyRegion, int> painIntensity;
  final PainDuration? selectedPainDuration;
  final Set<OptionalSymptom> selectedOptionalSymptoms;

  final WorkPattern workPattern;

  final WorkStation workstation;

  final RosaScore? rosaScore;

  final File? capturedImage;

  const AssessmentState({
    this.selectedBodyRegions = const {},
    this.painIntensity = const {},
    this.selectedPainDuration,
    this.selectedOptionalSymptoms = const {},

    this.workPattern = const WorkPattern(),

    this.workstation = const WorkStation(),

    this.rosaScore,

    this.capturedImage,
  });

  static const Set<BodyRegion> allPainRegions = {
    BodyRegion.neck,
    BodyRegion.upperBack,
    BodyRegion.lowerBack,
    BodyRegion.leftShoulder,
    BodyRegion.rightShoulder,
    BodyRegion.leftWrist,
    BodyRegion.rightWrist,
    BodyRegion.leftElbow,
    BodyRegion.rightElbow,
    BodyRegion.leftHip,
    BodyRegion.rightHip,
    BodyRegion.leftKnee,
    BodyRegion.rightKnee,
  };

  static const Set<PainDuration> allPainDurations = {
    PainDuration.lessThan1Week,
    PainDuration.oneToFourWeeks,
    PainDuration.oneToThreeMonths,
    PainDuration.threeToSixMonths,
    PainDuration.moreThanSixMonths,
  };

  static const Set<OptionalSymptom> allOptionalSymptoms = {
    OptionalSymptom.numbness,
    OptionalSymptom.stiffness,
    OptionalSymptom.swelling,
    OptionalSymptom.reducedRange,
    OptionalSymptom.headaches,
    OptionalSymptom.eyeStrain,
    OptionalSymptom.fatigue,
  };

  AssessmentState copyWith({
    Set<BodyRegion>? selectedBodyRegions,
    Map<BodyRegion, int>? painIntensity,
    PainDuration? selectedPainDuration,
    Set<OptionalSymptom>? selectedOptionalSymptoms,
    WorkPattern? workPattern,
    WorkStation? workstation,
    RosaScore? rosaScore,
    File? capturedImage,
  }) => AssessmentState(
    selectedBodyRegions: selectedBodyRegions ?? this.selectedBodyRegions,
    painIntensity: painIntensity ?? this.painIntensity,
    selectedPainDuration: selectedPainDuration ?? this.selectedPainDuration,
    selectedOptionalSymptoms:
        selectedOptionalSymptoms ?? this.selectedOptionalSymptoms,
    workPattern: workPattern ?? this.workPattern,
    workstation: workstation ?? this.workstation,
    rosaScore: rosaScore ?? this.rosaScore,
    capturedImage: capturedImage ?? this.capturedImage,
  );
}

@Riverpod(keepAlive: true)
class AssessmentNotifier extends _$AssessmentNotifier {
  @override
  AssessmentState build() => const AssessmentState();

  void toggleRegion(BodyRegion region) {
    final regions = Set<BodyRegion>.from(state.selectedBodyRegions);
    final pain = Map<BodyRegion, int>.from(state.painIntensity);

    if (regions.contains(region)) {
      regions.remove(region);
      pain.remove(region);
    } else {
      regions.add(region);
      pain[region] = 1;
    }

    state = state.copyWith(selectedBodyRegions: regions, painIntensity: pain);
  }

  int getPainForRegion(BodyRegion region) => state.painIntensity[region] ?? 1;

  void setPainForRegion(BodyRegion region, int value) {
    final pain = Map<BodyRegion, int>.from(state.painIntensity);
    pain[region] = value;
    state = state.copyWith(painIntensity: pain);
  }

  void setPainDuration(PainDuration duration) =>
      state = state.copyWith(selectedPainDuration: duration);

  void toggleSymptom(OptionalSymptom symptom) {
    final symptoms = Set<OptionalSymptom>.from(state.selectedOptionalSymptoms);
    if (symptoms.contains(symptom)) {
      symptoms.remove(symptom);
    } else {
      symptoms.add(symptom);
    }
    state = state.copyWith(selectedOptionalSymptoms: symptoms);
  }

  void setHourDeskPerDay(String value) => state = state.copyWith(
    workPattern: state.workPattern.copyWith(hoursAtDeskPerDay: value),
  );

  void setBreakHabit(String value) => state = state.copyWith(
    workPattern: state.workPattern.copyWith(breakHabit: value),
  );

  void setDeviceUsage(String value) => state = state.copyWith(
    workPattern: state.workPattern.copyWith(deviceUsage: value),
  );

  void setMouseType(String value) => state = state.copyWith(
    workPattern: state.workPattern.copyWith(mouseType: value),
  );

  void setMonitorDistance(String value) => state = state.copyWith(
    workstation: state.workstation.copyWith(monitorDistance: value),
  );

  void setCanAdjustChairHeight(bool value) => state = state.copyWith(
    workstation: state.workstation.copyWith(canAdjustChairHeight: value),
  );

  void setEnoughLegRoom(bool value) => state = state.copyWith(
    workstation: state.workstation.copyWith(enoughLegRoom: value),
  );

  void setChairHasLumbarSupport(bool value) => state = state.copyWith(
    workstation: state.workstation.copyWith(chairHasLumbarSupport: value),
  );

  void setFeetRestingFlat(bool value) => state = state.copyWith(
    workstation: state.workstation.copyWith(feetRestingFlat: value),
  );

  void setMonitorDirectlyInFront(bool value) => state = state.copyWith(
    workstation: state.workstation.copyWith(monitorDirectlyInFront: value),
  );

  void setChairHasArmrests(bool value) => state = state.copyWith(
    workstation: state.workstation.copyWith(chairHasArmrests: value),
  );

  void setRosaScore(RosaScore rosaScore) =>
      state = state.copyWith(rosaScore: rosaScore);

  void setCapturedImage(File image) =>
      state = state.copyWith(capturedImage: image);

  /// Submits the assessment with the currently captured image.
  /// Returns true on success, false on failure.
  Future<bool> submitAnalysis(ScanType type) async {
    if (state.capturedImage == null) {
      showCustomToast(text: 'No image selected');
      return false;
    }

    try {
      final painIntensityMap = state.painIntensity.map(
        (k, v) => MapEntry(k.label, v.toInt()),
      );

      var multipartFile = await http.MultipartFile.fromPath(
        'captured_image',
        state.capturedImage!.path,
      );

      final rosaScore = state.rosaScore!;

      final response = await CustomHttp.multipart(
        endpoint: 'assessments/scan-analyse',
        method: CommonCustomMethods.POST,
        fields: {
          'scan_type':
              type == ScanType.primaryScan || type == ScanType.captureImage
              ? 'primary'
              : 'instant',
          'body_regions': jsonEncode(
            state.selectedBodyRegions.map((r) => r.label).toList(),
          ),
          'pain_intensity': jsonEncode(painIntensityMap),
          'duration_pattern': state.selectedPainDuration?.label ?? '',
          'work_pattern': jsonEncode({
            'hours_at_desk': state.workPattern.hoursAtDeskPerDay,
            'break_habit': state.workPattern.breakHabit,
            'device_usage': state.workPattern.deviceUsage,
            'mouse_type': state.workPattern.mouseType,
          }),
          'symptoms': jsonEncode(
            state.selectedOptionalSymptoms.map((s) => s.label).toList(),
          ),
          'workstation': jsonEncode({
            'monitor_distance': state.workstation.monitorDistance,
            'can_adjust_chair_height': state.workstation.canAdjustChairHeight,
            'enough_leg_room': state.workstation.enoughLegRoom,
            'chair_has_lumbar_support': state.workstation.chairHasLumbarSupport,
            'feet_resting_flat': state.workstation.feetRestingFlat,
            'monitor_directly_in_front':
                state.workstation.monitorDirectlyInFront,
            'chair_has_armrests': state.workstation.chairHasArmrests,
          }),
          'rosa_score': jsonEncode({
            'final_score': rosaScore.finalScore,
            'chair_score': rosaScore.chairScore,
            'monitor_score': rosaScore.monitorScore,
            'keyboard_score': rosaScore.keyboardScore,
            'mouse_score': rosaScore.mouseScore,
            'peripheral_score': rosaScore.peripheralScore,
            'seat_height_score': rosaScore.seatHeightScore,
            'armrest_score': rosaScore.armrestScore,
            'knee_angle': rosaScore.kneeAngle,
            'trunk_angle': rosaScore.trunkAngle,
            'backrest_score': rosaScore.backrestScore,
            'forward_head': rosaScore.forwardHead,
            'neck_flexion': rosaScore.neckFlexion,
            'wrist_extension': rosaScore.wristExtension,
          }),
        },
        files: [multipartFile],
      );

      if (response.ok) {
        printLine('Successfully processed analysis');
        final model = AnalysisReport.fromJson(response.data);

        ref.read(reportNotifierProvider.notifier).setData(model);

        return true;
      }

      showCustomToast(text: response.error ?? 'Failed to process analysis');
    } catch (e) {
      debugPrint('Assessment submitAnalysis error: $e');
      showCustomToast(text: 'An unexpected error occurred');
    }

    return false;
  }

  void reset() => state = const AssessmentState();
}
