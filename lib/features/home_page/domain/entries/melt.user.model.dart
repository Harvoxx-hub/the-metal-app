import 'package:json_annotation/json_annotation.dart';
import 'package:metal/features/authentication/domain/entries/metal.properties.model.dart';

part 'melt.user.model.g.dart';

 

@JsonSerializable(explicitToJson: true)
class MeltUserModel {
  final String? name;
  final String? id;

  final String? gender;

  final Metal? metal;

  MeltUserModel({
    this.id,
    this.gender,
    this.metal,
    this.name,
  });

  factory MeltUserModel.fromJson(Map<String, dynamic> json) =>
      _$MeltUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$MeltUserModelToJson(this);
}
