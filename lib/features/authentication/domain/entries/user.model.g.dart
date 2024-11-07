// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      profileUpdated: json['profile_updated'] as bool?,
      completedProfile: json['completed_profile'] as bool?,
      dob: json['DOB'] as String?,
      address: json['address'] == null
          ? null
          : Address.fromJson(json['address'] as Map<String, dynamic>),
      connectWith: json['connect_with'] as String?,
      connectionOption: (json['connection_option'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      description: json['description'] as String?,
      extraData: json['extra_data'] == null
          ? null
          : ExtraData.fromJson(json['extra_data'] as Map<String, dynamic>),
      fullname: json['fullname'] as String?,
      gender: json['gender'] as String?,
      isVerified: json['isVerified'] as bool?,
      isActivated: json['isActivated'] as bool?,
      location: json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
      metal: json['metal'] == null
          ? null
          : Metal.fromJson(json['metal'] as Map<String, dynamic>),
      passion:
          (json['passion'] as List<dynamic>?)?.map((e) => e as String).toList(),
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      emailVerified: json['email_verified'] as bool?,
      preferences: json['preferences'] == null
          ? null
          : Preferences.fromJson(json['preferences'] as Map<String, dynamic>),
      username: json['username'] as String?,
      accessToken: json['access_token'] as String?,
      refreshToken: json['refreshToken'] as String?,
      subscription: json['subscription'] == null
          ? null
          : SubscribedPlanModel.fromJson(
              json['subscription'] as Map<String, dynamic>),
      sparkBalance: (json['sparkBalance'] as num?)?.toDouble(),
      distance: json['distance'] as String?,
      id: json['id'] as String?,
      referralCode: json['referralCode'] as String?,
      profilePhoto: json['profilePhoto'] as String?,
      fcmToken: json['fcmToken'] as String?,
      conversationId: json['conversationId'] as String?,
      blockedUsers: (json['blockedUsers'] as List<dynamic>?)
          ?.map((e) => BlockedUser.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'profile_updated': instance.profileUpdated,
      'completed_profile': instance.completedProfile,
      'DOB': instance.dob,
      'address': instance.address,
      'connect_with': instance.connectWith,
      'connection_option': instance.connectionOption,
      'description': instance.description,
      'extra_data': instance.extraData,
      'fullname': instance.fullname,
      'gender': instance.gender,
      'isVerified': instance.isVerified,
      'isActivated': instance.isActivated,
      'location': instance.location,
      'metal': instance.metal,
      'passion': instance.passion,
      'phone': instance.phone,
      'email': instance.email,
      'email_verified': instance.emailVerified,
      'preferences': instance.preferences,
      'username': instance.username,
      'access_token': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'subscription': instance.subscription,
      'sparkBalance': instance.sparkBalance,
      'distance': instance.distance,
      'id': instance.id,
      'referralCode': instance.referralCode,
      'profilePhoto': instance.profilePhoto,
      'fcmToken': instance.fcmToken,
      'conversationId': instance.conversationId,
      'blockedUsers': instance.blockedUsers,
    };

_$AddressImpl _$$AddressImplFromJson(Map<String, dynamic> json) =>
    _$AddressImpl(
      apartmentNumber: json['apartment_number'] as String?,
      houseNumber: json['house_number'] as String?,
      streetName: json['streetName'] as String?,
      postalCode: json['postalCode'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
    );

Map<String, dynamic> _$$AddressImplToJson(_$AddressImpl instance) =>
    <String, dynamic>{
      'apartment_number': instance.apartmentNumber,
      'house_number': instance.houseNumber,
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
      maritalStatus: json['marital_status'] as String?,
      profession: json['profession'] as String?,
      religion: json['religion'] as String?,
    );

Map<String, dynamic> _$$ExtraDataImplToJson(_$ExtraDataImpl instance) =>
    <String, dynamic>{
      'country': instance.country,
      'education': instance.education,
      'ethnicity': instance.ethnicity,
      'language': instance.language,
      'marital_status': instance.maritalStatus,
      'profession': instance.profession,
      'religion': instance.religion,
    };

_$PreferencesImpl _$$PreferencesImplFromJson(Map<String, dynamic> json) =>
    _$PreferencesImpl(
      ageRange: json['age_range'] as String?,
      demography: json['demography'] as String?,
      education: json['education'] as String?,
      ethnicity: json['ethnicity'] as String?,
      religion: json['religion'] as String?,
    );

Map<String, dynamic> _$$PreferencesImplToJson(_$PreferencesImpl instance) =>
    <String, dynamic>{
      'age_range': instance.ageRange,
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

_$BlockedUserImpl _$$BlockedUserImplFromJson(Map<String, dynamic> json) =>
    _$BlockedUserImpl(
      id: json['id'] as String?,
      metal: json['metal'] == null
          ? null
          : Metal.fromJson(json['metal'] as Map<String, dynamic>),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$$BlockedUserImplToJson(_$BlockedUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'metal': instance.metal,
      'name': instance.name,
    };
