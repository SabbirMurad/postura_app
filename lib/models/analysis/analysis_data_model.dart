// ===================== ROOT =====================
class AnalysisDataModel {
  final String message;
  final int assessmentId;
  final String? scanType;
  final bool aiSuccess;
  final String? aiErrorMessage;
  final AIResult aiResult;
  final Assessment? assessment;
  final User? user;

  AnalysisDataModel({
    required this.message,
    required this.assessmentId,
    this.scanType,
    this.aiSuccess = true,
    this.aiErrorMessage,
    required this.aiResult,
    this.assessment,
    this.user,
  });

  factory AnalysisDataModel.fromJson(Map<String, dynamic> json) =>
      AnalysisDataModel(
        message: json['message'] ?? '',
        assessmentId: json['assessment_id'] ?? 0,
        scanType: json['scan_type'],
        aiSuccess: json['ai_success'] ?? true,
        aiErrorMessage: json['ai_error_message'],
        aiResult: AIResult.fromJson(json['ai_result'] ?? {}),
        assessment: json['assessment'] != null
            ? Assessment.fromJson(json['assessment'])
            : null,
        user: json['user'] != null ? User.fromJson(json['user']) : null,
      );

  Map<String, dynamic> toJson() => {
    'message': message,
    'assessment_id': assessmentId,
    'scan_type': scanType,
    'ai_success': aiSuccess,
    'ai_error_message': aiErrorMessage,
    'ai_result': aiResult.toJson(),
    'assessment': assessment?.toJson(),
    'user': user?.toJson(),
  };
}

// ===================== ASSESSMENT =====================
class Assessment {
  final int id;
  final String? company;
  final String capturedImage;
  final DateTime lastScanAt;
  final DateTime createdAt;
  final List<String> bodyRegions;
  final List<PainIntensity> painIntensities;
  final String painDuration;
  final WorkPattern? workPattern;
  final List<String> symptoms;

  Assessment({
    required this.id,
    this.company,
    required this.capturedImage,
    required this.lastScanAt,
    required this.createdAt,
    required this.bodyRegions,
    required this.painIntensities,
    required this.painDuration,
    this.workPattern,
    required this.symptoms,
  });

  factory Assessment.fromJson(Map<String, dynamic> json) => Assessment(
    id: json['id'] ?? 0,
    company: json['company'],
    capturedImage: json['captured_image'] ?? '',
    lastScanAt: DateTime.tryParse(json['last_scan_at'] ?? '') ?? DateTime.now(),
    createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    bodyRegions: List<String>.from(json['body_regions'] ?? []),
    painIntensities: (json['pain_intensities'] as List<dynamic>? ?? [])
        .map((e) => PainIntensity.fromJson(e as Map<String, dynamic>))
        .toList(),
    painDuration: json['pain_duration'] ?? '',
    workPattern: json['work_pattern'] != null
        ? WorkPattern.fromJson(json['work_pattern'])
        : null,
    symptoms: List<String>.from(json['symptoms'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'company': company,
    'captured_image': capturedImage,
    'last_scan_at': lastScanAt.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'body_regions': bodyRegions,
    'pain_intensities': painIntensities.map((e) => e.toJson()).toList(),
    'pain_duration': painDuration,
    'work_pattern': workPattern?.toJson(),
    'symptoms': symptoms,
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

// ===================== WORK PATTERN =====================
class WorkPattern {
  final String hoursAtDesk;
  final String breakHabit;
  final String deviceUsage;

  WorkPattern({
    required this.hoursAtDesk,
    required this.breakHabit,
    required this.deviceUsage,
  });

  factory WorkPattern.fromJson(Map<String, dynamic> json) => WorkPattern(
    hoursAtDesk: json['hours_at_desk'] ?? '',
    breakHabit: json['break_habit'] ?? '',
    deviceUsage: json['device_usage'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'hours_at_desk': hoursAtDesk,
    'break_habit': breakHabit,
    'device_usage': deviceUsage,
  };
}

// ===================== USER =====================
class User {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String? fullName;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.fullName,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    avatar: json['avatar'],
    fullName: json['full_name'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'avatar': avatar,
    'full_name': fullName,
  };
}

// ===================== AI RESULT =====================
class AIResult {
  final double complianceScore;
  final String overallRisk;
  final String annotatedImageUrl;
  final DetailedAnalysis detailedAnalysis;
  final BodyRegionRisks bodyRegionRisks;
  final List<Correction> corrections;
  final Exercises exercises;
  final List<Equipment> equipment;
  final String pdfReportUrl;
  final String equipmentPdfUrl;

  AIResult({
    required this.complianceScore,
    required this.overallRisk,
    required this.annotatedImageUrl,
    required this.detailedAnalysis,
    required this.bodyRegionRisks,
    required this.corrections,
    required this.exercises,
    required this.equipment,
    required this.pdfReportUrl,
    required this.equipmentPdfUrl,
  });

  factory AIResult.fromJson(Map<String, dynamic> json) => AIResult(
    complianceScore: (json['compliance_score'] ?? 0).toDouble(),
    overallRisk: json['overall_risk'] ?? '',
    annotatedImageUrl: json['annotated_image_url'] ?? '',
    detailedAnalysis: DetailedAnalysis.fromJson(
      json['detailed_analysis'] ?? {},
    ),
    bodyRegionRisks: BodyRegionRisks.fromJson(json['body_region_risks'] ?? {}),
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
    equipmentPdfUrl: json['equipment_pdf_url'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'compliance_score': complianceScore,
    'overall_risk': overallRisk,
    'annotated_image_url': annotatedImageUrl,
    'detailed_analysis': detailedAnalysis.toJson(),
    'body_region_risks': bodyRegionRisks.toJson(),
    'corrections': corrections.map((e) => e.toJson()).toList(),
    'exercises': exercises.toJson(),
    'equipment': equipment.map((e) => e.toJson()).toList(),
    'pdf_report_url': pdfReportUrl,
    'equipment_pdf_url': equipmentPdfUrl,
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

// ===================== DETAILED ANALYSIS =====================
class DetailedAnalysis {
  final Posture posture;
  final Workstation workstation;

  DetailedAnalysis({required this.posture, required this.workstation});

  factory DetailedAnalysis.fromJson(Map<String, dynamic> json) =>
      DetailedAnalysis(
        posture: Posture.fromJson(json['posture'] ?? {}),
        workstation: Workstation.fromJson(json['workstation'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
    'posture': posture.toJson(),
    'workstation': workstation.toJson(),
  };
}

// ===================== POSTURE =====================
class Posture {
  final AngleData neckFlexion;
  final ShoulderElevation shoulderElevation;
  final AngleData elbowAngle;
  final AngleData wristDeviation;
  final AngleData pelvicTilt;

  Posture({
    required this.neckFlexion,
    required this.shoulderElevation,
    required this.elbowAngle,
    required this.wristDeviation,
    required this.pelvicTilt,
  });

  factory Posture.fromJson(Map<String, dynamic> json) => Posture(
    neckFlexion: AngleData.fromJson(json['neck_flexion'] ?? {}),
    shoulderElevation: ShoulderElevation.fromJson(
      json['shoulder_elevation'] ?? {},
    ),
    elbowAngle: AngleData.fromJson(json['elbow_angle'] ?? {}),
    wristDeviation: AngleData.fromJson(json['wrist_deviation'] ?? {}),
    pelvicTilt: AngleData.fromJson(json['pelvic_tilt'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'neck_flexion': neckFlexion.toJson(),
    'shoulder_elevation': shoulderElevation.toJson(),
    'elbow_angle': elbowAngle.toJson(),
    'wrist_deviation': wristDeviation.toJson(),
    'pelvic_tilt': pelvicTilt.toJson(),
  };
}

// ===================== ANGLE DATA =====================
class AngleData {
  final double angle;
  final String severity;
  final String iso;
  final double deviation;

  AngleData({
    required this.angle,
    required this.severity,
    required this.iso,
    required this.deviation,
  });

  factory AngleData.fromJson(Map<String, dynamic> json) => AngleData(
    angle: (json['angle'] ?? 0).toDouble(),
    severity: json['severity'] ?? '',
    iso: json['iso'] ?? '',
    deviation: (json['deviation'] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'angle': angle,
    'severity': severity,
    'iso': iso,
    'deviation': deviation,
  };
}

// ===================== SHOULDER ELEVATION =====================
class ShoulderElevation {
  final double angle;
  final String severity;
  final String iso;

  ShoulderElevation({
    required this.angle,
    required this.severity,
    required this.iso,
  });

  factory ShoulderElevation.fromJson(Map<String, dynamic> json) =>
      ShoulderElevation(
        angle: (json['angle'] ?? 0).toDouble(),
        severity: json['severity'] ?? '',
        iso: json['iso'] ?? '',
      );

  Map<String, dynamic> toJson() => {
    'angle': angle,
    'severity': severity,
    'iso': iso,
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
      video: json['video'] ?? '',
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

  Equipment({
    required this.name,
    required this.description,
    required this.priority,
    required this.improvementPercentage,
    this.source,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) => Equipment(
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    priority: json['priority'] ?? '',
    improvementPercentage: json['improvement_percentage'] ?? '',
    source: json['source'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'priority': priority,
    'improvement_percentage': improvementPercentage,
    'source': source,
  };
}

// ===================== WORKSTATION =====================
class Workstation {
  Workstation();

  factory Workstation.fromJson(Map<String, dynamic> json) => Workstation();

  Map<String, dynamic> toJson() => {};
}
