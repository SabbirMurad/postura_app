import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';
import 'features/step1_detection/data/ml_detector.dart';
import 'features/step1_detection/data/real_ml_detector.dart';
import 'features/step1_detection/presentation/bloc/detection_bloc.dart';
import 'features/step1_detection/presentation/screens/detection_screen.dart';
import 'features/step2_pose/data/real_pose_detector.dart';
import 'features/step2_pose/presentation/bloc/pose_bloc.dart';
import 'features/step2_pose/presentation/screens/pose_screen.dart';
import 'features/step3_capture/domain/capture_questionnaire.dart';
import 'features/step3_capture/presentation/bloc/capture_bloc.dart';
import 'features/step3_capture/presentation/bloc/capture_bloc_state.dart';
import 'features/step3_capture/presentation/screens/capture_screen.dart';
import 'features/step3_capture/presentation/screens/instruction_screen.dart';
import 'features/step3_capture/presentation/screens/review_screen.dart';
import 'features/step3_capture/domain/rosa_score.dart';
import 'features/step2_pose/domain/pose_result.dart';
import 'core/constants/pose_constants.dart';
import 'core/widgets/spine_orbit_loader.dart';
import 'services/accelerometer_service.dart';
import 'services/camera_service.dart';
import 'services/pipeline_controller.dart';

class LiveGuidance extends StatefulWidget {
  final void Function({
    required RosaScore rosaScore,
    required String imagePath,
    required PoseResult poseResult,
  })
  onComplete;

  final CaptureQuestionnaire questionnaire;

  const LiveGuidance({
    super.key,
    required this.onComplete,
    required this.questionnaire,
  });

  @override
  State<LiveGuidance> createState() => _LiveGuidanceState();
}

enum _AppPhase {
  step1,
  step2,
  step3Instruction,
  step3Capture,
  step3Review,
}

class _LiveGuidanceState extends State<LiveGuidance> {
  late final CameraService _cameraService;
  late final MlDetector _mlDetector;
  late final PipelineController _pipelineController;
  bool _cameraReady = false;
  String? _initError;
  _AppPhase _phase = _AppPhase.step1;

  // Step 3 review data.
  RosaScore? _rosaScore;
  String? _capturedImagePath;
  PoseResult? _capturedPoseResult;

  // Questionnaire — accumulates across 5 screens.
  late final CaptureQuestionnaire _questionnaire = widget.questionnaire;

  @override
  void initState() {
    super.initState();
    _cameraService = CameraService();
    _mlDetector = RealMlDetector();
    _pipelineController = PipelineController(
      cameraService: _cameraService,
      mlDetector: _mlDetector,
    );
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraService.initialize();
      setState(() => _cameraReady = true);
    } catch (e) {
      setState(() => _initError = e.toString());
    }
  }

  void _onStep1Confirmed() {
    debugPrint('[App] Step 1 confirmed — switching to Step 2');
    _mlDetector.pause();
    _cameraService.setFrameRate(PoseConstants.targetFps);
    setState(() => _phase = _AppPhase.step2);
    debugPrint('[App] PoseScreen active');
  }

  void _onPoseStabilized() {
    debugPrint('[App] Step 2 stabilized — switching to Step 3 instructions');
    setState(() => _phase = _AppPhase.step3Instruction);
  }

  void _onStep3Start() {
    debugPrint('[App] Instruction done — starting capture');
    setState(() => _phase = _AppPhase.step3Capture);
  }

  // ── Capture callbacks ──────────────────────────────────────

  void _onCaptureComplete(CaptureBlocState state) {
    if (state is CaptureComplete) {
      debugPrint(
        '[App] Capture complete — ROSA score: ${state.rosaScore.finalScore}',
      );
      _rosaScore = state.rosaScore;
      _capturedImagePath = state.imagePath;
      _capturedPoseResult = state.poseResult;
      setState(() => _phase = _AppPhase.step3Review);

      widget.onComplete(
        rosaScore: _rosaScore!,
        imagePath: _capturedImagePath!,
        poseResult: _capturedPoseResult!,
      );
    }
  }

  void _onRetake() {
    debugPrint('[App] Retake — back to setup guide');
    _mlDetector.resume();
    setState(() => _phase = _AppPhase.step1);
  }

  void _onCaptureCancel() {
    debugPrint('[App] Capture cancelled — back to instruction');
    setState(() => _phase = _AppPhase.step3Instruction);
  }

  @override
  void dispose() {
    _pipelineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Postura',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          home: _buildHome(),
        );
      },
    );
  }

  Widget _buildHome() {
    if (_initError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Camera initialization failed:\n$_initError',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      );
    }

    if (!_cameraReady) {
      return Scaffold(
        body: Center(child: SpineOrbitLoader(label: 'INITIALIZING CAMERA')),
      );
    }

    // Step 3: Review.
    if (_phase == _AppPhase.step3Review &&
        _rosaScore != null &&
        _capturedImagePath != null) {
      return ReviewScreen(
        rosaScore: _rosaScore!,
        imagePath: _capturedImagePath!,
        poseResult: _capturedPoseResult ?? const PoseResult.empty(),
        onRetake: _onRetake,
      );
    }

    // Step 3: Capture.
    if (_phase == _AppPhase.step3Capture) {
      return BlocProvider(
        create: (_) => CaptureBloc(
          mlDetector: _mlDetector,
          poseDetector: RealPoseDetector(),
          cameraService: _cameraService,
          accelerometerService: AccelerometerService(),
        ),
        child: CaptureScreen(
          cameraService: _cameraService,
          questionnaire: _questionnaire,
          onComplete: _onCaptureComplete,
          onCancel: _onCaptureCancel,
        ),
      );
    }

    // Step 3: Instruction.
    if (_phase == _AppPhase.step3Instruction) {
      return InstructionScreen(onStart: _onStep3Start);
    }

    // Step 2: Pose.
    if (_phase == _AppPhase.step2) {
      return BlocProvider(
        create: (_) => PoseBloc(detector: RealPoseDetector()),
        child: PoseScreen(
          cameraService: _cameraService,
          onStabilized: _onPoseStabilized,
        ),
      );
    }

    // Step 1: Detection.
    return BlocProvider(
      create: (_) => DetectionBloc(detector: _mlDetector),
      child: DetectionScreen(
        cameraService: _cameraService,
        onConfirmed: _onStep1Confirmed,
      ),
    );
  }
}
