import 'package:json_annotation/json_annotation.dart';
import 'package:metal/features/authentication/domain/entries/metal.properties.model.dart';
import 'package:metal/features/upgrade/domain/entries/metal.plan.model.dart';
import 'package:metal/features/upgrade/domain/entries/subscribed.plan.model.dart';

part 'user.model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel {
  bool? profile_updated;
  bool completed_profile;
  String? DOB;
  Address? address;
  String? connect_with;
  List<String>? connection_option;
  String? description;
  ExtraData? extra_data;
  String? fullname;
  String? gender;
  bool? isVerified;
  Location? location;
  Metal? metal;
  List<String>? passion;
  String? phone;
  String? email;
  Preferences? preferences;
  String? username;
  String? access_token;
  String? refresh_token;
  SubscribedPlanModel? subscription;
  double sparkBalance;
  String distance;
  String? id;

  UserModel(
      {this.profile_updated,
      this.DOB,
      this.address,
      this.connect_with,
      this.connection_option,
      this.description,
      this.extra_data,
      this.fullname,
      this.gender,
      this.isVerified,
      this.location,
      this.metal,
      this.passion,
      this.phone,
      this.preferences,
      this.email,
      this.username,
      this.access_token,
      this.refresh_token,
      this.subscription,
      this.distance = '4.0',
      this.sparkBalance = 0.0,
      this.id,
      this.completed_profile = false});

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

@JsonSerializable()
class Address {
  String? house_address;

  String? town;
  String? state;
  String? country;

  Address({
    this.house_address,
    this.town,
    this.state,
    this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);

  Map<String, dynamic> toJson() => _$AddressToJson(this);
}

@JsonSerializable()
class ExtraData {
  String? country;
  String? education;
  String? ethnicity;
  String? marital_status;
  String? profession;
  String? religion;
  String? language;

  ExtraData({
    this.country,
    this.education,
    this.ethnicity,
    this.marital_status,
    this.profession,
    this.religion,
    this.language,
  });

  factory ExtraData.fromJson(Map<String, dynamic> json) =>
      _$ExtraDataFromJson(json);

  Map<String, dynamic> toJson() => _$ExtraDataToJson(this);
}

@JsonSerializable()
class Preferences {
  String? age_range;
  String? demography;
  String? education;
  String? ethnicity;
  String? religion;

  Preferences({
    this.age_range,
    this.demography,
    this.education,
    this.ethnicity,
    this.religion,
  });

  factory Preferences.fromJson(Map<String, dynamic> json) =>
      _$PreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$PreferencesToJson(this);
}

@JsonSerializable()
class Location {
  double? lat;
  double? lng;
  String? address;

  Location({this.lat, this.lng, this.address});

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);
}
