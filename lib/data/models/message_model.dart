import 'package:metal/domain/entities/message_dto.dart';

/// Message data model (API response)
/// Maps API response to domain entity
class MessageModel {
  final String id;
  final String message;
  final String senderId;
  final String type;
  final String? content;
  final String timestamp;
  final bool isRead;
  final String? replyToMessageId;
  final String? replyToMessageText;
  final String? replyToSenderId;
  final String? replyToMessageType;

  MessageModel({
    required this.id,
    required this.message,
    required this.senderId,
    required this.type,
    this.content,
    required this.timestamp,
    this.isRead = false,
    this.replyToMessageId,
    this.replyToMessageText,
    this.replyToSenderId,
    this.replyToMessageType,
  });

  /// Create from API JSON response
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      message: json['message'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      content: json['content'] as String?,
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      isRead: json['isRead'] as bool? ?? false,
      replyToMessageId: json['replyToMessageId'] as String?,
      replyToMessageText: json['replyToMessageText'] as String?,
      replyToSenderId: json['replyToSenderId'] as String?,
      replyToMessageType: json['replyToMessageType'] as String?,
    );
  }

  /// Convert to domain entity
  MessageDto toDomain() {
    return MessageDto(
      id: id,
      message: message,
      senderId: senderId,
      type: MessageType.fromString(type),
      content: content,
      timestamp: DateTime.tryParse(timestamp) ?? DateTime.now(),
      isRead: isRead,
      replyToMessageId: replyToMessageId,
      replyToMessageText: replyToMessageText,
      replyToSenderId: replyToSenderId,
      replyToMessageType: replyToMessageType,
    );
  }

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'senderId': senderId,
      'type': type,
      if (content != null) 'content': content,
      'timestamp': timestamp,
      'isRead': isRead,
      if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
      if (replyToMessageText != null) 'replyToMessageText': replyToMessageText,
      if (replyToSenderId != null) 'replyToSenderId': replyToSenderId,
      if (replyToMessageType != null) 'replyToMessageType': replyToMessageType,
    };
  }

  /// Create from domain entity (for sending)
  factory MessageModel.fromDomain(MessageDto dto) {
    return MessageModel(
      id: dto.id,
      message: dto.message,
      senderId: dto.senderId,
      type: dto.type.value,
      content: dto.content,
      timestamp: dto.timestamp.toIso8601String(),
      isRead: dto.isRead,
      replyToMessageId: dto.replyToMessageId,
      replyToMessageText: dto.replyToMessageText,
      replyToSenderId: dto.replyToSenderId,
      replyToMessageType: dto.replyToMessageType,
    );
  }
}

/// Messages response model from API (paginated)
class MessagesResponseModel {
  final List<MessageModel> messages;
  final String? nextCursor;
  final bool hasMore;
  final int totalCount;

  MessagesResponseModel({
    required this.messages,
    this.nextCursor,
    this.hasMore = false,
    this.totalCount = 0,
  });

  /// Create from API JSON response
  factory MessagesResponseModel.fromJson(Map<String, dynamic> json) {
    final messagesJson = json['messages'] as List<dynamic>? ?? [];
    final paginationJson = json['pagination'] as Map<String, dynamic>? ?? {};

    return MessagesResponseModel(
      messages: messagesJson
          .map((m) => MessageModel.fromJson(m as Map<String, dynamic>))
          .toList(),
      nextCursor: paginationJson['nextCursor'] as String?,
      hasMore: paginationJson['hasMore'] as bool? ?? false,
      totalCount: paginationJson['totalCount'] as int? ?? messagesJson.length,
    );
  }

  /// Convert to domain entity
  MessagesResponseDto toDomain() {
    return MessagesResponseDto(
      messages: messages.map((m) => m.toDomain()).toList(),
      nextCursor: nextCursor,
      hasMore: hasMore,
      totalCount: totalCount,
    );
  }
}

/// Connection model from API
class ConnectionModel {
  final String id;
  final List<String> users;
  final String? lastMessage;
  final String? lastUpdatedAt;
  final String? lastSenderId;
  final int unreadCount;
  final String? game;
  final String meltStatus;
  final bool isAnonymous;
  final String? initiatorId;
  final String? receiverId;
  final String? connectedOn;
  final Map<String, dynamic>? otherUserData;

  ConnectionModel({
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
    this.otherUserData,
  });

  /// Create from API JSON response
  factory ConnectionModel.fromJson(Map<String, dynamic> json) {
    return ConnectionModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? json['connectionId'] as String? ?? '',
      users: (json['users'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      lastMessage: json['lastMessage'] as String?,
      lastUpdatedAt: json['lastUpdatedAt'] as String?,
      lastSenderId: json['lastSenderId'] as String?,
      unreadCount: json['unreadCount'] as int? ?? 0,
      game: json['game'] as String?,
      meltStatus: json['meltStatus'] as String? ?? 'mutual',
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      initiatorId: json['initiatorId'] as String?,
      receiverId: json['receiverId'] as String?,
      connectedOn: json['connectedOn'] as String?,
      otherUserData: json['otherUser'] as Map<String, dynamic>?,
    );
  }

  /// Convert to domain entity
  ChatConnectionDto toDomain() {
    return ChatConnectionDto(
      id: id,
      users: users,
      lastMessage: lastMessage,
      lastUpdatedAt: lastUpdatedAt != null ? DateTime.tryParse(lastUpdatedAt!) : null,
      lastSenderId: lastSenderId,
      unreadCount: unreadCount,
      game: game,
      meltStatus: meltStatus,
      isAnonymous: isAnonymous,
      initiatorId: initiatorId,
      receiverId: receiverId,
      connectedOn: connectedOn != null ? DateTime.tryParse(connectedOn!) : null,
      otherUser: otherUserData != null ? ChatUserModel.fromJson(otherUserData!).toDomain() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'users': users,
      if (lastMessage != null) 'lastMessage': lastMessage,
      if (lastUpdatedAt != null) 'lastUpdatedAt': lastUpdatedAt,
      if (lastSenderId != null) 'lastSenderId': lastSenderId,
      'unreadCount': unreadCount,
      if (game != null) 'game': game,
      'meltStatus': meltStatus,
      'isAnonymous': isAnonymous,
      if (initiatorId != null) 'initiatorId': initiatorId,
      if (receiverId != null) 'receiverId': receiverId,
      if (connectedOn != null) 'connectedOn': connectedOn,
    };
  }
}

/// Connections list response model from API
class ConnectionsResponseModel {
  final List<ConnectionModel> connections;
  final String? nextCursor;
  final bool hasMore;
  final int totalCount;

  ConnectionsResponseModel({
    required this.connections,
    this.nextCursor,
    this.hasMore = false,
    this.totalCount = 0,
  });

  /// Create from API JSON response
  factory ConnectionsResponseModel.fromJson(Map<String, dynamic> json) {
    final connectionsJson = json['connections'] as List<dynamic>? ?? [];
    final paginationJson = json['pagination'] as Map<String, dynamic>? ?? {};

    return ConnectionsResponseModel(
      connections: connectionsJson
          .map((c) => ConnectionModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      nextCursor: paginationJson['nextCursor'] as String?,
      hasMore: paginationJson['hasMore'] as bool? ?? false,
      totalCount: paginationJson['totalCount'] as int? ?? connectionsJson.length,
    );
  }
}

/// Simplified user model for chat
class ChatUserModel {
  final String id;
  final String? username;
  final String? fullname;
  final String? profilePhoto;
  final String? metal;
  final bool isOnline;
  final bool isVerified;

  ChatUserModel({
    required this.id,
    this.username,
    this.fullname,
    this.profilePhoto,
    this.metal,
    this.isOnline = false,
    this.isVerified = false,
  });

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      username: json['username'] as String?,
      fullname: json['fullname'] as String?,
      profilePhoto: json['profilePhoto'] as String?,
      metal: json['metal'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  ChatUserDto toDomain() {
    return ChatUserDto(
      id: id,
      username: username,
      fullname: fullname,
      profilePhoto: profilePhoto,
      metal: metal,
      isOnline: isOnline,
      isVerified: isVerified,
    );
  }
}

/// Send message request model
class SendMessageRequestModel {
  final String connectionId;
  final String message;
  final String type;
  final String? content;
  final String? replyToMessageId;
  final String? replyToMessageText;
  final String? replyToSenderId;
  final String? replyToMessageType;

  SendMessageRequestModel({
    required this.connectionId,
    required this.message,
    this.type = 'text',
    this.content,
    this.replyToMessageId,
    this.replyToMessageText,
    this.replyToSenderId,
    this.replyToMessageType,
  });

  Map<String, dynamic> toJson() {
    return {
      'connectionId': connectionId,
      'message': message,
      'type': type,
      if (content != null) 'content': content,
      if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
      if (replyToMessageText != null) 'replyToMessageText': replyToMessageText,
      if (replyToSenderId != null) 'replyToSenderId': replyToSenderId,
      if (replyToMessageType != null) 'replyToMessageType': replyToMessageType,
    };
  }

  /// Create from domain entity
  factory SendMessageRequestModel.fromDomain(
    String connectionId,
    MessageDto message,
  ) {
    return SendMessageRequestModel(
      connectionId: connectionId,
      message: message.message,
      type: message.type.value,
      content: message.content,
      replyToMessageId: message.replyToMessageId,
      replyToMessageText: message.replyToMessageText,
      replyToSenderId: message.replyToSenderId,
      replyToMessageType: message.replyToMessageType,
    );
  }
}
