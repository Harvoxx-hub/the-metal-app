import 'package:freezed_annotation/freezed_annotation.dart';

class ThoughtModel {
  final String id;
  final String userId;
  final String content;
  final String createdAt;
  final bool connectionOnly;

  ThoughtModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.connectionOnly = false,
  });

  factory ThoughtModel.fromJson(Map<String, dynamic> json) {
    return ThoughtModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      createdAt: json['createdAt'] as String,
      connectionOnly: json['connectionOnly'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'createdAt': createdAt,
      'connectionOnly': connectionOnly,
    };
  }
}
