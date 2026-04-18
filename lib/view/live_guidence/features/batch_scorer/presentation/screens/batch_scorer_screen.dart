import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/spine_orbit_loader.dart';
import '../../../step3_capture/domain/rosa_score.dart';
import '../../data/static_image_scorer.dart';

/// Internal QA tool — batch-score multiple gallery photos with ROSA.
class BatchScorerScreen extends StatefulWidget {
  const BatchScorerScreen({super.key});

  @override
  State<BatchScorerScreen> createState() => _BatchScorerScreenState();
}

enum _Phase { idle, photosSelected, scoring, done }

class _ScoredPhoto {
  _ScoredPhoto({required this.path, required this.filename, this.score});
  final String path;
  final String filename;
  RosaScore? score;
  bool get noPose => score == null;
}

class _BatchScorerScreenState extends State<BatchScorerScreen> {
  final _picker = ImagePicker();
  final _scorer = StaticImageScorer();

  _Phase _phase = _Phase.idle;
  List<_ScoredPhoto> _photos = [];
  int _scoringIndex = 0;
  int _mouseCb = 1;
  bool _picking = false;
  bool _exporting = false;

  @override
  void dispose() {
    _scorer.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    setState(() => _picking = true);
    try {
      debugPrint('[BatchScorer] Opening image picker...');
      final images = await _picker.pickMultiImage(requestFullMetadata: false);
      debugPrint('[BatchScorer] Picked ${images.length} images');
      if (images.isEmpty) {
        setState(() => _picking = false);
        return;
      }

      setState(() {
        _picking = false;
        _photos = images
            .map((xf) => _ScoredPhoto(path: xf.path, filename: xf.name))
            .toList();
        _phase = _Phase.photosSelected;
      });
    } catch (e) {
      debugPrint('[BatchScorer] Pick photos error: $e');
      setState(() => _picking = false);
    }
  }

  Future<void> _scoreAll() async {
    setState(() {
      _phase = _Phase.scoring;
      _scoringIndex = 0;
    });

    await _scorer.initialize();

    for (int i = 0; i < _photos.length; i++) {
      setState(() => _scoringIndex = i);
      try {
        final score = await _scorer.scoreImage(
          _photos[i].path,
          mouseCb: _mouseCb,
        );
        _photos[i] = _ScoredPhoto(
          path: _photos[i].path,
          filename: _photos[i].filename,
          score: score,
        );
      } catch (e) {
        debugPrint('[BatchScorer] Error scoring ${_photos[i].filename}: $e');
      }
    }

    await _scorer.dispose();
    setState(() => _phase = _Phase.done);
  }

  Future<void> _exportCsv() async {
    setState(() => _exporting = true);
    final buf = StringBuffer();
    buf.writeln(
      'filename,finalScore,riskLevel,chairScore,monitorScore,'
      'keyboardScore,mouseScore,peripheralScore,kneeAngle,trunkAngle',
    );
    for (final p in _photos) {
      if (p.noPose) {
        buf.writeln('${p.filename},,,,,,,,,');
      } else {
        final s = p.score!;
        buf.writeln(
          '${p.filename},${s.finalScore},${s.riskLevel},'
          '${s.chairScore},${s.monitorScore},${s.keyboardScore},'
          '${s.mouseScore},${s.peripheralScore},'
          '${s.kneeAngle.toStringAsFixed(1)},${s.trunkAngle.toStringAsFixed(1)}',
        );
      }
    }

    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/rosa_batch_results.csv');
      await file.writeAsString(buf.toString());
      debugPrint('[BatchScorer] CSV saved: ${file.path} (${buf.length} chars)');

      // Hide loader before opening share sheet — sheet blocks until dismissed.
      setState(() => _exporting = false);

      final result = await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        subject: 'ROSA Batch Results',
        sharePositionOrigin: origin,
      );
      debugPrint('[BatchScorer] Share result: ${result.status}');
      if (result.status == ShareResultStatus.success) {
        Fluttertoast.showToast(
          msg: 'CSV exported successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: AppColors.successGreen,
          textColor: Colors.white,
          fontSize: 14,
        );
      } else if (result.status == ShareResultStatus.dismissed) {
        Fluttertoast.showToast(
          msg: 'Export cancelled',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: AppColors.amber,
          textColor: Colors.white,
          fontSize: 14,
        );
      }
    } catch (e) {
      debugPrint('[BatchScorer] CSV export error: $e');
      Fluttertoast.showToast(
        msg: 'Export failed. Please try again.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.error,
        textColor: Colors.white,
        fontSize: 14,
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: const Text('Batch ROSA Scorer'),
        backgroundColor: c.surface,
        foregroundColor: c.textPrimary,
        elevation: 0,
        actions: [
          if (_phase == _Phase.done)
            IconButton(
              icon: const Icon(Icons.file_download_outlined),
              onPressed: _exportCsv,
              tooltip: 'Export CSV',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Mouse toggle.
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  Text(
                    'Mouse mode:',
                    style: TextStyle(color: c.textSecondary, fontSize: 12.sp),
                  ),
                  SizedBox(width: 8.w),
                  _ModeChip(
                    label: 'None',
                    selected: _mouseCb == 0,
                    onTap: () => setState(() => _mouseCb = 0),
                  ),
                  SizedBox(width: 6.w),
                  _ModeChip(
                    label: 'Normal',
                    selected: _mouseCb == 1,
                    onTap: () => setState(() => _mouseCb = 1),
                  ),
                  SizedBox(width: 6.w),
                  _ModeChip(
                    label: 'Dual',
                    selected: _mouseCb == 2,
                    onTap: () => setState(() => _mouseCb = 2),
                  ),
                ],
              ),
            ),
            Divider(color: c.border, height: 1),

            // Content.
            Expanded(child: _buildContent(c)),

            // Bottom buttons.
            _buildBottomBar(c),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AppColorSet c) {
    if (_picking) {
      return Center(child: SpineOrbitLoader(label: 'LOADING GALLERY'));
    }

    if (_exporting) {
      return Center(child: SpineOrbitLoader(label: 'EXPORTING CSV'));
    }

    if (_phase == _Phase.idle) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_library_outlined, color: c.iconMuted, size: 64.sp),
            SizedBox(height: 12.h),
            Text(
              'Pick photos to score',
              style: TextStyle(color: c.textSecondary, fontSize: 14.sp),
            ),
          ],
        ),
      );
    }

    if (_phase == _Phase.scoring) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpineOrbitLoader(label: 'SCORING'),
            SizedBox(height: 16.h),
            Text(
              'Scoring ${_scoringIndex + 1} / ${_photos.length}',
              style: TextStyle(color: c.textPrimary, fontSize: 16.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              'Photo ${_scoringIndex + 1} of ${_photos.length}',
              style: TextStyle(color: c.textSecondary, fontSize: 12.sp),
            ),
          ],
        ),
      );
    }

    // photosSelected or done — show list.
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      itemCount: _photos.length,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (_, i) =>
          _PhotoRow(photo: _photos[i], showScore: _phase == _Phase.done),
    );
  }

  Widget _buildBottomBar(AppColorSet c) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          if (_phase != _Phase.scoring)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickPhotos,
                icon: const Icon(Icons.photo_library),
                label: Text(
                  _phase == _Phase.idle
                      ? 'Pick Photos'
                      : '${_photos.length} photos',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.lightTeal,
                  side: const BorderSide(color: AppColors.lightTeal),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
          if (_phase == _Phase.photosSelected) ...[
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _scoreAll,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Score All'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
          ],
          if (_phase == _Phase.done) ...[
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _exportCsv,
                icon: const Icon(Icons.file_download_outlined),
                label: const Text('Export CSV'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PhotoRow extends StatelessWidget {
  const _PhotoRow({required this.photo, required this.showScore});
  final _ScoredPhoto photo;
  final bool showScore;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = photo.score;

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: c.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          // Thumbnail.
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: Image.file(
              File(photo.path),
              width: 60.w,
              height: 60.w,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12.w),

          // Info.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  photo.filename,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (showScore && s != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    s.riskLevel,
                    style: TextStyle(
                      color: _riskColor(s.finalScore),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Chair ${s.chairScore}  Periph ${s.peripheralScore}',
                    style: TextStyle(
                      color: c.textTertiary,
                      fontSize: 10.sp,
                      fontFamily: 'DMMono',
                    ),
                  ),
                ],
                if (showScore && photo.noPose) ...[
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'No pose',
                      style: TextStyle(
                        color: AppColors.amber,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Score badge.
          if (showScore && s != null)
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: _riskColor(s.finalScore).withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: _riskColor(s.finalScore)),
              ),
              child: Center(
                child: Text(
                  '${s.finalScore}',
                  style: TextStyle(
                    color: _riskColor(s.finalScore),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'DMMono',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _riskColor(int score) {
    if (score <= 4) return AppColors.successGreen;
    if (score <= 6) return AppColors.amber;
    return AppColors.error;
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryGreen.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? AppColors.primaryGreen : Colors.grey,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primaryGreen : Colors.grey,
            fontSize: 11.sp,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
