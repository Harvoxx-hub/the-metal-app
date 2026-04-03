import 'package:metal/core/error_handling/error_handler.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/data/datasources/remote/chat_remote_data_source.dart';
import 'package:metal/data/models/chat_assistant_model.dart';
import 'package:metal/data/models/message_model.dart';
import 'package:metal/data/repositories/chat/chat_repository_abstract.dart';
import 'package:metal/domain/entities/message_dto.dart';

/// Implementation of chat repository
/// Coordinates data sources and handles error mapping
class ChatRepository implements ChatRepositoryAbstract {
  final ChatRemoteDataSource _remoteDataSource;

  ChatRepository({
    required ChatRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  // ============ Connection Methods ============

  @override
  Future<BaseState<List<ChatConnectionDto>>> getConnections({
    int limit = 20,
    String? cursor,
  }) async {
    try {
      final response = await _remoteDataSource.getConnections(
        limit: limit,
        cursor: cursor,
      );

      final connections = response.connections
          .map((c) => c.toDomain())
          .toList();

      return BaseState.success(connections);
    } catch (e) {
      return ErrorHandler.handleError<List<ChatConnectionDto>>(e);
    }
  }

  @override
  Future<BaseState<ChatConnectionDto>> getConnectionById(
    String connectionId,
  ) async {
    try {
      final response = await _remoteDataSource.getConnectionById(connectionId);
      return BaseState.success(response.toDomain());
    } catch (e) {
      return ErrorHandler.handleError<ChatConnectionDto>(e);
    }
  }

  @override
  Future<BaseState<void>> clearChat(String connectionId) async {
    try {
      await _remoteDataSource.clearChat(connectionId);
      return BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<void>(e);
    }
  }

  @override
  Future<BaseState<ChatConnectionDto>> updateGame({
    required String connectionId,
    required String? gameTitle,
  }) async {
    try {
      final response = await _remoteDataSource.updateGame(
        connectionId: connectionId,
        gameTitle: gameTitle,
      );
      return BaseState.success(response.toDomain());
    } catch (e) {
      return ErrorHandler.handleError<ChatConnectionDto>(e);
    }
  }

  // ============ Message Methods ============

  @override
  Future<BaseState<MessagesResponseDto>> getMessages(
    String connectionId, {
    int limit = 50,
    String? cursor,
  }) async {
    try {
      final response = await _remoteDataSource.getMessages(
        connectionId,
        limit: limit,
        cursor: cursor,
      );
      return BaseState.success(response.toDomain());
    } catch (e) {
      return ErrorHandler.handleError<MessagesResponseDto>(e);
    }
  }

  @override
  Future<BaseState<List<MessageDto>>> getMessagesSince(
    String connectionId, {
    required String sinceMessageId,
  }) async {
    try {
      final messages = await _remoteDataSource.getMessagesSince(
        connectionId,
        sinceMessageId: sinceMessageId,
      );
      return BaseState.success(
        messages.map((m) => m.toDomain()).toList(),
      );
    } catch (e) {
      return ErrorHandler.handleError<List<MessageDto>>(e);
    }
  }

  @override
  Future<BaseState<MessageDto>> sendMessage({
    required String connectionId,
    required MessageDto message,
  }) async {
    try {
      final request = SendMessageRequestModel.fromDomain(connectionId, message);
      final response = await _remoteDataSource.sendMessage(request);
      return BaseState.success(response.toDomain());
    } catch (e) {
      return ErrorHandler.handleError<MessageDto>(e);
    }
  }

  @override
  Future<BaseState<MessageDto>> sendAudioMessage({
    required String connectionId,
    required String audioFilePath,
    String? replyToMessageId,
    String? replyToMessageText,
    String? replyToSenderId,
    String? replyToMessageType,
  }) async {
    try {
      final response = await _remoteDataSource.sendAudioMessage(
        connectionId: connectionId,
        audioFilePath: audioFilePath,
        replyToMessageId: replyToMessageId,
        replyToMessageText: replyToMessageText,
        replyToSenderId: replyToSenderId,
        replyToMessageType: replyToMessageType,
      );
      return BaseState.success(response.toDomain());
    } catch (e) {
      return ErrorHandler.handleError<MessageDto>(e);
    }
  }

  @override
  Future<BaseState<void>> deleteMessage(String messageId, String connectionId) async {
    try {
      await _remoteDataSource.deleteMessage(messageId, connectionId);
      return BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<void>(e);
    }
  }

  @override
  Future<BaseState<void>> markMessageAsRead(String messageId) async {
    try {
      await _remoteDataSource.markMessageAsRead(messageId);
      return BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<void>(e);
    }
  }

  @override
  Future<BaseState<void>> markAllMessagesAsRead(String connectionId) async {
    try {
      await _remoteDataSource.markAllMessagesAsRead(connectionId);
      return BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<void>(e);
    }
  }

  @override
  Future<BaseState<MessageDto>> updateMessage({
    required String messageId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _remoteDataSource.updateMessage(
        messageId: messageId,
        data: data,
      );
      return BaseState.success(response.toDomain());
    } catch (e) {
      return ErrorHandler.handleError<MessageDto>(e);
    }
  }

  // ============ Chat Assistant Methods ============

  @override
  Future<BaseState<ChatAssistantResponseModel>> getChatSuggestions({
    required String connectionId,
    required String mode,
    required String tone,
    String? interactiveKind,
  }) async {
    try {
      final response = await _remoteDataSource.getChatSuggestions(
        connectionId: connectionId,
        mode: mode,
        tone: tone,
        interactiveKind: interactiveKind,
      );
      return BaseState.success(response);
    } catch (e) {
      return ErrorHandler.handleError<ChatAssistantResponseModel>(e);
    }
  }

  // ============ Unmelt Methods ============

  @override
  Future<BaseState<void>> processUnmeltAction({
    required String connectionId,
    required String messageId,
    required String action,
  }) async {
    try {
      await _remoteDataSource.processUnmeltAction(
        connectionId: connectionId,
        messageId: messageId,
        action: action,
      );
      return BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<void>(e);
    }
  }
}
