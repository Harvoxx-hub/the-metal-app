import 'package:json_annotation/json_annotation.dart';
import 'package:metal/features/authentication/domain/entries/metal.properties.model.dart';
import 'package:metal/features/upgrade/domain/entries/metal.plan.model.dart';

part 'thought.model.g.dart';

@JsonSerializable(explicitToJson: true)
class ThoughtModel {
  final String? created_at;
  final int? id;
  final String? user;
  final String? thought;
  final UserData? userData;
final List<Reaction>? reactions;

  ThoughtModel({
    this.id,
    this.user,
    this.thought,
    this.created_at,
    this.userData,
    this.reactions,
  });

  factory ThoughtModel.fromJson(Map<String, dynamic> json) =>
      _$ThoughtModelFromJson(json);

  Map<String, dynamic> toJson() => _$ThoughtModelToJson(this);
}

 
@JsonSerializable(explicitToJson: true)
class UserData {
  final Metal? metal;
  final String? fullname;
  final String? username;
  final bool? verification;

  UserData({
    this.metal,
    this.fullname,
    this.username,
    this.verification = false,
  });

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Reaction {
  final List<ReactionUser>? users;
  final String? reaction;

  Reaction({
    this.users,
    this.reaction,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) =>
      _$ReactionFromJson(json);

  Map<String, dynamic> toJson() => _$ReactionToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ReactionUser {
  final String? userId;
  final String? userName;

  ReactionUser({
    this.userId,
    this.userName,
  });

  factory ReactionUser.fromJson(Map<String, dynamic> json) =>
      _$ReactionUserFromJson(json);

  Map<String, dynamic> toJson() => _$ReactionUserToJson(this);
}

