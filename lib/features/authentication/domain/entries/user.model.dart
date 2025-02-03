import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:metal/features/authentication/domain/entries/metal.properties.model.dart';
import 'package:metal/features/upgrade/domain/entries/subscribed.plan.model.dart';

part 'user.model.freezed.dart';
part 'user.model.g.dart';

@freezed
class UserModel with _$UserModel {
  @JsonSerializable(explicitToJson: true)
  factory UserModel({
    bool? profileUpdated,
    bool? completedProfile,
    String? dob,
    Address? address,
    @JsonKey(name: 'connectWith') String? connectWith,
    @JsonKey(name: 'connectionOption') List<String>? connectionOption,
    String? description,
    @JsonKey(name: 'extraData') ExtraData? extraData,
    String? fullname,
    String? gender,
    bool? isVerified,
    bool? isActivated,
    Location? location,
    String? metal,
    List<String>? passion,
    String? phone,
    String? email,
    bool? emailVerified,
    Preferences? preferences,
    String? username,
    String? refreshToken,
    SubscribedPlanModel? subscription,
    @Default(0) double sparkBalance,
    String? distance,
    String? id,
    String? referralCode,
    String? referredBy,
    @Default(true) bool showOnline,
    @Default(true) bool alwaysMetal,
    @Default(true) bool receiveNotification,
    @Default(true) bool showMyProfile,
    @Default(true) bool activateVoiceNote,
    @Default(true) bool activateVoiceCall,
    @Default(true) bool activateVideoCall,
    String? profilePhoto,
    String? fcmToken,
    @Default(true) bool isOnline,
    String? lastActive,
    @JsonKey(name: 'blockedUsers') List<String>? blockedUsers,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

@freezed
class Address with _$Address {
  factory Address({
    @JsonKey(name: 'apartmentNumber') String? apartmentNumber,
    @JsonKey(name: 'houseNumber') String? houseNumber,
    @JsonKey(name: 'streetName') String? streetName,
    @JsonKey(name: 'postalCode') String? postalCode,
    String? state,
    String? country,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
}

@freezed
class ExtraData with _$ExtraData {
  factory ExtraData({
    String? country,
    String? education,
    String? ethnicity,
    String? language,
    @JsonKey(name: 'maritalStatus') String? maritalStatus,
    String? profession,
    String? religion,
  }) = _ExtraData;

  factory ExtraData.fromJson(Map<String, dynamic> json) =>
      _$ExtraDataFromJson(json);
}

@freezed
class Preferences with _$Preferences {
  factory Preferences({
    @JsonKey(name: 'ageRange') String? ageRange,
    String? demography,
    String? education,
    String? ethnicity,
    String? religion,
  }) = _Preferences;

  factory Preferences.fromJson(Map<String, dynamic> json) =>
      _$PreferencesFromJson(json);
}

@freezed
class Location with _$Location {
  factory Location({
    double? lat,
    double? lng,
    String? address,
  }) = _Location;

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
}
