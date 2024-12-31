// {
//   "requestId": "unique_request_id",  // Unique ID for the request
//   "senderId": "user1_id",           // ID of the user who sent the request
//   "receiverId": "user2_id",         // ID of the user to whom the request was sent
//   "createdAt": "2024-12-01T20:30:00Z", // Timestamp of the request
//   "status": "pending",              // Status: "pending", "accepted", or "cancelled"
//   "isAnonymous": true,              // Whether the request is anonymous
//   "metadata": {                     // Optional metadata for additional context
//     "message": "Let's connect!"
//   }
// }

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
