import 'package:camera/camera.dart';
import 'package:get/get.dart';

class ImageCaptureController extends GetxController {
  Rx<XFile?> image = Rx<XFile?>(null);

  /// Release image buffer to free memory.
  void clearImage() {
    image.value = null;
  }

  @override
  void onClose() {
    image.value = null;
    super.onClose();
  }
}
