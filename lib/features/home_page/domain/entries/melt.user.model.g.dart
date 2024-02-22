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
      name: json['name'] as String?,
    );

Map<String, dynamic> _$MeltUserModelToJson(MeltUserModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'gender': instance.gender,
      'metal': instance.metal?.toJson(),
    };
