import 'package:flutter/material.dart';

import '../../../../core/enums/detection_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/detection_result.dart';
import '../bloc/detection_bloc_state.dart';

class StatusIndicator extends StatelessWidget {
  const StatusIndicator({super.key, required this.state});
  final DetectionBlocState state;

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = _resolveState();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(label),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  (Color, String, IconData) _resolveState() => switch (state) {
    DetectionLoading() => (
      Colors.grey.shade600,
      'Loading model...',
      Icons.hourglass_top_rounded,
    ),
    DetectionRunning(
      detectionState: DetectionState.partial,
      lastResult: final r,
    ) =>
      _partialHint(r),
    DetectionRunning(lastResult: final r) => _searchingHint(r),
    DetectionConfirmed() => (
      AppColors.confirmGreen,
      'Position Confirmed!',
      Icons.check_circle_rounded,
    ),
    DetectionError(message: final msg) => (
      AppColors.error,
      'Error: $msg',
      Icons.error_outline_rounded,
    ),
    DetectionDisposed() => (
      Colors.grey.shade600,
      'Detection stopped',
      Icons.stop_circle_rounded,
    ),
  };

  (Color, String, IconData) _searchingHint(DetectionResult? r) {
    if (r == null || (!r.personDetected && !r.monitorDetected)) {
      return (
        Colors.grey.shade600,
        'Point camera at your desk setup...',
        Icons.search_rounded,
      );
    }
    return (
      Colors.grey.shade600,
      'Looking for you and your screen...',
      Icons.search_rounded,
    );
  }

  (Color, String, IconData) _partialHint(DetectionResult? r) {
    if (r == null) {
      return (AppColors.amber, 'Almost there...', Icons.person_search_rounded);
    }
    if (r.personDetected && !r.monitorDetected) {
      return (
        AppColors.amber,
        'Found you! Now looking for screen...',
        Icons.person_search_rounded,
      );
    }
    if (!r.personDetected && r.monitorDetected) {
      return (
        AppColors.amber,
        'Screen found! Make sure you are visible...',
        Icons.person_search_rounded,
      );
    }
    return (
      AppColors.amber,
      'Almost there! Hold steady...',
      Icons.person_search_rounded,
    );
  }
}
