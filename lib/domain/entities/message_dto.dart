import 'package:metal/core/utils/constant/chat_constants.dart';
import 'package:metal/domain/entities/base_entity.dart';

/// Message types enum
enum MessageType {
  text,
  audio,
  unmelt,
  calls;

  /// Convert string to MessageType
  static MessageType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'text':
        return MessageType.text;
      case 'audio':
        return MessageType.audio;
      case 'un_melt':
      case 'unmelt':
        return MessageType.unmelt;
      case 'calls':
        return MessageType.calls;
      default:
        return MessageType.text;
    }
  }

  /// Convert MessageType to API string
  String get value {
    switch (this) {
      case MessageType.text:
        return 'text';
      case MessageType.audio:
        return 'audio';
      case MessageType.unmelt:
        return 'un_melt';
      case MessageType.calls:
        return 'calls';
    }
  }
}

/// Message state for optimistic UI updates
enum MessageState {
  sending,
  sent,
  delivered,
  read,
  error;

  static MessageState fromString(String value) {
    switch (value.toLowerCase()) {
      case 'sending':
        return MessageState.sending;
      case 'sent':
        return MessageState.sent;
      case 'delivered':
        return MessageState.delivered;
      case 'read':
        return MessageState.read;
      case 'error':
        return MessageState.error;
      default:
        return MessageState.sent;
    }
  }
}

/// Domain entity for messages
/// Represents a chat message in the domain layer
class MessageDto extends BaseEntity {
  final String id;
  final String message;
  final String senderId;
  final MessageType type;
  final String? content; // For audio URL or other media
  final DateTime timestamp;
  final bool isRead;
  final MessageState state;

  // Reply data
  final String? replyToMessageId;
  final String? replyToMessageText;
  final String? replyToSenderId;
  final String? replyToMessageType;

  const MessageDto({
    required this.id,
    required this.message,
    required this.senderId,
    required this.type,
    this.content,
    required this.timestamp,
    this.isRead = false,
    this.state = MessageState.sent,
    this.replyToMessageId,
    this.replyToMessageText,
    this.replyToSenderId,
    this.replyToMessageType,
  });

  /// Check if this message is a reply to another message
  bool get isReply =>
      replyToMessageId != null && replyToMessageId!.isNotEmpty;

  /// Get truncated reply text for display
  String get truncatedReplyText {
    if (!isReply || replyToMessageText == null) return '';

    if (replyToMessageText!.length <= ChatConstants.maxReplyPreviewLength) {
      return replyToMessageText!;
    }
    return '${replyToMessageText!.substring(0, ChatConstants.maxReplyPreviewLength)}...';
  }

  /// Get display text for reply preview based on message type
  String get replyPreviewText {
    if (!isReply) return '';

    final replyType = replyToMessageType?.toLowerCase();
    switch (replyType) {
      case 'text':
        return truncatedReplyText;
      case 'audio':
        return 'Voice message';
      case 'calls':
        return 'Call';
      case 'un_melt':
      case 'unmelt':
        return 'Unmelt request';
      default:
        return 'Message';
    }
  }

  /// Check if the message is from the current user
  bool isSentBy(String userId) => senderId == userId;

  /// Check if this is an audio message
  bool get isAudio => type == MessageType.audio;

  /// Check if this is a text message
  bool get isText => type == MessageType.text;

  /// Check if this is an unmelt message
  bool get isUnmelt => type == MessageType.unmelt;

  /// Check if this is a call message
  bool get isCall => type == MessageType.calls;

  /// Check if the message is still sending
  bool get isSending => state == MessageState.sending;

  /// Check if the message failed to send
  bool get hasError => state == MessageState.error;

  /// Create a copy with updated fields
  MessageDto copyWith({
    String? id,
    String? message,
    String? senderId,
    MessageType? type,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    MessageState? state,
    String? replyToMessageId,
    String? replyToMessageText,
    String? replyToSenderId,
    String? replyToMessageType,
  }) {
    return MessageDto(
      id: id ?? this.id,
      message: message ?? this.message,
      senderId: senderId ?? this.senderId,
      type: type ?? this.type,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      state: state ?? this.state,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToMessageText: replyToMessageText ?? this.replyToMessageText,
      replyToSenderId: replyToSenderId ?? this.replyToSenderId,
      replyToMessageType: replyToMessageType ?? this.replyToMessageType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageDto && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Paginated messages response DTO
class MessagesResponseDto extends BaseEntity {
  final List<MessageDto> messages;
  final String? nextCursor;
  final bool hasMore;
  final int totalCount;

  const MessagesResponseDto({
    required this.messages,
    this.nextCursor,
    this.hasMore = false,
    this.totalCount = 0,
  });
}

/// Connection DTO for chat list
/// Represents a chat connection in the domain layer
class ChatConnectionDto extends BaseEntity {
  final String id;
  final List<String> users;
  final String? lastMessage;
  final DateTime? lastUpdatedAt;
  final String? lastSenderId;
  final int unreadCount;
  final String? game;
  final String meltStatus;
  final bool isAnonymous;
  final String? initiatorId;
  final String? receiverId;
  final DateTime? connectedOn;

  // Enriched user data (the other user in the connection)
  final ChatUserDto? otherUser;

  const ChatConnectionDto({
    required this.id,
    required this.users,
    this.lastMessage,
    this.lastUpdatedAt,
    this.lastSenderId,
    this.unreadCount = 0,
    this.game,
    this.meltStatus = 'mutual',
    this.isAnonymous = false,
    this.initiatorId,
    this.receiverId,
    this.connectedOn,
    this.otherUser,
  });

  /// Check if this is a pending melt
  bool get isMeltPending => meltStatus == 'pending';

  /// Check if this is a mutual melt
  bool get isMutualMelt => meltStatus == 'mutual';

  /// Check if the given user can send messages
  bool canUserSendMessage(String userId) {
    if (isMutualMelt) return true;
    if (isMeltPending && initiatorId == userId) return true;
    return false;
  }

  /// Check if the given user is the melt receiver (can only view, not reply)
  bool isUserReceiver(String userId) {
    return isMeltPending && receiverId == userId;
  }

  /// Get the other user's ID from the connection
  String? getOtherUserId(String currentUserId) {
    return users.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  ChatConnectionDto copyWith({
    String? id,
    List<String>? users,
    String? lastMessage,
    DateTime? lastUpdatedAt,
    String? lastSenderId,
    int? unreadCount,
    String? game,
    String? meltStatus,
    bool? isAnonymous,
    String? initiatorId,
    String? receiverId,
    DateTime? connectedOn,
    ChatUserDto? otherUser,
  }) {
    return ChatConnectionDto(
      id: id ?? this.id,
      users: users ?? this.users,
      lastMessage: lastMessage ?? this.lastMessage,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      lastSenderId: lastSenderId ?? this.lastSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
      game: game ?? this.game,
      meltStatus: meltStatus ?? this.meltStatus,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      initiatorId: initiatorId ?? this.initiatorId,
      receiverId: receiverId ?? this.receiverId,
      connectedOn: connectedOn ?? this.connectedOn,
      otherUser: otherUser ?? this.otherUser,
    );
  }
}

/// Simplified user DTO for chat display
class ChatUserDto extends BaseEntity {
  final String id;
  final String? username;
  final String? fullname;
  final String? profilePhoto;
  final String? metal;
  final bool isOnline;
  final bool isVerified;

  const ChatUserDto({
    required this.id,
    this.username,
    this.fullname,
    this.profilePhoto,
    this.metal,
    this.isOnline = false,
    this.isVerified = false,
  });

  /// Get display name (username or fullname)
  String get displayName => username ?? fullname ?? 'User';
}
