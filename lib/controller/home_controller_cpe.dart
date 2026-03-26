import 'package:get/get.dart';
import 'package:posture_detector_app/services/network/custom_http.dart';

// ─────────────────────────────────────────
// Models
// ─────────────────────────────────────────
class CpeCompany {
  final int id;
  final String name;
  final String companyCode;

  const CpeCompany({
    required this.id,
    required this.name,
    required this.companyCode,
  });

  factory CpeCompany.fromJson(Map<String, dynamic> json) {
    return CpeCompany(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      companyCode: json['company_code'] ?? '',
    );
  }
}

class ScanItem {
  final int scanId;
  final int assessmentId;
  final int employeeId;
  final String employeeName;
  final String employeeEmail;
  final String deskLocation;
  final double riskScore;
  final String riskLevel; // "yellow" | "red" | "green"
  final double vasScore;
  final String
  reviewStatus; // "PENDING" | "FOLLOW_UP_REQUIRED" | "APPROVED" | "REJECTED"
  final String? reviewType; // "LIVE" | "REMOTE" | null
  final String reviewComment;
  final String? reviewedBy;
  final String? reviewedAt;
  final String createdAt;

  const ScanItem({
    required this.scanId,
    required this.assessmentId,
    required this.employeeId,
    required this.employeeName,
    required this.employeeEmail,
    required this.deskLocation,
    required this.riskScore,
    required this.riskLevel,
    required this.vasScore,
    required this.reviewStatus,
    this.reviewType,
    required this.reviewComment,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
  });

  factory ScanItem.fromJson(Map<String, dynamic> json) {
    return ScanItem(
      scanId: json['scan_id'] ?? 0,
      assessmentId: json['assessment_id'] ?? 0,
      employeeId: json['employee_id'] ?? 0,
      employeeName: json['employee_name'] ?? '',
      employeeEmail: json['employee_email'] ?? '',
      deskLocation: json['desk_location'] ?? '',
      riskScore: (json['risk_score'] ?? 0).toDouble(),
      riskLevel: json['risk_level'] ?? 'green',
      vasScore: (json['vas_score'] ?? 0).toDouble(),
      reviewStatus: json['review_status'] ?? 'PENDING',
      reviewType: json['review_type'],
      reviewComment: json['review_comment'] ?? '',
      reviewedBy: json['reviewed_by'],
      reviewedAt: json['reviewed_at'],
      createdAt: json['created_at'] ?? '',
    );
  }

  /// compliance % shown on card — inverse of riskScore
  int get compliance => riskScore.toInt();

  bool get isPending => reviewStatus == 'PENDING';
}

// ─────────────────────────────────────────
// Controller
// ─────────────────────────────────────────
class HomeCPEController extends GetxController {
  // ── Observables ──────────────────────────────────────────────────
  final RxString userName = ''.obs;
  final RxString userAvatar = ''.obs;

  final Rx<CpeCompany?> company = Rx<CpeCompany?>(null);
  final RxList<ScanItem> scanList = <ScanItem>[].obs;

  final RxInt totalCount = 0.obs;
  final RxInt totalPages = 1.obs;
  final RxInt currentPage = 1.obs;

  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();

  // ── Lifecycle ─────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchAssessmentList();
  }

  // ── API ───────────────────────────────────────────────────────────
  Future<void> fetchAssessmentList() async {
    isLoading.value = true;
    error.value = null;

    final result = await CustomHttp.get(
      endpoint: 'cpe/ergonomist/company/assessment-list',
      needAuth: true,
      showFloatingError: false,
    );

    isLoading.value = false;

    // ── Error / no connection ─────────────────────────────────────
    if (result.error != null) {
      error.value = result.error;
      return;
    }

    // ── Parse response body ───────────────────────────────────────
    final data = result.data;
    if (data == null) {
      error.value = 'No data received';
      return;
    }

    try {
      if (data['company'] != null) {
        company.value = CpeCompany.fromJson(
          Map<String, dynamic>.from(data['company']),
        );
      }

      totalCount.value = data['count'] ?? 0;
      totalPages.value = data['total_pages'] ?? 1;
      currentPage.value = data['current_page'] ?? 1;

      final List<dynamic> list = data['scan_list'] ?? [];
      scanList.assignAll(
        list.map((e) => ScanItem.fromJson(Map<String, dynamic>.from(e))),
      );
    } catch (e) {
      error.value = e.toString();
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────
  void setUserName(String name) => userName.value = name;
  void setUserAvatar(String url) => userAvatar.value = url;
  void refresh() => fetchAssessmentList();
}
