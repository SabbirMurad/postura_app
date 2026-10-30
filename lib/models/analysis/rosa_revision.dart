import 'package:posture_detector_app/models/analysis/rosa_score.dart';
import 'package:posture_detector_app/models/assessment/workstation_answers.dart';

/// The ergonomist's one-time update of the workstation answers on an
/// assessment the employee answered themselves (backend `rosa_revision`).
/// The employee's original answers and ROSA score are kept; both are shown.
class RosaRevision {
  const RosaRevision({
    required this.rosaScore,
    required this.answers,
    this.revisedBy,
    this.revisedAt,
    this.raw = const {},
  });

  /// The ROSA score re-calculated from the ergonomist's answers.
  final RosaScore rosaScore;

  /// The ergonomist's answers (checklist plus the two phone questions).
  final ChecklistAnswers answers;

  /// The ergonomist's name, when known.
  final String? revisedBy;
  final DateTime? revisedAt;

  /// The API object as received, so cached reports round-trip unchanged.
  final Map<String, dynamic> raw;

  /// Null when [json] isn't an object (the API sends `null` without a revision).
  static RosaRevision? fromJson(Object? json) {
    if (json is! Map) return null;
    final m = Map<String, dynamic>.from(json);
    return RosaRevision(
      rosaScore: RosaScore.fromJson(
        (m['rosa_score'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      answers: ChecklistAnswers(
        answers: WorkstationAnswers.fromMap(
          (m['workstation_answers'] as Map?)?.cast<String, dynamic>() ??
              const {},
        ),
        phoneCradle: m['phone_cradle'] == true,
        handsFreeAvailable: m['hands_free_available'] != false,
      ),
      revisedBy: m['revised_by'] as String?,
      revisedAt: DateTime.tryParse(m['revised_at'] as String? ?? '')?.toLocal(),
      raw: m,
    );
  }

  Map<String, dynamic> toJson() => raw;
}
