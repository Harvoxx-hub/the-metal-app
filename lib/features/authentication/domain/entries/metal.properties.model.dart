import 'package:json_annotation/json_annotation.dart';

part 'metal.properties.model.g.dart';

@JsonSerializable()
class MetalPropertiesModel {
  List<Metal>? metals;
  List<Passion>? passions;
  List<String>? profession;
  List<String>? education;
  List<String>? country;
  List<String>? ethnicity;
  List<String>? religion;
  List<String>? language;
  List<String>? marriageStatus;
  List<LookingFor>? lookingFor;
  List<String>? demography;

  MetalPropertiesModel({
    this.metals,
    this.passions,
    this.profession,
    this.education,
    this.country,
    this.ethnicity,
    this.religion,
    this.lookingFor,
    this.language,
    this.marriageStatus,
    this.demography,
  });

  factory MetalPropertiesModel.fromJson(Map<String, dynamic> json) =>
      _$MetalPropertiesModelFromJson(json);

  Map<String, dynamic> toJson() => _$MetalPropertiesModelToJson(this);
}

@JsonSerializable()
class Metal {
  String? title;
  String? desc;
  String? img;

  Metal({this.title, this.desc, this.img});

  factory Metal.fromJson(Map<String, dynamic> json) => _$MetalFromJson(json);

  Map<String, dynamic> toJson() => _$MetalToJson(this);
}

@JsonSerializable()
class Passion {
  String? title;
  String? img;

  Passion({this.title, this.img});

  factory Passion.fromJson(Map<String, dynamic> json) =>
      _$PassionFromJson(json);

  Map<String, dynamic> toJson() => _$PassionToJson(this);
}

@JsonSerializable()
class LookingFor {
  String? title;
  String? desc;

  LookingFor({this.title, this.desc});

  factory LookingFor.fromJson(Map<String, dynamic> json) =>
      _$LookingForFromJson(json);

  Map<String, dynamic> toJson() => _$LookingForToJson(this);
}
