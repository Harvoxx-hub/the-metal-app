import 'package:json_annotation/json_annotation.dart';
import 'package:metal/features/authentication/domain/entries/metal.properties.model.dart';

part 'melt.user.model.g.dart';

@JsonSerializable(explicitToJson: true)
class MeltUserModel {
  final String? name;
  final String? id;

  final String? gender;
  final String? username;
  final String? fcmToken;
  final String? conversationId;
  final String? meltedDate;

  final Metal? metal;
  final String? phone;

  MeltUserModel(
      {this.id,
      this.meltedDate,
      this.gender,
      this.metal,
      this.phone,
      this.name,
      this.conversationId,
      this.username,
      this.fcmToken});

  factory MeltUserModel.fromJson(Map<String, dynamic> json) =>
      _$MeltUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$MeltUserModelToJson(this);
}
