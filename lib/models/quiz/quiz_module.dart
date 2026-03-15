class QuizModule {
  final int id;
  final String title;
  final List<String> objectives;
  final String content;
  final List<QuizItemModel> quizzes;
  bool unlocked;
  int highestScore;

  QuizModule({
    required this.id,
    required this.title,
    required this.objectives,
    required this.content,
    required this.quizzes,
    this.unlocked = false,
    this.highestScore = 0,
  });
}

class QuizItemModel {
  final String question;
  final List<String> options;
  final int answer;

  QuizItemModel({
    required this.question,
    required this.options,
    required this.answer,
  });
}
