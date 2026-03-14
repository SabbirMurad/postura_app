import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/data/services/network/custom_http.dart';
import 'package:posture_detector_app/features/cpe/controller/home_controller_cpe.dart';

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
  bool isChecked;

  ApprovalItem({
    required this.label,
    required this.apiKey,
    this.isChecked = false,
  });
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
// Controller
// ─────────────────────────────────────────
class CPEAssessmentController extends GetxController {
  final _picker = ImagePicker();

  // Passed from HomeScreenCPE: arguments: {'scan_id': scan.scanId}
  int get scanId => (Get.arguments?['scan_id'] ?? 0) as int;

  // ── State ──────────────────────────────
  final isLoading = true.obs;
  final isSubmitting = false.obs;
  // Tracks the original status from API — button only shows when initially PENDING
  final initialReviewStatus = ''.obs;

  final patientName = ''.obs;
  final patientId = ''.obs;

  final compliance = 0.obs;
  final riskLevel = ''.obs;

  final deskLocation = ''.obs;
  final deskRole = ''.obs;

  final painSymptoms = <PainSymptom>[].obs;
  final photoItems = <PhotoItem>[].obs;
  final approvalItems = <ApprovalItem>[].obs;

  final reviewMode = ReviewMode.remote.obs;
  final decision = ReviewDecision.pending.obs;

  final comment = ''.obs;
  final maxCommentLength = 500;

  // Local file path picked by user
  final signaturePath = ''.obs;
  // Remote URL from API (review_signature_url)
  final signatureRemoteUrl = ''.obs;

  // ── Computed ───────────────────────────
  double get compliancePercent => (compliance.value / 100.0).clamp(0.0, 1.0);

  String get complianceLabel {
    switch (riskLevel.value.toLowerCase()) {
      case 'red':
        return 'Red';
      case 'yellow':
        return 'Moderate';
      case 'green':
        return 'Good';
      default:
        final v = compliance.value;
        if (v < 40) return 'Red';
        if (v < 70) return 'Moderate';
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

  String get decisionLabel => decision.value.label;
  bool get canAddMorePhotos => photoItems.length < 4;

  // ── Lifecycle ──────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  // ─────────────────────────────────────
  // GET  cpe/ergonomist/company/assessment/detail/{scan_id}/
  // ─────────────────────────────────────
  Future<void> _loadData() async {
    isLoading.value = true;

    final result = await CustomHttp.get(
      endpoint: 'cpe/ergonomist/company/assessment/detail/$scanId',
      needAuth: true,
      showFloatingError: true,
    );

    isLoading.value = false;

    if (result.error != null) return;
    final data = result.data;
    if (data == null) return;

    try {
      final d = Map<String, dynamic>.from(data['scan_detail'] ?? data);

      patientName.value = d['employee_name'] ?? '';
      patientId.value = '${d['employee_id'] ?? ''}';

      final rawRisk = (d['risk_score'] ?? 0).toDouble();
      compliance.value = rawRisk.toInt();
      riskLevel.value = d['risk_level'] ?? '';

      deskLocation.value = d['desk_location'] ?? '';
      final wp = d['work_pattern'] as Map<String, dynamic>?;
      deskRole.value = wp?['device_usage'] ?? '';

      final painDuration = d['pain_duration'] ?? '';
      final intensities = d['pain_intensities'] as List<dynamic>? ?? [];
      painSymptoms.assignAll(
        intensities.map((e) {
          final m = Map<String, dynamic>.from(e);
          return PainSymptom(
            area: m['body_region'] ?? '',
            duration: painDuration,
            intensity: (m['intensity'] ?? 0) as int,
          );
        }),
      );

      // Seed photos with annotated image from API
      photoItems.clear();
      final annotatedUrl = d['annotated_image_url'] as String?;
      if (annotatedUrl != null && annotatedUrl.isNotEmpty) {
        photoItems.add(PhotoItem.remote(annotatedUrl));
      }

      final approvalsMap = d['approvals'] as Map<String, dynamic>? ?? {};
      approvalItems.assignAll([
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
      ]);

      decision.value = ReviewDecision.fromApi(d['review_status']);
      initialReviewStatus.value = d['review_status'] ?? '';
      comment.value = d['review_comment'] ?? '';
      final reviewType = d['review_type'] as String?;
      reviewMode.value = reviewType == 'LIVE'
          ? ReviewMode.live
          : ReviewMode.remote;
      // Pre-fill signature from API if already reviewed
      signatureRemoteUrl.value = d['review_signature_url'] as String? ?? '';
    } catch (e) {
      final loc = AppLocalizations.of(Get.context!)!;
      Get.snackbar(loc.error, '${loc.failedToParseResponse}: $e');
    }
  }

  // ─────────────────────────────────────
  // Approvals
  // ─────────────────────────────────────
  void toggleApproval(int index) {
    if (index < 0 || index >= approvalItems.length) return;
    final item = approvalItems[index];
    approvalItems[index] = ApprovalItem(
      label: item.label,
      apiKey: item.apiKey,
      isChecked: !item.isChecked,
    );
    approvalItems.refresh();
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
      signaturePath.value = picked.path;
      signatureRemoteUrl.value = ''; // clear remote when user picks new
    }
  }

  void removeSignature() {
    signaturePath.value = '';
    signatureRemoteUrl.value = '';
  }

  // ─────────────────────────────────────
  // Setters
  // ─────────────────────────────────────
  void setReviewMode(ReviewMode mode) => reviewMode.value = mode;
  void setDecision(ReviewDecision d) => decision.value = d;

  void setComment(String value) {
    if (value.length <= maxCommentLength) comment.value = value;
  }

  // ─────────────────────────────────────
  // Submit
  // POST cpe/ergonomist/assessment/submit-review/{scan_id}/
  // Content-Type: multipart/form-data
  //
  // Fields:
  //   landmarks_verified        → "True" | "False"
  //   workstation_verified      → "True" | "False"
  //   rosa_verified             → "True" | "False"
  //   recommendations_verified  → "True" | "False"
  //   review_type               → "REMOTE" | "LIVE"
  //   review_status             → "APPROVED" | "REJECTED" | "FOLLOW_UP_REQUIRED" | "NEED_CHANGES" | "PENDING"
  //   review_comment            → string
  //   review_signature          → File (image)
  // ─────────────────────────────────────
  Future<void> submitReview() async {
    isSubmitting.value = true;
    try {
      // ── Text fields ──
      final fields = <String, String>{
        // Approvals — API expects "True" / "False" strings
        for (final item in approvalItems)
          item.apiKey: item.isChecked ? 'True' : 'False',

        'review_type': reviewMode.value.apiValue,
        'review_status': decision.value.apiValue,
        'review_comment': comment.value,
      };

      // ── File fields ──
      final files = <http.MultipartFile>[];
      if (signaturePath.value.isNotEmpty) {
        files.add(
          await http.MultipartFile.fromPath(
            'review_signature',
            signaturePath.value,
          ),
        );
      }

      // ── Send via CustomHttp.multipart ──
      final result = await CustomHttp.multipart(
        endpoint: 'cpe/ergonomist/assessment/submit-review/$scanId',
        method: CommonCustomMethods.POST,
        fields: fields,
        files: files,
      );

      if (result.error == null) {
        // Refresh CPE home list so the updated status shows
        if (Get.isRegistered<HomeCPEController>()) {
          Get.find<HomeCPEController>().fetchAssessmentList();
        }
        Get.back();
        final loc = AppLocalizations.of(Get.context!)!;
        Get.snackbar(loc.success, loc.reviewSubmittedSuccessfully);
      }
    } catch (e) {
      final loc = AppLocalizations.of(Get.context!)!;
      Get.snackbar(loc.error, '${loc.failedToSubmit}: $e');
    } finally {
      isSubmitting.value = false;
    }
  }
}
