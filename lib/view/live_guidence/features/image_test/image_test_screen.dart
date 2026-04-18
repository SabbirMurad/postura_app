import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/widgets/spine_orbit_loader.dart';
import '../../ml/label_constants.dart';
import '../../ml/model_handler.dart';

/// All 80 COCO class names supported by YOLOv8n.
const _cocoNames = <int, String>{
  0: 'person',
  1: 'bicycle',
  2: 'car',
  3: 'motorcycle',
  4: 'airplane',
  5: 'bus',
  6: 'train',
  7: 'truck',
  8: 'boat',
  9: 'traffic light',
  10: 'fire hydrant',
  11: 'stop sign',
  12: 'parking meter',
  13: 'bench',
  14: 'bird',
  15: 'cat',
  16: 'dog',
  17: 'horse',
  18: 'sheep',
  19: 'cow',
  20: 'elephant',
  21: 'bear',
  22: 'zebra',
  23: 'giraffe',
  24: 'backpack',
  25: 'umbrella',
  26: 'handbag',
  27: 'tie',
  28: 'suitcase',
  29: 'frisbee',
  30: 'skis',
  31: 'snowboard',
  32: 'sports ball',
  33: 'kite',
  34: 'baseball bat',
  35: 'baseball glove',
  36: 'skateboard',
  37: 'surfboard',
  38: 'tennis racket',
  39: 'bottle',
  40: 'wine glass',
  41: 'cup',
  42: 'fork',
  43: 'knife',
  44: 'spoon',
  45: 'bowl',
  46: 'banana',
  47: 'apple',
  48: 'sandwich',
  49: 'orange',
  50: 'broccoli',
  51: 'carrot',
  52: 'hot dog',
  53: 'pizza',
  54: 'donut',
  55: 'cake',
  56: 'chair',
  57: 'couch',
  58: 'potted plant',
  59: 'bed',
  60: 'dining table',
  61: 'toilet',
  62: 'tv',
  63: 'laptop',
  64: 'mouse',
  65: 'remote',
  66: 'keyboard',
  67: 'cell phone',
  68: 'microwave',
  69: 'oven',
  70: 'toaster',
  71: 'sink',
  72: 'refrigerator',
  73: 'book',
  74: 'clock',
  75: 'vase',
  76: 'scissors',
  77: 'teddy bear',
  78: 'hair drier',
  79: 'toothbrush',
};

/// Distinct colors for bounding boxes per class — cycles through these.
const _boxColors = [
  AppColors.lightTeal, // person
  AppColors.amber, // monitor/tv/laptop
  Color(0xFF42A5F5), // blue
  Color(0xFFEF5350), // red
  Color(0xFFAB47BC), // purple
  Color(0xFF66BB6A), // green
  Color(0xFFFFCA28), // yellow
  Color(0xFF26C6DA), // cyan
  Color(0xFFFF7043), // deep orange
  Color(0xFF8D6E63), // brown
];

class ImageTestScreen extends StatefulWidget {
  const ImageTestScreen({super.key});

  @override
  State<ImageTestScreen> createState() => _ImageTestScreenState();
}

class _ImageTestScreenState extends State<ImageTestScreen> {
  final ModelHandler _model = ModelHandler();
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  List<Detection>? _detections;
  bool _loading = false;
  bool _modelReady = false;
  String? _error;
  Size? _imageSize;
  String _loadingText = '';

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      await _model.loadModel(logShapes: true);
      setState(() => _modelReady = true);
    } catch (e) {
      setState(() => _error = 'Model load failed: $e');
    }
  }

  Future<void> _pickAndDetect(ImageSource source) async {
    // Show loading immediately BEFORE picker opens.
    setState(() {
      _loading = true;
      _loadingText =
          'Opening ${source == ImageSource.gallery ? 'gallery' : 'camera'}...';
      _error = null;
    });

    // Let UI render the loader before picker blocks the thread.
    await Future.delayed(const Duration(milliseconds: 50));

    final picked = await _picker.pickImage(source: source, maxWidth: 1280);
    if (picked == null) {
      setState(() => _loading = false);
      return;
    }

    setState(() {
      _imageFile = File(picked.path);
      _detections = null;
      _loadingText = 'Processing image...';
    });

    // Let the UI render the image before starting heavy work.
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      setState(() => _loadingText = 'Decoding image...');
      await Future.delayed(const Duration(milliseconds: 50));
      final bytes = await _imageFile!.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        setState(() {
          _error = 'Could not decode image';
          _loading = false;
        });
        return;
      }

      setState(() => _loadingText = 'Resizing to 320×320...');
      await Future.delayed(const Duration(milliseconds: 50));
      _imageSize = Size(decoded.width.toDouble(), decoded.height.toDouble());
      final resized = img.copyResize(
        decoded,
        width: 320,
        height: 320,
        interpolation: img.Interpolation.average,
      );
      final rgbBuffer = Uint8List(320 * 320 * 3);
      int idx = 0;
      for (int y = 0; y < 320; y++) {
        for (int x = 0; x < 320; x++) {
          final pixel = resized.getPixel(x, y);
          rgbBuffer[idx++] = pixel.r.toInt();
          rgbBuffer[idx++] = pixel.g.toInt();
          rgbBuffer[idx++] = pixel.b.toInt();
        }
      }

      setState(() => _loadingText = 'Running YOLOv8n detection...');
      await Future.delayed(const Duration(milliseconds: 50));
      final detections = _model.runInference(rgbBuffer);
      setState(() {
        _detections = detections;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Inference error: $e';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        title: Text(
          'Detection Test',
          style: TextStyle(color: colors.textPrimary, fontSize: 18.sp),
        ),
        iconTheme: IconThemeData(color: colors.iconDefault),
      ),
      body: Column(
        children: [
          // Image preview area.
          Expanded(
            child: _imageFile != null
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate the actual image rect within the container
                      // (same logic as BoxFit.contain).
                      Rect imageRect = Rect.zero;
                      if (_imageSize != null) {
                        final cW = constraints.maxWidth;
                        final cH = constraints.maxHeight;
                        final scale = (cW / _imageSize!.width).clamp(
                          0.0,
                          cH / _imageSize!.height,
                        );
                        final displayW = _imageSize!.width * scale;
                        final displayH = _imageSize!.height * scale;
                        imageRect = Rect.fromLTWH(
                          (cW - displayW) / 2,
                          (cH - displayH) / 2,
                          displayW,
                          displayH,
                        );
                      }
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(_imageFile!, fit: BoxFit.contain),
                          if (_detections != null)
                            CustomPaint(
                              size: Size(
                                constraints.maxWidth,
                                constraints.maxHeight,
                              ),
                              painter: _DetectionPainter(
                                detections: _detections!,
                                imageRect: imageRect,
                              ),
                            ),
                          if (_loading)
                            Center(
                              child: SpineOrbitLoader(label: _loadingText),
                            ),
                        ],
                      );
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.image_search_rounded,
                          size: 64.sp,
                          color: colors.textMuted,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Pick an image to test detection',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // Detection results.
          if (_detections != null) _buildResults(),

          if (_error != null)
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Text(
                _error!,
                style: TextStyle(color: AppColors.error, fontSize: 12.sp),
              ),
            ),

          // Action buttons.
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionBtn(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      enabled: _modelReady && !_loading,
                      onTap: () => _pickAndDetect(ImageSource.gallery),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _ActionBtn(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      enabled: _modelReady && !_loading,
                      onTap: () => _pickAndDetect(ImageSource.camera),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final all = _detections!;
    final hasPerson = all.any((d) => d.classId == cocoPersonClassId);
    final hasMonitor = all.any((d) => monitorClassIds.contains(d.classId));

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status row.
          Row(
            children: [
              _StatusChip(label: 'Person', detected: hasPerson),
              SizedBox(width: 8.w),
              _StatusChip(label: 'Monitor', detected: hasMonitor),
              const Spacer(),
              Text(
                '${all.length} detections',
                style: TextStyle(
                  color: context.colors.textTertiary,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
          if (all.isNotEmpty) ...[
            SizedBox(height: 8.h),
            ...all.map((d) {
              final name = _cocoNames[d.classId] ?? 'class_${d.classId}';
              final conf = (d.confidence * 100).toInt();
              return Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Text(
                  '$name — $conf%',
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 12.sp,
                    fontFamily: 'DMMono',
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.detected});
  final String label;
  final bool detected;

  @override
  Widget build(BuildContext context) {
    final color = detected ? AppColors.successGreen : AppColors.error;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            detected ? Icons.check_circle : Icons.cancel,
            size: 14.sp,
            color: color,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primaryGreen
              : AppColors.primaryGreen.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Draws bounding boxes on top of the displayed image.
class _DetectionPainter extends CustomPainter {
  _DetectionPainter({required this.detections, required this.imageRect});
  final List<Detection> detections;
  final Rect imageRect;

  Color _colorForClass(int classId) {
    if (classId == cocoPersonClassId) return AppColors.lightTeal;
    if (monitorClassIds.contains(classId)) return AppColors.amber;
    return _boxColors[classId % _boxColors.length];
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (imageRect.isEmpty) return;

    for (final d in detections) {
      final color = _colorForClass(d.classId);

      // Map normalized [0-1] coordinates to the actual image display area.
      final rect = Rect.fromLTRB(
        imageRect.left + d.boundingBox.left * imageRect.width,
        imageRect.top + d.boundingBox.top * imageRect.height,
        imageRect.left + d.boundingBox.right * imageRect.width,
        imageRect.top + d.boundingBox.bottom * imageRect.height,
      );

      // Box.
      final boxPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        boxPaint,
      );

      // Label background + text.
      final name = _cocoNames[d.classId] ?? 'class_${d.classId}';
      final conf = (d.confidence * 100).toInt();
      final label = '$name $conf%';

      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final labelW = textPainter.width + 8;
      final labelH = textPainter.height + 4;
      final labelY = (rect.top - labelH).clamp(0.0, size.height - labelH);

      // Background pill.
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(rect.left, labelY, labelW, labelH),
          const Radius.circular(3),
        ),
        Paint()..color = color.withValues(alpha: 0.85),
      );

      textPainter.paint(canvas, Offset(rect.left + 4, labelY + 2));
    }
  }

  @override
  bool shouldRepaint(covariant _DetectionPainter old) =>
      detections != old.detections;
}
