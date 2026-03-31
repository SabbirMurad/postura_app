import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final String reviewStatus; // "PENDING" | "FOLLOW_UP_REQUIRED" | "APPROVED" | "REJECTED"
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

  int get compliance => riskScore.toInt();
  bool get isPending => reviewStatus == 'PENDING';
}

// ─────────────────────────────────────────
// State
// ─────────────────────────────────────────
class CpeHomeState {
  final CpeCompany? company;
  final List<ScanItem> scanList;
  final int totalCount;
  final int totalPages;
  final int currentPage;
  final bool isLoading;
  final String? error;

  const CpeHomeState({
    this.company,
    this.scanList = const [],
    this.totalCount = 0,
    this.totalPages = 1,
    this.currentPage = 1,
    this.isLoading = false,
    this.error,
  });
}

// ─────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────
class CpeHomeNotifier extends Notifier<CpeHomeState> {
  @override
  CpeHomeState build() {
    fetchAssessmentList();
    return const CpeHomeState(isLoading: true);
  }

  Future<void> fetchAssessmentList() async {
    state = CpeHomeState(
      company: state.company,
      scanList: state.scanList,
      isLoading: true,
    );

    final result = await CustomHttp.get(
      endpoint: 'cpe/ergonomist/company/assessment-list',
      needAuth: true,
      showFloatingError: false,
    );

    if (result.error != null) {
      state = CpeHomeState(
        company: state.company,
        scanList: state.scanList,
        isLoading: false,
        error: result.error,
      );
      return;
    }

    final data = result.data;
    if (data == null) {
      state = CpeHomeState(
        company: state.company,
        scanList: state.scanList,
        isLoading: false,
        error: 'No data received',
      );
      return;
    }

    try {
      CpeCompany? company;
      if (data['company'] != null) {
        company = CpeCompany.fromJson(Map<String, dynamic>.from(data['company']));
      }

      final List<dynamic> list = data['scan_list'] ?? [];
      final scanList = list
          .map((e) => ScanItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      state = CpeHomeState(
        company: company,
        scanList: scanList,
        totalCount: data['count'] ?? 0,
        totalPages: data['total_pages'] ?? 1,
        currentPage: data['current_page'] ?? 1,
        isLoading: false,
      );
    } catch (e) {
      state = CpeHomeState(
        company: state.company,
        scanList: state.scanList,
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final cpeHomeNotifierProvider = NotifierProvider<CpeHomeNotifier, CpeHomeState>(
  CpeHomeNotifier.new,
);
