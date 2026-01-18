import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/services/websocket_service.dart';
import 'package:metal/core/utils/constant/chat_constants.dart';
import 'package:metal/data/models/message_model.dart';
import 'package:metal/domain/entities/message_dto.dart';
import 'package:metal/domain/usecases/chat/delete_message_usecase.dart';
import 'package:metal/domain/usecases/chat/get_messages_usecase.dart';
import 'package:metal/domain/usecases/chat/send_message_usecase.dart';

/// Chat Window State
class ChatWindowState {
  final bool isLoading;
  final bool isSuccess;
  final bool isError;
  final String? errorMessage;
  final List<MessageDto> messages;
  final bool hasMore;
  final String? nextCursor;
  final bool isSending;
  final MessageDto? replyingTo;
  final ChatConnectionDto? connection;
  final String? sendError;

  const ChatWindowState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage,
    this.messages = const [],
    this.hasMore = true,
    this.nextCursor,
    this.isSending = false,
    this.replyingTo,
    this.connection,
    this.sendError,
  });

  /// Initial state
  factory ChatWindowState.initial() => const ChatWindowState();

  /// Loading state
  factory ChatWindowState.loading({List<MessageDto>? existingMessages}) =>
      ChatWindowState(
        isLoading: true,
        messages: existingMessages ?? [],
      );

  /// Success state
  factory ChatWindowState.success(
    List<MessageDto> messages, {
    bool hasMore = true,
    String? nextCursor,
    ChatConnectionDto? connection,
  }) =>
      ChatWindowState(
        isSuccess: true,
        messages: messages,
        hasMore: hasMore,
        nextCursor: nextCursor,
        connection: connection,
      );

  /// Error state
  factory ChatWindowState.error(
    String message, {
    List<MessageDto>? existingMessages,
  }) =>
      ChatWindowState(
        isError: true,
        errorMessage: message,
        messages: existingMessages ?? [],
      );

  /// Copy with
  ChatWindowState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? isError,
    String? errorMessage,
    List<MessageDto>? messages,
    bool? hasMore,
    String? nextCursor,
    bool? isSending,
    MessageDto? replyingTo,
    bool clearReply = false,
    ChatConnectionDto? connection,
    String? sendError,
    bool clearSendError = false,
  }) {
    return ChatWindowState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      messages: messages ?? this.messages,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
      isSending: isSending ?? this.isSending,
      replyingTo: clearReply ? null : (replyingTo ?? this.replyingTo),
      connection: connection ?? this.connection,
      sendError: clearSendError ? null : (sendError ?? this.sendError),
    );
  }
}

/// Chat Window ViewModel
/// Handles message loading, sending, and real-time updates via WebSocket
class ChatWindowViewModel extends StateNotifier<ChatWindowState> {
  final String connectionId;
  final String? currentUserId;
  final GetMessagesUseCase _getMessagesUseCase;
  final GetMessagesSinceUseCase _getMessagesSinceUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final DeleteMessageUseCase _deleteMessageUseCase;
  final MarkAllMessagesReadUseCase _markAllMessagesReadUseCase;
  final WebSocketService _websocketService;

  Timer? _pollingTimer; // Fallback polling if WebSocket fails
  bool _isPollingEnabled = false;
  StreamSubscription? _websocketSubscription;
  final _random = Random();

  ChatWindowViewModel({
    required this.connectionId,
    this.currentUserId,
    required GetMessagesUseCase getMessagesUseCase,
    required GetMessagesSinceUseCase getMessagesSinceUseCase,
    required SendMessageUseCase sendMessageUseCase,
    required DeleteMessageUseCase deleteMessageUseCase,
    required MarkAllMessagesReadUseCase markAllMessagesReadUseCase,
    required WebSocketService websocketService,
  })  : _getMessagesUseCase = getMessagesUseCase,
        _getMessagesSinceUseCase = getMessagesSinceUseCase,
        _sendMessageUseCase = sendMessageUseCase,
        _deleteMessageUseCase = deleteMessageUseCase,
        _markAllMessagesReadUseCase = markAllMessagesReadUseCase,
        _websocketService = websocketService,
        super(ChatWindowState.initial());

  /// Load initial messages
  Future<void> loadMessages() async {
    if (state.isLoading) return;

    state = ChatWindowState.loading();

    final result = await _getMessagesUseCase(GetMessagesParams(
      connectionId: connectionId,
      limit: ChatConstants.initialMessagesLoad,
    ));

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        state = ChatWindowState.success(
          result.data!.messages,
          hasMore: result.data!.hasMore,
          nextCursor: result.data!.nextCursor,
        );

        // Mark all messages as read when opening chat
        _markAllAsRead();

        // Start WebSocket connection for real-time updates
        _startWebSocket();
      } else {
        state = ChatWindowState.error(
          result.errorMessage ?? 'Failed to load messages',
        );
      }
    }
  }

  /// Load more messages (pagination)
  Future<void> loadMoreMessages() async {
    if (state.isLoading || !state.hasMore || state.nextCursor == null) return;

    state = state.copyWith(isLoading: true);

    final result = await _getMessagesUseCase(GetMessagesParams(
      connectionId: connectionId,
      limit: ChatConstants.messagesPageSize,
      cursor: state.nextCursor,
    ));

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        // Prepend older messages to the list
        final updatedMessages = [
          ...result.data!.messages,
          ...state.messages,
        ];

        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          messages: updatedMessages,
          hasMore: result.data!.hasMore,
          nextCursor: result.data!.nextCursor,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isError: true,
          errorMessage: result.errorMessage,
        );
      }
    }
  }

  /// Generate a temporary ID for optimistic updates
  String _generateTempId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = _random.nextInt(999999).toString().padLeft(6, '0');
    return 'temp_${timestamp}_$randomPart';
  }

  /// Send a text message
  Future<bool> sendTextMessage(String text) async {
    if (text.trim().isEmpty) return false;

    final tempId = _generateTempId();
    final message = MessageDto(
      id: tempId,
      message: text.trim(),
      senderId:
          currentUserId ?? '', // Set current user ID for correct positioning
      type: MessageType.text,
      timestamp: DateTime.now(),
      state: MessageState.sending,
      replyToMessageId: state.replyingTo?.id,
      replyToMessageText: state.replyingTo?.message,
      replyToSenderId: state.replyingTo?.senderId,
      replyToMessageType: state.replyingTo?.type.value,
    );

    return _sendMessage(message, tempId);
  }

  /// Send an audio message
  Future<bool> sendAudioMessage(String audioUrl) async {
    final tempId = _generateTempId();
    final message = MessageDto(
      id: tempId,
      message: 'Voice message',
      senderId:
          currentUserId ?? '', // Set current user ID for correct positioning
      type: MessageType.audio,
      content: audioUrl,
      timestamp: DateTime.now(),
      state: MessageState.sending,
      replyToMessageId: state.replyingTo?.id,
      replyToMessageText: state.replyingTo?.message,
      replyToSenderId: state.replyingTo?.senderId,
      replyToMessageType: state.replyingTo?.type.value,
    );

    return _sendMessage(message, tempId);
  }

  /// Internal send message with optimistic update
  Future<bool> _sendMessage(MessageDto message, String tempId) async {
    // Optimistic update - add message immediately
    state = state.copyWith(
      messages: [...state.messages, message],
      isSending: true,
      clearReply: true,
      clearSendError: true,
    );

    final result = await _sendMessageUseCase(SendMessageParams(
      connectionId: connectionId,
      message: message,
    ));

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        // Replace temp message with real one
        final updatedMessages = state.messages.map((m) {
          if (m.id == tempId) {
            return result.data!;
          }
          return m;
        }).toList();

        state = state.copyWith(
          messages: updatedMessages,
          isSending: false,
        );
        return true;
      } else {
        // Mark message as failed
        final updatedMessages = state.messages.map((m) {
          if (m.id == tempId) {
            return m.copyWith(state: MessageState.error);
          }
          return m;
        }).toList();

        state = state.copyWith(
          messages: updatedMessages,
          isSending: false,
          sendError: result.errorMessage ?? 'Failed to send message',
        );
        return false;
      }
    }
    return false;
  }

  /// Delete a message
  Future<bool> deleteMessage(String messageId) async {
    if (messageId.isEmpty) {
      print('Cannot delete message: messageId is empty');
      return false;
    }

    // Don't try to delete temporary messages (optimistic updates that haven't been saved yet)
    if (messageId.startsWith('temp_')) {
      print(
          'Cannot delete message: message is still sending (temp ID: $messageId)');
      // Just remove it from local state since it was never saved
      if (mounted) {
        final updatedMessages =
            state.messages.where((m) => m.id != messageId).toList();
        state = state.copyWith(messages: updatedMessages);
      }
      return true;
    }

    final result = await _deleteMessageUseCase(DeleteMessageParams(
      messageId: messageId,
      connectionId: connectionId,
    ));

    if (mounted && result.isSuccess) {
      final updatedMessages =
          state.messages.where((m) => m.id != messageId).toList();

      state = state.copyWith(messages: updatedMessages);
      return true;
    }

    if (mounted && result.isError) {
      print(
          'Failed to delete message: ${result.errorMessage ?? "Unknown error"}');
    }

    return false;
  }

  /// Retry sending a failed message
  Future<bool> retryMessage(String messageId) async {
    final failedMessage = state.messages.firstWhere(
      (m) => m.id == messageId && m.hasError,
      orElse: () => throw Exception('Message not found'),
    );

    // Remove failed message
    final messagesWithoutFailed =
        state.messages.where((m) => m.id != messageId).toList();
    state = state.copyWith(messages: messagesWithoutFailed);

    // Resend
    if (failedMessage.isAudio) {
      return sendAudioMessage(failedMessage.content ?? '');
    } else {
      return sendTextMessage(failedMessage.message);
    }
  }

  /// Set message to reply to
  void setReplyingTo(MessageDto? message) {
    state = state.copyWith(replyingTo: message);
  }

  /// Clear reply
  void clearReply() {
    state = state.copyWith(clearReply: true);
  }

  /// Clear send error
  void clearSendError() {
    state = state.copyWith(clearSendError: true);
  }

  // ============ WebSocket ============

  /// Start WebSocket connection for real-time updates
  Future<void> _startWebSocket() async {
    // Connect to WebSocket if not already connected
    if (!_websocketService.isConnected) {
      await _websocketService.connect();
    }

    // Listen to WebSocket messages
    _websocketSubscription?.cancel();
    _websocketSubscription = _websocketService.messageStream.listen(
      _handleWebSocketMessage,
      onError: (error) {
        print('WebSocket error in chat: $error');
        // Fallback to polling if WebSocket fails
        _startPollingFallback();
      },
    );

    // Also listen to connection status
    _websocketService.connectionStream.listen((isConnected) {
      if (!isConnected) {
        // WebSocket disconnected, fallback to polling
        _startPollingFallback();
      } else {
        // WebSocket reconnected, stop polling
        stopPolling();
      }
    });
  }

  /// Handle WebSocket messages
  void _handleWebSocketMessage(Map<String, dynamic> message) {
    final type = message['type'] as String?;
    final data = message['data'] as Map<String, dynamic>?;

    if (data == null) return;

    switch (type) {
      case 'message':
        // New message received
        _handleNewMessage(data);
        break;

      case 'message_sent':
        // Confirmation that our message was sent (already handled by REST response)
        // Could update message state here if needed
        break;

      case 'message_read':
        // Read receipt received
        _handleReadReceipt(data);
        break;

      case 'messages_read':
        // Multiple messages read
        _handleMessagesRead(data);
        break;

      case 'message_deleted':
        // Message deleted
        _handleMessageDeleted(data);
        break;

      case 'message_updated':
        // Message updated
        _handleMessageUpdated(data);
        break;

      case 'typing':
        // Typing indicator (could be implemented in UI if needed)
        break;

      default:
        print('Unknown WebSocket message type: $type');
    }
  }

  /// Handle new message from WebSocket
  void _handleNewMessage(Map<String, dynamic> data) {
    final messageData = data['message'] as Map<String, dynamic>?;
    final msgConnectionId = data['connectionId'] as String?;

    if (messageData == null || msgConnectionId != connectionId) return;

    try {
      final messageModel = MessageModel.fromJson(messageData);
      final messageDto = messageModel.toDomain();

      // Check if message already exists (avoid duplicates)
      final existingIds = state.messages.map((m) => m.id).toSet();
      if (existingIds.contains(messageDto.id)) return;

      // Only add if not from current user (current user's messages come from REST API)
      if (currentUserId != null && messageDto.senderId != currentUserId) {
        state = state.copyWith(
          messages: [...state.messages, messageDto],
        );

        // Mark as read if chat is open
        _markAllAsRead();
      }
    } catch (e) {
      print('Error parsing WebSocket message: $e');
    }
  }

  /// Handle read receipt
  void _handleReadReceipt(Map<String, dynamic> data) {
    final messageId = data['messageId'] as String?;
    if (messageId == null) return;

    // Update message read status in state
    final updatedMessages = state.messages.map((m) {
      if (m.id == messageId) {
        return m.copyWith(isRead: true, state: MessageState.read);
      }
      return m;
    }).toList();

    state = state.copyWith(messages: updatedMessages);
  }

  /// Handle multiple messages read
  void _handleMessagesRead(Map<String, dynamic> data) {
    final msgConnectionId = data['connectionId'] as String?;
    if (msgConnectionId != connectionId) return;

    // Mark all messages sent by current user as read
    if (currentUserId != null) {
      final updatedMessages = state.messages.map((m) {
        if (m.senderId == currentUserId && !m.isRead) {
          return m.copyWith(isRead: true, state: MessageState.read);
        }
        return m;
      }).toList();

      state = state.copyWith(messages: updatedMessages);
    }
  }

  /// Handle message deleted
  void _handleMessageDeleted(Map<String, dynamic> data) {
    final messageId = data['messageId'] as String?;
    if (messageId == null) return;

    final updatedMessages =
        state.messages.where((m) => m.id != messageId).toList();

    state = state.copyWith(messages: updatedMessages);
  }

  /// Handle message updated
  void _handleMessageUpdated(Map<String, dynamic> data) {
    final messageData = data['message'] as Map<String, dynamic>?;
    if (messageData == null) return;

    try {
      final messageModel = MessageModel.fromJson(messageData);
      final updatedMessage = messageModel.toDomain();

      final updatedMessages = state.messages.map((m) {
        if (m.id == updatedMessage.id) {
          return updatedMessage;
        }
        return m;
      }).toList();

      state = state.copyWith(messages: updatedMessages);
    } catch (e) {
      print('Error parsing updated message: $e');
    }
  }

  /// Stop WebSocket subscription
  void _stopWebSocket() {
    _websocketSubscription?.cancel();
    _websocketSubscription = null;
  }

  // ============ Polling (Fallback) ============

  /// Start polling as fallback if WebSocket fails
  void _startPollingFallback() {
    if (!mounted || _isPollingEnabled) return;
    _isPollingEnabled = true;

    _pollingTimer = Timer.periodic(
      ChatConstants.pollingInterval,
      (_) {
        // Check mounted before polling
        if (!mounted || !_isPollingEnabled) {
          stopPolling();
          return;
        }
        _pollNewMessages();
      },
    );
  }

  /// Start polling for new messages (explicit fallback)
  void startPolling() {
    _startPollingFallback();
  }

  /// Stop polling
  void stopPolling() {
    _isPollingEnabled = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Poll for new messages (fallback)
  Future<void> _pollNewMessages() async {
    // Check mounted before accessing state
    if (!mounted || !_isPollingEnabled) return;

    if (state.messages.isEmpty) return;

    final lastMessageId = state.messages.last.id;

    final result = await _getMessagesSinceUseCase(GetMessagesSinceParams(
      connectionId: connectionId,
      sinceMessageId: lastMessageId,
    ));

    // Check mounted again after async operation
    if (!mounted) return;

    if (result.isSuccess && result.data != null) {
      final newMessages = result.data!;
      if (newMessages.isNotEmpty) {
        // Filter out messages we already have
        final existingIds = state.messages.map((m) => m.id).toSet();
        final uniqueNewMessages =
            newMessages.where((m) => !existingIds.contains(m.id)).toList();

        if (uniqueNewMessages.isNotEmpty) {
          // Final mounted check before updating state
          if (!mounted) return;

          state = state.copyWith(
            messages: [...state.messages, ...uniqueNewMessages],
          );

          // Mark new messages as read
          if (mounted) {
            _markAllAsRead();
          }
        }
      }
    }
  }

  /// Mark all messages as read
  Future<void> _markAllAsRead() async {
    if (!mounted) return;

    await _markAllMessagesReadUseCase(MarkAllMessagesReadParams(
      connectionId: connectionId,
    ));
  }

  /// Refresh messages
  Future<void> refresh() async {
    _stopWebSocket();
    stopPolling();
    state = ChatWindowState.initial();
    await loadMessages();
  }

  /// Find a message by ID (for scroll to reply)
  int? findMessageIndex(String messageId) {
    final index = state.messages.indexWhere((m) => m.id == messageId);
    return index >= 0 ? index : null;
  }

  @override
  void dispose() {
    _stopWebSocket();
    stopPolling();
    super.dispose();
  }
}
