/// Detection states driven by the ML layer.
///
/// The frontend never sets [confirmed] directly — only the ML layer
/// can trigger it after the rolling-window threshold is met.
enum DetectionState {
  /// No objects confirmed yet.
  searching,

  /// One object detected (person OR monitor), waiting for the other.
  partial,

  /// Both person AND monitor confirmed across the rolling window.
  confirmed,
}
