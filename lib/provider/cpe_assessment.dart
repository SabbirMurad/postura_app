import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/models/analysis/analysis_report.dart';
import 'package:posture_detector_app/services/network/custom_http.dart';
import 'package:posture_detector_app/provider/cpe_home.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/main.dart';
import 'package:posture_detector_app/view/live_guidance/features/step3_capture/domain/rosa_score.dart';

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
  final String label;
  final String apiKey;
  final bool isChecked;

  const ApprovalItem({
    required this.label,
    required this.apiKey,
    this.isChecked = false,
  });

  ApprovalItem copyWith({bool? isChecked}) => ApprovalItem(
    label: label,
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

enum ReviewMode { remote, live }

extension ReviewModeApi on ReviewMode {
  String get apiValue => this == ReviewMode.remote ? 'REMOTE' : 'LIVE';
}

enum ReviewDecision {
  approved('Approved', 'APPROVED'),
  followUpRequired('Follow Up Required', 'FOLLOW_UP_REQUIRED'),
  needChanges('Need Changes', 'NEED_CHANGES'),
  pending('Pending', 'PENDING');

  final String label;
  final String apiValue;
  const ReviewDecision(this.label, this.apiValue);

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
  final String deskLocation;
  final WorkPattern workPattern;
  final Workstation workstation;
  final List<PainSymptom> painSymptoms;
  final String image;
  final List<ApprovalItem> approvalItems;
  final ReviewMode reviewMode;
  final ReviewDecision decision;
  final String comment;
  final int maxCommentLength;
  final String signaturePath;
  final String signatureRemoteUrl;

  // ROSA scores
  final RosaScore rosaScore;

  const CpeAssessmentState({
    this.isLoading = true,
    this.isSubmitting = false,
    this.initialReviewStatus = '',
    this.patientName = '',
    this.patientId = '',
    this.compliance = 0,
    this.riskLevel = '',
    this.deskLocation = '',
    required this.workPattern,
    required this.workstation,
    this.painSymptoms = const [],
    required this.image,
    this.approvalItems = const [],
    this.reviewMode = ReviewMode.remote,
    this.decision = ReviewDecision.pending,
    this.comment = '',
    this.maxCommentLength = 500,
    this.signaturePath = '',
    this.signatureRemoteUrl = '',
    required this.rosaScore,
  });

  double get compliancePercent => (compliance / 100.0).clamp(0.0, 1.0);

  String get complianceLabel {
    switch (riskLevel.toLowerCase()) {
      case 'red':
        return 'Red';
      case 'yellow':
        return 'Moderate';
      case 'green':
        return 'Good';
      default:
        if (compliance < 40) return 'Red';
        if (compliance < 70) return 'Moderate';
        return 'Good';
    }
  }

  String get complianceSubtitle {
    switch (complianceLabel) {
      case 'Red':
        return 'Immediate correction required!';
      case 'Moderate':
        return 'Needs improvement.';
      default:
        return 'Keep it up!';
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
    String? deskLocation,
    WorkPattern? workPattern,
    Workstation? workstation,
    List<PainSymptom>? painSymptoms,
    List<PhotoItem>? photoItems,
    List<ApprovalItem>? approvalItems,
    ReviewMode? reviewMode,
    ReviewDecision? decision,
    String? comment,
    String? signaturePath,
    String? signatureRemoteUrl,
    RosaScore? rosaScore,
  }) => CpeAssessmentState(
    isLoading: isLoading ?? this.isLoading,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    initialReviewStatus: initialReviewStatus ?? this.initialReviewStatus,
    patientName: patientName ?? this.patientName,
    patientId: patientId ?? this.patientId,
    compliance: compliance ?? this.compliance,
    riskLevel: riskLevel ?? this.riskLevel,
    deskLocation: deskLocation ?? this.deskLocation,
    workPattern: workPattern ?? this.workPattern,
    workstation: workstation ?? this.workstation,
    painSymptoms: painSymptoms ?? this.painSymptoms,
    image: image,
    approvalItems: approvalItems ?? this.approvalItems,
    reviewMode: reviewMode ?? this.reviewMode,
    decision: decision ?? this.decision,
    comment: comment ?? this.comment,
    maxCommentLength: maxCommentLength,
    signaturePath: signaturePath ?? this.signaturePath,
    signatureRemoteUrl: signatureRemoteUrl ?? this.signatureRemoteUrl,
    rosaScore: rosaScore ?? this.rosaScore,
  );
}

// ─────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────
class CpeAssessmentNotifier
    extends AutoDisposeFamilyNotifier<CpeAssessmentState?, int> {
  final _picker = ImagePicker();

  @override
  CpeAssessmentState? build(int scanId) {
    _loadData(scanId);
    return null;
  }

  // ─────────────────────────────────────
  // GET  cpe/ergonomist/company/assessment/detail/{scan_id}/
  // ─────────────────────────────────────
  Future<void> _loadData(int scanId) async {
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

      final painDuration = d['pain_duration'] ?? '';
      final intensities = d['pain_intensities'] as List<dynamic>? ?? [];
      final painSymptoms = intensities.map((e) {
        final m = Map<String, dynamic>.from(e);
        return PainSymptom(
          area: m['body_region'] ?? '',
          duration: painDuration,
          intensity: (m['intensity'] ?? 0) as int,
        );
      }).toList();

      final photoItems = <PhotoItem>[];
      final annotatedUrl = d['annotated_image_url'] as String?;
      if (annotatedUrl != null && annotatedUrl.isNotEmpty) {
        photoItems.add(PhotoItem.remote(annotatedUrl));
      }

      final approvalsMap = d['approvals'] as Map<String, dynamic>? ?? {};
      final approvalItems = [
        ApprovalItem(
          label: 'Posture landmarks are valid and accurate',
          apiKey: 'landmarks_verified',
          isChecked: approvalsMap['landmarks_verified'] == true,
        ),
        ApprovalItem(
          label: 'Workstation equipment is correctly identified',
          apiKey: 'workstation_verified',
          isChecked: approvalsMap['workstation_verified'] == true,
        ),
        ApprovalItem(
          label: 'ROSA score calculation is verified',
          apiKey: 'rosa_verified',
          isChecked: approvalsMap['rosa_verified'] == true,
        ),
        ApprovalItem(
          label: 'Recommendations are professionally appropriate',
          apiKey: 'recommendations_verified',
          isChecked: approvalsMap['recommendations_verified'] == true,
        ),
      ];

      final wp = d['work_pattern'] as Map<String, dynamic>;
      final ws = d['workstation'] as Map<String, dynamic>;
      final reviewType = d['review_type'] as String?;

      state = CpeAssessmentState(
        isLoading: false,
        patientName: d['employee_name'] ?? '',
        patientId: '${d['employee_id'] ?? ''}',
        compliance: rawRisk.toInt(),
        riskLevel: d['risk_level'] ?? '',
        deskLocation: d['desk_location'] ?? '',
        workPattern: WorkPattern.fromJson(wp),
        workstation: Workstation.fromJson(ws),
        painSymptoms: painSymptoms,
        image: d['captured_image'],
        approvalItems: approvalItems,
        decision: ReviewDecision.fromApi(d['review_status']),
        initialReviewStatus: d['review_status'] ?? '',
        comment: d['review_comment'] ?? '',
        reviewMode: reviewType == 'LIVE' ? ReviewMode.live : ReviewMode.remote,
        signatureRemoteUrl: d['review_signature_url'] as String? ?? '',
        rosaScore: RosaScore.fromJson(d['rosa_score'] as Map<String, dynamic>),
      );
    } catch (e) {
      final loc = AppLocalizations.of(scaffoldMessengerKey.currentContext!)!;
      showCustomToast(text: '${loc.error}: ${loc.failedToParseResponse}: $e');
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
  void setReviewMode(ReviewMode mode) =>
      state = state?.copyWith(reviewMode: mode);
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
    state = s.copyWith(isSubmitting: true);
    try {
      final fields = <String, String>{
        for (final item in s.approvalItems)
          item.apiKey: item.isChecked ? 'True' : 'False',
        'review_type': s.reviewMode.apiValue,
        'review_status': s.decision.apiValue,
        'review_comment': s.comment,
      };

      final files = <http.MultipartFile>[];
      if (s.signaturePath.isNotEmpty) {
        files.add(
          await http.MultipartFile.fromPath(
            'review_signature',
            s.signaturePath,
          ),
        );
      }

      final result = await CustomHttp.multipart(
        endpoint: 'cpe/ergonomist/assessment/submit-review/$arg',
        method: CommonCustomMethods.POST,
        fields: fields,
        files: files,
      );

      if (result.error == null) {
        ref.read(cpeHomeNotifierProvider.notifier).fetchAssessmentList();
        final ctx = scaffoldMessengerKey.currentContext;
        if (ctx != null) {
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
      showCustomToast(text: '${loc.error}: ${loc.failedToSubmit}: $e');
    } finally {
      state = state?.copyWith(isSubmitting: false);
    }
    return false;
  }
}

final cpeAssessmentNotifierProvider = NotifierProvider.autoDispose
    .family<CpeAssessmentNotifier, CpeAssessmentState?, int>(
      CpeAssessmentNotifier.new,
    );
