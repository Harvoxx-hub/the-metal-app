import 'package:json_annotation/json_annotation.dart';

part 'reaction.model.g.dart';

@JsonSerializable(explicitToJson: true)
class ReactionModel {
  final String id;
  final String userId;
  final String thoughtId;
  final String emoji;
  final String createdAt;

  ReactionModel({
    required this.id,
    required this.userId,
    required this.thoughtId,
    required this.emoji,
    required this.createdAt,
  });

  factory ReactionModel.fromJson(Map<String, dynamic> json) =>
      _$ReactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReactionModelToJson(this);

  ReactionModel copyWith({
    String? id,
    String? userId,
    String? thoughtId,
    String? emoji,
    String? createdAt,
  }) {
    return ReactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      thoughtId: thoughtId ?? this.thoughtId,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
