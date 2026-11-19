import 'package:posture_detector_app/models/equipment/equipment_output.dart';
import 'package:posture_detector_app/models/analysis/analysis_report.dart';
import 'package:posture_detector_app/models/analysis/rosa_score.dart';
import 'package:posture_detector_app/utils/l10n.dart';

// ── Input contract (§2.1) ─────────────────────────────────────────────────────

class EquipmentEngineInput {
  // Full ROSA score object — sub-scores and final score are derived from it
  final RosaScore rosaScore;

  // VAS scores 0–10; null if region was not selected on intake screen
  final double? vasNeck;
  final double? vasUpperBack;
  final double? vasLowerBack;
  final double? vasShoulder;
  final double? vasWrist;
  final double? vasElbow;
  final double? vasKnee;
  final double? vasFeet;
  final double? vasHip;

  // Intake screen inputs
  final String workZoneType; // 'desk' | 'standingDesk' | 'hybrid' | 'other'
  final String hoursAtDesk; // 'h0_4' | 'h4_6' | 'h6_8' | 'h8plus'
  final String breakHabit; // 'every1h' | 'every2h' | 'every3h' | 'rarely'
  final String deviceSetup; // 'laptop' | 'singleScreen' | 'dualScreen'
  final String mouseType; // 'standard' | 'smallNotebook' | 'trackpadOrNone'
  final String?
  painDuration; // 'ltOneWeek' | 'oneToSixWeeks' | 'gtSixWeeks' | 'onOffMonths'

  // Optional symptoms
  final bool symTingling;
  final bool symFatigue;
  final bool symEndOfDay;
  final bool symStiffness;
  final bool symMorningPain;

  const EquipmentEngineInput({
    required this.rosaScore,
    this.vasNeck,
    this.vasUpperBack,
    this.vasLowerBack,
    this.vasShoulder,
    this.vasWrist,
    this.vasElbow,
    this.vasKnee,
    this.vasFeet,
    this.vasHip,
    required this.workZoneType,
    required this.hoursAtDesk,
    required this.breakHabit,
    required this.deviceSetup,
    required this.mouseType,
    this.painDuration,
    this.symTingling = false,
    this.symFatigue = false,
    this.symEndOfDay = false,
    this.symStiffness = false,
    this.symMorningPain = false,
  });
}

// ── Equipment library — hardcoded constant (§2.2, §2.3) ──────────────────────

class _LibraryItem {
  final String id;
  final String title;
  final String description;
  final String sourceLine;
  final String category;
  final String rosaSourceKey;
  final List<String> vasRegions;

  const _LibraryItem({
    required this.id,
    required this.title,
    required this.description,
    required this.sourceLine,
    required this.category,
    required this.rosaSourceKey,
    required this.vasRegions,
  });
}

// A getter, not a const: titles, descriptions and source lines are shown to the
// user and follow the selected language. Ids, categories and keys never change.
List<_LibraryItem> get _equipmentLibrary => [
  _LibraryItem(
    id: 'equip_01',
    title: l10n.rptEquipMonitorRiserTitle,
    description: l10n.rptEquipMonitorRiserDescription,
    sourceLine: l10n.rptEquipSourceIsoMonitor,
    category: 'monitor',
    rosaSourceKey: 'rosaMonitor',
    vasRegions: ['neck'],
  ),
  _LibraryItem(
    id: 'equip_02',
    title: l10n.rptEquipFootrestTitle,
    description: l10n.rptEquipFootrestDescription,
    sourceLine: l10n.rptEquipSourceIsoChair,
    category: 'chair',
    rosaSourceKey: 'rosaChair',
    vasRegions: ['lowerBack', 'knee', 'feet'],
  ),
  _LibraryItem(
    id: 'equip_03',
    title: l10n.rptEquipLumbarCushionTitle,
    description: l10n.rptEquipLumbarCushionDescription,
    sourceLine: l10n.rptEquipSourceIsoChair,
    category: 'chair',
    rosaSourceKey: 'rosaChair',
    vasRegions: ['lowerBack', 'hip'],
  ),
  _LibraryItem(
    id: 'equip_04',
    title: l10n.rptEquipWristRestTitle,
    description: l10n.rptEquipWristRestDescription,
    sourceLine: l10n.rptEquipSourceRempelKeyboard,
    category: 'keyboard',
    rosaSourceKey: 'rosaKeyboard',
    vasRegions: ['wrist', 'elbow'],
  ),
  _LibraryItem(
    id: 'equip_05',
    title: l10n.rptEquipKeyboardTrayTitle,
    description: l10n.rptEquipKeyboardTrayDescription,
    sourceLine: l10n.rptEquipSourceIsoKeyboard,
    category: 'keyboard',
    rosaSourceKey: 'rosaKeyboard',
    vasRegions: ['wrist', 'elbow'],
  ),
  _LibraryItem(
    id: 'equip_06',
    title: l10n.rptEquipErgonomicMouseTitle,
    description: l10n.rptEquipErgonomicMouseDescription,
    sourceLine: l10n.rptEquipSourceVanEerdMouse,
    category: 'mouse',
    rosaSourceKey: 'rosaMouse',
    vasRegions: ['wrist', 'shoulder'],
  ),
  _LibraryItem(
    id: 'equip_07',
    title: l10n.rptEquipArmrestPadsTitle,
    description: l10n.rptEquipArmrestPadsDescription,
    sourceLine: l10n.rptEquipSourceVanEerdArmrest,
    category: 'armrest',
    rosaSourceKey: 'rosaChairArmrest',
    vasRegions: ['shoulder', 'upperBack'],
  ),
];

// ── Lookup maps ───────────────────────────────────────────────────────────────

/// Risk badge text ("Monitor risk: 3") for a ROSA source key; '' when the key
/// has no badge. Keys are internal codes and never change.
String _riskBadgeText(String rosaSourceKey, int score) {
  switch (rosaSourceKey) {
    case 'rosaMonitor':
      return l10n.rptRiskBadgeMonitor(score);
    case 'rosaChair':
      return l10n.rptRiskBadgeChair(score);
    case 'rosaKeyboard':
      return l10n.rptRiskBadgeKeyboard(score);
    case 'rosaMouse':
      return l10n.rptRiskBadgeMouse(score);
    case 'rosaChairArmrest':
      return l10n.rptRiskBadgeArmrest(score);
    default:
      return '';
  }
}

/// Tier message by tier code (codes 'RED' / 'ORANGE' / ... stay as they are).
Map<String, String> get _tierMessageMap => {
  'RED': l10n.rptEquipTierMessageRed,
  'ORANGE': l10n.rptEquipTierMessageOrange,
  'GREEN': l10n.rptEquipTierMessageGreen,
  'YELLOW': l10n.rptEquipTierMessageYellow,
};

// ── Internal mutable card used during engine processing ───────────────────────

class _WorkingCard {
  final String equipmentId;
  final String title;
  final String description;
  final String sourceLine;
  final String category;
  final String rosaSourceKey;
  final int rosaSubScore;
  final String? linkedVasRegion;
  final double? linkedVasScore;

  int urgencyLevel;
  String? cardNote;
  bool chronicityFlag = false;
  bool suppressed = false;

  _WorkingCard({
    required this.equipmentId,
    required this.title,
    required this.description,
    required this.sourceLine,
    required this.category,
    required this.rosaSourceKey,
    required this.rosaSubScore,
    this.linkedVasRegion,
    this.linkedVasScore,
    required this.urgencyLevel,
  });

  void appendNote(String note) {
    cardNote = cardNote == null ? note : '$cardNote $note';
  }

  EquipmentCard toCard() {
    final String urgencyLabel;
    if (urgencyLevel >= 3) {
      urgencyLabel = l10n.rptUrgencyUrgent;
    } else if (urgencyLevel == 2) {
      urgencyLabel = l10n.rptUrgencyRecommended;
    } else {
      urgencyLabel = l10n.rptUrgencyPreventive;
    }

    final riskBadgeText = _riskBadgeText(rosaSourceKey, rosaSubScore);

    return EquipmentCard(
      equipmentId: equipmentId,
      title: title,
      description: description,
      sourceLine: sourceLine,
      category: category,
      rosaSourceKey: rosaSourceKey,
      rosaSubScore: rosaSubScore,
      linkedVasRegion: linkedVasRegion,
      linkedVasScore: linkedVasScore,
      urgencyLabel: urgencyLabel,
      urgencyLevel: urgencyLevel,
      riskBadgeText: riskBadgeText,
      cardNote: cardNote,
      chronicityFlag: chronicityFlag,
    );
  }
}

// ── Engine ────────────────────────────────────────────────────────────────────

class EquipmentEngine {
  EquipmentEngine._();

  /// Translated label for a tier code ('RED', 'ORANGE', 'GREEN', 'YELLOW').
  /// The code itself is what the logic and colours use; show this instead.
  static String tierLabel(String tier) {
    switch (tier.toUpperCase()) {
      case 'RED':
        return l10n.rptTierRed;
      case 'ORANGE':
        return l10n.rptTierOrange;
      case 'GREEN':
        return l10n.rptTierGreen;
      case 'YELLOW':
        return l10n.rptTierYellow;
      default:
        return tier;
    }
  }

  /// Equipment output for a pre-v1.3 report (no `action_report_v1_3`), built
  /// from its ROSA score, pain ratings and symptoms. Shared by the equipment
  /// screen and the exported PDF so both show the same cards.
  static EquipmentOutput legacyOutputFor(AnalysisReport data) {
    final painIntensities = data.painIntensities;

    double? vasFor(List<String> regions) {
      for (final pi in painIntensities) {
        if (regions.any(
          (r) => pi.bodyRegion.toLowerCase().contains(r.toLowerCase()),
        )) {
          return pi.intensity.toDouble();
        }
      }
      return null;
    }

    final symptoms = data.symptoms;

    return run(
      EquipmentEngineInput(
        rosaScore: data.rosaScore,
        workZoneType: 'desk',
        hoursAtDesk: data.workPattern.hoursAtDesk,
        breakHabit: data.workPattern.breakHabit,
        deviceSetup: data.workPattern.deviceUsage,
        mouseType: data.workPattern.mouseType,
        painDuration: data.painDuration,
        vasNeck: vasFor(['neck']),
        vasUpperBack: vasFor(['upper back', 'upper_back']),
        vasLowerBack: vasFor(['lower back', 'lower_back']),
        vasShoulder: vasFor(['shoulder']),
        vasWrist: vasFor(['wrist']),
        vasElbow: vasFor(['elbow']),
        vasKnee: vasFor(['knee']),
        vasFeet: vasFor(['feet', 'foot', 'ankle']),
        vasHip: vasFor(['hip']),
        symTingling: symptoms.any((s) => s.toLowerCase().contains('tingling')),
        symFatigue: symptoms.any((s) => s.toLowerCase().contains('fatigue')),
        symEndOfDay: symptoms.any((s) => s.toLowerCase().contains('end')),
        symStiffness: symptoms.any((s) => s.toLowerCase().contains('stiff')),
        symMorningPain: symptoms.any(
          (s) => s.toLowerCase().contains('morning'),
        ),
      ),
    );
  }

  static EquipmentOutput run(EquipmentEngineInput input) {
    // Build VAS and ROSA lookup maps for convenience
    final vasMap = _buildVasMap(input);
    final rosaMap = _buildRosaMap(input);

    // §2.12 — resolve effective painDuration before step 9
    // symEndOfDay + no painDuration → treat as oneToSixWeeks
    final effectivePainDuration =
        (input.symEndOfDay && input.painDuration == null)
        ? 'oneToSixWeeks'
        : input.painDuration;

    // ── Step 1 — Which items to include (§2.4) ────────────────────────────
    final cards = <_WorkingCard>[];

    for (final item in _equipmentLibrary) {
      final int? subScore = rosaMap[item.rosaSourceKey];

      // exclude if no score provided or score is 0
      if (subScore == null || subScore == 0) continue;

      // find highest VAS among linked regions
      double highestVas = 0;
      String? linkedRegion;
      for (final region in item.vasRegions) {
        final v = vasMap[region] ?? 0;
        if (v > highestVas) {
          highestVas = v;
          linkedRegion = region;
        }
      }

      // ── Step 2 — Base urgency (§2.5) ──────────────────────────────────
      final int urgencyLevel;
      if (subScore >= 2 && highestVas >= 4) {
        urgencyLevel = 3; // Urgent
      } else if (subScore >= 2) {
        urgencyLevel = 2; // Recommended
      } else {
        urgencyLevel = 1; // Preventive (subScore == 1)
      }

      cards.add(
        _WorkingCard(
          equipmentId: item.id,
          title: item.title,
          description: item.description,
          sourceLine: item.sourceLine,
          category: item.category,
          rosaSourceKey: item.rosaSourceKey,
          rosaSubScore: subScore,
          linkedVasRegion: highestVas > 0
              ? linkedRegion
              : item.vasRegions.firstOrNull,
          linkedVasScore: highestVas > 0 ? highestVas : null,
          urgencyLevel: urgencyLevel,
        ),
      );
    }

    // ── Step 3 — Exposure multiplier (§2.6) ──────────────────────────────
    for (final card in cards) {
      if ((input.hoursAtDesk == 'h6_8' || input.hoursAtDesk == 'h8plus') &&
          card.urgencyLevel == 2) {
        card.urgencyLevel = 3;
      }
      if (input.hoursAtDesk == 'h0_4' && card.urgencyLevel == 3) {
        card.urgencyLevel = 2; // cap — very low exposure
      }
    }

    // ── Step 4 — Symptom overrides (§2.7) ────────────────────────────────

    // Tingling + wrist VAS ≥ 4
    if (input.symTingling && (input.vasWrist ?? 0) >= 4) {
      _find(cards, 'equip_04')?.let((c) {
        c.urgencyLevel = 3;
        c.appendNote(l10n.rptEquipNoteTingling);
      });
      _find(cards, 'equip_06')?.urgencyLevel = 3;
    }

    // Stiffness + neck VAS ≥ 4
    if (input.symStiffness && (input.vasNeck ?? 0) >= 4) {
      _find(cards, 'equip_01')?.urgencyLevel = 3;
    }

    // Fatigue + high desk exposure → append to all currently Urgent cards
    if (input.symFatigue &&
        (input.hoursAtDesk == 'h6_8' || input.hoursAtDesk == 'h8plus')) {
      for (final card in cards) {
        if (card.urgencyLevel == 3) {
          card.appendNote(l10n.rptEquipNoteFatigue);
        }
      }
    }

    // Morning pain → dashboard flag only, no card change
    final morningPainFlag = input.symMorningPain;

    // ── Step 5 — Device setup modifiers (§2.8) ───────────────────────────
    if (input.deviceSetup == 'laptop') {
      if (input.rosaScore.monitorScore < 3) {
        _find(cards, 'equip_01')?.suppressed = true;
      } else {
        _find(cards, 'equip_01')?.cardNote = l10n.rptEquipNoteLaptopStand;
      }
    } else if (input.deviceSetup == 'dualScreen') {
      _find(cards, 'equip_01')?.let((c) {
        c.cardNote = l10n.rptEquipNoteDualScreen;
        if ((input.vasNeck ?? 0) >= 4) {
          c.appendNote(l10n.rptEquipNoteNeckRotation);
        }
      });
    }
    // singleScreen → no modifier

    // ── Step 6 — Mouse type modifiers (§2.9) ─────────────────────────────
    if (input.mouseType == 'trackpadOrNone') {
      _find(cards, 'equip_06')?.suppressed = true;
      if (input.rosaScore.mouseScore >= 2) {
        _find(cards, 'equip_04')?.appendNote(l10n.rptEquipNoteExternalMouse);
      }
    } else if (input.mouseType == 'smallNotebook' &&
        input.rosaScore.mouseScore >= 2) {
      _find(cards, 'equip_06')?.urgencyLevel = 3;
    }
    // standard mouse → no modifier

    // ── Step 7 — Work zone modifiers (§2.10) ─────────────────────────────
    if (input.workZoneType == 'standingDesk') {
      _find(cards, 'equip_02')?.suppressed = true;
      _find(cards, 'equip_03')?.suppressed = true;
      if (input.hoursAtDesk == 'h4_6' ||
          input.hoursAtDesk == 'h6_8' ||
          input.hoursAtDesk == 'h8plus') {
        cards.add(
          _WorkingCard(
            equipmentId: 'equip_S1',
            title: l10n.rptEquipAntiFatigueMatTitle,
            description: l10n.rptEquipAntiFatigueMatDescription,
            sourceLine: l10n.rptEquipSourceIsoStanding,
            category: 'other',
            rosaSourceKey: '',
            rosaSubScore: 0,
            linkedVasRegion: null,
            linkedVasScore: null,
            urgencyLevel: 2,
          ),
        );
      }
    } else if (input.workZoneType == 'hybrid') {
      // Run full seated rules (already applied above).
      // Override all card notes with the hybrid context message.
      for (final card in cards) {
        if (!card.suppressed) {
          card.cardNote = l10n.rptEquipNoteHybrid;
        }
      }
    }
    // desk | other → no modifier

    // ── Step 8 — Break habit modifiers (§2.11) ───────────────────────────
    if (input.breakHabit == 'rarely') {
      for (final card in cards) {
        if (!card.suppressed) {
          card.appendNote(l10n.rptEquipNoteBreaksRarely);
        }
      }
    } else if (input.breakHabit == 'every3h') {
      for (final card in cards) {
        if (!card.suppressed && card.urgencyLevel == 3) {
          card.appendNote(l10n.rptEquipNoteBreaksEvery3h);
        }
      }
    }

    // ── Step 9 — Chronicity flag (§2.12) ─────────────────────────────────
    if (effectivePainDuration == 'gtSixWeeks' ||
        effectivePainDuration == 'onOffMonths') {
      for (final card in cards) {
        if (!card.suppressed && card.urgencyLevel >= 2) {
          card.chronicityFlag = true;
        }
      }
    }

    // ── Step 10 — Risk badge text is computed inside _WorkingCard.toCard()

    // ── Step 11 — Sort (§2.14) ────────────────────────────────────────────
    // 1. urgencyLevel descending  2. rosaSubScore descending  3. equipmentId ascending
    final activeCards = cards.where((c) => !c.suppressed).toList()
      ..sort((a, b) {
        final byUrgency = b.urgencyLevel.compareTo(a.urgencyLevel);
        if (byUrgency != 0) return byUrgency;
        final byRosa = b.rosaSubScore.compareTo(a.rosaSubScore);
        if (byRosa != 0) return byRosa;
        return a.equipmentId.compareTo(b.equipmentId);
      });

    // ── Step 12 — Return output (§2.15) ──────────────────────────────────
    final finalScore = input.rosaScore.finalScore;
    final tier = finalScore >= 7
        ? 'RED'
        : finalScore >= 4
        ? 'ORANGE'
        : 'GREEN';

    return EquipmentOutput(
      tier: tier,
      tierMessage: _tierMessageMap[tier] ?? '',
      equipmentCards: activeCards.map((c) => c.toCard()).toList(),
      morningPainFlag: morningPainFlag,
    );
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  static _WorkingCard? _find(List<_WorkingCard> cards, String id) {
    for (final card in cards) {
      if (card.equipmentId == id) return card;
    }
    return null;
  }

  static Map<String, double> _buildVasMap(EquipmentEngineInput i) => {
    'neck': i.vasNeck ?? 0,
    'upperBack': i.vasUpperBack ?? 0,
    'lowerBack': i.vasLowerBack ?? 0,
    'shoulder': i.vasShoulder ?? 0,
    'wrist': i.vasWrist ?? 0,
    'elbow': i.vasElbow ?? 0,
    'knee': i.vasKnee ?? 0,
    'feet': i.vasFeet ?? 0,
    'hip': i.vasHip ?? 0,
  };

  static Map<String, int?> _buildRosaMap(EquipmentEngineInput i) => {
    'rosaMonitor': i.rosaScore.monitorScore,
    'rosaChair': i.rosaScore.chairScore,
    'rosaKeyboard': i.rosaScore.keyboardScore,
    'rosaMouse': i.rosaScore.mouseScore,
    'rosaChairArmrest': i.rosaScore.armrestScore,
  };
}

// ── Convenience extension ─────────────────────────────────────────────────────

extension _LetExt<T> on T {
  R let<R>(R Function(T) block) => block(this);
}
