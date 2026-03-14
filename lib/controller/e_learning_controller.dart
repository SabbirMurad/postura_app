import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'package:posture_detector_app/data/models/quiz/quiz_module.dart';
import 'package:posture_detector_app/data/services/db/sqlite_service.dart';
import 'package:posture_detector_app/data/services/network/custom_http.dart';
import 'package:posture_detector_app/data/services/light_nudges_service.dart';
import 'package:posture_detector_app/features/e_learning/data/e_learning_module_data.dart';

class ELearningController extends GetxController {
  final selectedAnswers = <int, int>{}.obs;
  final currentQuizQuestions =
      <QuizItemModel>[].obs; // Current quiz questions for this attempt

  // Make quizModules observable — loaded based on locale
  final quizModules = <QuizModule>[].obs;

  String _currentLocale = 'en';

  /// Load modules for the given locale, preserving scores and unlock status
  void loadModulesForLocale(String locale) {
    if (_currentLocale == locale && quizModules.isNotEmpty) return;

    // Save current scores and unlock status
    final scores = <int, int>{};
    final unlocked = <int, bool>{};
    for (final m in quizModules) {
      scores[m.id] = m.highestScore;
      unlocked[m.id] = m.unlocked;
    }

    _currentLocale = locale;
    final newModules = ELearningModuleData.getModules(locale);

    // Restore scores and unlock status
    for (final m in newModules) {
      if (scores.containsKey(m.id)) {
        m.highestScore = scores[m.id]!;
      }
      if (unlocked.containsKey(m.id)) {
        m.unlocked = unlocked[m.id]!;
      }
    }

    quizModules.assignAll(newModules);
  }

  Sqlite sqlite = Sqlite.instance;
  final Random _random = Random();
  final LightNudgesService _nudgesService = LightNudgesService.instance;

  @override
  void onInit() {
    super.onInit();
    final locale = Get.locale?.languageCode ?? 'en';
    loadModulesForLocale(locale);
    fetchQuizResults();
  }

  // Function to get random 5 questions from a module
  void loadRandomQuestions(int moduleId) {
    try {
      final module = quizModules.firstWhere((m) => m.id == moduleId);
      final allQuestions = List<QuizItemModel>.from(module.quizzes);

      // Shuffle and take first 5
      allQuestions.shuffle(_random);
      currentQuizQuestions.assignAll(allQuestions.take(5).toList());

      clearSelectedAnswers();
      debugPrint(
        'Loaded ${currentQuizQuestions.length} random questions for module $moduleId',
      );
    } catch (e) {
      debugPrint('Error loading random questions: ${e.runtimeType}');
    }
  }

  fetchQuizResults() async {
    try {
      final response = await CustomHttp.get(
        endpoint: 'elearning/progress',
        needAuth: true,
        showFloatingError: false,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final List modules = data['modules'] ?? [];

        debugPrint('Fetched ${modules.length} module results from backend');

        for (final item in modules) {
          try {
            final moduleId = item['module'] as int;
            final score = item['questions_correct'] as int;

            final module = quizModules.firstWhere(
              (element) => element.id == moduleId,
            );
            if (score > module.highestScore) {
              module.highestScore = score;
            }
            debugPrint('Updated Module $moduleId with score: ${module.highestScore}');
          } catch (e) {
            debugPrint('Error mapping module: ${e.runtimeType}');
          }
        }
      } else {
        debugPrint('Failed to fetch progress from backend: ${response.statusCode}');
        // Fallback to local SQLite
        await _fetchLocalResults();
      }

      // Update unlock status (once unlocked, never re-lock)
      for (int i = 0; i < quizModules.length; i++) {
        if (i == 0) {
          quizModules[i].unlocked = true;
        } else {
          if (quizModules[i - 1].highestScore > 3) {
            quizModules[i].unlocked = true;
          }
        }
      }

      quizModules.refresh();
    } catch (e) {
      debugPrint('Error in fetchQuizResults: ${e.runtimeType}');
      // Fallback to local SQLite on network error
      await _fetchLocalResults();
      quizModules.refresh();
    }
  }

  /// Fallback: load results from local SQLite if backend is unavailable
  Future<void> _fetchLocalResults() async {
    try {
      final result = await sqlite.query(table: 'quiz_result');
      debugPrint('Fallback: Fetched ${result.length} local quiz results');

      for (final item in result) {
        try {
          final moduleId = item['id'];
          final score = item['score'];
          final module = quizModules.firstWhere(
            (element) => element.id == moduleId,
          );
          final s = score is int ? score : 0;
          if (s > module.highestScore) {
            module.highestScore = s;
          }
        } catch (e) {
          debugPrint('Error finding local module: ${e.runtimeType}');
        }
      }

      for (int i = 0; i < quizModules.length; i++) {
        if (i == 0) {
          quizModules[i].unlocked = true;
        } else {
          if (quizModules[i - 1].highestScore > 3) {
            quizModules[i].unlocked = true;
          }
        }
      }
    } catch (e) {
      debugPrint('Error in _fetchLocalResults: ${e.runtimeType}');
    }
  }

  Future<bool> submitQuiz({required int moduleId, required int score}) async {
    debugPrint('Submitting Quiz - Module ID: $moduleId, Score: $score');

    try {
      final module = quizModules.firstWhere((item) => item.id == moduleId);

      // Already passed — skip backend call and local save
      if (module.highestScore > 3) {
        debugPrint('Module $moduleId already passed (score: ${module.highestScore}). Skipping submit.');
        await fetchQuizResults();
        return true;
      }

      if (score > module.highestScore) {
        module.highestScore = score;
        debugPrint('Updated highest score to: $score');
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
      await sqlite.delete(
        table: 'quiz_result',
        where: 'id = ?',
        whereArgs: [moduleId],
      );
      debugPrint('Deleted old quiz result for module $moduleId');
    } catch (e) {
      debugPrint('Error deleting: ${e.runtimeType}');
    }

    try {
      final module = quizModules.firstWhere((item) => item.id == moduleId);
      final createResult = await sqlite.insert(
        table: 'quiz_result',
        data: {'id': moduleId, 'score': module.highestScore},
      );
      debugPrint('Inserted new quiz result for module $moduleId');

      // LIGHT NUDGES V2: Activate nudges after Module 1 quiz completion
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
    selectedAnswers[questionIndex] = optionIndex;
    debugPrint('Selected answer for question $questionIndex: option $optionIndex');
  }

  bool isSelected(int questionIndex, int optionIndex) {
    return selectedAnswers[questionIndex] == optionIndex;
  }

  int? getSelectedAnswer(int questionIndex) {
    return selectedAnswers[questionIndex];
  }

  void clearSelectedAnswers() {
    selectedAnswers.clear();
    debugPrint('Cleared all selected answers');
  }

  /// Get the highest module index that user has started (0-6)
  /// Returns 0 if only Module 1 has been started
  int getHighestModuleIndex() {
    for (int i = quizModules.length - 1; i >= 0; i--) {
      if (quizModules[i].highestScore > 0) {
        return i; // Module index 0-6
      }
    }
    return 0; // Default to Module 1 if nothing completed
  }

  /// Check if course is complete (all modules passed with score > 3)
  bool isCourseComplete() {
    for (final module in quizModules) {
      if (module.highestScore <= 3) {
        return false;
      }
    }
    return true;
  }

  /// Trigger nudge check (call this when app comes to foreground or dashboard is shown)
  Future<void> checkNudges() async {
    final courseComplete = isCourseComplete();
    final highestModuleIndex = getHighestModuleIndex();

    await _nudgesService.checkAndShowNudge(
      courseComplete: courseComplete,
      highestModuleIndex: highestModuleIndex,
    );
  }
}
