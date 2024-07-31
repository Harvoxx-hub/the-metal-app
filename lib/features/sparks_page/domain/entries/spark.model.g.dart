// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spark.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SparkModel _$SparkModelFromJson(Map<String, dynamic> json) => SparkModel(
      type: json['type'] as String?,
      amount: json['amount'] as String?,
      numberOfSparks: (json['numberOfSparks'] as num?)?.toInt(),
      receiver: json['receiver'] as String?,
      date: json['date'] as String?,
      time: json['time'] as String?,
    );

Map<String, dynamic> _$SparkModelToJson(SparkModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'amount': instance.amount,
      'numberOfSparks': instance.numberOfSparks,
      'receiver': instance.receiver,
      'date': instance.date,
      'time': instance.time,
    };
