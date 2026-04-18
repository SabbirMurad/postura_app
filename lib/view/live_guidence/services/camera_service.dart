import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import '../core/constants/detection_constants.dart';

/// Copied camera frame data — holds raw bytes so the native CameraImage
/// buffer can be released immediately.
class CopiedCameraFrame {
  CopiedCameraFrame({
    required this.width,
    required this.height,
    required this.planes,
    required this.formatGroup,
    required this.sensorOrientation,
  });

  final int width;
  final int height;
  final List<CopiedPlane> planes;
  final ImageFormatGroup formatGroup;

  /// Camera sensor orientation in degrees (0, 90, 180, 270).
  final int sensorOrientation;
}

/// Copied plane data from a CameraImage plane.
class CopiedPlane {
  CopiedPlane({
    required this.bytes,
    required this.bytesPerRow,
    required this.bytesPerPixel,
  });

  final Uint8List bytes;
  final int bytesPerRow;
  final int? bytesPerPixel;
}

/// Manages camera lifecycle and provides a throttled frame stream at 2 fps.
class CameraService {
  CameraController? _controller;
  final _frameController = StreamController<CopiedCameraFrame>.broadcast();
  bool _isStreaming = false;
  DateTime _lastFrameTime = DateTime(0);

  /// Live camera controller — available after [initialize].
  CameraController? get controller => _controller;

  /// Stream of copied camera frames throttled to [DetectionConstants.targetFps].
  Stream<CopiedCameraFrame> get frameStream => _frameController.stream;

  /// Whether the camera is actively streaming frames.
  bool get isStreaming => _isStreaming;

  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;

  /// Current frame throttle interval. Defaults to Step 1's 2fps.
  Duration _frameInterval = DetectionConstants.frameInterval;

  /// Switch frame rate at runtime (e.g., 2fps for Step 1, 10fps for Step 2).
  void setFrameRate(int fps) {
    _frameInterval = Duration(milliseconds: (1000 / fps).round());
  }

  /// Whether the camera can be switched (device has more than one camera).
  bool get canSwitchCamera => _cameras.length > 1;

  /// Current camera lens direction.
  CameraLensDirection? get currentLensDirection =>
      _cameras.isNotEmpty ? _cameras[_currentCameraIndex].lensDirection : null;

  /// Initialize the camera. Defaults to back camera.
  Future<void> initialize() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      throw CameraException('noCameras', 'No cameras available on device.');
    }

    // Default to back camera so person + monitor are both visible.
    _currentCameraIndex = _cameras.indexWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
    );
    if (_currentCameraIndex < 0) _currentCameraIndex = 0;

    await _initController(_cameras[_currentCameraIndex]);
  }

  /// Switch between front and back camera.
  Future<void> switchCamera() async {
    if (!canSwitchCamera) return;

    final wasStreaming = _isStreaming;
    if (wasStreaming) await stopFrameSampling();
    await _controller?.dispose();

    // Toggle between front and back (not cycling through all lenses).
    final currentDirection = _cameras[_currentCameraIndex].lensDirection;
    final targetDirection = currentDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    final idx = _cameras.indexWhere((c) => c.lensDirection == targetDirection);
    if (idx >= 0) _currentCameraIndex = idx;

    await _initController(_cameras[_currentCameraIndex]);

    if (wasStreaming) startFrameSampling();
  }

  Future<void> _initController(CameraDescription camera) async {
    // Android: YUV420 (3 planes). iOS: BGRA8888 (1 plane).
    // iOS YUV420 uses biplanar NV12 (2 planes) which our converter doesn't handle.
    final formatGroup = Platform.isAndroid
        ? ImageFormatGroup.yuv420
        : ImageFormatGroup.bgra8888;

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: formatGroup,
    );
    await _controller!.initialize();
    // Ensure widest field of view — no zoom.
    await _controller!.setZoomLevel(await _controller!.getMinZoomLevel());
  }

  /// Start the 2 fps frame sampling loop.
  ///
  /// Immediately copies plane bytes from the CameraImage so the native
  /// buffer is released as soon as the callback returns. This prevents
  /// ImageReader buffer starvation on devices with limited buffer slots.
  bool _copying = false;

  void startFrameSampling() {
    if (_isStreaming) return;
    _isStreaming = true;
    _copying = false;

    _controller!.startImageStream((CameraImage image) {
      // Throttle: only emit one frame every 500ms (2fps).
      final now = DateTime.now();
      if (now.difference(_lastFrameTime) < _frameInterval) {
        return;
      }

      // Skip if previous frame's bytes are still being copied.
      // Prevents ImageReader buffer exhaustion on budget phones.
      if (_copying) return;

      _lastFrameTime = now;
      if (_frameController.isClosed) return;

      _copying = true;

      // Copy bytes immediately so the native buffer is released.
      final copied = CopiedCameraFrame(
        width: image.width,
        height: image.height,
        formatGroup: image.format.group,
        sensorOrientation: _cameras[_currentCameraIndex].sensorOrientation,
        planes: image.planes.map((plane) {
          return CopiedPlane(
            bytes: Uint8List.fromList(plane.bytes),
            bytesPerRow: plane.bytesPerRow,
            bytesPerPixel: plane.bytesPerPixel,
          );
        }).toList(),
      );

      _copying = false;
      _frameController.add(copied);
    });
  }

  /// Stop the frame sampling loop.
  Future<void> stopFrameSampling() async {
    if (_isStreaming && _controller != null) {
      await _controller!.stopImageStream();
    }
    _isStreaming = false;
  }

  /// Restart camera session — tries lightweight stream restart first,
  /// falls back to full dispose+reinit if the device doesn't support it.
  Future<void> restartCamera() async {
    await stopFrameSampling();

    // Lightweight restart: just stop+start the image stream.
    // Avoids the slow camera dispose+reinit cycle (~500ms-1s on budget phones).
    // Falls back to full reinit if stopImageStream threw or controller is bad.
    if (_controller != null && _controller!.value.isInitialized) {
      return; // Controller still valid — startFrameSampling will reuse it.
    }

    // Full restart fallback.
    final camera = _cameras[_currentCameraIndex];
    await _controller?.dispose();
    await _initController(camera);
  }

  /// Capture a single high-quality photo. Returns the file path.
  ///
  /// Used in Step 3 autocapture after all conditions pass.
  Future<String> capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw CameraException('notReady', 'Camera not initialized for capture.');
    }
    final xFile = await _controller!.takePicture();
    return xFile.path;
  }

  /// Fully dispose the camera and close the frame stream.
  Future<void> dispose() async {
    await stopFrameSampling();
    await _frameController.close();
    await _controller?.dispose();
    _controller = null;
  }
}
