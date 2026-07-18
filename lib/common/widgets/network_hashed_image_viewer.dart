import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:posture_detector_app/common/widgets/image_error_widget.dart';
import 'package:posture_detector_app/common/widgets/image_placeholder.dart';
import 'package:posture_detector_app/models/media/image.dart';

class NetworkHashedImageViewer extends StatelessWidget {
  final ImageModel image;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const NetworkHashedImageViewer({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: image.webp_url,
      width: width,
      height: height,
      fit: fit ?? BoxFit.contain,
      placeholder: (context, url) {
        return ImagePlaceholder(
          width: width,
          height: height,
          blur_hash: image.blur_hash,
        );
      },
      errorWidget: (context, url, error) {
        return ImageErrorWidget(blur_hash: image.blur_hash);
      },
    );
  }
}
