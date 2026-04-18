/// State of a single autocapture condition gate.
enum GateStatus {
  /// Not yet evaluated (waiting for earlier conditions).
  pending,

  /// Currently being checked — shown as amber/blinking.
  checking,

  /// Condition met — shown as green with checkmark.
  passed,

  /// Condition failed — shown as red (used for timeout).
  failed,
}

/// The 7 ordered autocapture conditions.
enum CaptureGate {
  framing,
  sideProfile,
  roll,
  pitch,
  lighting,
  finalYolo,
  stability,
}

/// Labels and guidance text for each gate.
extension CaptureGateInfo on CaptureGate {
  String get label {
    switch (this) {
      case CaptureGate.framing:
        return 'Worker + monitor visible';
      case CaptureGate.sideProfile:
        return 'Side profile';
      case CaptureGate.roll:
        return 'Phone level (roll)';
      case CaptureGate.pitch:
        return 'Phone straight (pitch)';
      case CaptureGate.lighting:
        return 'Lighting ok';
      case CaptureGate.finalYolo:
        return 'Final check';
      case CaptureGate.stability:
        return 'Hold steady';
    }
  }

  String get guidanceText {
    switch (this) {
      case CaptureGate.framing:
        return 'Make sure the worker and monitor are both fully visible';
      case CaptureGate.sideProfile:
        return 'Move until only one ear is visible';
      case CaptureGate.roll:
        return 'Keep phone level';
      case CaptureGate.pitch:
        return 'Hold phone straight up and down';
      case CaptureGate.lighting:
        return 'Adjust lighting for better visibility';
      case CaptureGate.finalYolo:
        return ''; // Silent — no text.
      case CaptureGate.stability:
        return 'Keep phone steady. Analysing...';
    }
  }
}
