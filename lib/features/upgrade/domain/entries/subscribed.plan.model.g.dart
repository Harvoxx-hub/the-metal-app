// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscribed.plan.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscribedPlanModel _$SubscribedPlanModelFromJson(Map<String, dynamic> json) =>
    SubscribedPlanModel(
      planName: json['planName'] as String,
      id: json['id'] as String,
      duration: (json['duration'] as num).toInt(),
      price: (json['price'] as num).toInt(),
      metaData:
          (json['metaData'] as List<dynamic>).map((e) => e as String).toList(),
      startingDate: (json['startingDate'] as num).toInt(),
      endingDate: (json['endingDate'] as num).toInt(),
    );

Map<String, dynamic> _$SubscribedPlanModelToJson(
        SubscribedPlanModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startingDate': instance.startingDate,
      'endingDate': instance.endingDate,
      'duration': instance.duration,
      'planName': instance.planName,
      'price': instance.price,
      'metaData': instance.metaData,
    };
