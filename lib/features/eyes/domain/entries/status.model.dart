import 'package:json_annotation/json_annotation.dart';
import 'package:metal/features/authentication/domain/entries/metal.properties.model.dart';

part 'status.model.g.dart';

@JsonSerializable(explicitToJson: true)
class StatusModel {
  String? file;
  String? text;
  int? id;
  List? views;
  int? postedAt;
  bool? isActive;

  StatusModel({
    this.file,
    this.text,
    this.id,
    this.views,
    this.isActive,
  });

  factory StatusModel.fromJson(Map<String, dynamic> json) =>
      _$StatusModelFromJson(json);

  Map<String, dynamic> toJson() => _$StatusModelToJson(this);
}

@JsonSerializable()
class StatusData {
  final List<StatusModel> status;
  final String username;
  final Metal metal;

  StatusData({
    required this.status,
    required this.username,
    required this.metal,
  });

  factory StatusData.fromJson(Map<String, dynamic> json) =>
      _$StatusDataFromJson(json);
  Map<String, dynamic> toJson() => _$StatusDataToJson(this);
}
