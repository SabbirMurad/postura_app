import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../domain/gate_state.dart';

/// Visual checklist of the 5 visible autocapture conditions.
///
/// Shows green dot + checkmark when passed, amber blinking when checking,
/// grey dash when pending. Conditions 6 (final YOLO) and 7 (stability)
/// are hidden from the user.
class GateChecklist extends StatelessWidget {
  const GateChecklist({super.key, required this.gates});

  final Map<CaptureGate, GateStatus> gates;

  /// Only show the 5 user-visible gates.
  static const _visibleGates = [
    CaptureGate.framing,
    CaptureGate.sideProfile,
    CaptureGate.roll,
    CaptureGate.pitch,
    CaptureGate.lighting,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: context.colors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _visibleGates.map((gate) {
          final status = gates[gate] ?? GateStatus.pending;
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: _GateRow(gate: gate, status: status),
          );
        }).toList(),
      ),
    );
  }
}

class _GateRow extends StatelessWidget {
  const _GateRow({required this.gate, required this.status});

  final CaptureGate gate;
  final GateStatus status;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(status);
    final statusIcon = _statusIcon(status);

    return Row(
      children: [
        _GateDot(color: color, pulse: status == GateStatus.checking),
        SizedBox(width: 10.w),
        Expanded(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color: color,
              fontSize: 12.sp,
              fontWeight: status == GateStatus.passed
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
            child: Text(gate.label),
          ),
        ),
        SizedBox(width: 8.w),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            statusIcon,
            key: ValueKey('${gate.name}_$status'),
            style: TextStyle(
              color: color,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Color _colorFor(GateStatus status) {
    switch (status) {
      case GateStatus.passed:
        return AppColors.successGreen;
      case GateStatus.checking:
        return AppColors.amber;
      case GateStatus.failed:
        return AppColors.error;
      case GateStatus.pending:
        return const Color(0xFF5A5A5A);
    }
  }

  String _statusIcon(GateStatus status) {
    switch (status) {
      case GateStatus.passed:
        return '\u2713'; // ✓
      case GateStatus.checking:
        return '...';
      case GateStatus.failed:
        return '\u2717'; // ✗
      case GateStatus.pending:
        return '\u2014'; // —
    }
  }
}

/// Animated dot that pulses when checking.
class _GateDot extends StatefulWidget {
  const _GateDot({required this.color, required this.pulse});
  final Color color;
  final bool pulse;

  @override
  State<_GateDot> createState() => _GateDotState();
}

class _GateDotState extends State<_GateDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.pulse) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_GateDot old) {
    super.didUpdateWidget(old);
    if (widget.pulse && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.pulse && _ctrl.isAnimating) {
      _ctrl.stop();
      _ctrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(
              alpha: widget.pulse ? (0.25 + _ctrl.value * 0.75) : 1.0,
            ),
          ),
        );
      },
    );
  }
}
