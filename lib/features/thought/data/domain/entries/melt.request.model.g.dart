// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'melt.request.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeltRequestModel _$MeltRequestModelFromJson(Map<String, dynamic> json) =>
    MeltRequestModel(
      requesterId: json['requesterId'] as String,
      recipientId: json['recipientId'] as String,
      isAnonymous: json['isAnonymous'] as bool? ?? true,
      createdAt: json['createdAt'] as String,
      senderId: json['senderId'] as String,
      status: json['status'] as String? ?? 'pending',
    );

Map<String, dynamic> _$MeltRequestModelToJson(MeltRequestModel instance) =>
    <String, dynamic>{
      'requesterId': instance.requesterId,
      'recipientId': instance.recipientId,
      'senderId': instance.senderId,
      'isAnonymous': instance.isAnonymous,
      'createdAt': instance.createdAt,
      'status': instance.status,
    };
