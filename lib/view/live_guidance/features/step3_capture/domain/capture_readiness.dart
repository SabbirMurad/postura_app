import 'gate_state.dart';

/// Aggregated state of all 7 autocapture conditions.
class CaptureReadiness {
  const CaptureReadiness({
    required this.gates,
    required this.activeGate,
    required this.allPassed,
  });

  /// Status of each gate.
  final Map<CaptureGate, GateStatus> gates;

  /// Which gate is currently being checked (null if all passed).
  final CaptureGate? activeGate;

  /// Whether all 7 conditions are green.
  final bool allPassed;

  /// Initial state — all pending, first gate active.
  factory CaptureReadiness.initial() {
    return CaptureReadiness(
      gates: {for (final gate in CaptureGate.values) gate: GateStatus.pending},
      activeGate: CaptureGate.framing,
      allPassed: false,
    );
  }

  CaptureReadiness copyWith({
    Map<CaptureGate, GateStatus>? gates,
    CaptureGate? activeGate,
    bool clearActiveGate = false,
    bool? allPassed,
  }) {
    return CaptureReadiness(
      gates: gates ?? this.gates,
      activeGate: clearActiveGate ? null : (activeGate ?? this.activeGate),
      allPassed: allPassed ?? this.allPassed,
    );
  }
}
