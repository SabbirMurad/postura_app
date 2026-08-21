import 'package:posture_detector_app/constants/credential.dart';
import 'package:posture_detector_app/models/analysis/rosa_score.dart';

class AnalysisReport {
  final BodyRegionRisks bodyRegionRisks;
  final List<Correction> corrections;
  final Exercises exercises;
  final List<Equipment> equipment;
  final String pdfReportUrl;
  final String equipmentExcelUrl;

  final WorkPattern workPattern;

  final List<PainIntensity> painIntensities;
  final String painDuration;

  final RosaScore rosaScore;

  final List<String> symptoms;

  /// Yellow-flag / chronicity risk level computed by the backend from the
  /// Work Ability & Recovery Outlook screen answers — "Low" or "Elevated".
  final String chronicityLevel;

  /// Employee height in centimeters, if entered. Never affects ROSA scoring.
  final double? heightCm;

  /// The two supplemental phone questions — informational only, shown in the
  /// Action Report's "Supplemental CPE Findings" section.
  final SupplementalCpeFindings supplementalCpeFindings;

  AnalysisReport({
    required this.workPattern,
    required this.bodyRegionRisks,
    required this.corrections,
    required this.exercises,
    required this.equipment,
    required this.pdfReportUrl,
    required this.equipmentExcelUrl,
    required this.rosaScore,
    required this.symptoms,
    required this.painIntensities,
    required this.painDuration,
    this.chronicityLevel = 'Low',
    this.heightCm,
    this.supplementalCpeFindings = const SupplementalCpeFindings(),
  });

  bool get chronicityElevated => chronicityLevel == 'Elevated';

  factory AnalysisReport.fromJson(Map<String, dynamic> json) {
    return AnalysisReport(
      // The backend replaced work_pattern with workstation_answers; keep an
      // empty WorkPattern so downstream readers stay null-safe.
      workPattern: json['work_pattern'] is Map
          ? WorkPattern.fromJson(json['work_pattern'] as Map<String, dynamic>)
          : WorkPattern.empty(),
      // Backend now sends pain_units ({body_region, intensity, duration}); fall
      // back to the legacy pain_intensities key.
      painIntensities:
          ((json['pain_units'] ?? json['pain_intensities']) as List<dynamic>? ??
                  const [])
              .map((e) => PainIntensity.fromJson(e as Map<String, dynamic>))
              .toList(),
      painDuration: json['pain_duration'] ?? '',
      bodyRegionRisks: BodyRegionRisks.fromJson(
        json['body_region_risks'] ?? {},
      ),
      corrections: (json['corrections'] as List<dynamic>? ?? [])
          .map((e) => Correction.fromJson(e as Map<String, dynamic>))
          .toList(),
      exercises: json['exercises'] is Map
          ? Exercises.fromJson(json['exercises'] as Map<String, dynamic>)
          : Exercises(
              conditionType: '',
              focusRegions: [],
              mainPainRegion: null,
              averagePainVas: 0,
              recommendedSession: [],
            ),
      equipment: (json['equipment'] as List<dynamic>? ?? [])
          .map((e) => Equipment.fromJson(e as Map<String, dynamic>))
          .toList(),
      pdfReportUrl: json['pdf_report_url'] ?? '',
      equipmentExcelUrl: json['equipment_excel_url'] ?? '',

      rosaScore: RosaScore.fromJson(json['rosa_score'] ?? const {}),

      symptoms: List<String>.from(json['symptoms'] ?? const []),
      chronicityLevel: json['chronicity_level'] ?? 'Low',
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      supplementalCpeFindings: SupplementalCpeFindings.fromJson(
        json['supplemental_cpe_findings'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'body_region_risks': bodyRegionRisks.toJson(),
    'corrections': corrections.map((e) => e.toJson()).toList(),
    'exercises': exercises.toJson(),
    'equipment': equipment.map((e) => e.toJson()).toList(),
    'pdf_report_url': pdfReportUrl,
    'equipment_excel_url': equipmentExcelUrl,
    'rosa_score': rosaScore.toJson(),
    'symptoms': symptoms,
    'work_pattern': workPattern.toJson(),
    'height_cm': heightCm,
    'supplemental_cpe_findings': supplementalCpeFindings.toJson(),
    'pain_intensities': painIntensities.map((e) => e.toJson()).toList(),
    'pain_duration': painDuration,
    'chronicity_level': chronicityLevel,
  };
}

// ===================== SUPPLEMENTAL CPE FINDINGS =====================
// The two supplemental phone questions — informational only, never affects
// ROSA scoring. `flags` carries the backend-computed finding codes
// (B_PHONE_CRADLE / B_PHONE_HANDSFREE).
class SupplementalCpeFindings {
  final bool phoneCradle;
  final bool handsFreeAvailable;
  final List<String> flags;

  const SupplementalCpeFindings({
    this.phoneCradle = false,
    this.handsFreeAvailable = true,
    this.flags = const [],
  });

  bool get hasFindings => flags.isNotEmpty;

  factory SupplementalCpeFindings.fromJson(Map<String, dynamic> json) =>
      SupplementalCpeFindings(
        phoneCradle: json['phone_cradle'] as bool? ?? false,
        handsFreeAvailable: json['hands_free_available'] as bool? ?? true,
        flags: List<String>.from(json['flags'] ?? const []),
      );

  Map<String, dynamic> toJson() => {
    'phone_cradle': phoneCradle,
    'hands_free_available': handsFreeAvailable,
    'flags': flags,
  };
}

// ===================== PAIN INTENSITY =====================
class PainIntensity {
  final String bodyRegion;
  final int intensity;

  PainIntensity({required this.bodyRegion, required this.intensity});

  factory PainIntensity.fromJson(Map<String, dynamic> json) => PainIntensity(
    bodyRegion: json['body_region'] ?? '',
    intensity: json['intensity'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'body_region': bodyRegion,
    'intensity': intensity,
  };
}

// ===================== WORKSTATION =====================
class Workstation {
  final bool? canAdjustChairHeight;
  final bool? enoughLegRoom;
  final bool? chairHasLumbarSupport;
  final String monitorDistance;
  final bool? feetRestingFlat;
  final bool? monitorDirectlyInFront;
  final bool? chairHasArmrests;

  Workstation({
    this.canAdjustChairHeight,
    this.enoughLegRoom,
    this.chairHasLumbarSupport,
    this.monitorDistance = '',
    this.feetRestingFlat,
    this.monitorDirectlyInFront,
    this.chairHasArmrests,
  });

  factory Workstation.fromJson(Map<String, dynamic> json) => Workstation(
    canAdjustChairHeight: json['can_adjust_chair_height'] as bool?,
    enoughLegRoom: json['enough_leg_room'] as bool?,
    chairHasLumbarSupport: json['chair_has_lumbar_support'] as bool?,
    monitorDistance: json['monitor_distance'] ?? '',
    feetRestingFlat: json['feet_resting_flat'] as bool?,
    monitorDirectlyInFront: json['monitor_directly_in_front'] as bool?,
    chairHasArmrests: json['chair_has_armrests'] as bool?,
  );

  Map<String, dynamic> toJson() => {
    'can_adjust_chair_height': canAdjustChairHeight,
    'enough_leg_room': enoughLegRoom,
    'chair_has_lumbar_support': chairHasLumbarSupport,
    'monitor_distance': monitorDistance,
    'feet_resting_flat': feetRestingFlat,
    'monitor_directly_in_front': monitorDirectlyInFront,
    'chair_has_armrests': chairHasArmrests,
  };
}

// ===================== WORK PATTERN =====================
class WorkPattern {
  final String hoursAtDesk;
  final String breakHabit;
  final String deviceUsage;
  final String mouseType;

  WorkPattern({
    required this.hoursAtDesk,
    required this.breakHabit,
    required this.deviceUsage,
    required this.mouseType,
  });

  /// The backend no longer supplies work-pattern data (replaced by
  /// workstation_answers); used as a null-safe placeholder.
  factory WorkPattern.empty() => WorkPattern(
    hoursAtDesk: '',
    breakHabit: '',
    deviceUsage: '',
    mouseType: '',
  );

  factory WorkPattern.fromJson(Map<String, dynamic> json) => WorkPattern(
    hoursAtDesk: json['hours_at_desk'] ?? '',
    breakHabit: json['break_habit'] ?? '',
    deviceUsage: json['device_usage'] ?? '',
    mouseType: json['mouse_type'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'hours_at_desk': hoursAtDesk,
    'break_habit': breakHabit,
    'device_usage': deviceUsage,
    'mouse_type': mouseType,
  };
}

// ===================== BODY REGION RISKS =====================
class BodyRegionRisks {
  final String elbows;
  final String shoulder;
  final String wrist;
  final String lowerBack;
  final String? neck;
  final String? upperBack;
  final String? hips;
  final String? knees;

  BodyRegionRisks({
    required this.elbows,
    required this.shoulder,
    required this.wrist,
    required this.lowerBack,
    this.neck,
    this.upperBack,
    this.hips,
    this.knees,
  });

  factory BodyRegionRisks.fromJson(Map<String, dynamic> json) =>
      BodyRegionRisks(
        elbows: json['elbows'] ?? '',
        shoulder: json['shoulder'] ?? '',
        wrist: json['wrist'] ?? '',
        lowerBack: json['lower_back'] ?? '',
        neck: json['neck'],
        upperBack: json['upper_back'],
        hips: json['hips'],
        knees: json['knees'],
      );

  Map<String, dynamic> toJson() => {
    'elbows': elbows,
    'shoulder': shoulder,
    'wrist': wrist,
    'lower_back': lowerBack,
    'neck': neck,
    'upper_back': upperBack,
    'hips': hips,
    'knees': knees,
  };
}

// ===================== CORRECTIONS =====================
class Correction {
  final String title;

  final String description;

  Correction({required this.title, required this.description});

  factory Correction.fromJson(Map<String, dynamic> json) => Correction(
    title: json['title'] ?? '',
    description: json['description'] ?? '',
  );

  Map<String, dynamic> toJson() => {'title': title, 'description': description};
}

// ===================== EXERCISES =====================
class Exercises {
  final String conditionType;
  final List<String> focusRegions;
  final MainPainRegion? mainPainRegion;
  final int averagePainVas;
  final List<RecommendedSession> recommendedSession;
  final ClinicalProjection? clinicalProjection; // ✅ NEW

  Exercises({
    required this.conditionType,
    required this.focusRegions,
    this.mainPainRegion,
    required this.averagePainVas,
    required this.recommendedSession,
    this.clinicalProjection, // ✅ NEW
  });

  factory Exercises.fromJson(Map<String, dynamic> json) => Exercises(
    conditionType: json['condition_type'] ?? '',
    focusRegions: List<String>.from(json['focus_regions'] ?? []),
    mainPainRegion: json['main_pain_region'] != null
        ? MainPainRegion.fromJson(
            json['main_pain_region'] as Map<String, dynamic>,
          )
        : null,
    averagePainVas: json['average_pain_vas'] ?? 0,
    recommendedSession: (json['recommended_session'] as List<dynamic>? ?? [])
        .map((e) => RecommendedSession.fromJson(e as Map<String, dynamic>))
        .toList(),
    clinicalProjection:
        json['clinical_projection'] !=
            null // ✅ NEW
        ? ClinicalProjection.fromJson(
            json['clinical_projection'] as Map<String, dynamic>,
          )
        : null,
  );

  Map<String, dynamic> toJson() => {
    'condition_type': conditionType,
    'focus_regions': focusRegions,
    'main_pain_region': mainPainRegion?.toJson(),
    'average_pain_vas': averagePainVas,
    'recommended_session': recommendedSession.map((e) => e.toJson()).toList(),
    'clinical_projection': clinicalProjection?.toJson(), // ✅ NEW
  };
}

// ===================== CLINICAL PROJECTION ✅ NEW =====================
class ClinicalProjection {
  final String text;
  final String source;

  ClinicalProjection({required this.text, required this.source});

  factory ClinicalProjection.fromJson(Map<String, dynamic> json) =>
      ClinicalProjection(
        text: json['text'] ?? '',
        source: json['source'] ?? '',
      );

  Map<String, dynamic> toJson() => {'text': text, 'source': source};
}

// ===================== MAIN PAIN REGION =====================
class MainPainRegion {
  final List<String> regions;
  final int vas;

  MainPainRegion({required this.regions, required this.vas});

  factory MainPainRegion.fromJson(Map<String, dynamic> json) => MainPainRegion(
    regions: List<String>.from(json['regions'] ?? []),
    vas: json['vas'] ?? 0,
  );

  Map<String, dynamic> toJson() => {'regions': regions, 'vas': vas};
}

// ===================== RECOMMENDED SESSION ✅ ALL FIELDS =====================
class RecommendedSession {
  final int id;
  final String title;
  final String? purpose;
  final String bodyRegion;
  final String? musclesAddressed;
  final String video;
  final String description;
  final String? contraindications;
  final int recommendedSets;
  final String recommendedDuration;
  final String safetyNote;
  final int? regionVas;
  final String? badge;
  final int? improvementPercentage;

  RecommendedSession({
    required this.id,
    required this.title,
    this.purpose,
    required this.bodyRegion,
    this.musclesAddressed,
    required this.video,
    required this.description,
    this.contraindications,
    required this.recommendedSets,
    required this.recommendedDuration,
    required this.safetyNote,
    this.regionVas,
    this.badge,
    this.improvementPercentage,
  });

  factory RecommendedSession.fromJson(Map<String, dynamic> json) {
    return RecommendedSession(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      purpose: json['Purpose'] ?? json['purpose'],
      bodyRegion: json['body_region'] ?? '',
      musclesAddressed: json['Muscles addressed'] ?? json['muscles_addressed'],
      // Backend sends the bare asset filename under `image`; build a
      // domain-relative path (the showcase widget prepends the host).
      video: '${AppCredentials.domain}/assets/exercise/${json['image']}',
      description: json['description'] ?? '',
      contraindications: json['Contraindications'] ?? json['contraindications'],
      recommendedSets: json['recommended_sets'] ?? 0,
      recommendedDuration: json['recommended_duration'] ?? '',
      safetyNote: json['safety_note'] ?? '',
      regionVas: json['region_vas'] as int?,
      badge: json['badge'] as String?,
      improvementPercentage: json['improvement_percentage'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'Purpose': purpose,
    'body_region': bodyRegion,
    'Muscles addressed': musclesAddressed,
    'video': video,
    'description': description,
    'Contraindications': contraindications,
    'recommended_sets': recommendedSets,
    'recommended_duration': recommendedDuration,
    'safety_note': safetyNote,
    'region_vas': regionVas,
    'badge': badge,
    'improvement_percentage': improvementPercentage,
  };
}

// ===================== EQUIPMENT =====================
class Equipment {
  final String name;
  final String description;
  final String priority;
  final String improvementPercentage;
  final String? source;
  final String status;

  Equipment({
    required this.name,
    required this.description,
    required this.priority,
    required this.improvementPercentage,
    this.source,
    required this.status,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? '',
      improvementPercentage: json['improvement_percentage'] ?? '',
      source: json['source'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'status': status,
    'description': description,
    'priority': priority,
    'improvement_percentage': improvementPercentage,
    'source': source,
  };
}
