 

import 'package:json_annotation/json_annotation.dart';

part 'melt.request.model.g.dart';

@JsonSerializable(explicitToJson: true)
class MeltRequestModel {
  final String requesterId;
  final String recipientId;
  final String senderId;

  final bool isAnonymous;
  final String createdAt;
  final String
      status; // Status of the request (e.g., "pending", "accepted", "rejected")

  MeltRequestModel({
    required this.requesterId,
    required this.recipientId,
    this.isAnonymous = true,
    required this.createdAt,
    required this.senderId,
    this.status = 'pending', // Default to "pending"s
  });

  factory MeltRequestModel.fromJson(Map<String, dynamic> json) =>
      _$MeltRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$MeltRequestModelToJson(this);
}
