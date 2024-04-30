import 'package:json_annotation/json_annotation.dart';
import 'package:metal/features/authentication/domain/entries/metal.properties.model.dart';

part 'all.user.model.g.dart';

@JsonSerializable(explicitToJson: true)
class ALLUserModel {
  final String? distance;
  final String? description;
  final String? username;
  final String? id;
  final String? age_range;
  final String? gender;
  final List<String>? passion;
  final List<String>? connection_option;
  final Metal? metal;
  final bool verfied;
  final String? phone;
  late final bool liked;
  final bool pushedMe;

  ALLUserModel({
    this.phone,
    this.distance,
    this.description,
    this.username,
    this.id,
    this.age_range,
    this.gender,
    this.passion,
    this.connection_option,
    this.metal,
    this.verfied = false,
    this.liked = false,
    this.pushedMe = false,
  });

  factory ALLUserModel.fromJson(Map<String, dynamic> json) =>
      _$ALLUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$ALLUserModelToJson(this);
}
