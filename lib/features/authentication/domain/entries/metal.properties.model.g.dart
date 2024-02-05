// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metal.properties.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MetalPropertiesModel _$MetalPropertiesModelFromJson(
        Map<String, dynamic> json) =>
    MetalPropertiesModel(
      metals: (json['metals'] as List<dynamic>?)
          ?.map((e) => Metal.fromJson(e as Map<String, dynamic>))
          .toList(),
      passions: (json['passions'] as List<dynamic>?)
          ?.map((e) => Passion.fromJson(e as Map<String, dynamic>))
          .toList(),
      profession: (json['profession'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      education: (json['education'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      country:
          (json['country'] as List<dynamic>?)?.map((e) => e as String).toList(),
      ethnicity: (json['ethnicity'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      religion: (json['religion'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      lookingFor: (json['lookingFor'] as List<dynamic>?)
          ?.map((e) => LookingFor.fromJson(e as Map<String, dynamic>))
          .toList(),
      language: (json['language'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      marriageStatus: (json['marriageStatus'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      demography: (json['demography'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$MetalPropertiesModelToJson(
        MetalPropertiesModel instance) =>
    <String, dynamic>{
      'metals': instance.metals,
      'passions': instance.passions,
      'profession': instance.profession,
      'education': instance.education,
      'country': instance.country,
      'ethnicity': instance.ethnicity,
      'religion': instance.religion,
      'language': instance.language,
      'marriageStatus': instance.marriageStatus,
      'lookingFor': instance.lookingFor,
      'demography': instance.demography,
    };

Metal _$MetalFromJson(Map<String, dynamic> json) => Metal(
      title: json['title'] as String?,
      desc: json['desc'] as String?,
      img: json['img'] as String?,
    );

Map<String, dynamic> _$MetalToJson(Metal instance) => <String, dynamic>{
      'title': instance.title,
      'desc': instance.desc,
      'img': instance.img,
    };

Passion _$PassionFromJson(Map<String, dynamic> json) => Passion(
      title: json['title'] as String?,
      img: json['img'] as String?,
    );

Map<String, dynamic> _$PassionToJson(Passion instance) => <String, dynamic>{
      'title': instance.title,
      'img': instance.img,
    };

LookingFor _$LookingForFromJson(Map<String, dynamic> json) => LookingFor(
      title: json['title'] as String?,
      desc: json['desc'] as String?,
    );

Map<String, dynamic> _$LookingForToJson(LookingFor instance) =>
    <String, dynamic>{
      'title': instance.title,
      'desc': instance.desc,
    };
