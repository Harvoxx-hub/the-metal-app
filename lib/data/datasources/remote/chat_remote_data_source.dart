import 'package:metal/core/network/api_routes.dart';
import 'package:metal/core/network/dio_client.dart';
import 'package:metal/data/models/message_model.dart';

/// Remote data source for chat operations
/// Handles API communication for messages and connections
class ChatRemoteDataSource {
  final DioClient _client;

  ChatRemoteDataSource(this._client);

  // ============ Connection Methods ============

  /// Get all connections for the current user
  /// Returns paginated list of chat connections
  Future<ConnectionsResponseModel> getConnections({
    int limit = 20,
    String? cursor,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      if (cursor != null) 'cursor': cursor,
    };

    final response = await _client.get(
      ApiRoutes.buildPath(ApiRoutes.connections),
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
      return ConnectionsResponseModel.fromJson(data);
    }

    throw Exception(response.data?['error'] ?? 'Failed to get connections');
  }

  /// Get a single connection by ID
  Future<ConnectionModel> getConnectionById(String connectionId) async {
    final response = await _client.get(
      '${ApiRoutes.buildPath(ApiRoutes.connectionById)}/$connectionId',
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
      return ConnectionModel.fromJson(data);
    }

    throw Exception(response.data?['error'] ?? 'Failed to get connection');
  }

  /// Clear chat history for a connection
  Future<void> clearChat(String connectionId) async {
    final response = await _client.delete(
      '${ApiRoutes.buildPath(ApiRoutes.clearChat)}/$connectionId/clear',
    );

    if (response.statusCode != 200) {
      throw Exception(response.data?['error'] ?? 'Failed to clear chat');
    }
  }

  /// Update game in a connection
  Future<ConnectionModel> updateGame({
    required String connectionId,
    required String? gameTitle,
  }) async {
    final response = await _client.patch(
      '${ApiRoutes.buildPath(ApiRoutes.connectionById)}/$connectionId',
      data: {'game': gameTitle},
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
      return ConnectionModel.fromJson(data);
    }

    throw Exception(response.data?['error'] ?? 'Failed to update game');
  }

  // ============ Message Methods ============

  /// Get messages for a connection
  /// Returns paginated list of messages
  Future<MessagesResponseModel> getMessages(
    String connectionId, {
    int limit = 50,
    String? cursor,
    String? sinceMessageId,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      if (cursor != null) 'cursor': cursor,
      if (sinceMessageId != null) 'since': sinceMessageId,
    };

    final response = await _client.get(
      '${ApiRoutes.buildPath(ApiRoutes.messagesByConnection)}/$connectionId',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
      return MessagesResponseModel.fromJson(data);
    }

    throw Exception(response.data?['error'] ?? 'Failed to get messages');
  }

  /// Get messages since a specific message ID (for polling)
  Future<List<MessageModel>> getMessagesSince(
    String connectionId, {
    required String sinceMessageId,
  }) async {
    final response = await _client.get(
      '${ApiRoutes.buildPath(ApiRoutes.messagesByConnection)}/$connectionId',
      queryParameters: {'since': sinceMessageId},
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
      final messagesJson = data['messages'] as List<dynamic>? ?? [];
      return messagesJson
          .map((m) => MessageModel.fromJson(m as Map<String, dynamic>))
          .toList();
    }

    throw Exception(response.data?['error'] ?? 'Failed to get messages');
  }

  /// Send a message
  Future<MessageModel> sendMessage(SendMessageRequestModel request) async {
    final response = await _client.post(
      ApiRoutes.buildPath(ApiRoutes.messages),
      data: request.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.data != null) {
        final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
        return MessageModel.fromJson(data);
      }
    }

    throw Exception(response.data?['error'] ?? 'Failed to send message');
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    final response = await _client.delete(
      '${ApiRoutes.buildPath(ApiRoutes.messageById)}/$messageId',
    );

    if (response.statusCode != 200) {
      throw Exception(response.data?['error'] ?? 'Failed to delete message');
    }
  }

  /// Mark a message as read
  Future<void> markMessageAsRead(String messageId) async {
    final response = await _client.put(
      '${ApiRoutes.buildPath(ApiRoutes.markMessageRead)}/$messageId/read',
    );

    if (response.statusCode != 200) {
      throw Exception(response.data?['error'] ?? 'Failed to mark message as read');
    }
  }

  /// Mark all messages in a connection as read
  Future<void> markAllMessagesAsRead(String connectionId) async {
    final response = await _client.put(
      '${ApiRoutes.buildPath(ApiRoutes.connectionById)}/$connectionId/read-all',
    );

    if (response.statusCode != 200) {
      throw Exception(response.data?['error'] ?? 'Failed to mark messages as read');
    }
  }

  /// Update a message (for unmelt actions, etc.)
  Future<MessageModel> updateMessage({
    required String messageId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _client.patch(
      '${ApiRoutes.buildPath(ApiRoutes.messageById)}/$messageId',
      data: data,
    );

    if (response.statusCode == 200 && response.data != null) {
      final responseData = response.data['data'] as Map<String, dynamic>? ?? response.data;
      return MessageModel.fromJson(responseData);
    }

    throw Exception(response.data?['error'] ?? 'Failed to update message');
  }

  // ============ Unmelt Methods ============

  /// Process unmelt action (approve/reject)
  Future<void> processUnmeltAction({
    required String connectionId,
    required String messageId,
    required String action, // 'approve' or 'reject'
  }) async {
    final response = await _client.post(
      '${ApiRoutes.buildPath(ApiRoutes.connectionById)}/$connectionId/unmelt',
      data: {
        'messageId': messageId,
        'action': action,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(response.data?['error'] ?? 'Failed to process unmelt action');
    }
  }
}
