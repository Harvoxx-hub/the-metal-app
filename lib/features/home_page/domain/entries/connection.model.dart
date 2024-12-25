// {
//   "connectionId": "unique_connection_id",   // Document ID
//   "pairId": "user1Id_user2Id",             // Concatenated user IDs for efficient querying
//   "user1Id": "user1_id",                   // First user
//   "user2Id": "user2_id",                   // Second user
//   "connectedOn": "2024-12-01T21:00:00Z",   // Timestamp when connection was established
//   "status": "active",                      // Status of the connection
//   "metadata": {                            // Optional metadata for chat
//     "isAnonymous": false                   // Whether the connection is anonymous
//   }
// }

// }

import 'package:json_annotation/json_annotation.dart';

part 'connection.model.g.dart';

@JsonSerializable(explicitToJson: true)
class ConnectionModel {
  final String connectionId; // Unique ID for the connection
  final List<String> users;
  final String? lastMessage;
  final String? lastUpdatedAt;
  final String? game;
  
  final String connectedOn; // Timestamp when the connection was created
  final String status; // Status of the connection (e.g., "active", "blocked")
  final bool isAnonymous; // Whether the connection remains anonymous

  ConnectionModel({
    required this.connectionId,
    required this.users,
    required this.connectedOn,
    this.status = 'active', // Default to "active"
    this.lastMessage,
    this.lastUpdatedAt,
    this.game,
    this.isAnonymous = false, // Default to not anonymous
  });

  factory ConnectionModel.fromJson(Map<String, dynamic> json) =>
      _$ConnectionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConnectionModelToJson(this);
}
