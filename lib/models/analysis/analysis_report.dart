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

  /// The deterministic, fixed-copy Action Report v1.3 (tier-limited priority
  /// findings + equipment cards). Additive alongside [corrections] — the
  /// AI-generated free-text guidance the backend still returns for now.
  final ActionReportV13? actionReportV13;

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
    this.actionReportV13,
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
      actionReportV13: json['action_report_v1_3'] is Map
          ? ActionReportV13.fromJson(
              json['action_report_v1_3'] as Map<String, dynamic>,
            )
          : null,
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
    'action_report_v1_3': actionReportV13?.toJson(),
  };
}

// ===================== ACTION REPORT v1.3 =====================
// The deterministic finding -> fixed-copy -> equipment pipeline (Postura
// Action Report v1.3 / Equipment Engine v1.3). Every text field here is fixed
// copy from the backend — no free-form text is generated for this section.

class ActionReportV13 {
  final int tierNumber;
  final String tierName;
  final int rosaScore;
  final String mainRiskDriver;
  final String executiveSummary;
  final String priorityFindingsIntro;
  final List<FindingV13> priorityFindings;
  final String? supplementalCpeIntro;
  final List<FindingV13> supplementalCpeFindings;
  final List<String> whatYouCanDoNow;
  final String? equipmentHelpsText;
  final List<EquipmentCardV13> equipmentCards;
  final String generalWorkstationHabits;
  final String? professionalReviewLine;

  const ActionReportV13({
    required this.tierNumber,
    required this.tierName,
    required this.rosaScore,
    required this.mainRiskDriver,
    required this.executiveSummary,
    required this.priorityFindingsIntro,
    required this.priorityFindings,
    this.supplementalCpeIntro,
    required this.supplementalCpeFindings,
    required this.whatYouCanDoNow,
    this.equipmentHelpsText,
    required this.equipmentCards,
    required this.generalWorkstationHabits,
    this.professionalReviewLine,
  });

  factory ActionReportV13.fromJson(Map<String, dynamic> json) {
    final header = json['header'] as Map<String, dynamic>? ?? const {};
    return ActionReportV13(
      tierNumber: header['tier_number'] ?? 1,
      tierName: header['tier_name'] ?? 'Low',
      rosaScore: header['rosa_score'] ?? 0,
      mainRiskDriver: header['main_risk_driver'] ?? '',
      executiveSummary: json['executive_summary'] ?? '',
      priorityFindingsIntro: json['priority_findings_intro'] ?? '',
      priorityFindings: (json['priority_findings'] as List<dynamic>? ?? [])
          .map((e) => FindingV13.fromJson(e as Map<String, dynamic>))
          .toList(),
      supplementalCpeIntro: json['supplemental_cpe_intro'] as String?,
      supplementalCpeFindings:
          (json['supplemental_cpe_findings'] as List<dynamic>? ?? [])
              .map((e) => FindingV13.fromJson(e as Map<String, dynamic>))
              .toList(),
      whatYouCanDoNow: List<String>.from(json['what_you_can_do_now'] ?? const []),
      equipmentHelpsText: json['equipment_helps_text'] as String?,
      equipmentCards: (json['equipment_cards'] as List<dynamic>? ?? [])
          .map((e) => EquipmentCardV13.fromJson(e as Map<String, dynamic>))
          .toList(),
      generalWorkstationHabits: json['general_workstation_habits'] ?? '',
      professionalReviewLine: json['professional_review_line'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'header': {
      'tier_number': tierNumber,
      'tier_name': tierName,
      'rosa_score': rosaScore,
      'main_risk_driver': mainRiskDriver,
    },
    'executive_summary': executiveSummary,
    'priority_findings_intro': priorityFindingsIntro,
    'priority_findings': priorityFindings.map((e) => e.toJson()).toList(),
    'supplemental_cpe_intro': supplementalCpeIntro,
    'supplemental_cpe_findings':
        supplementalCpeFindings.map((e) => e.toJson()).toList(),
    'what_you_can_do_now': whatYouCanDoNow,
    'equipment_helps_text': equipmentHelpsText,
    'equipment_cards': equipmentCards.map((e) => e.toJson()).toList(),
    'general_workstation_habits': generalWorkstationHabits,
    'professional_review_line': professionalReviewLine,
  };
}

class FindingV13 {
  final String findingId;
  final String section;
  final String sourceType;
  final bool rosaScored;
  final String employeeLabel;
  final String actionNow;
  final String ergonomicTarget;
  final String isoExplanation;
  final String driverText;
  final bool equipmentHandoff;
  final String? equipmentHandoffText;
  final String? relatedActionLabel;

  const FindingV13({
    required this.findingId,
    required this.section,
    required this.sourceType,
    required this.rosaScored,
    required this.employeeLabel,
    required this.actionNow,
    required this.ergonomicTarget,
    required this.isoExplanation,
    required this.driverText,
    required this.equipmentHandoff,
    this.equipmentHandoffText,
    this.relatedActionLabel,
  });

  factory FindingV13.fromJson(Map<String, dynamic> json) => FindingV13(
    findingId: json['finding_id'] ?? '',
    section: json['section'] ?? '',
    sourceType: json['source_type'] ?? '',
    rosaScored: json['rosa_scored'] as bool? ?? false,
    employeeLabel: json['employee_label'] ?? '',
    actionNow: json['action_now'] ?? '',
    ergonomicTarget: json['ergonomic_target'] ?? '',
    isoExplanation: json['iso_explanation'] ?? '',
    driverText: json['driver_text'] ?? '',
    equipmentHandoff: json['equipment_handoff'] as bool? ?? false,
    equipmentHandoffText: json['equipment_handoff_text'] as String?,
    relatedActionLabel: json['related_action_label'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'finding_id': findingId,
    'section': section,
    'source_type': sourceType,
    'rosa_scored': rosaScored,
    'employee_label': employeeLabel,
    'action_now': actionNow,
    'ergonomic_target': ergonomicTarget,
    'iso_explanation': isoExplanation,
    'driver_text': driverText,
    'equipment_handoff': equipmentHandoff,
    'equipment_handoff_text': equipmentHandoffText,
    'related_action_label': relatedActionLabel,
  };
}

class EquipmentCardV13 {
  final String equipmentId;
  final String cardTitle;
  final String cardDescription;
  final String priorityLabel;
  final String priorityText;
  final List<String> relatedFindings;
  final List<String> whyText;
  final String targetText;
  final List<String> requiredFeatures;
  final String nextStepText;
  final String relatedActionLabel;
  final String? consolidationNote;

  const EquipmentCardV13({
    required this.equipmentId,
    required this.cardTitle,
    required this.cardDescription,
    required this.priorityLabel,
    required this.priorityText,
    required this.relatedFindings,
    required this.whyText,
    required this.targetText,
    required this.requiredFeatures,
    required this.nextStepText,
    required this.relatedActionLabel,
    this.consolidationNote,
  });

  factory EquipmentCardV13.fromJson(Map<String, dynamic> json) => EquipmentCardV13(
    equipmentId: json['equipment_id'] ?? '',
    cardTitle: json['card_title'] ?? '',
    cardDescription: json['card_description'] ?? '',
    priorityLabel: json['priority_label'] ?? '',
    priorityText: json['priority_text'] ?? '',
    relatedFindings: List<String>.from(json['related_findings'] ?? const []),
    whyText: List<String>.from(json['why_text'] ?? const []),
    targetText: json['target_text'] ?? '',
    requiredFeatures: List<String>.from(json['required_features'] ?? const []),
    nextStepText: json['next_step_text'] ?? '',
    relatedActionLabel: json['related_action_label'] ?? 'View related action',
    consolidationNote: json['consolidation_note'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'equipment_id': equipmentId,
    'card_title': cardTitle,
    'card_description': cardDescription,
    'priority_label': priorityLabel,
    'priority_text': priorityText,
    'related_findings': relatedFindings,
    'why_text': whyText,
    'target_text': targetText,
    'required_features': requiredFeatures,
    'next_step_text': nextStepText,
    'related_action_label': relatedActionLabel,
    'consolidation_note': consolidationNote,
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
  // Legacy — the backend no longer sends this (unvalidated improvement
  // projections removed per client audit); kept nullable so old cached
  // reports still parse.
  final ClinicalProjection? clinicalProjection;

  /// "OK" | "STOP_AND_SEEK_CLINICAL_ASSESSMENT" — a real red-flag-checklist
  /// stop, not an NRS cutoff.
  final String exerciseStatus;

  /// "GENTLE" | "MODERATE" | "GENTLE_MAINTENANCE" — pain/duration-driven
  /// dose; never escalates purely because reported pain is higher.
  final String readiness;
  final bool needsCpeReview;
  final String? message;

  Exercises({
    required this.conditionType,
    required this.focusRegions,
    this.mainPainRegion,
    required this.averagePainVas,
    required this.recommendedSession,
    this.clinicalProjection,
    this.exerciseStatus = 'OK',
    this.readiness = 'GENTLE_MAINTENANCE',
    this.needsCpeReview = false,
    this.message,
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
    clinicalProjection: json['clinical_projection'] != null
        ? ClinicalProjection.fromJson(
            json['clinical_projection'] as Map<String, dynamic>,
          )
        : null,
    exerciseStatus: json['exercise_status'] ?? 'OK',
    readiness: json['readiness'] ?? 'GENTLE_MAINTENANCE',
    needsCpeReview: json['needs_cpe_review'] ?? false,
    message: json['message'],
  );

  Map<String, dynamic> toJson() => {
    'condition_type': conditionType,
    'focus_regions': focusRegions,
    'main_pain_region': mainPainRegion?.toJson(),
    'average_pain_vas': averagePainVas,
    'recommended_session': recommendedSession.map((e) => e.toJson()).toList(),
    'exercise_status': exerciseStatus,
    'readiness': readiness,
    'needs_cpe_review': needsCpeReview,
    'message': message,
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
  // Legacy — the backend no longer sends these (unvalidated "Therapy
  // Priority" badge + improvement projections removed per client audit);
  // kept nullable so old cached reports still parse.
  final String? badge;
  final int? improvementPercentage;

  /// "reported_pain" | "image_risk" — whether this exercise was dosed from
  /// employee-reported NRS or is optional gentle movement from a
  /// ROSA/image-only finding (never a "priority" treatment).
  final String? source;

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
    this.source,
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
      source: json['source'] as String?,
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
    'source': source,
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
