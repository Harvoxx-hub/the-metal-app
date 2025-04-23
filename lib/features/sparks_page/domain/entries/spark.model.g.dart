// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spark.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SparkModel _$SparkModelFromJson(Map<String, dynamic> json) => SparkModel(
      type: json['type'] as String?,
      amount: json['amount'] as String?,
      sparks: (json['sparks'] as num?)?.toInt(),
      receiverId: json['receiverId'] as String?,
      receiverName: json['receiverName'] as String?,
      senderName: json['senderName'] as String?,
      userId: json['userId'] as String?,
      timestamp: json['timestamp'] as String?,
      referredName: json['referredName'] as String?,
      referrerName: json['referrerName'] as String?,
      referredUserId: json['referredUserId'] as String?,
      referrerId: json['referrerId'] as String?,
    );

Map<String, dynamic> _$SparkModelToJson(SparkModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'amount': instance.amount,
      'sparks': instance.sparks,
      'receiverId': instance.receiverId,
      'receiverName': instance.receiverName,
      'senderName': instance.senderName,
      'referredName': instance.referredName,
      'referrerName': instance.referrerName,
      'referredUserId': instance.referredUserId,
      'referrerId': instance.referrerId,
      'userId': instance.userId,
      'timestamp': instance.timestamp,
    };
