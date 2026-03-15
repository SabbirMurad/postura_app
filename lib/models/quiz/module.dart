class Module {
  int? id;
  String moduleId;
  String title;
  String description;
  int score;
  bool isCompleted;
  bool isUnlocked;
  DateTime? lastAttempt;
  int totalQuestions;
  int attempts;

  Module({
    this.id,
    required this.moduleId,
    required this.title,
    required this.description,
    this.score = 0,
    this.isCompleted = false,
    this.isUnlocked = false,
    this.lastAttempt,
    this.totalQuestions = 5,
    this.attempts = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'module_id': moduleId,
      'title': title,
      'description': description,
      'score': score,
      'is_completed': isCompleted ? 1 : 0,
      'is_unlocked': isUnlocked ? 1 : 0,
      'last_attempt': lastAttempt?.toIso8601String(),
      'total_questions': totalQuestions,
      'attempts': attempts,
    };
  }

  factory Module.fromMap(Map<String, dynamic> map) {
    return Module(
      id: map['id'],
      moduleId: map['module_id'],
      title: map['title'],
      description: map['description'],
      score: map['score'],
      isCompleted: map['is_completed'] == 1,
      isUnlocked: map['is_unlocked'] == 1,
      lastAttempt: map['last_attempt'] != null
          ? DateTime.parse(map['last_attempt'])
          : null,
      totalQuestions: map['total_questions'] ?? 5,
      attempts: map['attempts'] ?? 0,
    );
  }
}
