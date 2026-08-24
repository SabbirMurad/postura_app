enum SeatDepthFit { ok, tooLong, tooShort }

enum PhoneUsage { none, headsetOrOneHand, reachFar }

enum DeskDuration { short, medium, long }

/// Top of the monitor relative to eye level — directional signal for
/// B_MON_LOW / B_MON_HIGH (Action Report v1.3 / Equipment Engine v1.3).
/// `monitorNonAdjustable` stays a separate ROSA modifier and does not carry
/// direction.
enum MonitorHeightDirection { below, atEyeLevel, above }

/// Manual answers to the ROSA checklist items the camera can't see.
/// Field names mirror the official ROSA form's +1/+2 modifiers.
///
/// [toMap] is a contract: the native `RosaScorer.WorkstationModifiers.fromMap()`
/// on both Android and iOS parses these exact snake_case keys. Do not rename
/// them without changing both native sides.
class WorkstationAnswers {
  // Section A — Chair
  final bool chairHeightNonAdjustable;
  final bool insufficientUnderDeskSpace;
  final SeatDepthFit seatDepthFit;
  final bool seatPanNonAdjustable;
  final bool armrestNonAdjustable;
  final bool armrestHardDamaged;
  final bool armrestTooWide;
  final bool backrestNonAdjustable;
  final bool workSurfaceTooHigh;

  // A_LUMBAR / A_FEET / A_NO_BACK source fields (Action Report v1.3). These
  // are separate from the ROSA-affecting adjustability booleans above and
  // only feed FINDING_ID derivation — they never change the ROSA score.
  final bool lumbarSupport;
  final bool feetSupported;
  final bool usableBackrest;

  // Section B — Monitor & Telephone
  final bool monitorNonAdjustable;
  final bool neckTwistOver30;
  final bool monitorTooFar;
  final bool screenGlare;
  final bool noDocumentHolder;
  final PhoneUsage phoneUsage;
  final bool phoneCradleNeckShoulder;
  final bool noHandsFreeOption;

  // B_MON_LOW / B_MON_HIGH direction (Action Report v1.3). Separate from
  // monitorNonAdjustable, which stays a ROSA-only modifier.
  final MonitorHeightDirection monitorHeightDirection;

  // Section C — Mouse & Keyboard
  final bool mouseKeyboardDifferentSurfaces;
  final bool mousePinchGrip;
  final bool mousePalmrest;
  final bool mouseNonAdjustable;
  final bool mouseTooFar;
  final bool keyboardDeviation;
  final bool keyboardTooHigh;
  final bool reachingOverhead;
  final bool keyboardPlatformNonAdjustable;

  // Daily duration — applies to chair, monitor/phone, and mouse/keyboard sections
  final DeskDuration deskDuration;

  const WorkstationAnswers({
    this.chairHeightNonAdjustable = false,
    this.insufficientUnderDeskSpace = false,
    this.seatDepthFit = SeatDepthFit.ok,
    this.seatPanNonAdjustable = false,
    this.armrestNonAdjustable = false,
    this.armrestHardDamaged = false,
    this.armrestTooWide = false,
    this.backrestNonAdjustable = false,
    this.workSurfaceTooHigh = false,
    this.lumbarSupport = true,
    this.feetSupported = true,
    this.usableBackrest = true,
    this.monitorNonAdjustable = false,
    this.neckTwistOver30 = false,
    this.monitorTooFar = false,
    this.screenGlare = false,
    this.noDocumentHolder = false,
    this.phoneUsage = PhoneUsage.none,
    this.phoneCradleNeckShoulder = false,
    this.noHandsFreeOption = false,
    this.monitorHeightDirection = MonitorHeightDirection.atEyeLevel,
    this.mouseKeyboardDifferentSurfaces = false,
    this.mousePinchGrip = false,
    this.mousePalmrest = false,
    this.mouseNonAdjustable = false,
    this.mouseTooFar = false,
    this.keyboardDeviation = false,
    this.keyboardTooHigh = false,
    this.reachingOverhead = false,
    this.keyboardPlatformNonAdjustable = false,
    this.deskDuration = DeskDuration.medium,
  });

  WorkstationAnswers copyWith({
    bool? chairHeightNonAdjustable,
    bool? insufficientUnderDeskSpace,
    SeatDepthFit? seatDepthFit,
    bool? seatPanNonAdjustable,
    bool? armrestNonAdjustable,
    bool? armrestHardDamaged,
    bool? armrestTooWide,
    bool? backrestNonAdjustable,
    bool? workSurfaceTooHigh,
    bool? lumbarSupport,
    bool? feetSupported,
    bool? usableBackrest,
    bool? monitorNonAdjustable,
    bool? neckTwistOver30,
    bool? monitorTooFar,
    bool? screenGlare,
    bool? noDocumentHolder,
    PhoneUsage? phoneUsage,
    bool? phoneCradleNeckShoulder,
    bool? noHandsFreeOption,
    MonitorHeightDirection? monitorHeightDirection,
    bool? mouseKeyboardDifferentSurfaces,
    bool? mousePinchGrip,
    bool? mousePalmrest,
    bool? mouseNonAdjustable,
    bool? mouseTooFar,
    bool? keyboardDeviation,
    bool? keyboardTooHigh,
    bool? reachingOverhead,
    bool? keyboardPlatformNonAdjustable,
    DeskDuration? deskDuration,
  }) {
    return WorkstationAnswers(
      chairHeightNonAdjustable:
          chairHeightNonAdjustable ?? this.chairHeightNonAdjustable,
      insufficientUnderDeskSpace:
          insufficientUnderDeskSpace ?? this.insufficientUnderDeskSpace,
      seatDepthFit: seatDepthFit ?? this.seatDepthFit,
      seatPanNonAdjustable: seatPanNonAdjustable ?? this.seatPanNonAdjustable,
      armrestNonAdjustable: armrestNonAdjustable ?? this.armrestNonAdjustable,
      armrestHardDamaged: armrestHardDamaged ?? this.armrestHardDamaged,
      armrestTooWide: armrestTooWide ?? this.armrestTooWide,
      backrestNonAdjustable:
          backrestNonAdjustable ?? this.backrestNonAdjustable,
      workSurfaceTooHigh: workSurfaceTooHigh ?? this.workSurfaceTooHigh,
      lumbarSupport: lumbarSupport ?? this.lumbarSupport,
      feetSupported: feetSupported ?? this.feetSupported,
      usableBackrest: usableBackrest ?? this.usableBackrest,
      monitorNonAdjustable: monitorNonAdjustable ?? this.monitorNonAdjustable,
      neckTwistOver30: neckTwistOver30 ?? this.neckTwistOver30,
      monitorTooFar: monitorTooFar ?? this.monitorTooFar,
      screenGlare: screenGlare ?? this.screenGlare,
      noDocumentHolder: noDocumentHolder ?? this.noDocumentHolder,
      phoneUsage: phoneUsage ?? this.phoneUsage,
      phoneCradleNeckShoulder:
          phoneCradleNeckShoulder ?? this.phoneCradleNeckShoulder,
      noHandsFreeOption: noHandsFreeOption ?? this.noHandsFreeOption,
      monitorHeightDirection:
          monitorHeightDirection ?? this.monitorHeightDirection,
      mouseKeyboardDifferentSurfaces:
          mouseKeyboardDifferentSurfaces ?? this.mouseKeyboardDifferentSurfaces,
      mousePinchGrip: mousePinchGrip ?? this.mousePinchGrip,
      mousePalmrest: mousePalmrest ?? this.mousePalmrest,
      mouseNonAdjustable: mouseNonAdjustable ?? this.mouseNonAdjustable,
      mouseTooFar: mouseTooFar ?? this.mouseTooFar,
      keyboardDeviation: keyboardDeviation ?? this.keyboardDeviation,
      keyboardTooHigh: keyboardTooHigh ?? this.keyboardTooHigh,
      reachingOverhead: reachingOverhead ?? this.reachingOverhead,
      keyboardPlatformNonAdjustable:
          keyboardPlatformNonAdjustable ?? this.keyboardPlatformNonAdjustable,
      deskDuration: deskDuration ?? this.deskDuration,
    );
  }

  Map<String, dynamic> toMap() => {
    'chair_height_non_adjustable': chairHeightNonAdjustable,
    'insufficient_under_desk_space': insufficientUnderDeskSpace,
    'seat_depth_score': seatDepthFit == SeatDepthFit.ok ? 1 : 2,
    // Direction the lossy seat_depth_score above can't carry — FINDING_ID
    // derivation only (A_SEAT_LONG / A_SEAT_SHORT), never fed into ROSA.
    'seat_depth_direction': switch (seatDepthFit) {
      SeatDepthFit.ok => 'ok',
      SeatDepthFit.tooLong => 'too_long',
      SeatDepthFit.tooShort => 'too_short',
    },
    'seat_pan_non_adjustable': seatPanNonAdjustable,
    'armrest_non_adjustable': armrestNonAdjustable,
    'armrest_hard_damaged': armrestHardDamaged,
    'armrest_too_wide': armrestTooWide,
    'backrest_non_adjustable': backrestNonAdjustable,
    'work_surface_too_high': workSurfaceTooHigh,
    'lumbar_support': lumbarSupport,
    'feet_supported': feetSupported,
    'usable_backrest': usableBackrest,
    'monitor_non_adjustable': monitorNonAdjustable,
    'neck_twist_over_30': neckTwistOver30,
    'monitor_too_far': monitorTooFar,
    'screen_glare': screenGlare,
    'no_document_holder': noDocumentHolder,
    'monitor_height_direction': switch (monitorHeightDirection) {
      MonitorHeightDirection.below => 'below',
      MonitorHeightDirection.atEyeLevel => 'at',
      MonitorHeightDirection.above => 'above',
    },
    'phone_score': switch (phoneUsage) {
      PhoneUsage.none => 0,
      PhoneUsage.headsetOrOneHand => 1,
      PhoneUsage.reachFar => 2,
    },
    'phone_cradle_neck_shoulder': phoneCradleNeckShoulder,
    'no_hands_free_option': noHandsFreeOption,
    'mouse_keyboard_different_surfaces': mouseKeyboardDifferentSurfaces,
    'mouse_pinch_grip': mousePinchGrip,
    'mouse_palmrest': mousePalmrest,
    'mouse_non_adjustable': mouseNonAdjustable,
    'mouse_too_far': mouseTooFar,
    'keyboard_deviation': keyboardDeviation,
    'keyboard_too_high': keyboardTooHigh,
    'reaching_overhead': reachingOverhead,
    'keyboard_platform_non_adjustable': keyboardPlatformNonAdjustable,
    'duration_modifier': switch (deskDuration) {
      DeskDuration.short => -1,
      DeskDuration.medium => 0,
      DeskDuration.long => 1,
    },
  };
}
