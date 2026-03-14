import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/core/routes/app_routes.dart';
import 'package:posture_detector_app/core/constants/app_text.dart';
import 'package:posture_detector_app/controller/image_capture_controller.dart';
import 'package:posture_detector_app/features/camera_capture/widgets/scan_confirmation_dialog.dart';
import 'package:posture_detector_app/features/camera_capture/widgets/camera_bottom_bar.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/core/enums/scan_type.dart';

class ImageCaptureScreen extends StatefulWidget {
  final ScanType type;

  const ImageCaptureScreen({super.key, required this.type});

  @override
  State<ImageCaptureScreen> createState() => _ImageCaptureScreenState();
}

class _ImageCaptureScreenState extends State<ImageCaptureScreen> {
  CameraController? cameraController;
  late List<CameraDescription> _cameras;
  late Future<void> _initializeController;
  late ImageCaptureController _imageCaptureController;

  bool isFlashOn = false;
  bool _primaryScan = false;
  bool _instantScan = false;
  bool _captureImage = false;

  @override
  void initState() {
    super.initState();

    _imageCaptureController = Get.put(ImageCaptureController());

    _initializeController = initCamera();
  }

  Future<void> initCamera() async {
    _cameras = await availableCameras();
    final backCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => _cameras.first,
    );

    cameraController = CameraController(
      backCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    try {
      await cameraController!.initialize();

      if (mounted) {
        setState(() {});

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widget.type == ScanType.primaryScan) {
            _showPrimaryScanAlert();
          } else if (widget.type == ScanType.instantScan) {
            _showInstantScanAlert();
          } else if (widget.type == ScanType.captureImage) {
            _showImageCaptureAlert();
          }
        });
      }
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  void toggleFlash() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }
    try {
      if (isFlashOn) {
        await cameraController!.setFlashMode(FlashMode.off);
      } else {
        await cameraController!.setFlashMode(FlashMode.torch);
      }
      setState(() => isFlashOn = !isFlashOn);
    } catch (e) {
      debugPrint('Flash toggle error: $e');
    }
  }

  void captureImage() async {
    try {
      final XFile image = await cameraController!.takePicture();
      await cameraController!.setFlashMode(FlashMode.off);

      _imageCaptureController.image.value = image;

      await Get.toNamed(
        AppRoute.imagePreview,
        arguments: {'imagePath': image.path, 'type': widget.type},
      );
    } catch (e) {
      debugPrint("Error capturing image: $e");
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  void _showPrimaryScanAlert() {
    if (_primaryScan) return;
    _primaryScan = true;
    showScanConfirmationDialog(
      context,
      icon: Assets.icons.nav.cameraScan.svg(height: 46.h, width: 46.w),
      title: AppText.primaryScan,
      content: AppText.primaryScanInfo,
      onCancel: () => Get.offNamed(AppRoute.bottomNavBusiness),
      onConfirm: () => Get.back(),
    );
  }

  void _showInstantScanAlert() {
    if (_instantScan) return;
    _instantScan = true;
    showScanConfirmationDialog(
      context,
      icon: Assets.icons.general.instantScan.svg(height: 46.h, width: 46.w),
      title: AppText.instantScan,
      content: AppText.instantScanInfo,
      onCancel: () => Get.offNamed(AppRoute.bottomNavBusiness),
      onConfirm: () => Get.back(),
    );
  }

  void _showImageCaptureAlert() {
    if (_captureImage) return;
    _captureImage = true;
    showScanConfirmationDialog(
      context,
      icon: Assets.icons.nav.cameraScan.svg(height: 46.h, width: 46.w),
      title: AppText.consentToUpload,
      content: AppText.consentToUploadInfo,
      onCancel: () => Get.offNamed(AppRoute.cameraGuideScreen),
      onConfirm: () => Get.back(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initializeController,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              cameraController != null &&
              cameraController!.value.isInitialized) {
            return Stack(
              fit: StackFit.expand,
              children: [
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: cameraController!.value.previewSize!.height,
                      height: cameraController!.value.previewSize!.width,
                      child: CameraPreview(cameraController!),
                    ),
                  ),
                ),
                Center(
                  child: Assets.images.camera.photoFrame.image(
                    width: 220.w,
                    height: 269.h,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: CameraBottomBar(
                    onCapture: captureImage,
                    onToggleFlash: toggleFlash,
                    isFlashOn: isFlashOn,
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
