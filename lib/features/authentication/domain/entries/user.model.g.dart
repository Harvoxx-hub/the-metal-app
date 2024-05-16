// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      profile_updated: json['profile_updated'] as bool?,
      DOB: json['DOB'] as String?,
      referralCode: json['referralCode'] as String?,
      address: json['address'] == null
          ? null
          : Address.fromJson(json['address'] as Map<String, dynamic>),
      connect_with: json['connect_with'] as String?,
      connection_option: (json['connection_option'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      description: json['description'] as String?,
      extra_data: json['extra_data'] == null
          ? null
          : ExtraData.fromJson(json['extra_data'] as Map<String, dynamic>),
      fullname: json['fullname'] as String?,
      gender: json['gender'] as String?,
      isVerified: json['isVerified'] as bool?,
      location: json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
      metal: json['metal'] == null
          ? null
          : Metal.fromJson(json['metal'] as Map<String, dynamic>),
      passion:
          (json['passion'] as List<dynamic>?)?.map((e) => e as String).toList(),
      phone: json['phone'] as String?,
      preferences: json['preferences'] == null
          ? null
          : Preferences.fromJson(json['preferences'] as Map<String, dynamic>),
      email: json['email'] as String?,
      username: json['username'] as String?,
      access_token: json['access_token'] as String?,
      refresh_token: json['refresh_token'] as String?,
      subscription: json['subscription'] == null
          ? null
          : SubscribedPlanModel.fromJson(
              json['subscription'] as Map<String, dynamic>),
      distance: json['distance'] as String?,
      sparkBalance: (json['sparkBalance'] as num?)?.toDouble(),
      id: json['id'] as String?,
      profilePhoto: json['profilePhoto'] as String?,
      completed_profile: json['completed_profile'] as bool?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'profile_updated': instance.profile_updated,
      'completed_profile': instance.completed_profile,
      'DOB': instance.DOB,
      'address': instance.address?.toJson(),
      'connect_with': instance.connect_with,
      'connection_option': instance.connection_option,
      'description': instance.description,
      'extra_data': instance.extra_data?.toJson(),
      'fullname': instance.fullname,
      'gender': instance.gender,
      'isVerified': instance.isVerified,
      'location': instance.location?.toJson(),
      'metal': instance.metal?.toJson(),
      'passion': instance.passion,
      'phone': instance.phone,
      'email': instance.email,
      'preferences': instance.preferences?.toJson(),
      'username': instance.username,
      'access_token': instance.access_token,
      'refresh_token': instance.refresh_token,
      'subscription': instance.subscription?.toJson(),
      'sparkBalance': instance .sparkBalance,
      'distance': instance.distance,
      'id': instance.id,
      'referralCode': instance.referralCode,
      'profilePhoto': instance.profilePhoto,
    };

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
      apartment_number: json['apartment_number'] as String?,
      house_number: json['house_number'] as String?,
      postalCode: json['postalCode'] as String?,
      streetName: json['streetName'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
    );

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
      'apartment_number': instance.apartment_number,
      'house_number': instance.house_number,
      'streetName': instance.streetName,
      'postalCode': instance.postalCode,
      'state': instance.state,
      'country': instance.country,
    };

ExtraData _$ExtraDataFromJson(Map<String, dynamic> json) => ExtraData(
      country: json['country'] as String?,
      education: json['education'] as String?,
      ethnicity: json['ethnicity'] as String?,
      marital_status: json['marital_status'] as String?,
      profession: json['profession'] as String?,
      religion: json['religion'] as String?,
      language: json['language'] as String?,
    );

Map<String, dynamic> _$ExtraDataToJson(ExtraData instance) => <String, dynamic>{
      'country': instance.country,
      'education': instance.education,
      'ethnicity': instance.ethnicity,
      'marital_status': instance.marital_status,
      'profession': instance.profession,
      'religion': instance.religion,
      'language': instance.language,
    };

Preferences _$PreferencesFromJson(Map<String, dynamic> json) => Preferences(
      age_range: json['age_range'] as String?,
      demography: json['demography'] as String?,
      education: json['education'] as String?,
      ethnicity: json['ethnicity'] as String?,
      religion: json['religion'] as String?,
    );

Map<String, dynamic> _$PreferencesToJson(Preferences instance) =>
    <String, dynamic>{
      'age_range': instance.age_range,
      'demography': instance.demography,
      'education': instance.education,
      'ethnicity': instance.ethnicity,
      'religion': instance.religion,
    };

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      address: json['address'] as String?,
    );

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
      'address': instance.address,
    };
