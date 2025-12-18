import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/utils/constant/chat_constants.dart';
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
/// Handles message loading, sending, and polling
class ChatWindowViewModel extends StateNotifier<ChatWindowState> {
  final String connectionId;
  final GetMessagesUseCase _getMessagesUseCase;
  final GetMessagesSinceUseCase _getMessagesSinceUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final DeleteMessageUseCase _deleteMessageUseCase;
  final MarkAllMessagesReadUseCase _markAllMessagesReadUseCase;

  Timer? _pollingTimer;
  bool _isPollingEnabled = false;
  final _random = Random();

  ChatWindowViewModel({
    required this.connectionId,
    required GetMessagesUseCase getMessagesUseCase,
    required GetMessagesSinceUseCase getMessagesSinceUseCase,
    required SendMessageUseCase sendMessageUseCase,
    required DeleteMessageUseCase deleteMessageUseCase,
    required MarkAllMessagesReadUseCase markAllMessagesReadUseCase,
  })  : _getMessagesUseCase = getMessagesUseCase,
        _getMessagesSinceUseCase = getMessagesSinceUseCase,
        _sendMessageUseCase = sendMessageUseCase,
        _deleteMessageUseCase = deleteMessageUseCase,
        _markAllMessagesReadUseCase = markAllMessagesReadUseCase,
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

        // Start polling for new messages
        startPolling();
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
      senderId: '', // Will be set by backend
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
      senderId: '',
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
    final result = await _deleteMessageUseCase(DeleteMessageParams(
      messageId: messageId,
    ));

    if (mounted && result.isSuccess) {
      final updatedMessages = state.messages
          .where((m) => m.id != messageId)
          .toList();

      state = state.copyWith(messages: updatedMessages);
      return true;
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
    final messagesWithoutFailed = state.messages
        .where((m) => m.id != messageId)
        .toList();
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

  // ============ Polling ============

  /// Start polling for new messages
  void startPolling() {
    if (_isPollingEnabled) return;
    _isPollingEnabled = true;

    _pollingTimer = Timer.periodic(
      ChatConstants.pollingInterval,
      (_) => _pollNewMessages(),
    );
  }

  /// Stop polling
  void stopPolling() {
    _isPollingEnabled = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Poll for new messages
  Future<void> _pollNewMessages() async {
    if (!_isPollingEnabled || state.messages.isEmpty) return;

    final lastMessageId = state.messages.last.id;

    final result = await _getMessagesSinceUseCase(GetMessagesSinceParams(
      connectionId: connectionId,
      sinceMessageId: lastMessageId,
    ));

    if (mounted && result.isSuccess && result.data != null) {
      final newMessages = result.data!;
      if (newMessages.isNotEmpty) {
        // Filter out messages we already have
        final existingIds = state.messages.map((m) => m.id).toSet();
        final uniqueNewMessages = newMessages
            .where((m) => !existingIds.contains(m.id))
            .toList();

        if (uniqueNewMessages.isNotEmpty) {
          state = state.copyWith(
            messages: [...state.messages, ...uniqueNewMessages],
          );

          // Mark new messages as read
          _markAllAsRead();
        }
      }
    }
  }

  /// Mark all messages as read
  Future<void> _markAllAsRead() async {
    await _markAllMessagesReadUseCase(MarkAllMessagesReadParams(
      connectionId: connectionId,
    ));
  }

  /// Refresh messages
  Future<void> refresh() async {
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
    stopPolling();
    super.dispose();
  }
}
