import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/common/widgets/back_button.dart';
import 'package:posture_detector_app/common/widgets/e_learning_card.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/controller/e_learning_controller.dart';
import 'package:posture_detector_app/view/e_learning/screens/quiz_screen.dart';

class ELearningScreen extends StatefulWidget {
  const ELearningScreen({super.key});

  @override
  State<ELearningScreen> createState() => _ELearningScreenState();
}

class _ELearningScreenState extends State<ELearningScreen>
    with WidgetsBindingObserver {
  final ELearningController _eLearningController = Get.put(
    ELearningController(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initial nudge check when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _eLearningController.checkNudges();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Check nudges when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _eLearningController.checkNudges();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppBackButton(),
                    Spacer(),
                    Text(
                      loc.elearning,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
                SizedBox(height: 20.h),

                // Wrap with Obx to rebuild when quizModules changes
                Obx(
                  () => ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _eLearningController.quizModules.length,
                    separatorBuilder: (context, index) {
                      return SizedBox(height: 12.h);
                    },
                    itemBuilder: (context, index) {
                      final quizModule =
                          _eLearningController.quizModules[index];

                      return ELearningCard(
                        quizModule: quizModule,
                        onTap: () {
                          Get.to(() => QuizScreen(module: quizModule));
                        },
                      );
                    },
                  ),
                ),

                SizedBox(height: 50.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
