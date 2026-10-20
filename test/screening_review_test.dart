import 'package:flutter_test/flutter_test.dart';
import 'package:posture_detector_app/models/assessment/screening_review.dart';

void main() {
  test('red-flag answers flag every Yes', () {
    final a = redFlagAnswersFromJson({
      'saddle_anaesthesia': true,
      'new_bladder_or_bowel_dysfunction': false,
      'red_flag_positive': true,
    });
    expect(a, hasLength(7));
    expect(a.where((x) => x.flagged).map((x) => x.answer), ['Yes']);
  });

  test('recovery answers use the backend chronicity thresholds', () {
    final a = recoveryAnswersFromJson({
      'chronicity_risk': 7, // >= 7 flags
      'rtw_expectancy': 5, // <= 4 flags
      'fear_avoidance': 6,
      'light_work_capacity': 4, // <= 4 flags
      'sleep_interference': 9,
      'presenteeism': 0,
      'previous_absence': '6-15 days', // flags
      'workplace_support': 4, // <= 3 flags
    });
    expect(a, hasLength(8));
    expect(a.map((x) => x.flagged).toList(),
        [true, false, false, true, false, false, true, false]);
    expect(a.first.answer, '7 / 10');
  });

  test('missing screening gives no rows', () {
    expect(redFlagAnswersFromJson(null), isEmpty);
    expect(recoveryAnswersFromJson(null), isEmpty);
  });
}
