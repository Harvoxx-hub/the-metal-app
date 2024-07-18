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

  ThoughtModel({
    this.id,
    this.user,
    this.thought,
    this.created_at,
    this.userData,
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

  UserData({
    this.metal,
    this.fullname,
    this.username,
  });

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}
