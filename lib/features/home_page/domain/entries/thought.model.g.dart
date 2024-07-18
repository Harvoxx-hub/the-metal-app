// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thought.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThoughtModel _$ThoughtModelFromJson(Map<String, dynamic> json) => ThoughtModel(
      id: json['id'] as int?,
      user: json['user'] as String?,
      thought: json['thought'] as String?,
      created_at: json['created_at'] as String?,
      userData: json['userData'] == null
          ? null
          : UserData.fromJson(json['userData'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ThoughtModelToJson(ThoughtModel instance) =>
    <String, dynamic>{
      'created_at': instance.created_at,
      'id': instance.id,
      'user': instance.user,
      'thought': instance.thought,
      'userData': instance.userData?.toJson(),
    };

UserData _$UserDataFromJson(Map<String, dynamic> json) => UserData(
      metal: json['metal'] == null
          ? null
          : Metal.fromJson(json['metal'] as Map<String, dynamic>),
      fullname: json['fullname'] as String?,
      username: json['username'] as String?,
    );

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
      'metal': instance.metal?.toJson(),
      'fullname': instance.fullname,
      'username': instance.username,
    };
