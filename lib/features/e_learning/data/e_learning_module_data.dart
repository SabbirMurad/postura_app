import 'package:posture_detector_app/data/models/quiz/quiz_module.dart';
import 'package:posture_detector_app/features/e_learning/data/modules_en.dart' as en;
import 'package:posture_detector_app/features/e_learning/data/modules_nl.dart' as nl;
import 'package:posture_detector_app/features/e_learning/data/modules_de.dart' as de;
import 'package:posture_detector_app/features/e_learning/data/modules_es.dart' as es;

class ELearningModuleData {
  static List<QuizModule> getModules(String locale) {
    switch (locale) {
      case 'nl':
        return [nl.m1Nl(), nl.m2Nl(), nl.m3Nl(), nl.m4Nl(), nl.m5Nl(), nl.m6Nl(), nl.m7Nl()];
      case 'de':
        return [de.m1De(), de.m2De(), de.m3De(), de.m4De(), de.m5De(), de.m6De(), de.m7De()];
      case 'es':
        return [es.m1Es(), es.m2Es(), es.m3Es(), es.m4Es(), es.m5Es(), es.m6Es(), es.m7Es()];
      default:
        return [en.m1En(), en.m2En(), en.m3En(), en.m4En(), en.m5En(), en.m6En(), en.m7En()];
    }
  }
}
