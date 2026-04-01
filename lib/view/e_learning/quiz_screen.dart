import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:posture_detector_app/common/widgets/primary_button.dart';
import 'package:posture_detector_app/models/quiz/quiz_module.dart';
import 'package:posture_detector_app/provider/e_learning.dart';
import 'package:posture_detector_app/constants/app_colors.dart';
import 'package:posture_detector_app/l10n/app_localizations.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final QuizModule module;

  const QuizScreen({super.key, required this.module});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late QuizModule module;

  @override
  void initState() {
    super.initState();
    module = widget.module;
    ref.read(eLearningNotifierProvider.notifier).loadRandomQuestions(module.id);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.pop(),
          ),
          title: Text(
            "${AppLocalizations.of(context)!.moduleLabel} ${module.id}",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.border,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            indicatorWeight: 2,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            tabs: [
              Tab(text: AppLocalizations.of(context)!.details),
              Tab(text: AppLocalizations.of(context)!.quiz),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildDetailsTab(context), _buildQuizTab(context)],
        ),
      ),
    );
  }

  Widget _buildDetailsTab(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              module.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.objective,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: module.objectives.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                return _buildBulletPoint(module.objectives[index]);
              },
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.content,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              module.content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizTab(BuildContext context) {
    final randomQuestions = ref.watch(
      eLearningNotifierProvider.select((s) => s.currentQuizQuestions),
    );

    if (randomQuestions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: AppColors.onBoardingSurface,
      child: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          ...randomQuestions.asMap().entries.map((entry) {
            final item = entry.value;
            final idx = entry.key;
            return Padding(
              padding: EdgeInsets.only(bottom: 48.h),
              child: _buildQuizQuestion(idx, item),
            );
          }).toList(),

          const SizedBox(height: 24),

          PrimaryButton(
            text: AppLocalizations.of(context)!.submit,
            backgroundColor: AppColors.primaryColor,
            textColor: AppColors.surface,
            onTap: () async {
              final notifier = ref.read(eLearningNotifierProvider.notifier);
              final selectedAnswers = ref.read(
                eLearningNotifierProvider.select((s) => s.selectedAnswers),
              );

              if (selectedAnswers.length < randomQuestions.length) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${AppLocalizations.of(context)!.incomplete}: ${AppLocalizations.of(context)!.pleaseAnswerAllQuestions}',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              int correctAnswers = 0;
              for (int i = 0; i < randomQuestions.length; i++) {
                if (selectedAnswers[i] == randomQuestions[i].answer) {
                  correctAnswers++;
                }
              }

              await notifier.submitQuiz(
                moduleId: module.id,
                score: correctAnswers,
              );

              if (context.mounted) {
                _showScoreModal(
                  context,
                  score: correctAnswers,
                  total: randomQuestions.length,
                  moduleId: module.id,
                );
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildQuizQuestion(int index, QuizItemModel quiz) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Q${index + 1}. ${quiz.question}',
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
            child: _buildRadioOption(index, optionIndex, option),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRadioOption(int questionIndex, int optionIndex, String option) {
    final isSelected = ref.watch(
      eLearningNotifierProvider.select(
        (s) => s.selectedAnswers[questionIndex] == optionIndex,
      ),
    );

    return InkWell(
      onTap: () {
        ref.read(eLearningNotifierProvider.notifier).selectAnswer(questionIndex, optionIndex);
      },
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primaryColor : Colors.grey,
                width: 2,
              ),
            ),
            child: Center(
              child: isSelected
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryColor,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              option,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? AppColors.primaryColor : Colors.black87,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showScoreModal(
    BuildContext context, {
    required int score,
    required int total,
    required int moduleId,
  }) {
    final passed = score > 3;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (ctx, a1, a2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(a1.value),
          child: Opacity(opacity: a1.value, child: child),
        );
      },
      pageBuilder: (ctx, a1, a2) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 310.w,
            margin: EdgeInsets.symmetric(horizontal: 28.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28.r),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 32.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: passed
                          ? [const Color(0xFF22C55E), const Color(0xFF16A34A)]
                          : [const Color(0xFFFF6B6B), const Color(0xFFEF4444)],
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 56.w,
                        height: 56.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        child: Icon(
                          passed ? Icons.emoji_events_rounded : Icons.replay_rounded,
                          size: 30.sp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        AppLocalizations.of(context)!.yourScore,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$score',
                              style: TextStyle(
                                fontSize: 48.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            TextSpan(
                              text: ' / $total',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.8),
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 28.h),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(total, (i) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 3.w),
                            child: Icon(
                              i < score ? Icons.star_rounded : Icons.star_outline_rounded,
                              size: 28.sp,
                              color: i < score
                                  ? const Color(0xFFFBBF24)
                                  : Colors.grey.withValues(alpha: 0.3),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        passed
                            ? AppLocalizations.of(context)!.wellDone
                            : AppLocalizations.of(context)!.keepTrying,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        passed
                            ? AppLocalizations.of(context)!.youPassedModule(moduleId)
                            : AppLocalizations.of(context)!.needAtLeast4Correct,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.secondaryText,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24.h),
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            ref.read(eLearningNotifierProvider.notifier).clearSelectedAnswers();
                            context.pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: passed
                                ? const Color(0xFF22C55E)
                                : AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            passed
                                ? AppLocalizations.of(context)!.continueButton
                                : AppLocalizations.of(context)!.tryAgain,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(fontSize: 14, height: 1.5)),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
