import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/services/websocket_provider.dart';
import 'package:metal/domain/usecases/chat/chat_usecase_providers.dart';
import 'package:metal/domain/usecases/chat/connection_usecase.dart';
import 'package:metal/presentation/viewmodels/chat/chat_list_viewmodel.dart';
import 'package:metal/presentation/viewmodels/chat/chat_window_viewmodel.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';

// ============ Chat List ============

/// Provider for ChatListViewModel
/// Manages the list of chat connections
final chatListViewModelProvider =
    StateNotifierProvider.autoDispose<ChatListViewModel, ChatListState>((ref) {
  final viewModel = ChatListViewModel(
    getConnectionsUseCase: ref.watch(getConnectionsUseCaseProvider),
    websocketService: ref.watch(websocketServiceProvider),
  );

  // Load connections on init
  viewModel.loadConnections();

  return viewModel;
});

/// Provider for search query in chat list
final chatSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// Provider for total unread count across all chats
final chatTotalUnreadProvider = Provider.autoDispose<int>((ref) {
  final chatState = ref.watch(chatListViewModelProvider);
  return chatState.totalUnreadCount;
});

// ============ Chat Window ============

/// Provider for ChatWindowViewModel
/// Family provider - one instance per connectionId
final chatWindowViewModelProvider = StateNotifierProvider.autoDispose
    .family<ChatWindowViewModel, ChatWindowState, String>((ref, connectionId) {
  final currentUserId = ref.watch(userStateProvider).user?.id;
  final websocketService = ref.watch(websocketServiceProvider);

  final viewModel = ChatWindowViewModel(
    connectionId: connectionId,
    currentUserId: currentUserId,
    getMessagesUseCase: ref.watch(getMessagesUseCaseProvider),
    getMessagesSinceUseCase: ref.watch(getMessagesSinceUseCaseProvider),
    sendMessageUseCase: ref.watch(sendMessageUseCaseProvider),
    deleteMessageUseCase: ref.watch(deleteMessageUseCaseProvider),
    markAllMessagesReadUseCase: ref.watch(markAllMessagesReadUseCaseProvider),
    websocketService: websocketService,
  );

  // Load messages on init
  viewModel.loadMessages();

  // Clean up when disposed
  ref.onDispose(() {
    viewModel.stopPolling();
  });

  return viewModel;
});

/// Provider for reply state in chat window
final chatReplyProvider = StateProvider.autoDispose<dynamic>((ref) => null);

// ============ Connection Detail ============

/// Provider to get a single connection by ID
final connectionDetailProvider = FutureProvider.autoDispose
    .family<dynamic, String>((ref, connectionId) async {
  final useCase = ref.watch(getConnectionByIdUseCaseProvider);
  final result =
      await useCase(GetConnectionByIdParams(connectionId: connectionId));

  if (result.isSuccess && result.data != null) {
    return result.data;
  }

  throw Exception(result.errorMessage ?? 'Failed to load connection');
});
