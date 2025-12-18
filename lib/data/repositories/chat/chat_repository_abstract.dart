import 'package:metal/core/state/base.state.dart';
import 'package:metal/domain/entities/message_dto.dart';

/// Abstract repository interface for chat operations
/// Defines the contract for chat data access
abstract class ChatRepositoryAbstract {
  // ============ Connection Methods ============

  /// Get all connections for the current user
  Future<BaseState<List<ChatConnectionDto>>> getConnections({
    int limit = 20,
    String? cursor,
  });

  /// Get a single connection by ID
  Future<BaseState<ChatConnectionDto>> getConnectionById(String connectionId);

  /// Clear all messages in a connection
  Future<BaseState<void>> clearChat(String connectionId);

  /// Update game in a connection
  Future<BaseState<ChatConnectionDto>> updateGame({
    required String connectionId,
    required String? gameTitle,
  });

  // ============ Message Methods ============

  /// Get messages for a connection (paginated)
  Future<BaseState<MessagesResponseDto>> getMessages(
    String connectionId, {
    int limit = 50,
    String? cursor,
  });

  /// Get new messages since a specific message ID (for polling)
  Future<BaseState<List<MessageDto>>> getMessagesSince(
    String connectionId, {
    required String sinceMessageId,
  });

  /// Send a message
  Future<BaseState<MessageDto>> sendMessage({
    required String connectionId,
    required MessageDto message,
  });

  /// Send an audio message
  Future<BaseState<MessageDto>> sendAudioMessage({
    required String connectionId,
    required String audioFilePath,
    String? replyToMessageId,
    String? replyToMessageText,
    String? replyToSenderId,
    String? replyToMessageType,
  });

  /// Delete a message
  Future<BaseState<void>> deleteMessage(String messageId);

  /// Mark a message as read
  Future<BaseState<void>> markMessageAsRead(String messageId);

  /// Mark all messages in a connection as read
  Future<BaseState<void>> markAllMessagesAsRead(String connectionId);

  /// Update a message (for unmelt actions, etc.)
  Future<BaseState<MessageDto>> updateMessage({
    required String messageId,
    required Map<String, dynamic> data,
  });

  // ============ Unmelt Methods ============

  /// Process unmelt action (approve/reject)
  Future<BaseState<void>> processUnmeltAction({
    required String connectionId,
    required String messageId,
    required String action,
  });
}
