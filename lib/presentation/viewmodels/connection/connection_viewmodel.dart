import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/datasources/remote/connection_remote_data_source.dart';
import 'package:metal/data/repositories/connection/connection_repository.dart';

/// State for connections list
class ConnectionViewState {
  final List<ConnectionApiModel> connections;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isError;
  final String? errorMessage;
  final bool hasMore;
  final String? nextCursor;

  const ConnectionViewState({
    this.connections = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isError = false,
    this.errorMessage,
    this.hasMore = false,
    this.nextCursor,
  });

  factory ConnectionViewState.initial() => const ConnectionViewState();

  factory ConnectionViewState.loading() => const ConnectionViewState(isLoading: true);

  factory ConnectionViewState.success(
    List<ConnectionApiModel> connections, {
    bool hasMore = false,
    String? nextCursor,
  }) =>
      ConnectionViewState(
        connections: connections,
        hasMore: hasMore,
        nextCursor: nextCursor,
      );

  factory ConnectionViewState.error(String message) =>
      ConnectionViewState(isError: true, errorMessage: message);

  ConnectionViewState copyWith({
    List<ConnectionApiModel>? connections,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isError,
    String? errorMessage,
    bool? hasMore,
    String? nextCursor,
  }) {
    return ConnectionViewState(
      connections: connections ?? this.connections,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor,
    );
  }
}

/// ViewModel for managing connections list
class ConnectionViewModel extends StateNotifier<ConnectionViewState> {
  final ConnectionRepository _repository;

  ConnectionViewModel({
    required ConnectionRepository repository,
  })  : _repository = repository,
        super(ConnectionViewState.initial());

  /// Load connections
  Future<void> loadConnections({String? status, String? meltStatus}) async {
    state = ConnectionViewState.loading();

    final result = await _repository.getConnections(
      status: status,
      meltStatus: meltStatus,
    );

    if (result.isSuccess && result.data != null) {
      state = ConnectionViewState.success(
        result.data!.connections,
        hasMore: result.data!.hasMore,
        nextCursor: result.data!.nextCursor,
      );
    } else if (result.isError) {
      state = ConnectionViewState.error(
        result.errorMessage ?? 'Failed to load connections',
      );
    } else {
      state = ConnectionViewState.success([]);
    }
  }

  /// Load more connections (pagination)
  Future<void> loadMoreConnections() async {
    if (state.isLoadingMore || !state.hasMore || state.nextCursor == null) return;

    state = state.copyWith(isLoadingMore: true);

    final result = await _repository.getConnections(
      cursor: state.nextCursor,
    );

    if (result.isSuccess && result.data != null) {
      final newConnections = [...state.connections, ...result.data!.connections];
      state = state.copyWith(
        connections: newConnections,
        isLoadingMore: false,
        hasMore: result.data!.hasMore,
        nextCursor: result.data!.nextCursor,
      );
    } else {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// Refresh connections
  Future<void> refresh() async {
    await loadConnections();
  }

  /// Get connection by user ID
  ConnectionApiModel? getConnectionByUserId(String userId) {
    try {
      return state.connections.firstWhere(
        (c) => c.users.contains(userId),
      );
    } catch (_) {
      return null;
    }
  }

  /// Get connection by connection ID
  ConnectionApiModel? getConnectionById(String connectionId) {
    try {
      return state.connections.firstWhere(
        (c) => c.id == connectionId,
      );
    } catch (_) {
      return null;
    }
  }

  /// Filter connections by search query
  List<ConnectionApiModel> filterConnections(String query) {
    if (query.isEmpty) return state.connections;

    return state.connections.where((connection) {
      final name = connection.otherUser?.fullName.toLowerCase() ?? '';
      return name.contains(query.toLowerCase());
    }).toList();
  }

  /// Remove connection from list (after delete/block)
  void removeConnection(String connectionId) {
    final newConnections = state.connections
        .where((c) => c.id != connectionId)
        .toList();
    state = state.copyWith(connections: newConnections);
  }
}
