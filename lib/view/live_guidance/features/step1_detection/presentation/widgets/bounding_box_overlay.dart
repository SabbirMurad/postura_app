import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../ml/label_constants.dart';
import '../../domain/detection_result.dart';

class BoundingBoxOverlay extends StatelessWidget {
  const BoundingBoxOverlay({super.key, required this.detectedObjects});
  final List<DetectedObject> detectedObjects;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomPaint(
        painter: _BoundingBoxPainter(detectedObjects),
        size: Size.infinite,
      ),
    );
  }
}

class _BoundingBoxPainter extends CustomPainter {
  _BoundingBoxPainter(this.objects);
  final List<DetectedObject> objects;

  @override
  void paint(Canvas canvas, Size size) {
    for (final obj in objects) {
      final isMonitor = monitorClassIds.contains(obj.classId);
      final isPerson = obj.classId == cocoPersonClassId;
      if (!isPerson && !isMonitor) continue;

      // Person = green, Monitor = blue (using brand teal).
      final color = isPerson ? AppColors.lightTeal : const Color(0xFF42A5F5);

      final boxPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      final rect = Rect.fromLTRB(
        (obj.boundingBox.left * size.width).clamp(2, size.width - 2),
        (obj.boundingBox.top * size.height).clamp(2, size.height - 2),
        (obj.boundingBox.right * size.width).clamp(2, size.width - 2),
        (obj.boundingBox.bottom * size.height).clamp(2, size.height - 2),
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        boxPaint,
      );

      final label = isPerson ? 'Person' : 'Monitor';
      final labelText = '$label ${(obj.confidence * 100).toInt()}%';

      final tp = TextPainter(
        text: TextSpan(
          text: labelText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final bgRect = Rect.fromLTWH(
        rect.left,
        rect.top - tp.height - 6,
        tp.width + 12,
        tp.height + 6,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
        Paint()..color = color.withValues(alpha: 0.8),
      );
      tp.paint(canvas, Offset(bgRect.left + 6, bgRect.top + 3));
    }
  }

  @override
  bool shouldRepaint(_BoundingBoxPainter old) => true;
}
