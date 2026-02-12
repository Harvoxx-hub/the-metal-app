import 'package:metal/domain/entities/base_entity.dart';

/// Prompt Question DTO
/// Represents an available prompt question that users can select
class PromptQuestionDto extends BaseEntity {
  final String id;
  final String text;

  const PromptQuestionDto({
    required this.id,
    required this.text,
  });

  factory PromptQuestionDto.fromJson(Map<String, dynamic> json) {
    return PromptQuestionDto(
      id: json['id'] as String,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
    };
  }
}

/// User Prompt DTO
/// Represents a user's selected question with their answer
class UserPromptDto extends BaseEntity {
  final String questionId;
  final String questionText;
  final String answer;

  const UserPromptDto({
    required this.questionId,
    required this.questionText,
    required this.answer,
  });

  factory UserPromptDto.fromJson(Map<String, dynamic> json) {
    return UserPromptDto(
      questionId: json['questionId'] as String,
      questionText: json['questionText'] as String,
      answer: json['answer'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'answer': answer,
    };
  }

  UserPromptDto copyWith({
    String? questionId,
    String? questionText,
    String? answer,
  }) {
    return UserPromptDto(
      questionId: questionId ?? this.questionId,
      questionText: questionText ?? this.questionText,
      answer: answer ?? this.answer,
    );
  }
}
