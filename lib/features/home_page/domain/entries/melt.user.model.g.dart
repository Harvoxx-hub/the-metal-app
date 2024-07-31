// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'melt.user.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeltUserModel _$MeltUserModelFromJson(Map<String, dynamic> json) =>
    MeltUserModel(
      id: json['id'] as String?,
      gender: json['gender'] as String?,
      metal: json['metal'] == null
          ? null
          : Metal.fromJson(json['metal'] as Map<String, dynamic>),
      phone: json['phone'] as String?,
      name: json['name'] as String?,
      conversationId: json['conversationId'] as String?,
      username: json['username'] as String?,
      fcmToken: json['fcmToken'] as String?,
    );

Map<String, dynamic> _$MeltUserModelToJson(MeltUserModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'gender': instance.gender,
      'username': instance.username,
      'fcmToken': instance.fcmToken,
      'conversationId': instance.conversationId,
      'metal': instance.metal?.toJson(),
      'phone': instance.phone,
    };
