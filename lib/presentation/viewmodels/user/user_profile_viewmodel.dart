import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/profile/profile_repository_abstract.dart';
import 'package:metal/data/repositories/thought/thought_repository.dart';
import 'package:metal/domain/entities/user_dto.dart';
import 'package:metal/domain/entities/thought_dto.dart';

/// User Profile State
class UserProfileState {
  final bool isLoading;
  final bool isLoadingThoughts;
  final bool isError;
  final String? errorMessage;
  final UserDto? user;
  final List<ThoughtDto> thoughts;
  final bool hasMoreThoughts;
  final String? nextCursor;
  /// True when GET /users/:id returned 404 (e.g. deleted user).
  final bool userUnavailable;

  const UserProfileState({
    this.isLoading = false,
    this.isLoadingThoughts = false,
    this.isError = false,
    this.errorMessage,
    this.user,
    this.thoughts = const [],
    this.hasMoreThoughts = false,
    this.nextCursor,
    this.userUnavailable = false,
  });

  factory UserProfileState.initial() => const UserProfileState();

  UserProfileState copyWith({
    bool? isLoading,
    bool? isLoadingThoughts,
    bool? isError,
    String? errorMessage,
    UserDto? user,
    List<ThoughtDto>? thoughts,
    bool? hasMoreThoughts,
    String? nextCursor,
    bool? userUnavailable,
  }) {
    return UserProfileState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingThoughts: isLoadingThoughts ?? this.isLoadingThoughts,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
      thoughts: thoughts ?? this.thoughts,
      hasMoreThoughts: hasMoreThoughts ?? this.hasMoreThoughts,
      nextCursor: nextCursor,
      userUnavailable: userUnavailable ?? this.userUnavailable,
    );
  }
}

/// User Profile ViewModel
class UserProfileViewModel extends StateNotifier<UserProfileState> {
  final ProfileRepositoryAbstract _profileRepository;
  final ThoughtRepository _thoughtRepository;
  final String userId;
  /// When set and equal to [userId], use GET /users/me for full profile; otherwise GET /users/:id returns limited public profile.
  final String? _currentUserId;

  UserProfileViewModel({
    required ProfileRepositoryAbstract profileRepository,
    required ThoughtRepository thoughtRepository,
    required this.userId,
    String? currentUserId,
  })  : _profileRepository = profileRepository,
        _thoughtRepository = thoughtRepository,
        _currentUserId = currentUserId,
        super(UserProfileState.initial()) {
    loadUserProfile();
    loadUserThoughts();
  }

  /// Load user profile data.
  /// When viewing own profile (userId == currentUser), uses GET /users/me for full data; otherwise GET /users/:id returns limited public profile.
  Future<void> loadUserProfile() async {
    if (!mounted) return;
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      isError: false,
      userUnavailable: false,
    );

    final isViewingSelf = _currentUserId != null && _currentUserId == userId;
    final result = isViewingSelf
        ? await _profileRepository.getUserProfile()
        : await _profileRepository.getUserById(userId);

    if (!mounted) return;
    if (result.isSuccess && result.data != null) {
      state = state.copyWith(
        isLoading: false,
        user: result.data,
        userUnavailable: false,
      );
    } else {
      final unavailable = result.errorHttpStatus == 404;
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: result.errorMessage ?? 'Failed to load user profile',
        userUnavailable: unavailable,
      );
    }
  }

  /// Load user's thoughts
  Future<void> loadUserThoughts() async {
    if (!mounted) return;
    if (state.isLoadingThoughts) return;

    state = state.copyWith(isLoadingThoughts: true);

    final result = await _thoughtRepository.getThoughts(
      limit: 20,
      userId: userId,
    );

    if (!mounted) return;
    if (result.isSuccess && result.data != null) {
      state = state.copyWith(
        isLoadingThoughts: false,
        thoughts: result.data!.thoughts,
        hasMoreThoughts: result.data!.hasMore,
        nextCursor: result.data!.nextCursor,
      );
    } else {
      // Do not overwrite profile load errors (e.g. 404) while user is still null.
      if (state.user != null) {
        state = state.copyWith(
          isLoadingThoughts: false,
          isError: true,
          errorMessage: result.errorMessage ?? 'Failed to load thoughts',
        );
      } else {
        state = state.copyWith(isLoadingThoughts: false);
      }
    }
  }

  /// Load more thoughts (pagination)
  Future<void> loadMoreThoughts() async {
    if (!mounted) return;
    if (state.isLoadingThoughts || !state.hasMoreThoughts || state.nextCursor == null) {
      return;
    }

    state = state.copyWith(isLoadingThoughts: true);

    final result = await _thoughtRepository.getThoughts(
      limit: 20,
      cursor: state.nextCursor,
      userId: userId,
    );

    if (!mounted) return;
    if (result.isSuccess && result.data != null) {
      final newThoughts = [...state.thoughts, ...result.data!.thoughts];
      state = state.copyWith(
        isLoadingThoughts: false,
        thoughts: newThoughts,
        hasMoreThoughts: result.data!.hasMore,
        nextCursor: result.data!.nextCursor,
      );
    } else {
      state = state.copyWith(isLoadingThoughts: false);
    }
  }

  /// Refresh all data. No-ops if notifier was disposed (e.g. user left profile screen).
  Future<void> refresh() async {
    if (!mounted) return;
    await loadUserProfile();
    if (!mounted) return;
    await loadUserThoughts();
  }
}
