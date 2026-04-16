import 'package:posture_detector_app/models/equipment/equipment_output.dart';

// ── Input contract (§2.1) ─────────────────────────────────────────────────────

class EquipmentEngineInput {
  // ROSA sub-scores (1–3; rosaChairArmrest nullable if not assessed)
  final int rosaChair;
  final int rosaMonitor;
  final int rosaKeyboard;
  final int rosaMouse;
  final int? rosaChairArmrest;

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

  // Tier derived from ROSA total score
  final String tier; // 'GREEN' | 'ORANGE' | 'RED' | 'YELLOW'

  // Intake screen inputs
  final String workZoneType; // 'desk' | 'standingDesk' | 'hybrid' | 'other'
  final String hoursAtDesk;  // 'h0_4' | 'h4_6' | 'h6_8' | 'h8plus'
  final String breakHabit;   // 'every1h' | 'every2h' | 'every3h' | 'rarely'
  final String deviceSetup;  // 'laptop' | 'singleScreen' | 'dualScreen'
  final String mouseType;    // 'standard' | 'smallNotebook' | 'trackpadOrNone'
  final String? painDuration; // 'ltOneWeek' | 'oneToSixWeeks' | 'gtSixWeeks' | 'onOffMonths'

  // Optional symptoms
  final bool symTingling;
  final bool symFatigue;
  final bool symEndOfDay;
  final bool symStiffness;
  final bool symMorningPain;

  const EquipmentEngineInput({
    required this.rosaChair,
    required this.rosaMonitor,
    required this.rosaKeyboard,
    required this.rosaMouse,
    this.rosaChairArmrest,
    this.vasNeck,
    this.vasUpperBack,
    this.vasLowerBack,
    this.vasShoulder,
    this.vasWrist,
    this.vasElbow,
    this.vasKnee,
    this.vasFeet,
    this.vasHip,
    required this.tier,
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

const List<_LibraryItem> _equipmentLibrary = [
  _LibraryItem(
    id: 'equip_01',
    title: 'Adjustable monitor riser',
    description:
        'Height-adjustable stand (8–12 cm) to position monitor at eye level.',
    sourceLine: 'ISO 9241-5:2024; ROSA monitor section.',
    category: 'monitor',
    rosaSourceKey: 'rosaMonitor',
    vasRegions: ['neck'],
  ),
  _LibraryItem(
    id: 'equip_02',
    title: 'Adjustable footrest',
    description:
        'Angled footrest with height adjustment (10–15 cm) for stable foot support.',
    sourceLine: 'ISO 9241-5:2024; ROSA chair section.',
    category: 'chair',
    rosaSourceKey: 'rosaChair',
    vasRegions: ['lowerBack', 'knee', 'feet'],
  ),
  _LibraryItem(
    id: 'equip_03',
    title: 'Lumbar support cushion',
    description:
        'Memory-foam lumbar roll to support the lower back in the chair.',
    sourceLine: 'ISO 9241-5:2024; ROSA chair section.',
    category: 'chair',
    rosaSourceKey: 'rosaChair',
    vasRegions: ['lowerBack', 'hip'],
  ),
  _LibraryItem(
    id: 'equip_04',
    title: 'Wrist rest',
    description:
        'Soft wrist rest to support neutral wrist posture while typing.',
    sourceLine: 'Rempel et al. 2006; ROSA keyboard section.',
    category: 'keyboard',
    rosaSourceKey: 'rosaKeyboard',
    vasRegions: ['wrist', 'elbow'],
  ),
  _LibraryItem(
    id: 'equip_05',
    title: 'Keyboard tray',
    description:
        'Under-desk keyboard tray to set keyboard height at elbow level.',
    sourceLine: 'ISO 9241-5:2024; ROSA keyboard section.',
    category: 'keyboard',
    rosaSourceKey: 'rosaKeyboard',
    vasRegions: ['wrist', 'elbow'],
  ),
  _LibraryItem(
    id: 'equip_06',
    title: 'Ergonomic mouse',
    description:
        'Alternative mouse design to reduce lateral wrist and shoulder loading.',
    sourceLine: 'Van Eerd et al. 2016; ROSA mouse section.',
    category: 'mouse',
    rosaSourceKey: 'rosaMouse',
    vasRegions: ['wrist', 'shoulder'],
  ),
  _LibraryItem(
    id: 'equip_07',
    title: 'Armrest pads/risers',
    description:
        'Adjustable armrest pads (+3 cm or more) to support forearms at elbow height.',
    sourceLine: 'Van Eerd et al. 2016; ROSA armrest section.',
    category: 'armrest',
    rosaSourceKey: 'rosaChairArmrest',
    vasRegions: ['shoulder', 'upperBack'],
  ),
];

// ── Lookup maps ───────────────────────────────────────────────────────────────

const Map<String, String> _riskLabelMap = {
  'rosaMonitor': 'Monitor risk',
  'rosaChair': 'Chair risk',
  'rosaKeyboard': 'Keyboard risk',
  'rosaMouse': 'Mouse risk',
  'rosaChairArmrest': 'Armrest risk',
};

const Map<String, String> _tierMessageMap = {
  'RED': 'Immediate ergonomic action required for this workstation.',
  'ORANGE':
      'Plan and implement these equipment changes to reduce ergonomic risk.',
  'GREEN': 'No urgent actions; maintain current setup and continue monitoring.',
  'YELLOW':
      'Symptoms reported; consider equipment changes and follow-up review.',
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
      urgencyLabel = 'Urgent';
    } else if (urgencyLevel == 2) {
      urgencyLabel = 'Recommended';
    } else {
      urgencyLabel = 'Preventive';
    }

    final riskLabel = _riskLabelMap[rosaSourceKey];
    final riskBadgeText =
        riskLabel != null ? '$riskLabel: $rosaSubScore' : '';

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
          linkedVasRegion:
              highestVas > 0 ? linkedRegion : item.vasRegions.firstOrNull,
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
        c.appendNote(
          'Tingling may indicate nerve compression — consult a healthcare provider if symptoms persist.',
        );
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
          card.appendNote(
            'Fatigue reported — high desk exposure amplifies strain risk.',
          );
        }
      }
    }

    // Morning pain → dashboard flag only, no card change
    final morningPainFlag = input.symMorningPain;

    // ── Step 5 — Device setup modifiers (§2.8) ───────────────────────────
    if (input.deviceSetup == 'laptop') {
      if (input.rosaMonitor < 3) {
        _find(cards, 'equip_01')?.suppressed = true;
      } else {
        _find(cards, 'equip_01')?.cardNote =
            'Use a laptop stand + external keyboard.';
      }
    } else if (input.deviceSetup == 'dualScreen') {
      _find(cards, 'equip_01')?.let((c) {
        c.cardNote =
            'Ensure primary screen is centred; secondary at same height.';
        if ((input.vasNeck ?? 0) >= 4) {
          c.appendNote(
            'Neck rotation risk detected — consider single primary screen.',
          );
        }
      });
    }
    // singleScreen → no modifier

    // ── Step 6 — Mouse type modifiers (§2.9) ─────────────────────────────
    if (input.mouseType == 'trackpadOrNone') {
      _find(cards, 'equip_06')?.suppressed = true;
      if (input.rosaMouse >= 2) {
        _find(cards, 'equip_04')?.appendNote(
          'Consider adding an external mouse to reduce wrist load.',
        );
      }
    } else if (input.mouseType == 'smallNotebook' && input.rosaMouse >= 2) {
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
            title: 'Anti-fatigue mat',
            description:
                'Cushioned mat to reduce leg and lower-back fatigue during prolonged standing.',
            sourceLine: 'ISO 9241-5:2024; standing workstation section.',
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
          card.cardNote = 'Recommendations apply to your seated setup.';
        }
      }
    }
    // desk | other → no modifier

    // ── Step 8 — Break habit modifiers (§2.11) ───────────────────────────
    if (input.breakHabit == 'rarely') {
      for (final card in cards) {
        if (!card.suppressed) {
          card.appendNote(
            'Take breaks every 30–60 min to allow posture variation.',
          );
        }
      }
    } else if (input.breakHabit == 'every3h') {
      for (final card in cards) {
        if (!card.suppressed && card.urgencyLevel == 3) {
          card.appendNote(
            'Increase break frequency to reduce sustained load.',
          );
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
    return EquipmentOutput(
      tier: input.tier,
      tierMessage: _tierMessageMap[input.tier] ?? '',
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
    'rosaMonitor': i.rosaMonitor,
    'rosaChair': i.rosaChair,
    'rosaKeyboard': i.rosaKeyboard,
    'rosaMouse': i.rosaMouse,
    'rosaChairArmrest': i.rosaChairArmrest,
  };
}

// ── Convenience extension ─────────────────────────────────────────────────────

extension _LetExt<T> on T {
  R let<R>(R Function(T) block) => block(this);
}
