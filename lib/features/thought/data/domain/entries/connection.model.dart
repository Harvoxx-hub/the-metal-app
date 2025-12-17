 

import 'package:json_annotation/json_annotation.dart';
import 'package:metal/core/services/firebase.remote.config.service.dart';
import 'package:metal/core/utils/constant/firebase.remote.config.key.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';

part 'connection.model.g.dart';

@JsonSerializable(explicitToJson: true)
class ConnectionModel {
  final String connectionId; // Unique ID for the connection
  final List<String> users;
  final String? lastMessage;
  final String? lastUpdatedAt;
  final String? game;
  final int unreadCount; // Number of unread messages
  final UserModel? otherUser; // The other user in the connection

  final String connectedOn; // Timestamp when the connection was created
  final String status; // Status of the connection (e.g., "active", "blocked")
  final bool isAnonymous; // Whether the connection remains anonymous
 // List of dates when conversations occurred
  final String? lastConversationDate; // Last date when a conversation occurred
  final String? lastSenderId; // Last sender ID

  // New fields to store original melt request info
  final String? initiatorId; // Who sent the original melt request
  final String? receiverId; // Who received the original melt request
  final bool wasAnonymous; // Whether the original request was anonymous
  
  // Melt status: 'mutual' = both users melted, 'pending' = one-way, needs melt to reply
  final String meltStatus; // 'mutual' | 'pending'

  ConnectionModel({
    required this.connectionId,
    required this.users,
    required this.connectedOn,
    this.status = 'active', // Default to "active"
    this.lastMessage,
    this.lastUpdatedAt,
    this.game,
    this.lastSenderId,
    this.isAnonymous = false, // Default to not anonymous
 
    this.lastConversationDate, // Default to null
    this.unreadCount = 0, // Default to 0 unread messages
    this.otherUser, // The other user in the connection
    this.initiatorId, // Who initiated the connection (from melt request)
    this.receiverId, // Who received the connection request
    this.wasAnonymous = false, // Was the original request anonymous
    this.meltStatus = 'mutual', // Default to 'mutual' for existing connections
  });

  factory ConnectionModel.fromJson(Map<String, dynamic> json) =>
      _$ConnectionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConnectionModelToJson(this);
 
  /// Check if the connection meets unmelt requirements
  bool canUnmelt(String? userProfilePhoto) {
    // Get required days from remote config
    final daysRequiredToUnMelt = FirebaseRemoteConfigService()
        .getInt(FirebaseRemoteConfigKeys.daysRequiredToUnMelt);

    // Check if required days have passed since connection
    final connectedDate = DateTime.parse(connectedOn);
    final daysSinceConnection = DateTime.now().difference(connectedDate).inDays;

    // Must have required days since connection, 10 unique days of conversation, and a profile photo
    return daysSinceConnection >= daysRequiredToUnMelt &&
       
        userProfilePhoto != null &&
        userProfilePhoto.isNotEmpty;
  }

  /// Check if the current user is the initiator of this connection
  bool isInitiator(String currentUserId) {
    return initiatorId == currentUserId;
  }

  /// Check if both users have melted (mutual melt)
  bool get isMutualMelt => meltStatus == 'mutual';

  /// Check if melt is pending (one-way connection)
  bool get isMeltPending => meltStatus == 'pending';

  /// Check if a user can send messages in this connection
  /// Returns true if:
  /// - Connection has mutual melt (both users melted)
  /// - Connection is pending and user is the initiator (can send)
  /// Returns false if:
  /// - Connection is pending and user is the receiver (cannot send)
  bool canUserSendMessage(String userId) {
    if (isMutualMelt) return true;
    if (isMeltPending) {
      // Only initiator can send when pending
      return initiatorId == userId;
    }
    return false;
  }

  /// Check if a user is the receiver in a pending connection
  /// This means they can view messages but cannot send
  bool isUserReceiver(String userId) {
    return isMeltPending && receiverId == userId;
  }
 
  ConnectionModel copyWith({
    String? connectionId,
    List<String>? users,
    String? lastMessage,
    String? lastUpdatedAt,
    String? game,
    int? unreadCount,
    String? connectedOn,
    String? status,
    bool? isAnonymous,
    
    String? lastConversationDate,
    UserModel? otherUser,
    String? lastSenderId,
    String? initiatorId,
    String? receiverId,
    bool? wasAnonymous,
    String? meltStatus,
  }) {
    return ConnectionModel(
      connectionId: connectionId ?? this.connectionId,
      users: users ?? this.users,
      lastMessage: lastMessage ?? this.lastMessage,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      game: game ?? this.game,
      unreadCount: unreadCount ?? this.unreadCount,
      connectedOn: connectedOn ?? this.connectedOn,
      status: status ?? this.status,
      lastSenderId: lastSenderId ?? this.lastSenderId,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      
      lastConversationDate: lastConversationDate ?? this.lastConversationDate,
      otherUser: otherUser ?? this.otherUser,
      initiatorId: initiatorId ?? this.initiatorId,
      receiverId: receiverId ?? this.receiverId,
      wasAnonymous: wasAnonymous ?? this.wasAnonymous,
      meltStatus: meltStatus ?? this.meltStatus,
    );
  }
}
