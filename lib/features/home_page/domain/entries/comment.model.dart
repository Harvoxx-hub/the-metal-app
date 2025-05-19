import 'package:json_annotation/json_annotation.dart';

part 'comment.model.g.dart';

@JsonSerializable(explicitToJson: true)
class CommentModel {
  final String id;
  final String userId;
  final String thoughtId;
  final String content;
  final String createdAt;
  final List<ReactionModel> reactions;

  CommentModel({
    required this.id,
    required this.userId,
    required this.thoughtId,
    required this.content,
    required this.createdAt,
    this.reactions = const [],
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommentModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ReactionModel {
  final String userId;
  final String emoji;

  ReactionModel({
    required this.userId,
    required this.emoji,
  });

  factory ReactionModel.fromJson(Map<String, dynamic> json) =>
      _$ReactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReactionModelToJson(this);
}
