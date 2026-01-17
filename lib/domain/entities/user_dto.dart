import 'package:metal/data/models/user_extra_data_model.dart';
import 'package:metal/data/models/user_location_model.dart';
import 'package:metal/data/models/user_preferences_model.dart';
import 'package:metal/domain/entities/base_entity.dart';

/// User domain entity (DTO)
/// This represents the user in the domain layer
class UserDto extends BaseEntity {
  final String id;
  final String email;
  final String? username;
  final String? fullname;
  final String? phone;
  final String? dob;
  final String? gender;
  final String? bio;
  final String? profilePhoto;
  final String? fcmToken;
  final bool isVerified;
  final bool isActivated;
  final bool? emailVerified;
  final bool? workEmailVerified;
  final bool? profileUpdated;
  final bool? completedProfile;
  final String? metal;
  final List<String>? passion;
  final String? connectWith;
  final List<String>? connectionOption;
  final String? distance;
  final bool? enableDistanceFilter;
  final bool? showOnline;
  final bool? alwaysMetal;
  final bool? receiveNotification;
  final bool? showMyProfile;
  final UserLocationModel? location;
  final UserPreferencesModel? preferences;
  final UserExtraDataModel? extraData;
  final String? createdAt;
  final String? updatedAt;
  // Connection status fields (when viewing other users)
  final bool? isConnected;
  final String? connectionId;
  final String? connectedOn;

  const UserDto({
    required this.id,
    required this.email,
    this.username,
    this.fullname,
    this.phone,
    this.dob,
    this.gender,
    this.bio,
    this.profilePhoto,
    this.fcmToken,
    this.isVerified = false,
    this.isActivated = false,
    this.emailVerified,
    this.workEmailVerified,
    this.profileUpdated,
    this.completedProfile,
    this.metal,
    this.passion,
    this.connectWith,
    this.connectionOption,
    this.distance,
    this.enableDistanceFilter,
    this.showOnline,
    this.alwaysMetal,
    this.receiveNotification,
    this.showMyProfile,
    this.location,
    this.preferences,
    this.extraData,
    this.createdAt,
    this.updatedAt,
    this.isConnected,
    this.connectionId,
    this.connectedOn,
  });

  UserDto copyWith({
    String? id,
    String? email,
    String? username,
    String? fullname,
    String? phone,
    String? dob,
    String? gender,
    String? bio,
    String? profilePhoto,
    String? fcmToken,
    bool? isVerified,
    bool? isActivated,
    bool? emailVerified,
    bool? workEmailVerified,
    bool? profileUpdated,
    bool? completedProfile,
    String? metal,
    List<String>? passion,
    String? connectWith,
    List<String>? connectionOption,
    String? distance,
    bool? enableDistanceFilter,
    bool? showOnline,
    bool? alwaysMetal,
    bool? receiveNotification,
    bool? showMyProfile,
    UserLocationModel? location,
    UserPreferencesModel? preferences,
    UserExtraDataModel? extraData,
    String? createdAt,
    String? updatedAt,
    bool? isConnected,
    String? connectionId,
    String? connectedOn,
  }) {
    return UserDto(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullname: fullname ?? this.fullname,
      phone: phone ?? this.phone,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      fcmToken: fcmToken ?? this.fcmToken,
      isVerified: isVerified ?? this.isVerified,
      isActivated: isActivated ?? this.isActivated,
      emailVerified: emailVerified ?? this.emailVerified,
      workEmailVerified: workEmailVerified ?? this.workEmailVerified,
      profileUpdated: profileUpdated ?? this.profileUpdated,
      completedProfile: completedProfile ?? this.completedProfile,
      metal: metal ?? this.metal,
      passion: passion ?? this.passion,
      connectWith: connectWith ?? this.connectWith,
      connectionOption: connectionOption ?? this.connectionOption,
      distance: distance ?? this.distance,
      enableDistanceFilter: enableDistanceFilter ?? this.enableDistanceFilter,
      showOnline: showOnline ?? this.showOnline,
      alwaysMetal: alwaysMetal ?? this.alwaysMetal,
      receiveNotification: receiveNotification ?? this.receiveNotification,
      showMyProfile: showMyProfile ?? this.showMyProfile,
      location: location ?? this.location,
      preferences: preferences ?? this.preferences,
      extraData: extraData ?? this.extraData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isConnected: isConnected ?? this.isConnected,
      connectionId: connectionId ?? this.connectionId,
      connectedOn: connectedOn ?? this.connectedOn,
    );
  }
}

/// Login response DTO
class LoginResponseDto extends BaseEntity {
  final String token;
  final UserDto user;
  final int expiresIn;
  final String? refreshToken;

  const LoginResponseDto({
    required this.token,
    required this.user,
    required this.expiresIn,
    this.refreshToken,
  });
}
