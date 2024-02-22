// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscribed.plan.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscribedPlanModel _$SubscribedPlanModelFromJson(Map<String, dynamic> json) =>
    SubscribedPlanModel(
      planName: json['planName'] as String,
      id: json['id'] as String,
      duration: json['duration'] as int,
      price: json['price'] as int,
      metaData:
          (json['metaData'] as List<dynamic>).map((e) => e as String).toList(),
      startingDate: json['startingDate'] as int,
      endingDate: json['endingDate'] as int,
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
