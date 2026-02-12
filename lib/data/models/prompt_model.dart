import 'package:metal/domain/entities/prompt_dto.dart';

/// Prompt Question Model
/// Maps API response to domain entity
class PromptQuestionModel {
  final String id;
  final String text;

  PromptQuestionModel({
    required this.id,
    required this.text,
  });

  factory PromptQuestionModel.fromJson(Map<String, dynamic> json) {
    return PromptQuestionModel(
      id: json['id'] as String,
      text: json['text'] as String,
    );
  }

  PromptQuestionDto toDto() {
    return PromptQuestionDto(
      id: id,
      text: text,
    );
  }
}

/// User Prompt Model
/// Maps API response to domain entity
class UserPromptModel {
  final String questionId;
  final String questionText;
  final String answer;

  UserPromptModel({
    required this.questionId,
    required this.questionText,
    required this.answer,
  });

  factory UserPromptModel.fromJson(Map<String, dynamic> json) {
    return UserPromptModel(
      questionId: json['questionId'] as String,
      questionText: json['questionText'] as String,
      answer: json['answer'] as String,
    );
  }

  UserPromptDto toDto() {
    return UserPromptDto(
      questionId: questionId,
      questionText: questionText,
      answer: answer,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'answer': answer,
    };
  }
}
