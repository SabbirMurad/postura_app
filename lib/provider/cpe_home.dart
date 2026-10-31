import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posture_detector_app/services/network/custom_http.dart';

// ─────────────────────────────────────────
// Models
// ─────────────────────────────────────────
class CpeCompany {
  final String id;
  final String name;
  final String companyCode;

  const CpeCompany({
    required this.id,
    required this.name,
    required this.companyCode,
  });

  factory CpeCompany.fromJson(Map<String, dynamic> json) {
    return CpeCompany(
      id: '${json['id'] ?? ''}',
      name: json['name'] ?? '',
      companyCode: json['company_code'] ?? '',
    );
  }
}

class ScanItem {
  final String scanId;
  final String assessmentId;
  final String employeeId;
  final String employeeName;
  final String employeeEmail;
  final String deskLocation;
  final double riskScore;
  final String riskLevel; // "yellow" | "red" | "green"
  final double vasScore;
  final String
  reviewStatus; // "PENDING" | "FOLLOW_UP_REQUIRED" | "APPROVED" | "REJECTED"
  /// A photos-only scan still waiting for the ergonomist's workstation answers.
  final bool awaitingErgonomist;
  final String reviewComment;
  final String? reviewedBy;
  final String? reviewedAt;
  final String createdAt;

  /// ROSA final score (the ergonomist's updated one if revised); null when
  /// the scan has none yet.
  final int? rosaFinal;

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
    this.awaitingErgonomist = false,
    required this.reviewComment,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
    this.rosaFinal,
  });

  factory ScanItem.fromJson(Map<String, dynamic> json) {
    final riskScore = (json['risk_score'] ?? 0).toDouble();
    return ScanItem(
      scanId: '${json['scan_id'] ?? ''}',
      assessmentId: '${json['assessment_id'] ?? ''}',
      employeeId: '${json['employee_id'] ?? ''}',
      employeeName: json['employee_name'] ?? '',
      employeeEmail: json['employee_email'] ?? '',
      deskLocation: json['desk_location'] ?? '',
      riskScore: riskScore,
      riskLevel: json['risk_level'] ?? 'green',
      vasScore: (json['vas_score'] ?? 0).toDouble(),
      reviewStatus: json['review_status'] ?? 'PENDING',
      awaitingErgonomist: json['status'] == 'awaiting_ergonomist',
      reviewComment: json['review_comment'] ?? '',
      reviewedBy: json['reviewed_by'],
      reviewedAt: json['reviewed_at'],
      createdAt: json['created_at'] ?? '',
      rosaFinal: (json['rosa_final'] as num?)?.toInt(),
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

  /// Fetching the next page (the list stays on screen meanwhile).
  final bool isLoadingMore;
  final String? error;

  const CpeHomeState({
    this.company,
    this.scanList = const [],
    this.totalCount = 0,
    this.totalPages = 1,
    this.currentPage = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  bool get hasMore => currentPage < totalPages;
}

// ─────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────
class CpeHomeNotifier extends Notifier<CpeHomeState> {
  @override
  CpeHomeState build() {
    Future.microtask(fetchAssessmentList);
    return const CpeHomeState(isLoading: true);
  }

  Future<void> fetchAssessmentList() async {
    state = CpeHomeState(
      company: state.company,
      scanList: state.scanList,
      isLoading: true,
    );

    final result = await CustomHttp.get(
      endpoint: 'cpe/ergonomist/company/assessment-list?page=1',
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
        company = CpeCompany.fromJson(
          Map<String, dynamic>.from(data['company']),
        );
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
        error: 'Failed to load assessments.',
      );
    }
  }

  /// Load the next page and append it. A failure keeps what's already shown;
  /// scrolling to the end again retries.
  Future<void> fetchNextPage() async {
    final s = state;
    if (s.isLoading || s.isLoadingMore || !s.hasMore) return;
    state = _with(s, isLoadingMore: true);

    final result = await CustomHttp.get(
      endpoint:
          'cpe/ergonomist/company/assessment-list?page=${s.currentPage + 1}',
      needAuth: true,
      showFloatingError: false,
    );
    // A refresh started meanwhile replaced the list; drop this stale page.
    if (!state.isLoadingMore) return;
    final data = result.data;
    if (result.error != null || data == null) {
      state = _with(state, isLoadingMore: false);
      return;
    }
    try {
      final List<dynamic> list = data['scan_list'] ?? [];
      final known = state.scanList.map((e) => e.scanId).toSet();
      // Skip rows already shown (a new scan can shift the pages).
      final more = list
          .map((e) => ScanItem.fromJson(Map<String, dynamic>.from(e)))
          .where((e) => !known.contains(e.scanId));
      state = CpeHomeState(
        company: state.company,
        scanList: [...state.scanList, ...more],
        totalCount: data['count'] ?? state.totalCount,
        totalPages: data['total_pages'] ?? state.totalPages,
        currentPage: data['current_page'] ?? s.currentPage + 1,
      );
    } catch (_) {
      state = _with(state, isLoadingMore: false);
    }
  }

  static CpeHomeState _with(CpeHomeState s, {required bool isLoadingMore}) =>
      CpeHomeState(
        company: s.company,
        scanList: s.scanList,
        totalCount: s.totalCount,
        totalPages: s.totalPages,
        currentPage: s.currentPage,
        isLoadingMore: isLoadingMore,
      );
}

final cpeHomeNotifierProvider = NotifierProvider<CpeHomeNotifier, CpeHomeState>(
  CpeHomeNotifier.new,
);
