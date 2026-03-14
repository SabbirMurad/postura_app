import 'dart:convert';

class QuizAttempt {
  int? id;
  String moduleId;
  int score;
  int totalQuestions;
  bool passed;
  DateTime timestamp;
  Map<String, dynamic>? userAnswers; // Store which questions were correct/wrong

  QuizAttempt({
    this.id,
    required this.moduleId,
    required this.score,
    required this.totalQuestions,
    required this.passed,
    required this.timestamp,
    this.userAnswers,
  });

  double get percentage => (score / totalQuestions) * 100;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'module_id': moduleId,
      'score': score,
      'total_questions': totalQuestions,
      'passed': passed ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
      'user_answers': userAnswers != null ? json.encode(userAnswers) : null,
    };
  }

  factory QuizAttempt.fromMap(Map<String, dynamic> map) {
    return QuizAttempt(
      id: map['id'],
      moduleId: map['module_id'],
      score: map['score'],
      totalQuestions: map['total_questions'],
      passed: map['passed'] == 1,
      timestamp: DateTime.parse(map['timestamp']),
      userAnswers: map['user_answers'] != null
          ? Map<String, dynamic>.from(json.decode(map['user_answers']))
          : null,
    );
  }
}
