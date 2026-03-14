import 'package:get/get.dart';
import 'package:posture_detector_app/data/models/analysis/body_region_risk_model.dart';
import 'package:posture_detector_app/data/models/analysis/analysis_data_model.dart';
import 'package:posture_detector_app/controller/report_controller.dart';

class PersonalHomeController extends GetxController {
  final RxList<BodyRegionRiskModel> menuItems = <BodyRegionRiskModel>[].obs;
  Worker? _analysisWorker;

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

    // Initial check
    if (reportController.analysisData.value?.aiResult.bodyRegionRisks != null) {
      setBodyRegionRisksFromModel(
        reportController.analysisData.value!.aiResult.bodyRegionRisks,
      );
    }

    // Listen for changes
    _analysisWorker = ever(reportController.analysisData, (data) {
      if (data?.aiResult.bodyRegionRisks != null) {
        setBodyRegionRisksFromModel(data!.aiResult.bodyRegionRisks);
      }
    });
  }

  @override
  void onClose() {
    _analysisWorker?.dispose();
    super.onClose();
  }
}

