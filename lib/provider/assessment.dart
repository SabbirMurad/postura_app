import 'dart:io';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/helpers/app_helper.dart';
import 'package:posture_detector_app/models/analysis/analysis_report.dart';
import 'package:posture_detector_app/models/analysis/capture.dart';
import 'package:posture_detector_app/models/analysis/rosa_score.dart';
import 'package:posture_detector_app/models/assessment/pain.dart';
import 'package:posture_detector_app/models/assessment/workstation_answers.dart';
import 'package:posture_detector_app/provider/report.dart';
import 'package:posture_detector_app/models/scan_type.dart';
import 'package:posture_detector_app/services/network/custom_http.dart';
import 'package:posture_detector_app/utils/print_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posture_detector_app/models/prepared_image.dart';
import 'package:posture_detector_app/utils/media.dart' as media;

// Re-exported so the many screens that import this provider keep naming the
// pain enums (and the ROSA models) without a separate import.
export 'package:posture_detector_app/models/assessment/pain.dart';
export 'package:posture_detector_app/models/analysis/rosa_score.dart';
export 'package:posture_detector_app/models/analysis/body_angles.dart';
export 'package:posture_detector_app/models/analysis/capture.dart';

part 'assessment.g.dart';

class AssessmentState {
  final Set<BodyRegion> selectedBodyRegions;
  final Map<BodyRegion, int> painIntensity;

  /// Pain duration per selected region — each region is reported independently.
  final Map<BodyRegion, PainDuration> painDuration;
  final Set<OptionalSymptom> selectedOptionalSymptoms;

  /// Manual ROSA checklist answers, fed to the native PostureEngine.
  final WorkstationAnswers workstationAnswers;

  /// The side-view shots from the capture session (image + score + angles each).
  final List<SideViewCapture> sideCaptures;

  /// The single front-view shot (image + abduction/wrist-deviation angles).
  final FrontViewCapture? frontCapture;

  const AssessmentState({
    this.selectedBodyRegions = const {},
    this.painIntensity = const {},
    this.painDuration = const {},
    this.selectedOptionalSymptoms = const {},
    this.workstationAnswers = const WorkstationAnswers(),
    this.sideCaptures = const [],
    this.frontCapture,
  });

  /// Session ROSA score — the side shots' scores averaged into one. Null until a
  /// capture completes. (Kept as a getter so screens read one score as before.)
  RosaScore? get rosaScore => sideCaptures.isEmpty
      ? null
      : RosaScore.average(sideCaptures.map((c) => c.rosaScore).toList());

  /// Representative image for the assessment — the first side shot.
  File? get capturedImage =>
      sideCaptures.isEmpty ? null : sideCaptures.first.image;

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
    Map<BodyRegion, PainDuration>? painDuration,
    Set<OptionalSymptom>? selectedOptionalSymptoms,
    WorkstationAnswers? workstationAnswers,
    List<SideViewCapture>? sideCaptures,
    FrontViewCapture? frontCapture,
  }) {
    return AssessmentState(
      selectedBodyRegions: selectedBodyRegions ?? this.selectedBodyRegions,
      painIntensity: painIntensity ?? this.painIntensity,
      painDuration: painDuration ?? this.painDuration,
      selectedOptionalSymptoms:
          selectedOptionalSymptoms ?? this.selectedOptionalSymptoms,
      workstationAnswers: workstationAnswers ?? this.workstationAnswers,
      sideCaptures: sideCaptures ?? this.sideCaptures,
      frontCapture: frontCapture ?? this.frontCapture,
    );
  }
}

@Riverpod(keepAlive: true)
class AssessmentNotifier extends _$AssessmentNotifier {
  @override
  AssessmentState build() => const AssessmentState();

  void toggleRegion(BodyRegion region) {
    final regions = Set<BodyRegion>.from(state.selectedBodyRegions);
    final pain = Map<BodyRegion, int>.from(state.painIntensity);
    final duration = Map<BodyRegion, PainDuration>.from(state.painDuration);

    if (regions.contains(region)) {
      regions.remove(region);
      pain.remove(region);
      duration.remove(region);
    } else {
      regions.add(region);
      pain[region] = 1;
    }

    state = state.copyWith(
      selectedBodyRegions: regions,
      painIntensity: pain,
      painDuration: duration,
    );
  }

  int getPainForRegion(BodyRegion region) => state.painIntensity[region] ?? 1;

  void setPainForRegion(BodyRegion region, int value) {
    final pain = Map<BodyRegion, int>.from(state.painIntensity);
    pain[region] = value;
    state = state.copyWith(painIntensity: pain);
  }

  PainDuration? getPainDurationForRegion(BodyRegion region) =>
      state.painDuration[region];

  void setPainDurationForRegion(BodyRegion region, PainDuration duration) {
    final durations = Map<BodyRegion, PainDuration>.from(state.painDuration);
    durations[region] = duration;
    state = state.copyWith(painDuration: durations);
  }

  /// True once every selected region has a duration — gates the Continue button.
  bool get allRegionsHaveDuration =>
      state.selectedBodyRegions.every(state.painDuration.containsKey);

  void toggleSymptom(OptionalSymptom symptom) {
    final symptoms = Set<OptionalSymptom>.from(state.selectedOptionalSymptoms);
    if (symptoms.contains(symptom)) {
      symptoms.remove(symptom);
    } else {
      symptoms.add(symptom);
    }
    state = state.copyWith(selectedOptionalSymptoms: symptoms);
  }

  void setWorkstationAnswers(WorkstationAnswers answers) =>
      state = state.copyWith(workstationAnswers: answers);

  /// Store the captures returned by the native PostureEngine.
  void setCaptures(List<SideViewCapture> side, FrontViewCapture? front) =>
      state = state.copyWith(sideCaptures: side, frontCapture: front);

  /// Submits the assessment. Uploads every capture image (side shots + the front
  /// shot), then posts the grouped structure.
  /// Returns true on success, false on failure.
  Future<bool> submitAnalysis(ScanType type) async {
    if (state.sideCaptures.isEmpty) {
      showCustomToast(text: 'No capture to submit');
      return false;
    }

    // Upload every image in one request. The /image endpoint returns ids in the
    // same order it received the parts, and Dart's MultipartRequest preserves file
    // order, so the response maps back to captures by position. Order is
    // [side_1, …, side_N, front?].
    final front = state.frontCapture;
    final files = <File>[
      ...state.sideCaptures.map((c) => c.image),
      if (front != null) front.image,
    ];
    final prepared = <PreparedImage>[];
    for (final f in files) {
      final p = PreparedImage.fromFile(f);
      p.meta = await p.get_prepare_meta();
      p.prepared = true;
      prepared.add(p);
    }

    final imageIds = await media.upload_images(
      images: prepared,
      used_at: media.AssetUsedAt.Post,
      temporary: true,
    );
    if (imageIds == null || imageIds.length != prepared.length) {
      showCustomToast(text: 'Failed to upload images');
      return false;
    }

    final sideIds = imageIds.take(state.sideCaptures.length).toList();
    final frontId = front != null ? imageIds.last : null;

    final response = await CustomHttp.post(
      endpoint: 'assessments/scan-analyse',
      body: {
        'symptoms': state.selectedOptionalSymptoms.map((s) => s.label).toList(),
        // One pain unit per selected region: { body_region, intensity, duration }.
        'pain_units': state.selectedBodyRegions
            .map(
              (r) => {
                'body_region': r.label,
                'intensity': (state.painIntensity[r] ?? 0).toInt(),
                'duration': state.painDuration[r]?.label ?? '',
              },
            )
            .toList(),
        // Manual ROSA checklist answers (native scorer input contract).
        'workstation_answers': state.workstationAnswers.toMap(),
        // One ROSA score per scan (the side shots' scores averaged).
        'rosa_score': state.rosaScore?.toJson() ?? {},
        // Grouped captures: one entry per side shot (image + measured angles),
        // plus the single front shot (image + abduction/wrist-deviation angles).
        'side_captures': [
          for (var i = 0; i < state.sideCaptures.length; i++)
            state.sideCaptures[i].toJson(sideIds[i]),
        ],
        if (front != null && frontId != null)
          'front_capture': front.toJson(frontId),
      },
    );

    printLine(response.ok);
    printLine(response.status_code);

    if (response.ok) {
      printLine('Successfully processed analysis');
      final model = AnalysisReport.fromJson(response.data);

      ref.read(reportNotifierProvider.notifier).setData(model);

      // The scan marks the user onboarded server-side; persist it locally too so
      // the splash screen routes to home (not onboarding) on the next launch.
      await AppHelper.instance.setIsonBoarding(true);

      return true;
    }

    showCustomToast(text: response.error ?? 'Failed to process analysis');

    return false;
  }

  void reset() => state = const AssessmentState();
}
