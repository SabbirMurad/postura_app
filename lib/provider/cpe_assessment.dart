import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:posture_detector_app/models/prepared_image.dart';
import 'package:posture_detector_app/utils/media.dart' as media;
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/utils/l10n.dart';
import 'package:posture_detector_app/models/analysis/body_angles.dart';
import 'package:posture_detector_app/services/network/custom_http.dart';
import 'package:posture_detector_app/provider/cpe_home.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/main.dart';
import 'package:posture_detector_app/models/analysis/rosa_revision.dart';
import 'package:posture_detector_app/models/analysis/rosa_score.dart';
import 'package:posture_detector_app/models/assessment/assessment_mode.dart';
import 'package:posture_detector_app/models/assessment/screening_review.dart';
import 'package:posture_detector_app/models/assessment/workstation_answers.dart';
import 'package:posture_detector_app/models/analysis/analysis_report.dart'
    show ActionReportV13;
import 'package:posture_detector_app/models/analysis/review_flag.dart';

// ─────────────────────────────────────────
// Models
// ─────────────────────────────────────────
class PainSymptom {
  final String area;
  final String duration;
  final int intensity;

  const PainSymptom({
    required this.area,
    required this.duration,
    required this.intensity,
  });
}

class ApprovalItem {
  final String apiKey;
  final bool isChecked;

  const ApprovalItem({
    required this.apiKey,
    this.isChecked = false,
  });

  /// The checklist text shown for [apiKey], in the selected language.
  String get label => switch (apiKey) {
    'landmarks_verified' => l10n.rvwApprovalLandmarksVerified,
    'workstation_verified' => l10n.rvwApprovalWorkstationVerified,
    'rosa_verified' => l10n.rvwApprovalRosaVerified,
    'recommendations_verified' => l10n.rvwApprovalRecommendationsVerified,
    _ => apiKey,
  };

  ApprovalItem copyWith({bool? isChecked}) => ApprovalItem(
    apiKey: apiKey,
    isChecked: isChecked ?? this.isChecked,
  );
}

class PhotoItem {
  final String path;
  final String? remoteUrl;
  final bool isRemote;

  const PhotoItem.local(this.path) : remoteUrl = null, isRemote = false;

  const PhotoItem.remote(String url)
    : path = '',
      remoteUrl = url,
      isRemote = true;
}

/// One side-view capture as shown in review: the image URL plus its measured
/// angles (reuses [BodyAngles] for the geometry).
class SideCaptureView {
  final String image;
  final BodyAngles angles;
  final bool? monitorDetected;

  /// Top of the monitor relative to eye level as read from this photo:
  /// 'below', 'at' or 'above' (the questionnaire's values). Null on older
  /// scans, or when the photo had no monitor box or eye-level line.
  final String? monitorHeightFromPhoto;

  const SideCaptureView({
    required this.image,
    required this.angles,
    this.monitorDetected,
    this.monitorHeightFromPhoto,
  });

  factory SideCaptureView.fromJson(Map<String, dynamic> m) => SideCaptureView(
    image: m['image'] as String? ?? '',
    angles: BodyAngles.fromJson(m),
    monitorDetected: m['monitor_detected'] as bool?,
    monitorHeightFromPhoto: m['monitor_height_from_photo'] as String?,
  );
}

/// The front-view capture as shown in review: the image URL plus the two raw
/// front-view angles.
class FrontCaptureView {
  final String image;
  /// Null when the app couldn't measure the angle on the front photo.
  final double? abductionAngle;
  final double? wristDeviationAngle;

  const FrontCaptureView({
    required this.image,
    this.abductionAngle,
    this.wristDeviationAngle,
  });

  factory FrontCaptureView.fromJson(Map<String, dynamic> m) => FrontCaptureView(
    image: m['image'] as String? ?? '',
    abductionAngle: (m['abduction_angle'] as num?)?.toDouble(),
    wristDeviationAngle: (m['wrist_deviation_angle'] as num?)?.toDouble(),
  );
}

enum ReviewDecision {
  approved('APPROVED'),
  followUpRequired('FOLLOW_UP_REQUIRED'),
  needChanges('NEED_CHANGE'),
  pending('PENDING');

  final String apiValue;
  const ReviewDecision(this.apiValue);

  /// The label shown for this decision, in the selected language.
  String get label => switch (this) {
    ReviewDecision.approved => l10n.approved,
    ReviewDecision.followUpRequired => l10n.rvwFollowUpRequired,
    ReviewDecision.needChanges => l10n.rvwNeedChanges,
    ReviewDecision.pending => l10n.pending,
  };

  static ReviewDecision fromApi(String? value) {
    return ReviewDecision.values.firstWhere(
      (d) => d.apiValue == value,
      orElse: () => ReviewDecision.pending,
    );
  }
}

// ─────────────────────────────────────────
// State
// ─────────────────────────────────────────
class CpeAssessmentState {
  final bool isLoading;
  final bool isSubmitting;
  final String initialReviewStatus;
  final String patientName;
  final String patientId;
  final int compliance;
  final String riskLevel;
  final String chronicityLevel;
  final double? heightCm;
  final String deskLocation;
  final List<PainSymptom> painSymptoms;
  final List<SideCaptureView> sideCaptures;
  final FrontCaptureView? frontCapture;
  final List<ApprovalItem> approvalItems;
  final ReviewDecision decision;
  final String comment;
  final int maxCommentLength;
  final String signaturePath;
  final String signatureRemoteUrl;

  // ROSA scores
  final RosaScore rosaScore;

  /// The deterministic Action Report v1.3 (tier-limited priority findings +
  /// equipment cards) for this scan, when the backend has computed one.
  final ActionReportV13? actionReportV13;

  /// True for a photos-only scan the employee left to the ergonomist: it has
  /// no ROSA score or report until [checklistAnswers] are submitted with the
  /// review.
  final bool awaitingErgonomist;

  /// The ergonomist's workstation answers, sent with the review: required for
  /// a photos-only scan, or the one-time update of the employee's answers
  /// (null until they fill in the checklist).
  final ChecklistAnswers? checklistAnswers;

  /// True when the employee answered the workstation questions themselves.
  final bool answeredByEmployee;

  /// The employee's own answers, used to pre-fill the checklist when the
  /// ergonomist updates them. Null for photos-only scans.
  final ChecklistAnswers? employeeAnswers;

  /// The ergonomist's one-time update of the employee's answers, once
  /// submitted. [rosaScore] stays the employee's original score.
  final RosaRevision? rosaRevision;

  /// The ergonomist may update the employee's answers once per assessment.
  bool get canReviseAnswers =>
      answeredByEmployee && !awaitingErgonomist && rosaRevision == null;

  /// The score the recommendations follow: the updated one when there is one.
  RosaScore get currentRosaScore => rosaRevision?.rosaScore ?? rosaScore;

  /// The employee's health screening answers. Sent only on the ergonomist
  /// detail endpoint; empty for scans recorded without them.
  final List<ScreeningAnswer> redFlagAnswers;
  final bool redFlagPositive;
  final List<ScreeningAnswer> recoveryAnswers;

  /// Why the server marked this scan for review (uncertain or conflicting
  /// photo readings); empty when there is nothing to check.
  final List<ReviewFlag> reviewFlags;

  const CpeAssessmentState({
    this.isLoading = true,
    this.isSubmitting = false,
    this.initialReviewStatus = '',
    this.patientName = '',
    this.patientId = '',
    this.compliance = 0,
    this.riskLevel = '',
    this.chronicityLevel = 'Low',
    this.heightCm,
    this.deskLocation = '',
    this.painSymptoms = const [],
    this.sideCaptures = const [],
    this.frontCapture,
    this.approvalItems = const [],
    this.decision = ReviewDecision.pending,
    this.comment = '',
    this.maxCommentLength = 500,
    this.signaturePath = '',
    this.signatureRemoteUrl = '',
    required this.rosaScore,
    this.actionReportV13,
    this.awaitingErgonomist = false,
    this.checklistAnswers,
    this.answeredByEmployee = true,
    this.employeeAnswers,
    this.rosaRevision,
    this.redFlagAnswers = const [],
    this.redFlagPositive = false,
    this.recoveryAnswers = const [],
    this.reviewFlags = const [],
  });

  double get compliancePercent => (compliance / 100.0).clamp(0.0, 1.0);

  bool get chronicityElevated => chronicityLevel == 'Elevated';

  /// 'red', 'moderate' or 'good' (internal, never shown).
  String get _complianceBand {
    switch (riskLevel.toLowerCase()) {
      case 'red':
        return 'red';
      case 'yellow':
        return 'moderate';
      case 'green':
        return 'good';
      default:
        if (compliance < 40) return 'red';
        if (compliance < 70) return 'moderate';
        return 'good';
    }
  }

  String get complianceLabel {
    switch (_complianceBand) {
      case 'red':
        return l10n.scoreRed;
      case 'moderate':
        return l10n.scoreModerate;
      default:
        return l10n.scoreGood;
    }
  }

  String get complianceSubtitle {
    switch (_complianceBand) {
      case 'red':
        return l10n.immediateCorrectRequired;
      case 'moderate':
        return l10n.needsImprovement;
      default:
        return l10n.keepItUp;
    }
  }

  String get decisionLabel => decision.label;

  CpeAssessmentState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? initialReviewStatus,
    String? patientName,
    String? patientId,
    int? compliance,
    String? riskLevel,
    String? chronicityLevel,
    double? heightCm,
    String? deskLocation,
    List<PainSymptom>? painSymptoms,
    List<PhotoItem>? photoItems,
    List<ApprovalItem>? approvalItems,
    ReviewDecision? decision,
    String? comment,
    String? signaturePath,
    String? signatureRemoteUrl,
    RosaScore? rosaScore,
    ChecklistAnswers? checklistAnswers,
    bool clearChecklistAnswers = false,
  }) => CpeAssessmentState(
    isLoading: isLoading ?? this.isLoading,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    initialReviewStatus: initialReviewStatus ?? this.initialReviewStatus,
    patientName: patientName ?? this.patientName,
    patientId: patientId ?? this.patientId,
    compliance: compliance ?? this.compliance,
    riskLevel: riskLevel ?? this.riskLevel,
    chronicityLevel: chronicityLevel ?? this.chronicityLevel,
    heightCm: heightCm ?? this.heightCm,
    deskLocation: deskLocation ?? this.deskLocation,
    painSymptoms: painSymptoms ?? this.painSymptoms,
    sideCaptures: sideCaptures,
    frontCapture: frontCapture,
    approvalItems: approvalItems ?? this.approvalItems,
    decision: decision ?? this.decision,
    comment: comment ?? this.comment,
    maxCommentLength: maxCommentLength,
    signaturePath: signaturePath ?? this.signaturePath,
    signatureRemoteUrl: signatureRemoteUrl ?? this.signatureRemoteUrl,
    rosaScore: rosaScore ?? this.rosaScore,
    // Not a copyWith param — only ever set once in _loadData, same as
    // sideCaptures/frontCapture above, so always preserved as-is.
    actionReportV13: actionReportV13,
    awaitingErgonomist: awaitingErgonomist,
    checklistAnswers: clearChecklistAnswers
        ? null
        : checklistAnswers ?? this.checklistAnswers,
    answeredByEmployee: answeredByEmployee,
    employeeAnswers: employeeAnswers,
    rosaRevision: rosaRevision,
    redFlagAnswers: redFlagAnswers,
    redFlagPositive: redFlagPositive,
    recoveryAnswers: recoveryAnswers,
    reviewFlags: reviewFlags,
  );
}

// ─────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────
class CpeAssessmentNotifier
    extends AutoDisposeFamilyNotifier<CpeAssessmentState?, String> {
  final _picker = ImagePicker();

  @override
  CpeAssessmentState? build(String scanId) {
    _loadData(scanId);
    return null;
  }

  // ─────────────────────────────────────
  // GET  cpe/ergonomist/company/assessment/detail/{scan_id}/
  // ─────────────────────────────────────
  Future<void> _loadData(String scanId) async {
    final result = await CustomHttp.get(
      endpoint: 'cpe/ergonomist/company/assessment/detail/$scanId',
      needAuth: true,
      showFloatingError: true,
    );

    if (result.error != null) return;
    final data = result.data;
    if (data == null) return;

    try {
      final d = Map<String, dynamic>.from(data['scan_detail'] ?? data);

      final rawRisk = (d['risk_score'] ?? 0).toDouble();

      // Backend sends `pain_units` — each row carries its own body_region,
      // intensity and duration (not the old flat pain_intensities/pain_duration).
      final painUnits = d['pain_units'] as List<dynamic>? ?? [];
      final painSymptoms = painUnits.map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        return PainSymptom(
          area: m['body_region'] ?? '',
          duration: m['duration'] ?? '',
          intensity: (m['intensity'] as num?)?.toInt() ?? 0,
        );
      }).toList();

      final approvalsMap = d['approvals'] as Map<String, dynamic>? ?? {};
      final approvalItems = [
        ApprovalItem(
          apiKey: 'landmarks_verified',
          isChecked: approvalsMap['landmarks_verified'] == true,
        ),
        ApprovalItem(
          apiKey: 'workstation_verified',
          isChecked: approvalsMap['workstation_verified'] == true,
        ),
        ApprovalItem(
          apiKey: 'rosa_verified',
          isChecked: approvalsMap['rosa_verified'] == true,
        ),
        ApprovalItem(
          apiKey: 'recommendations_verified',
          isChecked: approvalsMap['recommendations_verified'] == true,
        ),
      ];

      state = CpeAssessmentState(
        isLoading: false,
        patientName: d['employee_name'] ?? '',
        patientId: '${d['employee_id'] ?? ''}',
        compliance: rawRisk.toInt(),
        riskLevel: d['risk_level'] ?? '',
        chronicityLevel: d['chronicity_level'] ?? 'Low',
        heightCm: (d['height_cm'] as num?)?.toDouble(),
        deskLocation: d['desk_location'] ?? '',
        painSymptoms: painSymptoms,
        sideCaptures: (d['side_captures'] as List? ?? const [])
            .map((e) => SideCaptureView.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        frontCapture: d['front_capture'] == null
            ? null
            : FrontCaptureView.fromJson(
                Map<String, dynamic>.from(d['front_capture'] as Map),
              ),
        approvalItems: approvalItems,
        decision: ReviewDecision.fromApi(d['review_status']),
        initialReviewStatus: d['review_status'] ?? '',
        comment: d['review_comment'] ?? '',
        signatureRemoteUrl: d['review_signature_url'] as String? ?? '',
        rosaScore: RosaScore.fromJson(
          (d['rosa_score'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{},
        ),
        actionReportV13: d['action_report_v1_3'] is Map
            ? ActionReportV13.fromJson(
                Map<String, dynamic>.from(d['action_report_v1_3'] as Map),
              )
            : null,
        awaitingErgonomist: d['status'] == scanStatusAwaitingErgonomist,
        answeredByEmployee: AssessmentMode.fromApi(d['assessment_mode'] as String?) ==
            AssessmentMode.employee,
        employeeAnswers: d['workstation_answers'] is Map &&
                (d['workstation_answers'] as Map).isNotEmpty
            ? ChecklistAnswers(
                answers: WorkstationAnswers.fromMap(
                  Map<String, dynamic>.from(d['workstation_answers'] as Map),
                ),
                phoneCradle:
                    (d['supplemental_cpe_findings'] as Map?)?['phone_cradle'] == true,
                handsFreeAvailable:
                    (d['supplemental_cpe_findings'] as Map?)?['hands_free_available'] !=
                        false,
              )
            : null,
        rosaRevision: RosaRevision.fromJson(d['rosa_revision']),
        redFlagAnswers: redFlagAnswersFromJson(
          (d['red_flag_screening'] as Map?)?.cast<String, dynamic>(),
        ),
        redFlagPositive:
            (d['red_flag_screening'] as Map?)?['red_flag_positive'] == true,
        recoveryAnswers: recoveryAnswersFromJson(
          (d['yellow_flag_answers'] as Map?)?.cast<String, dynamic>(),
        ),
        reviewFlags: ReviewFlag.listFromJson(d['review_flags']),
      );
    } catch (e) {
      final loc = AppLocalizations.of(scaffoldMessengerKey.currentContext!)!;
      showCustomToast(text: '${loc.error}: ${loc.failedToParseResponse}');
    }
  }

  // ─────────────────────────────────────
  // Approvals
  // ─────────────────────────────────────
  void toggleApproval(int index) {
    final s = state;
    if (s == null || index < 0 || index >= s.approvalItems.length) return;
    final items = List<ApprovalItem>.from(s.approvalItems);
    items[index] = items[index].copyWith(isChecked: !items[index].isChecked);
    state = s.copyWith(approvalItems: items);
  }

  // ─────────────────────────────────────
  // Signature
  // ─────────────────────────────────────
  Future<void> pickSignature() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked != null) {
      state = state?.copyWith(
        signaturePath: picked.path,
        signatureRemoteUrl: '',
      );
    }
  }

  void removeSignature() {
    state = state?.copyWith(signaturePath: '', signatureRemoteUrl: '');
  }

  // ─────────────────────────────────────
  // Setters
  // ─────────────────────────────────────
  void setChecklistAnswers(ChecklistAnswers answers) =>
      state = state?.copyWith(checklistAnswers: answers);

  /// Drop an unsent update of the employee's answers.
  void clearChecklistAnswers() =>
      state = state?.copyWith(clearChecklistAnswers: true);
  void setDecision(ReviewDecision d) => state = state?.copyWith(decision: d);

  void setComment(String value) {
    final s = state;
    if (s != null && value.length <= s.maxCommentLength) {
      state = s.copyWith(comment: value);
    }
  }

  // ─────────────────────────────────────
  // Submit
  // POST cpe/ergonomist/assessment/submit-review/{scan_id}/
  // ─────────────────────────────────────
  Future<bool> submitReview() async {
    final s = state;
    if (s == null) return false;

    // A photos-only scan is scored from the ergonomist's answers, so they're
    // required with its review.
    if (s.awaitingErgonomist && s.checklistAnswers == null) {
      final loc = AppLocalizations.of(scaffoldMessengerKey.currentContext!)!;
      showCustomToast(text: loc.answerWorkstationQuestionsFirst);
      return false;
    }

    // A signature image is required (the backend rejects a submission without one).
    if (s.signaturePath.isEmpty) {
      final loc = AppLocalizations.of(scaffoldMessengerKey.currentContext!)!;
      showCustomToast(text: '${loc.error}: ${loc.failedToSubmit}');
      return false;
    }

    state = s.copyWith(isSubmitting: true);
    try {
      // All image bytes go through the /image endpoint. Upload the signature
      // there first and submit only its returned id (used_at = Signature, so it
      // is auth-gated when served).
      final prepared = PreparedImage.fromFile(File(s.signaturePath));
      prepared.meta = await prepared.get_prepare_meta();
      prepared.prepared = true;
      final ids = await media.upload_images(
        images: [prepared],
        used_at: media.AssetUsedAt.Signature,
      );
      if (ids == null || ids.isEmpty) {
        final loc = AppLocalizations.of(scaffoldMessengerKey.currentContext!)!;
        showCustomToast(text: '${loc.error}: ${loc.failedToSubmit}');
        return false;
      }

      final body = <String, dynamic>{
        for (final item in s.approvalItems) item.apiKey: item.isChecked,
        'review_status': s.decision.apiValue,
        'review_comment': s.comment,
        'review_signature': ids.first,
        // Completes a photos-only scan, or is the one-time update of the
        // employee's answers.
        if (s.checklistAnswers != null &&
            (s.awaitingErgonomist || s.canReviseAnswers))
          'answers': s.checklistAnswers!.toJson(),
      };

      final result = await CustomHttp.post(
        endpoint: 'cpe/ergonomist/assessment/submit-review/$arg',
        body: body,
      );

      if (result.error == null) {
        ref.read(cpeHomeNotifierProvider.notifier).fetchAssessmentList();
        final ctx = scaffoldMessengerKey.currentContext;
        if (ctx != null) {
          // ignore: use_build_context_synchronously
          final loc = AppLocalizations.of(ctx)!;
          showCustomToast(
            text: '${loc.success}: ${loc.reviewSubmittedSuccessfully}',
          );
          // ignore: use_build_context_synchronously
          return true;
        }
      }
    } catch (e) {
      final loc = AppLocalizations.of(scaffoldMessengerKey.currentContext!)!;
      showCustomToast(text: '${loc.error}: ${loc.failedToSubmit}');
    } finally {
      state = state?.copyWith(isSubmitting: false);
    }
    return false;
  }
}

final cpeAssessmentNotifierProvider = NotifierProvider.autoDispose
    .family<CpeAssessmentNotifier, CpeAssessmentState?, String>(
      CpeAssessmentNotifier.new,
    );
