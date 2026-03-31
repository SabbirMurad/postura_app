import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/services/network/custom_http.dart';
import 'package:posture_detector_app/provider/cpe_home.dart';
import 'package:get/get.dart';

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
  final String deskRole;
  final List<PainSymptom> painSymptoms;
  final List<PhotoItem> photoItems;
  final List<ApprovalItem> approvalItems;
  final ReviewMode reviewMode;
  final ReviewDecision decision;
  final String comment;
  final int maxCommentLength;
  final String signaturePath;
  final String signatureRemoteUrl;

  const CpeAssessmentState({
    this.isLoading = true,
    this.isSubmitting = false,
    this.initialReviewStatus = '',
    this.patientName = '',
    this.patientId = '',
    this.compliance = 0,
    this.riskLevel = '',
    this.deskLocation = '',
    this.deskRole = '',
    this.painSymptoms = const [],
    this.photoItems = const [],
    this.approvalItems = const [],
    this.reviewMode = ReviewMode.remote,
    this.decision = ReviewDecision.pending,
    this.comment = '',
    this.maxCommentLength = 500,
    this.signaturePath = '',
    this.signatureRemoteUrl = '',
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
  bool get canAddMorePhotos => photoItems.length < 4;

  CpeAssessmentState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? initialReviewStatus,
    String? patientName,
    String? patientId,
    int? compliance,
    String? riskLevel,
    String? deskLocation,
    String? deskRole,
    List<PainSymptom>? painSymptoms,
    List<PhotoItem>? photoItems,
    List<ApprovalItem>? approvalItems,
    ReviewMode? reviewMode,
    ReviewDecision? decision,
    String? comment,
    String? signaturePath,
    String? signatureRemoteUrl,
  }) =>
      CpeAssessmentState(
        isLoading: isLoading ?? this.isLoading,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        initialReviewStatus: initialReviewStatus ?? this.initialReviewStatus,
        patientName: patientName ?? this.patientName,
        patientId: patientId ?? this.patientId,
        compliance: compliance ?? this.compliance,
        riskLevel: riskLevel ?? this.riskLevel,
        deskLocation: deskLocation ?? this.deskLocation,
        deskRole: deskRole ?? this.deskRole,
        painSymptoms: painSymptoms ?? this.painSymptoms,
        photoItems: photoItems ?? this.photoItems,
        approvalItems: approvalItems ?? this.approvalItems,
        reviewMode: reviewMode ?? this.reviewMode,
        decision: decision ?? this.decision,
        comment: comment ?? this.comment,
        maxCommentLength: maxCommentLength,
        signaturePath: signaturePath ?? this.signaturePath,
        signatureRemoteUrl: signatureRemoteUrl ?? this.signatureRemoteUrl,
      );
}

// ─────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────
class CpeAssessmentNotifier
    extends AutoDisposeFamilyNotifier<CpeAssessmentState, int> {
  final _picker = ImagePicker();

  @override
  CpeAssessmentState build(int scanId) {
    _loadData(scanId);
    return const CpeAssessmentState();
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

    if (result.error != null) {
      state = state.copyWith(isLoading: false);
      return;
    }
    final data = result.data;
    if (data == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

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

      final wp = d['work_pattern'] as Map<String, dynamic>?;
      final reviewType = d['review_type'] as String?;

      state = CpeAssessmentState(
        isLoading: false,
        patientName: d['employee_name'] ?? '',
        patientId: '${d['employee_id'] ?? ''}',
        compliance: rawRisk.toInt(),
        riskLevel: d['risk_level'] ?? '',
        deskLocation: d['desk_location'] ?? '',
        deskRole: wp?['device_usage'] ?? '',
        painSymptoms: painSymptoms,
        photoItems: photoItems,
        approvalItems: approvalItems,
        decision: ReviewDecision.fromApi(d['review_status']),
        initialReviewStatus: d['review_status'] ?? '',
        comment: d['review_comment'] ?? '',
        reviewMode: reviewType == 'LIVE' ? ReviewMode.live : ReviewMode.remote,
        signatureRemoteUrl: d['review_signature_url'] as String? ?? '',
      );
    } catch (e) {
      final loc = AppLocalizations.of(Get.context!)!;
      Get.snackbar(loc.error, '${loc.failedToParseResponse}: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  // ─────────────────────────────────────
  // Approvals
  // ─────────────────────────────────────
  void toggleApproval(int index) {
    if (index < 0 || index >= state.approvalItems.length) return;
    final items = List<ApprovalItem>.from(state.approvalItems);
    items[index] = items[index].copyWith(isChecked: !items[index].isChecked);
    state = state.copyWith(approvalItems: items);
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
      state = state.copyWith(
        signaturePath: picked.path,
        signatureRemoteUrl: '',
      );
    }
  }

  void removeSignature() {
    state = state.copyWith(signaturePath: '', signatureRemoteUrl: '');
  }

  // ─────────────────────────────────────
  // Setters
  // ─────────────────────────────────────
  void setReviewMode(ReviewMode mode) => state = state.copyWith(reviewMode: mode);
  void setDecision(ReviewDecision d) => state = state.copyWith(decision: d);

  void setComment(String value) {
    if (value.length <= state.maxCommentLength) {
      state = state.copyWith(comment: value);
    }
  }

  // ─────────────────────────────────────
  // Submit
  // POST cpe/ergonomist/assessment/submit-review/{scan_id}/
  // ─────────────────────────────────────
  Future<void> submitReview() async {
    state = state.copyWith(isSubmitting: true);
    try {
      final fields = <String, String>{
        for (final item in state.approvalItems)
          item.apiKey: item.isChecked ? 'True' : 'False',
        'review_type': state.reviewMode.apiValue,
        'review_status': state.decision.apiValue,
        'review_comment': state.comment,
      };

      final files = <http.MultipartFile>[];
      if (state.signaturePath.isNotEmpty) {
        files.add(
          await http.MultipartFile.fromPath(
            'review_signature',
            state.signaturePath,
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
        Get.back();
        final loc = AppLocalizations.of(Get.context!)!;
        Get.snackbar(loc.success, loc.reviewSubmittedSuccessfully);
      }
    } catch (e) {
      final loc = AppLocalizations.of(Get.context!)!;
      Get.snackbar(loc.error, '${loc.failedToSubmit}: $e');
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}

final cpeAssessmentNotifierProvider = NotifierProvider.autoDispose
    .family<CpeAssessmentNotifier, CpeAssessmentState, int>(
  CpeAssessmentNotifier.new,
);
