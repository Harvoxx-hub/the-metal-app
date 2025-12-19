import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/profile/profile_repository.dart';
import 'package:metal/data/repositories/profile/profile_repository_providers.dart';
import 'package:metal/domain/entities/blocked_user_dto.dart';

/// Blocked Users State
class BlockedUsersState {
  final bool isLoading;
  final bool isBlocking;
  final bool isUnblocking;
  final bool isSuccess;
  final bool isError;
  final String? errorMessage;
  final List<BlockedUserDto> blockedUsers;
  final bool hasMore;
  final int currentPage;

  const BlockedUsersState({
    this.isLoading = false,
    this.isBlocking = false,
    this.isUnblocking = false,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage,
    this.blockedUsers = const [],
    this.hasMore = true,
    this.currentPage = 1,
  });

  /// Initial state
  factory BlockedUsersState.initial() => const BlockedUsersState();

  /// Loading state
  factory BlockedUsersState.loading({
    List<BlockedUserDto>? existingUsers,
  }) =>
      BlockedUsersState(
        isLoading: true,
        blockedUsers: existingUsers ?? [],
      );

  /// Success state
  factory BlockedUsersState.success({
    required List<BlockedUserDto> blockedUsers,
    bool hasMore = true,
    int currentPage = 1,
  }) {
    return BlockedUsersState(
      isSuccess: true,
      blockedUsers: blockedUsers,
      hasMore: hasMore,
      currentPage: currentPage,
    );
  }

  /// Error state
  factory BlockedUsersState.error(
    String message, {
    List<BlockedUserDto>? existingUsers,
  }) =>
      BlockedUsersState(
        isError: true,
        errorMessage: message,
        blockedUsers: existingUsers ?? [],
      );

  /// Copy with
  BlockedUsersState copyWith({
    bool? isLoading,
    bool? isBlocking,
    bool? isUnblocking,
    bool? isSuccess,
    bool? isError,
    String? errorMessage,
    List<BlockedUserDto>? blockedUsers,
    bool? hasMore,
    int? currentPage,
  }) {
    return BlockedUsersState(
      isLoading: isLoading ?? this.isLoading,
      isBlocking: isBlocking ?? this.isBlocking,
      isUnblocking: isUnblocking ?? this.isUnblocking,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Blocked Users ViewModel
/// Handles loading and managing blocked users
class BlockedUsersViewModel extends StateNotifier<BlockedUsersState> {
  final ProfileRepository _repository;

  BlockedUsersViewModel({
    required ProfileRepository repository,
  })  : _repository = repository,
        super(BlockedUsersState.initial());

  /// Load blocked users list with pagination
  Future<void> loadBlockedUsers({bool refresh = false, int limit = 20}) async {
    if (state.isLoading) return;

    final page = refresh ? 1 : state.currentPage;

    if (refresh) {
      state = BlockedUsersState.loading();
    } else {
      state = state.copyWith(isLoading: true);
    }

    final result = await _repository.getBlockedUsers(
      page: page,
      limit: limit,
    );

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        final newUsers = refresh
            ? result.data!.blockedUsers
            : [...state.blockedUsers, ...result.data!.blockedUsers];

        state = BlockedUsersState.success(
          blockedUsers: newUsers,
          hasMore: result.data!.hasMore,
          currentPage: result.data!.currentPage ?? page,
        );
      } else {
        state = BlockedUsersState.error(
          result.errorMessage ?? 'Failed to load blocked users',
          existingUsers: state.blockedUsers,
        );
      }
    }
  }

  /// Block a user
  Future<bool> blockUser({
    required String userId,
    String? reason,
  }) async {
    if (state.isBlocking) return false;

    state = state.copyWith(isBlocking: true);

    final result = await _repository.blockUser(
      userId: userId,
      reason: reason,
    );

    if (mounted) {
      if (result.isSuccess) {
        state = state.copyWith(
          isBlocking: false,
          isSuccess: true,
        );

        // Refresh the list after blocking
        await loadBlockedUsers(refresh: true);

        return true;
      } else {
        state = state.copyWith(
          isBlocking: false,
          isError: true,
          errorMessage: result.errorMessage ?? 'Failed to block user',
        );

        return false;
      }
    }

    return false;
  }

  /// Unblock a user
  Future<bool> unblockUser({required String userId}) async {
    if (state.isUnblocking) return false;

    state = state.copyWith(isUnblocking: true);

    final result = await _repository.unblockUser(userId: userId);

    if (mounted) {
      if (result.isSuccess) {
        // Remove the user from the list
        final updatedUsers = state.blockedUsers
            .where((user) => user.userId != userId)
            .toList();

        state = state.copyWith(
          isUnblocking: false,
          blockedUsers: updatedUsers,
          isSuccess: true,
        );

        return true;
      } else {
        state = state.copyWith(
          isUnblocking: false,
          isError: true,
          errorMessage: result.errorMessage ?? 'Failed to unblock user',
        );

        return false;
      }
    }

    return false;
  }

  /// Refresh blocked users list
  Future<void> refreshBlockedUsers() async {
    await loadBlockedUsers(refresh: true);
  }

  /// Load more blocked users (pagination)
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;

    await loadBlockedUsers(
      refresh: false,
    );
  }
}

/// Blocked Users ViewModel Provider
final blockedUsersViewModelProvider =
    StateNotifierProvider.autoDispose<BlockedUsersViewModel, BlockedUsersState>(
        (ref) {
  final repository =
      ref.watch(profileRepositoryProvider) as ProfileRepository;
  final viewModel = BlockedUsersViewModel(repository: repository);
  viewModel.loadBlockedUsers(); // Auto-load on creation
  return viewModel;
});
