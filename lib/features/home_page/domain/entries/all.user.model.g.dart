// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all.user.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ALLUserModel _$ALLUserModelFromJson(Map<String, dynamic> json) => ALLUserModel(
      phone: json['phone'] as String?,
      distance: json['distance'] as String?,
      description: json['description'] as String?,
      username: json['username'] as String?,
      id: json['id'] as String?,
      age_range: json['age_range'] as String?,
      gender: json['gender'] as String?,
      passion:
          (json['passion'] as List<dynamic>?)?.map((e) => e as String).toList(),
      connection_option: (json['connection_option'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      metal: json['metal'] == null
          ? null
          : Metal.fromJson(json['metal'] as Map<String, dynamic>),
      verfied: json['verfied'] as bool? ?? false,
      liked: json['liked'] as bool? ?? false,
      melted: json['melted'] as bool? ?? false,
    );

Map<String, dynamic> _$ALLUserModelToJson(ALLUserModel instance) =>
    <String, dynamic>{
      'distance': instance.distance,
      'description': instance.description,
      'username': instance.username,
      'id': instance.id,
      'age_range': instance.age_range,
      'gender': instance.gender,
      'passion': instance.passion,
      'connection_option': instance.connection_option,
      'metal': instance.metal?.toJson(),
      'verfied': instance.verfied,
      'phone': instance.phone,
      'liked': instance.liked,
      'melted': instance.melted,
    };
