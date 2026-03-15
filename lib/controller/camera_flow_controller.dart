import 'package:get/get.dart';
import 'package:posture_detector_app/models/analysis/body_region_risk_model.dart';
import 'package:posture_detector_app/models/analysis/analysis_data_model.dart';

import 'package:posture_detector_app/controller/report_controller.dart';

class CameraFlowController extends GetxController {
  final RxList<BodyRegionRiskModel> menuItems = <BodyRegionRiskModel>[].obs;

  void setBodyRegionRisksFromModel(BodyRegionRisks risks) {
    menuItems.value = [
      BodyRegionRiskModel(region: 'Elbows', risk: risks.elbows),
      BodyRegionRiskModel(region: 'Shoulder', risk: risks.shoulder),
      BodyRegionRiskModel(region: 'Wrist', risk: risks.wrist),
      BodyRegionRiskModel(region: 'Lower Back', risk: risks.lowerBack),
    ];
  }

  @override
  void onInit() {
    super.onInit();

    final reportController = Get.find<ReportController>();

    final bodyRegionData =
        reportController.analysisData.value?.aiResult.bodyRegionRisks;

    if (bodyRegionData != null) {
      setBodyRegionRisksFromModel(bodyRegionData);
    }
  }

  @override
  void onClose() {
    menuItems.clear();
    super.onClose();
  }
}

