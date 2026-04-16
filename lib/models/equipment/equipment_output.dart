// ===================== EQUIPMENT OUTPUT MODELS =====================
// Output contract for the EquipmentEngine (§2.15)

class EquipmentOutput {
  final String tier;
  final String tierMessage;
  final List<EquipmentCard> equipmentCards;
  final bool morningPainFlag;

  const EquipmentOutput({
    required this.tier,
    required this.tierMessage,
    required this.equipmentCards,
    required this.morningPainFlag,
  });
}

class EquipmentCard {
  final String equipmentId;
  final String title;
  final String description;
  final String sourceLine;
  final String category;
  final String rosaSourceKey;
  final int rosaSubScore;
  final String? linkedVasRegion;
  final double? linkedVasScore;
  final String urgencyLabel;   // 'Urgent' | 'Recommended' | 'Preventive'
  final int urgencyLevel;      // 3 | 2 | 1
  final String riskBadgeText;  // e.g. 'Monitor risk: 3'
  final String? cardNote;      // null if no modifiers applied
  final bool chronicityFlag;

  const EquipmentCard({
    required this.equipmentId,
    required this.title,
    required this.description,
    required this.sourceLine,
    required this.category,
    required this.rosaSourceKey,
    required this.rosaSubScore,
    this.linkedVasRegion,
    this.linkedVasScore,
    required this.urgencyLabel,
    required this.urgencyLevel,
    required this.riskBadgeText,
    this.cardNote,
    required this.chronicityFlag,
  });
}
