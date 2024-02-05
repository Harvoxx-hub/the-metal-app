import 'package:json_annotation/json_annotation.dart';

part 'metal.plan.model.g.dart'; // This file will be generated

@JsonSerializable()
class MetalPlanModel {
  final String planeName;
  final double price;
  final List<String> metaData;

  MetalPlanModel({
    required this.planeName,
    required this.price,
    required this.metaData,
  });

  factory MetalPlanModel.fromJson(Map<String, dynamic> json) =>
      _$MetalPlanModelFromJson(json); // Generated factory method

  Map<String, dynamic> toJson() =>
      _$MetalPlanModelToJson(this); // Generated method
}
