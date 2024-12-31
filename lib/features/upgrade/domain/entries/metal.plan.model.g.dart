// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metal.plan.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MetalPlanModel _$MetalPlanModelFromJson(Map<String, dynamic> json) =>
    MetalPlanModel(
      planeName: json['planeName'] as String,
      id: json['id'] as String?,
      duration: (json['duration'] as num).toInt(),
      price: (json['price'] as num).toInt(),
      metaData:
          (json['metaData'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$MetalPlanModelToJson(MetalPlanModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'duration': instance.duration,
      'planeName': instance.planeName,
      'price': instance.price,
      'metaData': instance.metaData,
    };
