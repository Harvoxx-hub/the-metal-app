// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metal.plan.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MetalPlanModel _$MetalPlanModelFromJson(Map<String, dynamic> json) =>
    MetalPlanModel(
      planName: json['planName'] as String,
      id: json['id'] as String,
      duration: json['duration'] as int,
      price: json['price'] as int,
      metaData:
          (json['metaData'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$MetalPlanModelToJson(MetalPlanModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'duration': instance.duration,
      'planName': instance.planName,
      'price': instance.price,
      'metaData': instance.metaData,
    };
