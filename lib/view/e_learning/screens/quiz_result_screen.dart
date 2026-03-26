import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/gen/assets.gen.dart';
import 'package:posture_detector_app/models/quiz/quiz_module.dart';
import 'package:posture_detector_app/routes.dart';
import 'package:posture_detector_app/core/enums/user_type.dart';
import 'package:posture_detector_app/data/helpers/app_helper.dart';
import 'package:posture_detector_app/core/constants/app_colors.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';
import 'package:posture_detector_app/controller/e_learning_controller.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizModule quizModule;
  final ELearningController controller;

  const QuizResultScreen({
    super.key,
    required this.quizModule,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onBoardingSurface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 24.h),
              // EN: "Your Score"
              Text(
                AppLocalizations.of(context)!.yourScore,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '${quizModule.highestScore}/5',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),

              // Quiz list
              ...quizModule.quizzes.asMap().entries.map((entry) {
                final item = entry.value;
                final idx = entry.key;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: _buildQuizQuestion(idx, item, controller),
                );
              }).toList(),

              // Buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        // EN: "Home"
                        text: AppLocalizations.of(context)!.home,
                        textColor: AppColors.surface,
                        backgroundColor: AppColors.primaryColor,
                        onTap: () async {
                          controller.selectedAnswers.clear();
                          Get.offAllNamed(AppRoute.bottomNavBusiness);
                        },
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: PrimaryButton(
                        // EN: "Go to E-Learning"
                        text: AppLocalizations.of(context)!.goToElearning,
                        textColor: AppColors.surface,
                        onTap: () async {
                          controller.selectedAnswers.clear();
                          Get.back();
                          Get.back();

                          // if (userRole == Users.EMPLOYEE.name) {
                          //   Get.offAllNamed(AppRoute.bottomNavBusiness);
                          // } else {
                          //   Get.offAllNamed(AppRoute.bottomNavPersonal);
                          // }
                        },
                        backgroundColor: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizQuestion(
    int index,
    QuizItemModel quiz,
    ELearningController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          quiz.question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 24.h),
        ...quiz.options.asMap().entries.map((entry) {
          final option = entry.value;
          final optionIndex = entry.key;

          return Padding(
            padding: EdgeInsets.only(bottom: 18.h),
            child: _buildRadioOption(
              index,
              optionIndex,
              option,
              controller,
              quiz.answer,
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRadioOption(
    int questionIndex,
    int optionIndex,
    String option,
    ELearningController controller,
    int correctAnswer,
  ) {
    return Obx(() {
      final selectedAnswer = controller.selectedAnswers[questionIndex];
      final isCorrectAnswer = selectedAnswer == correctAnswer;
      final isSelected = selectedAnswer == optionIndex;

      return Row(
        children: [
          // Green check: only if user selected THIS option AND it's correct
          if (isSelected && isCorrectAnswer)
            Assets.icons.status.check.svg(width: 24.w, height: 24.w),
          // Red X: only if user selected THIS option AND it's wrong
          if (isSelected && !isCorrectAnswer)
            Assets.icons.status.cancelCircle.svg(width: 24.w, height: 24.w),
          // Black dot: all other options
          if (!isSelected)
            Container(
              width: 10,
              height: 10,
              margin: EdgeInsets.only(left: 8.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.text,
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              option,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      );
    });
  }
}
