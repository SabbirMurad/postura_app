import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:posture_detector_app/models/quiz/quiz_module.dart';
import 'package:posture_detector_app/services/db/sqlite_service.dart';
import 'package:posture_detector_app/services/network/custom_http.dart';
import 'package:posture_detector_app/services/light_nudges_service.dart';
import 'package:posture_detector_app/view/e_learning/data/e_learning_module_data.dart';

// ─────────────────────────────────────────
// State
// ─────────────────────────────────────────
class ELearningState {
  final List<QuizModule> quizModules;
  final List<QuizItemModel> currentQuizQuestions;
  final Map<int, int> selectedAnswers;
  final String currentLocale;

  const ELearningState({
    this.quizModules = const [],
    this.currentQuizQuestions = const [],
    this.selectedAnswers = const {},
    this.currentLocale = 'en',
  });

  ELearningState copyWith({
    List<QuizModule>? quizModules,
    List<QuizItemModel>? currentQuizQuestions,
    Map<int, int>? selectedAnswers,
    String? currentLocale,
  }) =>
      ELearningState(
        quizModules: quizModules ?? this.quizModules,
        currentQuizQuestions: currentQuizQuestions ?? this.currentQuizQuestions,
        selectedAnswers: selectedAnswers ?? this.selectedAnswers,
        currentLocale: currentLocale ?? this.currentLocale,
      );
}

// ─────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────
class ELearningNotifier extends Notifier<ELearningState> {
  final _random = Random();
  final _sqlite = Sqlite.instance;
  final _nudgesService = LightNudgesService.instance;

  @override
  ELearningState build() {
    final locale = Get.locale?.languageCode ?? 'en';
    final modules = ELearningModuleData.getModules(locale);
    Future.microtask(fetchQuizResults);
    return ELearningState(quizModules: modules, currentLocale: locale);
  }

  void loadModulesForLocale(String locale) {
    if (state.currentLocale == locale && state.quizModules.isNotEmpty) return;

    final scores = <int, int>{};
    final unlocked = <int, bool>{};
    for (final m in state.quizModules) {
      scores[m.id] = m.highestScore;
      unlocked[m.id] = m.unlocked;
    }

    final newModules = ELearningModuleData.getModules(locale);
    for (final m in newModules) {
      if (scores.containsKey(m.id)) m.highestScore = scores[m.id]!;
      if (unlocked.containsKey(m.id)) m.unlocked = unlocked[m.id]!;
    }

    state = state.copyWith(quizModules: newModules, currentLocale: locale);
  }

  void loadRandomQuestions(int moduleId) {
    try {
      final module = state.quizModules.firstWhere((m) => m.id == moduleId);
      final allQuestions = List<QuizItemModel>.from(module.quizzes);
      allQuestions.shuffle(_random);
      state = state.copyWith(
        currentQuizQuestions: allQuestions.take(5).toList(),
        selectedAnswers: {},
      );
      debugPrint('Loaded ${state.currentQuizQuestions.length} random questions for module $moduleId');
    } catch (e) {
      debugPrint('Error loading random questions: ${e.runtimeType}');
    }
  }

  Future<void> fetchQuizResults() async {
    try {
      final response = await CustomHttp.get(
        endpoint: 'elearning/progress',
        needAuth: true,
        showFloatingError: false,
      );

      if (response.ok && response.data != null) {
        final List modules = response.data!['modules'] ?? [];
        debugPrint('Fetched ${modules.length} module results from backend');

        final quizModules = state.quizModules;
        for (final item in modules) {
          try {
            final moduleId = item['module'] as int;
            final score = item['questions_correct'] as int;
            final module = quizModules.firstWhere((m) => m.id == moduleId);
            if (score > module.highestScore) module.highestScore = score;
          } catch (e) {
            debugPrint('Error mapping module: ${e.runtimeType}');
          }
        }

        _updateUnlockStatus(quizModules);
        state = state.copyWith(quizModules: List.from(quizModules));
      } else {
        debugPrint('Failed to fetch progress from backend: ${response.status_code}');
        await _fetchLocalResults();
      }
    } catch (e) {
      debugPrint('Error in fetchQuizResults: ${e.runtimeType}');
      await _fetchLocalResults();
    }
  }

  Future<void> _fetchLocalResults() async {
    try {
      final result = await _sqlite.query(table: 'quiz_result');
      debugPrint('Fallback: Fetched ${result.length} local quiz results');

      final quizModules = state.quizModules;
      for (final item in result) {
        try {
          final moduleId = item['id'];
          final score = item['score'];
          final module = quizModules.firstWhere((m) => m.id == moduleId);
          final s = score is int ? score : 0;
          if (s > module.highestScore) module.highestScore = s;
        } catch (e) {
          debugPrint('Error finding local module: ${e.runtimeType}');
        }
      }

      _updateUnlockStatus(quizModules);
      state = state.copyWith(quizModules: List.from(quizModules));
    } catch (e) {
      debugPrint('Error in _fetchLocalResults: ${e.runtimeType}');
    }
  }

  void _updateUnlockStatus(List<QuizModule> modules) {
    for (int i = 0; i < modules.length; i++) {
      if (i == 0) {
        modules[i].unlocked = true;
      } else if (modules[i - 1].highestScore > 3) {
        modules[i].unlocked = true;
      }
    }
  }

  Future<bool> submitQuiz({required int moduleId, required int score}) async {
    debugPrint('Submitting Quiz - Module ID: $moduleId, Score: $score');

    try {
      final module = state.quizModules.firstWhere((item) => item.id == moduleId);
      if (module.highestScore > 3) {
        debugPrint('Module $moduleId already passed. Skipping submit.');
        await fetchQuizResults();
        return true;
      }
      if (score > module.highestScore) {
        module.highestScore = score;
      }

      await CustomHttp.post(
        endpoint: 'elearning/submit-module',
        body: {
          'module_id': moduleId,
          'questions_answered': 5,
          'questions_correct': score,
        },
        showFloatingError: true,
        needAuth: true,
      );
    } catch (e) {
      debugPrint('Error finding module: ${e.runtimeType}');
    }

    try {
      await _sqlite.delete(
        table: 'quiz_result',
        where: 'id = ?',
        whereArgs: [moduleId],
      );
    } catch (e) {
      debugPrint('Error deleting: ${e.runtimeType}');
    }

    try {
      final module = state.quizModules.firstWhere((item) => item.id == moduleId);
      final createResult = await _sqlite.insert(
        table: 'quiz_result',
        data: {'id': moduleId, 'score': module.highestScore},
      );

      if (moduleId == 1) {
        await _nudgesService.activateNudges();
        debugPrint('Light Nudges V2 activated after Module 1 quiz');
      }

      await fetchQuizResults();
      return createResult;
    } catch (e) {
      debugPrint('Error inserting: ${e.runtimeType}');
      return false;
    }
  }

  void selectAnswer(int questionIndex, int optionIndex) {
    final answers = Map<int, int>.from(state.selectedAnswers);
    answers[questionIndex] = optionIndex;
    state = state.copyWith(selectedAnswers: answers);
    debugPrint('Selected answer for question $questionIndex: option $optionIndex');
  }

  bool isSelected(int questionIndex, int optionIndex) {
    return state.selectedAnswers[questionIndex] == optionIndex;
  }

  int? getSelectedAnswer(int questionIndex) {
    return state.selectedAnswers[questionIndex];
  }

  void clearSelectedAnswers() {
    state = state.copyWith(selectedAnswers: {});
    debugPrint('Cleared all selected answers');
  }

  int getHighestModuleIndex() {
    for (int i = state.quizModules.length - 1; i >= 0; i--) {
      if (state.quizModules[i].highestScore > 0) return i;
    }
    return 0;
  }

  bool isCourseComplete() {
    for (final module in state.quizModules) {
      if (module.highestScore <= 3) return false;
    }
    return true;
  }

  Future<void> checkNudges() async {
    await _nudgesService.checkAndShowNudge(
      courseComplete: isCourseComplete(),
      highestModuleIndex: getHighestModuleIndex(),
    );
  }
}

final eLearningNotifierProvider =
    NotifierProvider<ELearningNotifier, ELearningState>(
  ELearningNotifier.new,
);
