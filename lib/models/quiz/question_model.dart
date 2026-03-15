import 'dart:convert';

class QuestionModel {
  int? id;
  String moduleId;
  String questionText;
  List<String> options;
  int correctAnswerIndex;
  String explanation;

  QuestionModel({
    this.id,
    required this.moduleId,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'module_id': moduleId,
      'question_text': questionText,
      'options': json.encode(options),
      'correct_answer_index': correctAnswerIndex,
      'explanation': explanation,
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'],
      moduleId: map['module_id'],
      questionText: map['question_text'],
      options: List<String>.from(json.decode(map['options'])),
      correctAnswerIndex: map['correct_answer_index'],
      explanation: map['explanation'],
    );
  }
}