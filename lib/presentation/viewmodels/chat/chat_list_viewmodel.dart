import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/domain/entities/message_dto.dart';
import 'package:metal/domain/usecases/chat/connection_usecase.dart';

/// Chat List State
class ChatListState {
  final bool isLoading;
  final bool isSuccess;
  final bool isError;
  final String? errorMessage;
  final List<ChatConnectionDto> connections;
  final List<ChatConnectionDto> filteredConnections;
  final String searchQuery;
  final bool hasMore;
  final String? nextCursor;
  final int totalUnreadCount;

  const ChatListState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage,
    this.connections = const [],
    this.filteredConnections = const [],
    this.searchQuery = '',
    this.hasMore = true,
    this.nextCursor,
    this.totalUnreadCount = 0,
  });

  /// Initial state
  factory ChatListState.initial() => const ChatListState();

  /// Loading state
  factory ChatListState.loading({
    List<ChatConnectionDto>? existingConnections,
  }) =>
      ChatListState(
        isLoading: true,
        connections: existingConnections ?? [],
        filteredConnections: existingConnections ?? [],
      );

  /// Success state
  factory ChatListState.success(
    List<ChatConnectionDto> connections, {
    bool hasMore = true,
    String? nextCursor,
    String searchQuery = '',
  }) {
    final totalUnread = connections.fold<int>(
      0,
      (sum, conn) => sum + conn.unreadCount,
    );

    return ChatListState(
      isSuccess: true,
      connections: connections,
      filteredConnections: connections,
      hasMore: hasMore,
      nextCursor: nextCursor,
      searchQuery: searchQuery,
      totalUnreadCount: totalUnread,
    );
  }

  /// Error state
  factory ChatListState.error(
    String message, {
    List<ChatConnectionDto>? existingConnections,
  }) =>
      ChatListState(
        isError: true,
        errorMessage: message,
        connections: existingConnections ?? [],
        filteredConnections: existingConnections ?? [],
      );

  /// Copy with
  ChatListState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? isError,
    String? errorMessage,
    List<ChatConnectionDto>? connections,
    List<ChatConnectionDto>? filteredConnections,
    String? searchQuery,
    bool? hasMore,
    String? nextCursor,
    int? totalUnreadCount,
  }) {
    return ChatListState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      connections: connections ?? this.connections,
      filteredConnections: filteredConnections ?? this.filteredConnections,
      searchQuery: searchQuery ?? this.searchQuery,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
      totalUnreadCount: totalUnreadCount ?? this.totalUnreadCount,
    );
  }
}

/// Chat List ViewModel
/// Handles loading and filtering of chat connections
class ChatListViewModel extends StateNotifier<ChatListState> {
  final GetConnectionsUseCase _getConnectionsUseCase;

  ChatListViewModel({
    required GetConnectionsUseCase getConnectionsUseCase,
  })  : _getConnectionsUseCase = getConnectionsUseCase,
        super(ChatListState.initial());

  /// Load connections
  Future<void> loadConnections() async {
    if (state.isLoading) return;

    state = ChatListState.loading();

    final result = await _getConnectionsUseCase(GetConnectionsParams(
      limit: 20,
    ));

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        // Sort by lastUpdatedAt descending (newest first)
        final sortedConnections = _sortByLastUpdated(result.data!);

        state = ChatListState.success(
          sortedConnections,
          hasMore: sortedConnections.length >= 20,
        );
      } else {
        state = ChatListState.error(
          result.errorMessage ?? 'Failed to load connections',
        );
      }
    }
  }

  /// Load more connections (pagination)
  Future<void> loadMoreConnections() async {
    if (state.isLoading || !state.hasMore || state.nextCursor == null) return;

    state = state.copyWith(isLoading: true);

    final result = await _getConnectionsUseCase(GetConnectionsParams(
      limit: 20,
      cursor: state.nextCursor,
    ));

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        final allConnections = [...state.connections, ...result.data!];
        final sortedConnections = _sortByLastUpdated(allConnections);

        // Re-apply search filter if active
        final filteredConnections = state.searchQuery.isEmpty
            ? sortedConnections
            : _filterConnections(sortedConnections, state.searchQuery);

        final totalUnread = sortedConnections.fold<int>(
          0,
          (sum, conn) => sum + conn.unreadCount,
        );

        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          connections: sortedConnections,
          filteredConnections: filteredConnections,
          hasMore: result.data!.length >= 20,
          totalUnreadCount: totalUnread,
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

  /// Search/filter connections
  void search(String query) {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      // Clear search - show all connections
      state = state.copyWith(
        searchQuery: '',
        filteredConnections: state.connections,
      );
    } else {
      // Filter connections
      final filtered = _filterConnections(state.connections, normalizedQuery);

      state = state.copyWith(
        searchQuery: normalizedQuery,
        filteredConnections: filtered,
      );
    }
  }

  /// Filter connections by query
  List<ChatConnectionDto> _filterConnections(
    List<ChatConnectionDto> connections,
    String query,
  ) {
    return connections.where((conn) {
      // Search by username
      final username = conn.otherUser?.username?.toLowerCase() ?? '';
      if (username.contains(query)) return true;

      // Search by fullname
      final fullname = conn.otherUser?.fullname?.toLowerCase() ?? '';
      if (fullname.contains(query)) return true;

      // Search by last message
      final lastMessage = conn.lastMessage?.toLowerCase() ?? '';
      if (lastMessage.contains(query)) return true;

      return false;
    }).toList();
  }

  /// Sort connections by last updated (newest first)
  List<ChatConnectionDto> _sortByLastUpdated(List<ChatConnectionDto> connections) {
    final sorted = List<ChatConnectionDto>.from(connections);
    sorted.sort((a, b) {
      final aTime = a.lastUpdatedAt ?? DateTime(1970);
      final bTime = b.lastUpdatedAt ?? DateTime(1970);
      return bTime.compareTo(aTime);
    });
    return sorted;
  }

  /// Refresh connections
  Future<void> refresh() async {
    state = ChatListState.initial();
    await loadConnections();
  }

  /// Update a connection in the list (e.g., after sending a message)
  void updateConnection(ChatConnectionDto updatedConnection) {
    final index = state.connections.indexWhere(
      (c) => c.id == updatedConnection.id,
    );

    if (index >= 0) {
      final updatedConnections = List<ChatConnectionDto>.from(state.connections);
      updatedConnections[index] = updatedConnection;

      // Re-sort
      final sortedConnections = _sortByLastUpdated(updatedConnections);

      // Re-apply filter
      final filteredConnections = state.searchQuery.isEmpty
          ? sortedConnections
          : _filterConnections(sortedConnections, state.searchQuery);

      final totalUnread = sortedConnections.fold<int>(
        0,
        (sum, conn) => sum + conn.unreadCount,
      );

      state = state.copyWith(
        connections: sortedConnections,
        filteredConnections: filteredConnections,
        totalUnreadCount: totalUnread,
      );
    }
  }

  /// Mark a connection as read (reset unread count)
  void markConnectionAsRead(String connectionId) {
    final index = state.connections.indexWhere((c) => c.id == connectionId);

    if (index >= 0 && state.connections[index].unreadCount > 0) {
      final updatedConnection = state.connections[index].copyWith(
        unreadCount: 0,
      );
      updateConnection(updatedConnection);
    }
  }

  /// Get total unread count
  int get totalUnreadCount => state.totalUnreadCount;
}
