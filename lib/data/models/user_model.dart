import 'package:metal/domain/entities/user_dto.dart';
import 'package:metal/data/models/user_address_model.dart';
import 'package:metal/data/models/user_location_model.dart';
import 'package:metal/data/models/user_preferences_model.dart';
import 'package:metal/data/models/user_extra_data_model.dart';
import 'package:metal/data/models/user_subscription_model.dart';

/// User data model (API response)
/// Maps API response to domain entity
class UserModel {
  final String id;
  final String email;
  final String? username;
  final String? fullname;
  final String? phone;
  final String? dob;
  final String? gender;
  final String? bio;
  final String? description;
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
  final UserAddressModel? address;
  final UserLocationModel? location;
  final UserPreferencesModel? preferences;
  final UserExtraDataModel? extraData;
  final UserSubscriptionModel? subscription;
  final String? createdAt;
  final String? updatedAt;
  // Connection status fields (when viewing other users)
  final bool? isConnected;
  final String? connectionId;
  final String? connectedOn;
  final String? connectionStatus;
  // Melt status fields
  final String?
      meltStatus; // 'connected', 'pending_outgoing', 'pending_incoming', 'none', 'mutual'
  final String? meltRequestId;
  final String? meltRequestCreatedAt;
  // Anonymous and unmelt fields
  final bool? isAnonymous;
  final bool? canUnmelt;
  final String? initiatorId;
  final String? receiverId;

  UserModel({
    required this.id,
    required this.email,
    this.username,
    this.fullname,
    this.phone,
    this.dob,
    this.gender,
    this.bio,
    this.description,
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
    this.address,
    this.location,
    this.preferences,
    this.extraData,
    this.subscription,
    this.createdAt,
    this.updatedAt,
    this.isConnected,
    this.connectionId,
    this.connectedOn,
    this.connectionStatus,
    this.meltStatus,
    this.meltRequestId,
    this.meltRequestCreatedAt,
    this.isAnonymous,
    this.canUnmelt,
    this.initiatorId,
    this.receiverId,
  });

  /// Create from API JSON response
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String?,
      fullname: json['fullname'] as String?,
      phone: json['phone'] as String?,
      dob: json['dob'] as String?,
      gender: json['gender'] as String?,
      bio: json['bio'] as String?,
      description: json['description'] as String?,
      profilePhoto: json['profilePhoto'] as String?,
      fcmToken: json['fcmToken'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      isActivated: json['isActivated'] as bool? ?? false,
      emailVerified: json['emailVerified'] as bool?,
      workEmailVerified: json['workEmailVerified'] as bool?,
      profileUpdated: json['profileUpdated'] as bool?,
      completedProfile: json['completedProfile'] as bool?,
      metal: json['metal'] as String?,
      passion: json['passion'] != null
          ? (json['passion'] is List
              ? (json['passion'] as List).map((e) => e.toString()).toList()
              : json['passion']
                  .toString()
                  .split(',')
                  .where((e) => e.isNotEmpty)
                  .toList())
          : null,
      connectWith: json['connectWith'] as String?,
      connectionOption: json['connectionOption'] != null
          ? (json['connectionOption'] is List
              ? (json['connectionOption'] as List)
                  .map((e) => e.toString())
                  .toList()
              : json['connectionOption']
                  .toString()
                  .split(',')
                  .where((e) => e.isNotEmpty)
                  .toList())
          : null,
      distance: json['distance'] as String?,
      enableDistanceFilter: json['enableDistanceFilter'] as bool?,
      showOnline: json['showOnline'] as bool?,
      alwaysMetal: json['alwaysMetal'] as bool?,
      receiveNotification: json['receiveNotification'] as bool?,
      showMyProfile: json['showMyProfile'] as bool?,
      address: json['address'] != null
          ? UserAddressModel.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      location: json['location'] != null
          ? UserLocationModel.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      preferences: json['preferences'] != null
          ? UserPreferencesModel.fromJson(
              json['preferences'] as Map<String, dynamic>)
          : null,
      extraData: json['extraData'] != null
          ? UserExtraDataModel.fromJson(
              json['extraData'] as Map<String, dynamic>)
          : null,
      subscription: json['subscription'] != null
          ? UserSubscriptionModel.fromJson(
              json['subscription'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      isConnected: json['isConnected'] as bool?,
      connectionId: json['connectionId'] as String?,
      connectedOn: json['connectedOn'] as String?,
      connectionStatus: json['connectionStatus'] as String?,
      meltStatus: json['meltStatus'] as String?,
      meltRequestId: json['meltRequestId'] as String?,
      meltRequestCreatedAt: json['meltRequestCreatedAt'] as String?,
      isAnonymous: json['isAnonymous'] as bool?,
      canUnmelt: json['canUnmelt'] as bool?,
      initiatorId: json['initiatorId'] as String?,
      receiverId: json['receiverId'] as String?,
    );
  }

  /// Convert to domain entity
  UserDto toDomain() {
    return UserDto(
      id: id,
      email: email,
      username: username,
      fullname: fullname,
      phone: phone,
      dob: dob,
      gender: gender,
      bio: bio ?? description,
      profilePhoto: profilePhoto,
      fcmToken: fcmToken,
      isVerified: isVerified,
      isActivated: isActivated,
      emailVerified: emailVerified,
      workEmailVerified: workEmailVerified,
      profileUpdated: profileUpdated ?? completedProfile,
      completedProfile: completedProfile,
      metal: metal,
      passion: passion,
      connectWith: connectWith,
      connectionOption: connectionOption,
      distance: distance,
      enableDistanceFilter: enableDistanceFilter,
      showOnline: showOnline,
      alwaysMetal: alwaysMetal,
      receiveNotification: receiveNotification,
      showMyProfile: showMyProfile,
      location: location,
      preferences: preferences,
      extraData: extraData,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isConnected: isConnected,
      connectionId: connectionId,
      connectedOn: connectedOn,
      connectionStatus: connectionStatus,
      meltStatus: meltStatus,
      meltRequestId: meltRequestId,
      meltRequestCreatedAt: meltRequestCreatedAt,
      isAnonymous: isAnonymous,
      canUnmelt: canUnmelt,
      initiatorId: initiatorId,
      receiverId: receiverId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (username != null) 'username': username,
      if (fullname != null) 'fullname': fullname,
      if (phone != null) 'phone': phone,
      if (dob != null) 'dob': dob,
      if (gender != null) 'gender': gender,
      if (description != null) 'description': description,
      if (profilePhoto != null) 'profilePhoto': profilePhoto,
      if (fcmToken != null) 'fcmToken': fcmToken,
      'isVerified': isVerified,
      'isActivated': isActivated,
      if (emailVerified != null) 'emailVerified': emailVerified,
      if (profileUpdated != null) 'profileUpdated': profileUpdated,
      if (completedProfile != null) 'completedProfile': completedProfile,
      if (metal != null) 'metal': metal,
      if (passion != null) 'passion': passion,
      if (connectWith != null) 'connectWith': connectWith,
      if (connectionOption != null) 'connectionOption': connectionOption,
      if (address != null) 'address': address!.toJson(),
      if (location != null) 'location': location!.toJson(),
      if (preferences != null) 'preferences': preferences!.toJson(),
      if (extraData != null) 'extraData': extraData!.toJson(),
      if (subscription != null) 'subscription': subscription!.toJson(),
      if (isConnected != null) 'isConnected': isConnected,
      if (connectionId != null) 'connectionId': connectionId,
      if (connectedOn != null) 'connectedOn': connectedOn,
      if (connectionStatus != null) 'connectionStatus': connectionStatus,
      if (meltStatus != null) 'meltStatus': meltStatus,
      if (meltRequestId != null) 'meltRequestId': meltRequestId,
      if (meltRequestCreatedAt != null)
        'meltRequestCreatedAt': meltRequestCreatedAt,
      if (isAnonymous != null) 'isAnonymous': isAnonymous,
      if (canUnmelt != null) 'canUnmelt': canUnmelt,
      if (initiatorId != null) 'initiatorId': initiatorId,
      if (receiverId != null) 'receiverId': receiverId,
    };
  }
}

/// Login response model from API
class LoginResponseModel {
  final String token;
  final Map<String, dynamic> user;
  final int expiresIn;
  final String? refreshToken;

  LoginResponseModel({
    required this.token,
    required this.user,
    required this.expiresIn,
    this.refreshToken,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return LoginResponseModel(
      token: data['token'] as String? ?? '',
      user: data['user'] as Map<String, dynamic>? ?? {},
      expiresIn: data['expiresIn'] as int? ?? 3600,
      refreshToken: data['refreshToken'] as String?,
    );
  }

  LoginResponseDto toDomain() {
    return LoginResponseDto(
      token: token,
      user: UserModel.fromJson(user).toDomain(),
      expiresIn: expiresIn,
      refreshToken: refreshToken,
    );
  }
}
