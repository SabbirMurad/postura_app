import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/services/api/onboarding_service.dart';
import 'package:posture_detector_app/core/constants/app_text.dart';
import 'package:posture_detector_app/models/scan_type.dart';
import 'package:posture_detector_app/controller/image_capture_controller.dart';
import 'package:posture_detector_app/controller/camera_flow_controller.dart';
import 'package:posture_detector_app/controller/report_controller.dart';

class SignupController extends GetxController {
  RxString userRole = RxString('');
  RxString selectedLanguage = RxString('en');
  RxString workRole = RxString('');
  RxString workPatternRole = RxString('');
  RxString breakHabit = RxString('');
  RxString hourDeskPerDay = RxString('');
  RxBool isLoading = RxBool(false);
  RxBool isLoadingAnalysis = RxBool(false);
  Rx<File?> image = Rx<File?>(null);
  RxString lastAssessmentId = RxString('');

  final OnboardingService _onboardingService = OnboardingService();
  final ImageCaptureController _imageCaptureController = Get.put(
    ImageCaptureController(),
  );

  AppLocalizations get _loc => AppLocalizations.of(Get.context!)!;

  RxList<String> selectedRegion = <String>[].obs;
  RxMap<String, RxDouble> painIntensityValues = <String, RxDouble>{}.obs;

  void initializePainValues() {
    painIntensityValues.clear();
    for (var region in selectedRegion) {
      painIntensityValues[region] = RxDouble(1.0);
    }
  }

  RxDouble getPainValueForRegion(String region) {
    if (!painIntensityValues.containsKey(region)) {
      painIntensityValues[region] = RxDouble(1.0);
    }
    return painIntensityValues[region]!;
  }

  RxList<String> bodyRegionList = <String>[
    AppText.neck,
    AppText.elbow,
    AppText.upperBack,
    AppText.lowerBack,
    AppText.shoulder,
    AppText.wrist,
    AppText.knees,
    AppText.ankles,
    AppText.hipsGultes,
  ].obs;

  RxString selectedPainDuration = RxString('');
  RxList<String> painDuration = <String>[
    AppText.lessThanWeek,
    AppText.week1To6,
    AppText.moreThan6Week,
    AppText.onOffForMonth,
  ].obs;

  Map<String, int> painIntensityMap = {};

  void setPainForRegion(String region, int value) {
    painIntensityMap[region] = value;
  }

  RxList<String> selectedSymptom = <String>[].obs;
  RxList<String> symptoms = <String>[
    AppText.tingling,
    AppText.fatigue,
    AppText.endOfDayPain,
    AppText.stiffness,
    AppText.morningPain,
  ].obs;

  /// ------------------- business module ----------------------------- ///
  TextEditingController companyCodeController = TextEditingController();
  TextEditingController companyEmailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController companyPasswordController = TextEditingController();
  TextEditingController employeeIdController = TextEditingController();
  TextEditingController deskIdController = TextEditingController();
  TextEditingController departmentController = TextEditingController();

  void reset() {
    userRole.value = '';
    selectedLanguage.value = 'english';
    workRole.value = '';
    workPatternRole.value = '';
    breakHabit.value = '';
    hourDeskPerDay.value = '';
    selectedRegion.clear();
    painIntensityValues.clear();
    painIntensityMap.clear();
    selectedPainDuration.value = '';
    selectedSymptom.clear();
    companyCodeController.clear();
    userNameController.clear();
    companyEmailController.clear();
    employeeIdController.clear();
    deskIdController.clear();
    departmentController.clear();
  }

  Future<bool> poseAnalysisProcess(type) async {
    try {
      isLoadingAnalysis.value = true;

      if (_imageCaptureController.image.value == null) {
        isLoadingAnalysis.value = false;
        // EN: "No image selected"
        showCustomToast(text: _loc.noImageSelected);
        return false;
      }

      final File imageFile = File(_imageCaptureController.image.value!.path);

      painIntensityMap.clear();
      painIntensityValues.forEach((region, rxDouble) {
        painIntensityMap[region] = rxDouble.value.toInt();
      });

      final response = await _onboardingService.onboardingFlow(
        scan_type: type == ScanType.primaryScan || type == ScanType.captureImage
            ? "primary"
            : "instant",
        image: imageFile,
        bodyRegions: selectedRegion,
        painIntensity: painIntensityMap,
        durationPattern: selectedPainDuration.value,
        workHabits: {
          'hours_at_desk': hourDeskPerDay.value,
          'break_habit': breakHabit.value,
          'device_usage': workPatternRole.value,
        },
        symptoms: selectedSymptom,
      );

      if (response.data != null) {
        final reportController = Get.find<ReportController>();
        reportController.analysisData.value = response.data!;
        reportController.saveAnalysisData(response.data!);

        if (Get.isRegistered<CameraFlowController>()) {
          Get.delete<CameraFlowController>();
        }
        Get.put(CameraFlowController());

        isLoadingAnalysis.value = false;

        return true;
      } else {
        isLoadingAnalysis.value = false;
        // EN: "Failed to process analysis"
        showCustomToast(text: response.error ?? _loc.failedToProcessAnalysis);
      }
    } catch (e) {
      isLoadingAnalysis.value = false;
      debugPrint('Pose analysis error: $e');
      // EN: "An unexpected error occurred"
      showCustomToast(text: _loc.unexpectedError);
    }
    return false;
  }

  @override
  void onClose() {
    companyCodeController.dispose();
    companyEmailController.dispose();
    userNameController.dispose();
    companyPasswordController.dispose();
    employeeIdController.dispose();
    deskIdController.dispose();
    departmentController.dispose();
    super.onClose();
  }
}
