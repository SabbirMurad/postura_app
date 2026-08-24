import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';

import 'package:posture_detector_app/constants/colors.dart';

/// ===============================
/// IMAGE UPLOADER WIDGET
/// ===============================
class ImageUploaderVOne extends StatefulWidget {
  final double height;
  final String? defaultImage; // fallback image path
  final String? currentImage; // existing profile image path
  final bool enable;
  final bool loading;
  final bool showBorder;
  final void Function(File)? onImageSelected;
  final File? selectedImage;

  const ImageUploaderVOne({
    super.key,
    this.enable = true,
    this.defaultImage,
    this.currentImage,
    this.onImageSelected,
    this.height = 90,
    this.loading = false,
    this.showBorder = false,
    this.selectedImage,
  });

  @override
  State<ImageUploaderVOne> createState() => _ImageUploaderVOneState();
}

class _ImageUploaderVOneState extends State<ImageUploaderVOne> {
  Uint8List? _imageData;

  /// Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? file = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (file == null) return;

      final imgFile = File(file.path);
      final bytes = await imgFile.readAsBytes();

      if (!mounted) return;

      setState(() {
        _imageData = bytes;
      });

      widget.onImageSelected?.call(imgFile);
    } catch (e) {
      debugPrint('Image pick error: $e');
    }
  }

  /// Bottom sheet for camera / gallery
  void _showPickerOptions() {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.onBoardingSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                // EN: "Take a photo"
                title: Text(loc.takePhoto),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                // EN: "Choose from gallery"
                title: Text(loc.chooseFromGallery),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Update widget when external selectedImage changes
  @override
  void didUpdateWidget(covariant ImageUploaderVOne oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedImage != null &&
        widget.selectedImage != oldWidget.selectedImage) {
      widget.selectedImage!.readAsBytes().then((bytes) {
        if (!mounted) return;
        setState(() {
          _imageData = bytes;
        });
      });
    }
  }

  /// Build image widget depending on type
  Widget _buildImage() {
    if (_imageData != null) {
      // picked image from device
      return Image.memory(_imageData!, fit: BoxFit.cover);
    } else if (widget.currentImage != null &&
        widget.currentImage!.startsWith('http')) {
      // network image from server
      return CachedNetworkImage(
        imageUrl: widget.currentImage!,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) =>
            const Icon(Icons.person, size: 40, color: Colors.grey),
        placeholder: (_, __) =>
            const Center(child: CircularProgressIndicator()),
      );
    } else if (widget.currentImage != null) {
      // local asset image
      final ext = widget.currentImage!.split('.').last.toLowerCase();
      if (ext == 'svg') {
        return SvgPicture.asset(widget.currentImage!, fit: BoxFit.cover);
      } else {
        return Image.asset(widget.currentImage!, fit: BoxFit.cover);
      }
    } else if (widget.defaultImage != null && widget.defaultImage!.isNotEmpty) {
      // fallback default image
      final ext = widget.defaultImage!.split('.').last.toLowerCase();
      if (ext == 'svg') {
        return Padding(
          padding: EdgeInsets.all(12.w),
          child: SvgPicture.asset(
            widget.defaultImage!,
            width: widget.height * .6,
            height: widget.height * .6,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        );
      } else {
        return Image.asset(
          widget.defaultImage!,
          width: widget.height * .6,
          height: widget.height * .6,
          fit: BoxFit.cover,
        );
      }
    } else {
      return const Icon(Icons.person, size: 40, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.height,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (!widget.enable || widget.loading) return;
              _showPickerOptions();
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                border: widget.showBorder
                    ? Border.all(
                        color: Colors.grey.withValues(alpha: 0.3),
                        width: 1.5,
                      )
                    : null,
                borderRadius: BorderRadius.circular(widget.height / 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.height / 2),
                child: _buildImage(),
              ),
            ),
          ),

          /// Loading overlay
          if (widget.loading)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: .3),
                borderRadius: BorderRadius.circular(widget.height / 2),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),

          /// Edit icon
          if (widget.enable)
            Positioned(
              bottom: 4,
              right: 4,
              child: GestureDetector(
                onTap: () {
                  if (!widget.loading) _showPickerOptions();
                },
                child: Container(
                  width: widget.height * .28,
                  height: widget.height * .28,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
