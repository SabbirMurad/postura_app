import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/provider/assessment.dart';
import 'package:posture_detector_app/view/assessment/pain_duration_screen.dart';
import 'package:posture_detector_app/view/live_guidance/features/step3_capture/domain/capture_questionnaire.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PainDurationScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders one duration picker per selected region', (
    tester,
  ) async {
    final notifier = container.read(assessmentNotifierProvider.notifier);
    notifier.toggleRegion(BodyRegion.neck);
    notifier.toggleRegion(BodyRegion.lowerBack);

    await pumpScreen(tester);

    expect(find.text('Neck'), findsOneWidget);
    expect(find.text('Lower Back'), findsOneWidget);
    // Each region gets its own full set of duration chips.
    expect(find.text('1-4 weeks'), findsNWidgets(2));
  });

  testWidgets('a duration applies only to the region it was picked under', (
    tester,
  ) async {
    final notifier = container.read(assessmentNotifierProvider.notifier);
    notifier.toggleRegion(BodyRegion.neck);
    notifier.toggleRegion(BodyRegion.lowerBack);

    await pumpScreen(tester);

    // Tap "1-4 weeks" under the first region (Neck) only.
    await tester.tap(find.text('1-4 weeks').first);
    await tester.pumpAndSettle();

    final state = container.read(assessmentNotifierProvider);
    expect(state.painDuration[BodyRegion.neck], PainDuration.oneToFourWeeks);
    expect(state.painDuration[BodyRegion.lowerBack], isNull);
  });

  testWidgets('each region keeps its own distinct duration', (tester) async {
    final notifier = container.read(assessmentNotifierProvider.notifier);
    notifier.toggleRegion(BodyRegion.neck);
    notifier.toggleRegion(BodyRegion.lowerBack);

    await pumpScreen(tester);

    await tester.tap(find.text('1-4 weeks').first);
    await tester.pumpAndSettle();

    // The second region's chips sit below the fold — scroll before tapping.
    final lowerBackChip = find.text('More than 6 months').last;
    await tester.ensureVisible(lowerBackChip);
    await tester.pumpAndSettle();
    await tester.tap(lowerBackChip);
    await tester.pumpAndSettle();

    final state = container.read(assessmentNotifierProvider);
    expect(state.painDuration[BodyRegion.neck], PainDuration.oneToFourWeeks);
    expect(
      state.painDuration[BodyRegion.lowerBack],
      PainDuration.moreThanSixMonths,
    );
  });

  test('deselecting a region drops its duration', () {
    final notifier = container.read(assessmentNotifierProvider.notifier);
    notifier.toggleRegion(BodyRegion.neck);
    notifier.setPainDurationForRegion(
      BodyRegion.neck,
      PainDuration.lessThan1Week,
    );
    expect(notifier.allRegionsHaveDuration, isTrue);

    notifier.toggleRegion(BodyRegion.neck);

    final state = container.read(assessmentNotifierProvider);
    expect(state.painDuration.containsKey(BodyRegion.neck), isFalse);
  });

  test('allRegionsHaveDuration gates until every region is answered', () {
    final notifier = container.read(assessmentNotifierProvider.notifier);
    notifier.toggleRegion(BodyRegion.neck);
    notifier.toggleRegion(BodyRegion.lowerBack);
    expect(notifier.allRegionsHaveDuration, isFalse);

    notifier.setPainDurationForRegion(
      BodyRegion.neck,
      PainDuration.lessThan1Week,
    );
    expect(notifier.allRegionsHaveDuration, isFalse);

    notifier.setPainDurationForRegion(
      BodyRegion.lowerBack,
      PainDuration.oneToThreeMonths,
    );
    expect(notifier.allRegionsHaveDuration, isTrue);
  });
}
