import 'package:freezed_annotation/freezed_annotation.dart';

part 'thought.model.freezed.dart';
part 'thought.model.g.dart';

@freezed
class ThoughtModel with _$ThoughtModel {
  factory ThoughtModel({
    required String id, // Unique ID for the thought
    required String userId, // The user who posted the thought
    required String content, // The text content of the thought
    required String createdAt, // Timestamp of when the thought was created
    @Default(false)
    bool connectionOnly, // Whether the thought is visible only to connections
    @Default([])
    List<ReactionModel> reactions, // List of reactions on the thought
  }) = _ThoughtModel;

  factory ThoughtModel.fromJson(Map<String, dynamic> json) =>
      _$ThoughtModelFromJson(json);
}

@freezed
class ReactionModel with _$ReactionModel {
  factory ReactionModel({
    required String userId, // ID of the user reacting
    required String emoji, // Emoji used for the reaction
  }) = _ReactionModel;

  factory ReactionModel.fromJson(Map<String, dynamic> json) =>
      _$ReactionModelFromJson(json);
}
