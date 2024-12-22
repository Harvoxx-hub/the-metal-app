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
      userId: json['userId'] as String?,
      timestamp: json['timestamp'] as String?,
    );

Map<String, dynamic> _$SparkModelToJson(SparkModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'amount': instance.amount,
      'sparks': instance.sparks,
      'receiverId': instance.receiverId,
      'userId': instance.userId,
      'timestamp': instance.timestamp,
    };
