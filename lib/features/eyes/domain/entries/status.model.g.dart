// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatusModel _$StatusModelFromJson(Map<String, dynamic> json) => StatusModel(
      file: json['file'] as String?,
      text: json['text'] as String?,
      id: json['id'] as int?,
      views: json['views'] as List<dynamic>?,
      isActive: json['isActive'] as bool?,
    )..postedAt = json['postedAt'] as int?;

Map<String, dynamic> _$StatusModelToJson(StatusModel instance) =>
    <String, dynamic>{
      'file': instance.file,
      'text': instance.text,
      'id': instance.id,
      'views': instance.views,
      'postedAt': instance.postedAt,
      'isActive': instance.isActive,
    };

StatusData _$StatusDataFromJson(Map<String, dynamic> json) => StatusData(
      status: (json['status'] as List<dynamic>)
          .map((e) => StatusModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      username: json['username'] as String,
      metal: Metal.fromJson(json['metal'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StatusDataToJson(StatusData instance) =>
    <String, dynamic>{
      'status': instance.status,
      'username': instance.username,
      'metal': instance.metal,
    };
