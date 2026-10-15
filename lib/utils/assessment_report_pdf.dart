import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:posture_detector_app/models/analysis/analysis_report.dart';
import 'package:posture_detector_app/models/analysis/rosa_score.dart';
import 'package:posture_detector_app/models/profile/author_model.dart';
import 'package:posture_detector_app/services/equipment_engine.dart';
import 'package:posture_detector_app/view/exercises/exercise_screen.dart';

/// Builds the employee's assessment report as a PDF, entirely on-device, from
/// the `assessments/my-reports` data. Sections follow the order the app shows
/// them after an assessment: ROSA result → risk by body region → ROSA Posture
/// Guidance (Action Report v1.3) → exercise programme → equipment.
///
/// Copy and thresholds mirror the screens (home/analysis result, correction
/// report, exercise and equipment screens) so the PDF says what the app says.
class AssessmentReportPdf {
  AssessmentReportPdf._(this._report, this._profile);

  final AnalysisReport _report;
  final AuthorModel? _profile;

  static const _primary = PdfColor.fromInt(0xFF2180E6);
  static const _text = PdfColor.fromInt(0xFF202020);
  static const _muted = PdfColor.fromInt(0xFF4A4A4A);
  static const _border = PdfColor.fromInt(0xFFE4E7EC);
  static const _red = PdfColor.fromInt(0xFFE53935);
  static const _orange = PdfColor.fromInt(0xFFFB8C00);
  static const _green = PdfColor.fromInt(0xFF43A047);
  static const _warningBg = PdfColor.fromInt(0xFFFFF3CD);
  static const _warningText = PdfColor.fromInt(0xFF856404);

  /// Renders the report and returns the PDF bytes.
  static Future<Uint8List> build({
    required AnalysisReport report,
    AuthorModel? profile,
  }) async {
    // Embedded so names and backend copy outside Latin-1 render correctly
    // (the PDF standard fonts only cover Latin-1).
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/pdf/NotoSans-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/pdf/NotoSans-Bold.ttf'),
    );

    final doc = pw.Document(
      title: 'Postura Ergonomic Assessment Report',
      author: 'Postura',
    );
    final builder = AssessmentReportPdf._(report, profile);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 40, 40, 48),
        theme: pw.ThemeData.withFont(base: regular, bold: bold).copyWith(
          defaultTextStyle: pw.TextStyle(
            font: regular,
            fontBold: bold,
            fontSize: 10,
            color: _text,
            lineSpacing: 2,
          ),
        ),
        footer: builder._footer,
        build: (_) => builder._content(),
      ),
    );
    return doc.save();
  }

  // ── Layout pieces ──────────────────────────────────────────────────────────

  List<pw.Widget> _content() => [
    ..._header(),
    ..._rosaSection(),
    ..._bodyRegionSection(),
    ..._assessmentInputsSection(),
    ..._guidanceSection(),
    ..._exerciseSection(),
    ..._equipmentSection(),
  ];

  pw.Widget _footer(pw.Context context) => pw.Container(
    margin: const pw.EdgeInsets.only(top: 12),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Postura - Ergonomic Assessment Report',
          style: const pw.TextStyle(fontSize: 8, color: _muted),
        ),
        pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 8, color: _muted),
        ),
      ],
    ),
  );

  List<pw.Widget> _header() {
    final rows = <List<String>>[
      if (_profile != null && _profile.fullName.isNotEmpty)
        ['Name', _profile.fullName],
      if (_profile != null && _profile.email.isNotEmpty)
        ['Email', _profile.email],
      if (_report.createdAt != null)
        ['Assessment date', _formatDate(_report.createdAt!)],
      if (_report.heightCm != null && _report.heightCm! > 0)
        ['Height', '${_report.heightCm!.round()} cm'],
    ];
    return [
      pw.Text(
        'POSTURA',
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: _primary,
          letterSpacing: 2,
        ),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        'Ergonomic Assessment Report',
        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 12),
      for (final r in rows)
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 3),
          child: pw.Row(
            children: [
              pw.SizedBox(
                width: 110,
                child: pw.Text(r[0], style: const pw.TextStyle(color: _muted)),
              ),
              pw.Expanded(
                child: pw.Text(
                  r[1],
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      pw.Divider(color: _border, height: 24),
    ];
  }

  // ROSA thresholds match the home / analysis-result screens.
  List<pw.Widget> _rosaSection() {
    final score = _report.rosaScore;
    final color = _finalScoreColor(score.finalScore);
    return [
      _heading('ROSA Ergonomic Analysis'),
      pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: _tint(color),
          border: pw.Border.all(color: color, width: 0.8),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Row(
          children: [
            pw.Text(
              score.isValid ? '${score.finalScore} / 10' : 'N/A',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
            pw.SizedBox(width: 16),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    _finalLabel(score.finalScore),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: color,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    _actionLevel(score.finalScore),
                    style: const pw.TextStyle(fontSize: 9, color: _muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      if (_report.chronicityElevated) ...[
        pw.SizedBox(height: 8),
        _callout(
          title: 'Recovery Outlook: Elevated',
          body:
              'Your answers indicate a higher risk that the current pain could '
              'become longer-term. Early targeted support is recommended in '
              'addition to the workstation adjustments below.',
        ),
      ],
      pw.SizedBox(height: 12),
      _subHeading('Detailed Analysis'),
      _table(
        headers: const ['Category', 'Score', 'Status'],
        rows: _rosaItems(
          score,
        ).map((i) => [i.$1, '${i.$2}', _subScoreLabel(i.$2)]).toList(),
        flex: const [3, 1, 3],
      ),
      pw.SizedBox(height: 16),
    ];
  }

  List<pw.Widget> _bodyRegionSection() {
    final r = _report.bodyRegionRisks;
    // Same four regions the home screen shows.
    final rows = [
      ['Elbows', r.elbows],
      ['Shoulder', r.shoulder],
      ['Wrist', r.wrist],
      ['Lower Back', r.lowerBack],
    ].where((e) => e[1].isNotEmpty).toList();
    if (rows.isEmpty) return const [];
    return [
      _heading('Risk by Body Region'),
      _table(
        headers: const ['Body region', 'Risk'],
        rows: rows.map((e) => [e[0], _capitalize(e[1])]).toList(),
        flex: const [3, 4],
      ),
      pw.SizedBox(height: 16),
    ];
  }

  /// What the employee reported — the context the results are based on.
  List<pw.Widget> _assessmentInputsSection() {
    final pain = _report.painIntensities;
    final symptoms = _report.symptoms.where((s) => s.trim().isNotEmpty);
    if (pain.isEmpty && symptoms.isEmpty && _report.painDuration.isEmpty) {
      return const [];
    }
    return [
      _heading('Reported Pain & Symptoms'),
      if (pain.isNotEmpty)
        _table(
          headers: const ['Body region', 'Pain level (0-10)'],
          rows: pain
              .map((p) => [_humanize(p.bodyRegion), '${p.intensity}'])
              .toList(),
          flex: const [3, 4],
        ),
      if (_report.painDuration.isNotEmpty) ...[
        pw.SizedBox(height: 6),
        _keyValue('Pain duration', _report.painDuration),
      ],
      if (symptoms.isNotEmpty) ...[
        pw.SizedBox(height: 4),
        _keyValue('Symptoms', symptoms.join(', ')),
      ],
      pw.SizedBox(height: 16),
    ];
  }

  /// "ROSA Posture Guidance" — the correction report screen.
  List<pw.Widget> _guidanceSection() {
    final report = _report.actionReportV13;
    if (report == null) {
      // Pre-v1.3 scans: the screen falls back to the AI corrections list.
      final corrections = _report.corrections;
      final legacyFlags = _report.supplementalCpeFindings.flags;
      if (corrections.isEmpty && legacyFlags.isEmpty) return const [];
      return [
        _heading('ROSA Posture Guidance'),
        for (final c in corrections) ..._item(c.title, [c.description]),
        if (legacyFlags.isNotEmpty) ...[
          _subHeading('Supplemental CPE Findings'),
          for (final f in legacyFlags) _bullet(_cpeFindingLabel(f)),
          pw.SizedBox(height: 8),
        ],
        pw.SizedBox(height: 8),
      ];
    }

    return [
      _heading('ROSA Posture Guidance'),
      pw.Text(
        'Tier ${report.tierNumber} - ${report.tierName} | '
        'ROSA ${report.rosaScore}/10',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: _primary),
      ),
      if (report.mainRiskDriver.isNotEmpty)
        pw.Text(
          'Main risk driver: ${report.mainRiskDriver}',
          style: const pw.TextStyle(color: _muted),
        ),
      pw.SizedBox(height: 6),
      if (report.executiveSummary.isNotEmpty) pw.Text(report.executiveSummary),
      pw.SizedBox(height: 10),

      if (report.priorityFindings.isNotEmpty) ...[
        _subHeading('Priority Findings'),
        if (report.priorityFindingsIntro.isNotEmpty)
          _intro(report.priorityFindingsIntro),
        for (final f in report.priorityFindings) ..._finding(f),
      ],

      if (report.supplementalCpeFindings.isNotEmpty) ...[
        _subHeading('Supplemental CPE Findings'),
        if (report.supplementalCpeIntro != null)
          _intro(report.supplementalCpeIntro!),
        for (final f in report.supplementalCpeFindings) ..._finding(f),
      ],

      if (report.whatYouCanDoNow.isNotEmpty) ...[
        _subHeading('What You Can Do Right Now'),
        for (final a in report.whatYouCanDoNow) _bullet(a),
        pw.SizedBox(height: 8),
      ],

      if (report.equipmentHelpsText != null) ...[
        _subHeading('When Equipment Helps'),
        pw.Text(report.equipmentHelpsText!),
        pw.SizedBox(height: 8),
      ],

      if (report.generalWorkstationHabits.isNotEmpty) ...[
        _subHeading('General Workstation Habits'),
        pw.Text(report.generalWorkstationHabits),
        pw.SizedBox(height: 8),
      ],

      if (report.professionalReviewLine != null) ...[
        _callout(body: report.professionalReviewLine!),
        pw.SizedBox(height: 8),
      ],
      pw.SizedBox(height: 8),
    ];
  }

  List<pw.Widget> _finding(FindingV13 f) => _item(f.employeeLabel, [
    f.actionNow,
    f.isoExplanation,
    if (f.equipmentHandoff) f.equipmentHandoffText ?? '',
  ]);

  /// The exercise screen: dose tier header, then one entry per exercise.
  List<pw.Widget> _exerciseSection() {
    final data = _report.exercises;
    final stopped = data.exerciseStatus == 'STOP_AND_SEEK_CLINICAL_ASSESSMENT';
    // Same clinical-projection de-dup the exercise screen applies.
    final cp = data.clinicalProjection;
    final exercises = data.recommendedSession.where((e) {
      if (cp != null && cp.text.isNotEmpty) {
        if (e.bodyRegion.toLowerCase().contains('clinical projection')) {
          return false;
        }
        if (e.description.trim() == cp.text.trim()) return false;
      }
      return true;
    }).toList();

    if (exercises.isEmpty) {
      if (!stopped) return const [];
      return [
        _heading('Personalized Exercise Programme'),
        _callout(
          title: 'Please Check In With a Professional',
          body:
              data.message ??
              'Based on your screening answers, please consult a healthcare '
                  'professional before starting exercises.',
        ),
        pw.SizedBox(height: 16),
      ];
    }

    final label = ExerciseBusinessScreen.sensitivityLabel(data.readiness);
    return [
      _heading('Personalized Exercise Programme'),
      pw.Text(
        '$label programme',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: _primary),
      ),
      pw.Text(ExerciseBusinessScreen.tierMessage(label)),
      pw.Text(
        ExerciseBusinessScreen.frequency(label),
        style: const pw.TextStyle(color: _muted),
      ),
      if (data.needsCpeReview) ...[
        pw.SizedBox(height: 6),
        _callout(
          body:
              'Based on your answers, we recommend keeping these gentle and '
              'reviewing them with your CPE or a healthcare professional. Stop '
              'immediately if any exercise increases your symptoms.',
        ),
      ],
      pw.SizedBox(height: 8),
      for (final e in exercises)
        ..._item(e.bodyRegion, [
          e.description,
          _join([
            if (e.recommendedSets > 0) 'Sets: ${e.recommendedSets}',
            if (e.recommendedDuration.isNotEmpty)
              'Duration: ${e.recommendedDuration}',
            if (e.regionVas != null) 'Pain level (VAS): ${e.regionVas} / 10',
          ]),
          if (e.musclesAddressed?.isNotEmpty ?? false)
            'Why this helps: ${e.musclesAddressed}',
          if (e.purpose?.isNotEmpty ?? false) 'How to do it: ${e.purpose}',
          if (e.safetyNote.isNotEmpty) 'When to stop: ${e.safetyNote}',
        ]),
      pw.SizedBox(height: 8),
    ];
  }

  /// The equipment screen: v1.3 cards when present, otherwise the same legacy
  /// engine / API-list fallback the screen uses.
  List<pw.Widget> _equipmentSection() {
    final v13 = _report.actionReportV13;
    if (v13 != null) {
      if (v13.equipmentCards.isEmpty) return const [];
      return [
        _heading('Equipment Recommendations'),
        for (final c in v13.equipmentCards)
          ..._item('${c.cardTitle}  -  ${c.priorityLabel}', [
            c.priorityText,
            c.cardDescription,
            c.consolidationNote ?? '',
            if (c.whyText.isNotEmpty)
              'Why this appears: ${c.whyText.join(' ')}',
            if (c.requiredFeatures.isNotEmpty)
              'Required features: ${c.requiredFeatures.join(', ')}',
            c.nextStepText,
          ]),
      ];
    }

    final engine = EquipmentEngine.legacyOutputFor(_report);
    if (engine.equipmentCards.isNotEmpty) {
      return [
        _heading('Equipment Recommendations'),
        pw.Text(
          engine.tier,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: _primary),
        ),
        pw.Text(engine.tierMessage),
        pw.SizedBox(height: 8),
        for (final c in engine.equipmentCards)
          ..._item('${c.title}  -  ${c.urgencyLabel}', [
            c.description,
            c.sourceLine,
            c.riskBadgeText,
            c.cardNote ?? '',
          ]),
      ];
    }

    final list = _report.equipment;
    if (list.isEmpty) return const [];
    return [
      _heading('Equipment Recommendations'),
      for (final e in list)
        ..._item(e.name, [
          e.description,
          _join([
            if (e.priority.isNotEmpty) 'Priority: ${_capitalize(e.priority)}',
            if (e.status.isNotEmpty) 'Status: ${e.status}',
          ]),
        ]),
    ];
  }

  // ── Building blocks ────────────────────────────────────────────────────────

  pw.Widget _heading(String text) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
        color: _primary,
      ),
    ),
  );

  pw.Widget _subHeading(String text) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 4, bottom: 4),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
    ),
  );

  pw.Widget _intro(String text) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Text(text, style: const pw.TextStyle(color: _muted)),
  );

  /// A titled entry with its paragraphs. Emitted as separate flow widgets
  /// (not one box) so a long entry can break across pages.
  List<pw.Widget> _item(String title, List<String> paragraphs) => [
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: 4, bottom: 2),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
    ),
    for (final p in paragraphs.where((p) => p.trim().isNotEmpty))
      pw.Padding(
        padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
        child: pw.Text(p.trim()),
      ),
    pw.SizedBox(height: 6),
  ];

  pw.Widget _bullet(String text) => pw.Padding(
    padding: const pw.EdgeInsets.only(left: 4, bottom: 3),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('•  ', style: const pw.TextStyle(color: _primary)),
        pw.Expanded(child: pw.Text(text)),
      ],
    ),
  );

  pw.Widget _keyValue(String key, String value) => pw.RichText(
    text: pw.TextSpan(
      children: [
        pw.TextSpan(
          text: '$key: ',
          style: const pw.TextStyle(color: _muted),
        ),
        pw.TextSpan(text: value),
      ],
    ),
  );

  pw.Widget _callout({String? title, required String body}) => pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: _warningBg,
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (title != null)
          pw.Text(
            title,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: _warningText,
            ),
          ),
        pw.Text(body, style: const pw.TextStyle(color: _warningText)),
      ],
    ),
  );

  pw.Widget _table({
    required List<String> headers,
    required List<List<String>> rows,
    required List<int> flex,
  }) => pw.TableHelper.fromTextArray(
    headers: headers,
    data: rows,
    border: pw.TableBorder.all(color: _border, width: 0.6),
    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
    headerDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
    cellStyle: const pw.TextStyle(fontSize: 9),
    cellAlignment: pw.Alignment.centerLeft,
    cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    columnWidths: {
      for (var i = 0; i < flex.length; i++)
        i: pw.FlexColumnWidth(flex[i].toDouble()),
    },
  );

  // ── Copy & thresholds (same as the app screens) ────────────────────────────

  List<(String, int)> _rosaItems(RosaScore s) => [
    ('Seat Height', s.seatHeightScore),
    ('Backrest', s.backrestScore),
    ('Armrest', s.armrestScore),
    ('Chair', s.chairScore),
    ('Monitor', s.monitorScore),
    ('Keyboard', s.keyboardScore),
    ('Mouse', s.mouseScore),
    ('Peripheral', s.peripheralScore),
  ];

  String _subScoreLabel(int score) {
    if (score == 0) return 'Not assessed';
    if (score >= 3) return 'High risk';
    if (score >= 2) return 'Review needed';
    return 'Optimal';
  }

  PdfColor _finalScoreColor(int score) {
    if (score >= 7) return _red;
    if (score >= 4) return _orange;
    return _green;
  }

  String _finalLabel(int score) {
    if (score >= 7) return 'High risk — immediate action required';
    if (score >= 4) return 'Moderate risk — further investigation';
    return 'Low risk — no immediate action needed';
  }

  String _actionLevel(int score) {
    if (score >= 7) return 'Level 3 — Action required as soon as possible';
    if (score >= 4) return 'Level 2 — Further investigation needed';
    return 'Level 1 — No immediate action needed';
  }

  String _cpeFindingLabel(String flag) {
    switch (flag) {
      case 'B_PHONE_CRADLE':
        return 'Cradles the phone between ear and shoulder during calls';
      case 'B_PHONE_HANDSFREE':
        return 'No hands-free option available for phone calls';
      default:
        return flag;
    }
  }

  // ── Small helpers ──────────────────────────────────────────────────────────

  /// A light background tint of [c], pre-blended onto white (PDF fills don't
  /// reliably honour alpha).
  static PdfColor _tint(PdfColor c) {
    double mix(double v) => 1 - 0.08 * (1 - v);
    return PdfColor(mix(c.red), mix(c.green), mix(c.blue));
  }

  static String _join(List<String> parts) => parts.join('   ·   ');

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  static String _humanize(String s) =>
      _capitalize(s.replaceAll('_', ' ').trim());

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String _formatDate(DateTime d) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${_months[d.month - 1]} ${d.year}, $hh:$mm';
  }
}
