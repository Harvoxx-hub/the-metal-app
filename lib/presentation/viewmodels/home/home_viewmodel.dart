import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/discovery/discovery_repository.dart';
import 'package:metal/domain/entities/discovery_user_dto.dart';

/// Home ViewModel State
class HomeState {
  final bool isLoading;
  final bool isSuccess;
  final bool isError;
  final String? errorMessage;
  final List<DiscoveryUserDto>? data;
  final bool hasMore;
  final String? nextCursor;
  final SwipeResultDto? lastSwipeResult;

  const HomeState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage,
    this.data,
    this.hasMore = true,
    this.nextCursor,
    this.lastSwipeResult,
  });

  /// Initial state
  factory HomeState.initial() => const HomeState(data: []);

  /// Loading state
  factory HomeState.loading({List<DiscoveryUserDto>? existingUsers}) => HomeState(
        isLoading: true,
        data: existingUsers ?? [],
      );

  /// Success state
  factory HomeState.success(
    List<DiscoveryUserDto> users, {
    bool hasMore = true,
    String? nextCursor,
    SwipeResultDto? lastSwipeResult,
  }) =>
      HomeState(
        isSuccess: true,
        data: users,
        hasMore: hasMore,
        nextCursor: nextCursor,
        lastSwipeResult: lastSwipeResult,
      );

  /// Error state
  factory HomeState.error(String message, {List<DiscoveryUserDto>? existingUsers}) =>
      HomeState(
        isError: true,
        errorMessage: message,
        data: existingUsers ?? [],
      );

  /// Copy with
  HomeState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? isError,
    String? errorMessage,
    List<DiscoveryUserDto>? data,
    bool? hasMore,
    String? nextCursor,
    SwipeResultDto? lastSwipeResult,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      data: data ?? this.data,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
      lastSwipeResult: lastSwipeResult ?? this.lastSwipeResult,
    );
  }
}

/// Home ViewModel Notifier
class HomeViewModelNotifier extends StateNotifier<HomeState> {
  final IDiscoveryRepository _repository;

  HomeViewModelNotifier(this._repository) : super(HomeState.initial());

  /// Load initial discovery users
  Future<void> loadUsers() async {
    if (state.isLoading) return;

    state = HomeState.loading();

    try {
      final response = await _repository.getDiscoveryUsers(limit: 20);

      if (mounted) {
        state = HomeState.success(
          response.users,
          hasMore: response.pagination?.hasMore ?? false,
          nextCursor: response.pagination?.nextCursor,
        );
      }
    } catch (e) {
      if (mounted) {
        state = HomeState.error(e.toString());
      }
    }
  }

  /// Load more users (pagination)
  Future<void> loadMoreUsers() async {
    if (state.isLoading || !state.hasMore || state.nextCursor == null) return;

    try {
      final response = await _repository.getDiscoveryUsers(
        limit: 20,
        cursor: state.nextCursor,
      );

      if (mounted) {
        final updatedUsers = [...(state.data ?? []), ...response.users];
        state = HomeState.success(
          updatedUsers,
          hasMore: response.pagination?.hasMore ?? false,
          nextCursor: response.pagination?.nextCursor,
        );
      }
    } catch (e) {
      // Don't override existing users on pagination error
      if (mounted) {
        state = state.copyWith(isError: true, errorMessage: e.toString());
      }
    }
  }

  /// Like a user
  Future<SwipeResultDto?> likeUser(String userId) async {
    return _recordSwipe(userId, SwipeAction.like);
  }

  /// Pass on a user
  Future<SwipeResultDto?> passUser(String userId) async {
    return _recordSwipe(userId, SwipeAction.pass);
  }

  /// Super like a user
  Future<SwipeResultDto?> superLikeUser(String userId) async {
    return _recordSwipe(userId, SwipeAction.superlike);
  }

  /// Record swipe action and remove user from list
  Future<SwipeResultDto?> _recordSwipe(String userId, SwipeAction action) async {
    try {
      final result = await _repository.recordSwipe(
        targetUserId: userId,
        action: action,
      );

      if (mounted) {
        // Remove swiped user from list
        final updatedUsers = (state.data ?? [])
            .where((user) => user.id != userId)
            .toList();

        state = HomeState.success(
          updatedUsers,
          hasMore: state.hasMore,
          nextCursor: state.nextCursor,
          lastSwipeResult: result,
        );

        // Auto-load more if running low
        if (updatedUsers.length < 5 && state.hasMore) {
          loadMoreUsers();
        }
      }

      return result;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isError: true, errorMessage: e.toString());
      }
      return null;
    }
  }

  /// Undo last swipe
  Future<void> undoLastSwipe() async {
    try {
      await _repository.undoLastSwipe();

      // Refresh the list to potentially show the undone user
      await loadUsers();
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isError: true, errorMessage: e.toString());
      }
    }
  }

  /// Refresh users list
  Future<void> refresh() async {
    state = HomeState.initial();
    await loadUsers();
  }

  /// Clear last swipe result (after showing match dialog)
  void clearLastSwipeResult() {
    state = state.copyWith(lastSwipeResult: null);
  }

  /// Get current users
  List<DiscoveryUserDto> get users => state.data ?? [];

  /// Check if there are users to show
  bool get hasUsers => users.isNotEmpty;

  /// Get next user to display
  DiscoveryUserDto? get currentUser => users.isNotEmpty ? users.first : null;
}

/// Home ViewModel Provider
final homeViewModelProvider =
    StateNotifierProvider.autoDispose<HomeViewModelNotifier, HomeState>((ref) {
  final repository = ref.watch(discoveryRepositoryProvider);
  return HomeViewModelNotifier(repository);
});

/// Convenience provider for current users
final discoveryUsersProvider = Provider.autoDispose<List<DiscoveryUserDto>>((ref) {
  return ref.watch(homeViewModelProvider).data ?? [];
});

/// Provider for checking if there's a match
final lastSwipeResultProvider = Provider.autoDispose<SwipeResultDto?>((ref) {
  return ref.watch(homeViewModelProvider).lastSwipeResult;
});

