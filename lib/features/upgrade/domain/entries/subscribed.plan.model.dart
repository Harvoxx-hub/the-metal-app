import 'package:json_annotation/json_annotation.dart';

part 'subscribed.plan.model.g.dart'; // This file will be generated

@JsonSerializable()
class SubscribedPlanModel {
  final String id;
  final int startingDate;
  final int endingDate;
  final int duration;
  final String planName;
  final int price;
  final List<String> metaData;

  SubscribedPlanModel({
    required this.planName,
    required this.id,
    required this.duration,
    required this.price,
    required this.metaData,
    required this.startingDate,
    required this.endingDate,
  });

  factory SubscribedPlanModel.fromJson(Map<String, dynamic> json) =>
      _$SubscribedPlanModelFromJson(json); // Generated factory method

  Map<String, dynamic> toJson() =>
      _$SubscribedPlanModelToJson(this); // Generated method
}
