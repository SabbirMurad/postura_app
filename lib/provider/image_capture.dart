import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageCaptureNotifier extends Notifier<XFile?> {
  @override
  XFile? build() => null;

  void setImage(XFile image) => state = image;
  void clear() => state = null;
}

final imageCaptureNotifierProvider =
    NotifierProvider<ImageCaptureNotifier, XFile?>(
  ImageCaptureNotifier.new,
);
