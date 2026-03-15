import 'package:get/get.dart';
import 'package:posture_detector_app/models/analysis/body_region_risk_model.dart';
import 'package:posture_detector_app/models/analysis/analysis_data_model.dart';
import 'package:posture_detector_app/controller/report_controller.dart';

class BusinessHomeController extends GetxController {
  final RxList<BodyRegionRiskModel> menuItems = <BodyRegionRiskModel>[].obs;

  late ReportController _reportController;
  Worker? _analysisWorker;

  void setBodyRegionRisksFromModel(BodyRegionRisks risks) {
    menuItems.value = [
      BodyRegionRiskModel(region: 'Elbows', risk: risks.elbows),
      BodyRegionRiskModel(region: 'Shoulder', risk: risks.shoulder),
      BodyRegionRiskModel(region: 'Wrist', risk: risks.wrist),
      BodyRegionRiskModel(region: 'Lower Back', risk: risks.lowerBack),
    ];
  }

  Future<void> refreshBodyRegionData() async {
    final bodyRegionData =
        _reportController.analysisData.value?.aiResult.bodyRegionRisks;
    if (bodyRegionData != null) {
      setBodyRegionRisksFromModel(bodyRegionData);
    }
  }

  @override
  void onInit() {
    super.onInit();

    _reportController = Get.find<ReportController>();

    // Initial check
    final bodyRegionData =
        _reportController.analysisData.value?.aiResult.bodyRegionRisks;
    if (bodyRegionData != null) {
      setBodyRegionRisksFromModel(bodyRegionData);
    }

    // Listen for changes
    _analysisWorker = ever(_reportController.analysisData, (data) {
      if (data != null) {
        setBodyRegionRisksFromModel(data.aiResult.bodyRegionRisks);
      }
    });
  }

  @override
  void onClose() {
    _analysisWorker?.dispose();
    super.onClose();
  }
}

