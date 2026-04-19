import 'dart:collection';

import '../../../core/constants/pose_constants.dart';
import 'pose_result.dart';

/// Tracks which side of the body is facing the camera with hysteresis.
///
/// Compares left vs right landmark likelihoods. Only switches active side
/// after the new side has won for [PoseConstants.sideSwitchWindow] consecutive
/// frames — prevents flicker on borderline angles.
class SideSelector {
  final Queue<BodyOrientation> _recentWinners = Queue();
  BodyOrientation _currentSide = BodyOrientation.unknown;

  /// Current active side.
  BodyOrientation get currentSide => _currentSide;

  /// Update with the latest frame's left and right likelihoods.
  /// [leftLikelihoods] and [rightLikelihoods] are lists of confidence scores
  /// for the left-side and right-side landmarks respectively.
  BodyOrientation update(
    List<double> leftLikelihoods,
    List<double> rightLikelihoods,
  ) {
    // Average likelihood per side.
    final leftAvg = leftLikelihoods.isEmpty
        ? 0.0
        : leftLikelihoods.reduce((a, b) => a + b) / leftLikelihoods.length;
    final rightAvg = rightLikelihoods.isEmpty
        ? 0.0
        : rightLikelihoods.reduce((a, b) => a + b) / rightLikelihoods.length;

    // Determine this frame's winner.
    final winner = (leftAvg > rightAvg)
        ? BodyOrientation.left
        : (rightAvg > leftAvg)
        ? BodyOrientation.right
        : _currentSide; // Tie — keep current.

    _recentWinners.addLast(winner);
    while (_recentWinners.length > PoseConstants.sideSwitchWindow) {
      _recentWinners.removeFirst();
    }

    // Only switch if the new side has won for the entire window.
    if (_recentWinners.length >= PoseConstants.sideSwitchWindow) {
      final allSame = _recentWinners.every((s) => s == winner);
      if (allSame && winner != BodyOrientation.unknown) {
        _currentSide = winner;
      }
    }

    // Initial: if still unknown and we have a clear winner, set it.
    if (_currentSide == BodyOrientation.unknown &&
        winner != BodyOrientation.unknown) {
      _currentSide = winner;
    }

    return _currentSide;
  }

  /// Reset side detection state.
  void reset() {
    _recentWinners.clear();
    _currentSide = BodyOrientation.unknown;
  }
}
