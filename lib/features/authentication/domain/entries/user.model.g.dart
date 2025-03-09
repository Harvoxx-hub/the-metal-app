// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      profileUpdated: json['profileUpdated'] as bool?,
      completedProfile: json['completedProfile'] as bool?,
      dob: json['dob'] as String?,
      address: json['address'] == null
          ? null
          : Address.fromJson(json['address'] as Map<String, dynamic>),
      connectWith: json['connectWith'] as String?,
      connectionOption: (json['connectionOption'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      description: json['description'] as String?,
      extraData: json['extraData'] == null
          ? null
          : ExtraData.fromJson(json['extraData'] as Map<String, dynamic>),
      fullname: json['fullname'] as String?,
      gender: json['gender'] as String?,
      isVerified: json['isVerified'] as bool?,
      isActivated: json['isActivated'] as bool?,
      location: json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
      metal: json['metal'] as String?,
      passion:
          (json['passion'] as List<dynamic>?)?.map((e) => e as String).toList(),
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      emailVerified: json['emailVerified'] as bool?,
      preferences: json['preferences'] == null
          ? null
          : Preferences.fromJson(json['preferences'] as Map<String, dynamic>),
      username: json['username'] as String?,
      refreshToken: json['refreshToken'] as String?,
      subscription: json['subscription'] == null
          ? null
          : SubscribedPlanModel.fromJson(
              json['subscription'] as Map<String, dynamic>),
      sparkBalance: (json['sparkBalance'] as num?)?.toDouble() ?? 0,
      distance: json['distance'] as String?,
      id: json['id'] as String?,
      referralCode: json['referralCode'] as String?,
      referredBy: json['referredBy'] as String?,
      showOnline: json['showOnline'] as bool? ?? true,
      alwaysMetal: json['alwaysMetal'] as bool? ?? true,
      receiveNotification: json['receiveNotification'] as bool? ?? true,
      showMyProfile: json['showMyProfile'] as bool? ?? true,
      activateVoiceNote: json['activateVoiceNote'] as bool? ?? true,
      activateVoiceCall: json['activateVoiceCall'] as bool? ?? true,
      activateVideoCall: json['activateVideoCall'] as bool? ?? true,
      profilePhoto: json['profilePhoto'] as String?,
      fcmToken: json['fcmToken'] as String?,
      isOnline: json['isOnline'] as bool? ?? true,
      lastActive: json['lastActive'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'profileUpdated': instance.profileUpdated,
      'completedProfile': instance.completedProfile,
      'dob': instance.dob,
      'address': instance.address?.toJson(),
      'connectWith': instance.connectWith,
      'connectionOption': instance.connectionOption,
      'description': instance.description,
      'extraData': instance.extraData?.toJson(),
      'fullname': instance.fullname,
      'gender': instance.gender,
      'isVerified': instance.isVerified,
      'isActivated': instance.isActivated,
      'location': instance.location?.toJson(),
      'metal': instance.metal,
      'passion': instance.passion,
      'phone': instance.phone,
      'email': instance.email,
      'emailVerified': instance.emailVerified,
      'preferences': instance.preferences?.toJson(),
      'username': instance.username,
      'refreshToken': instance.refreshToken,
      'subscription': instance.subscription?.toJson(),
      'sparkBalance': instance.sparkBalance,
      'distance': instance.distance,
      'id': instance.id,
      'referralCode': instance.referralCode,
      'referredBy': instance.referredBy,
      'showOnline': instance.showOnline,
      'alwaysMetal': instance.alwaysMetal,
      'receiveNotification': instance.receiveNotification,
      'showMyProfile': instance.showMyProfile,
      'activateVoiceNote': instance.activateVoiceNote,
      'activateVoiceCall': instance.activateVoiceCall,
      'activateVideoCall': instance.activateVideoCall,
      'profilePhoto': instance.profilePhoto,
      'fcmToken': instance.fcmToken,
      'isOnline': instance.isOnline,
      'lastActive': instance.lastActive,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

_$AddressImpl _$$AddressImplFromJson(Map<String, dynamic> json) =>
    _$AddressImpl(
      apartmentNumber: json['apartmentNumber'] as String?,
      houseNumber: json['houseNumber'] as String?,
      streetName: json['streetName'] as String?,
      postalCode: json['postalCode'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
    );

Map<String, dynamic> _$$AddressImplToJson(_$AddressImpl instance) =>
    <String, dynamic>{
      'apartmentNumber': instance.apartmentNumber,
      'houseNumber': instance.houseNumber,
      'streetName': instance.streetName,
      'postalCode': instance.postalCode,
      'state': instance.state,
      'country': instance.country,
    };

_$ExtraDataImpl _$$ExtraDataImplFromJson(Map<String, dynamic> json) =>
    _$ExtraDataImpl(
      country: json['country'] as String?,
      education: json['education'] as String?,
      ethnicity: json['ethnicity'] as String?,
      language: json['language'] as String?,
      maritalStatus: json['maritalStatus'] as String?,
      profession: json['profession'] as String?,
      religion: json['religion'] as String?,
    );

Map<String, dynamic> _$$ExtraDataImplToJson(_$ExtraDataImpl instance) =>
    <String, dynamic>{
      'country': instance.country,
      'education': instance.education,
      'ethnicity': instance.ethnicity,
      'language': instance.language,
      'maritalStatus': instance.maritalStatus,
      'profession': instance.profession,
      'religion': instance.religion,
    };

_$PreferencesImpl _$$PreferencesImplFromJson(Map<String, dynamic> json) =>
    _$PreferencesImpl(
      ageRange: json['ageRange'] as String?,
      demography: json['demography'] as String?,
      education: json['education'] as String?,
      ethnicity: json['ethnicity'] as String?,
      religion: json['religion'] as String?,
    );

Map<String, dynamic> _$$PreferencesImplToJson(_$PreferencesImpl instance) =>
    <String, dynamic>{
      'ageRange': instance.ageRange,
      'demography': instance.demography,
      'education': instance.education,
      'ethnicity': instance.ethnicity,
      'religion': instance.religion,
    };

_$LocationImpl _$$LocationImplFromJson(Map<String, dynamic> json) =>
    _$LocationImpl(
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      address: json['address'] as String?,
    );

Map<String, dynamic> _$$LocationImplToJson(_$LocationImpl instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
      'address': instance.address,
    };
