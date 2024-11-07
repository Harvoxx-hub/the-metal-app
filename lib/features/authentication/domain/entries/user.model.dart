import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:metal/features/authentication/domain/entries/metal.properties.model.dart';
import 'package:metal/features/upgrade/domain/entries/subscribed.plan.model.dart';

part 'user.model.freezed.dart';
part 'user.model.g.dart';

@freezed
class UserModel with _$UserModel {
  factory UserModel({
    @JsonKey(name: 'profile_updated') bool? profileUpdated,
    @JsonKey(name: 'completed_profile') bool? completedProfile,
    @JsonKey(name: 'DOB') String? dob,
    Address? address,
    @JsonKey(name: 'connect_with') String? connectWith,
    @JsonKey(name: 'connection_option') List<String>? connectionOption,
    String? description,
    @JsonKey(name: 'extra_data') ExtraData? extraData,
    String? fullname,
    String? gender,
    @JsonKey(name: 'isVerified') bool? isVerified,
    @JsonKey(name: 'isActivated') bool? isActivated,
    Location? location,
    Metal? metal,
    List<String>? passion,
    String? phone,
    String? email,
    @JsonKey(name: 'email_verified') bool? emailVerified,
    Preferences? preferences,
    String? username,
    @JsonKey(name: 'access_token') String? accessToken,
    String? refreshToken,
    SubscribedPlanModel? subscription,
    double? sparkBalance,
    String? distance,
    String? id,
    String? referralCode,
    String? profilePhoto,
    String? fcmToken,
    String? conversationId,
    @JsonKey(name: 'blockedUsers') List<BlockedUser>? blockedUsers,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

@freezed
class Address with _$Address {
  factory Address({
    @JsonKey(name: 'apartment_number') String? apartmentNumber,
    @JsonKey(name: 'house_number') String? houseNumber,
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
    @JsonKey(name: 'marital_status') String? maritalStatus,
    String? profession,
    String? religion,
  }) = _ExtraData;

  factory ExtraData.fromJson(Map<String, dynamic> json) =>
      _$ExtraDataFromJson(json);
}

@freezed
class Preferences with _$Preferences {
  factory Preferences({
    @JsonKey(name: 'age_range') String? ageRange,
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

@freezed
class BlockedUser with _$BlockedUser {
  factory BlockedUser({
    String? id,
    Metal? metal,
    String? name,
  }) = _BlockedUser;

  factory BlockedUser.fromJson(Map<String, dynamic> json) =>
      _$BlockedUserFromJson(json);
}
