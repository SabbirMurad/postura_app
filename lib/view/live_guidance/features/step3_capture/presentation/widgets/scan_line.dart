import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Sweeping scan line animation — teal horizontal line moving top to bottom.
///
/// 1.5px width, 2.8 seconds per cycle, opacity fade in/out, infinite loop.
class ScanLine extends StatefulWidget {
  const ScanLine({super.key});

  @override
  State<ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<ScanLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
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
      builder: (_, child) {
        // Fade in first 10%, full in middle, fade out last 10%.
        final t = _ctrl.value;
        double opacity;
        if (t < 0.1) {
          opacity = t / 0.1;
        } else if (t > 0.9) {
          opacity = (1.0 - t) / 0.1;
        } else {
          opacity = 1.0;
        }

        return Transform.translate(
          offset: Offset(0, t * MediaQuery.of(context).size.height),
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.lightTeal.withValues(alpha: 0.6 * opacity),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
