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

  const UserProfileState({
    this.isLoading = false,
    this.isLoadingThoughts = false,
    this.isError = false,
    this.errorMessage,
    this.user,
    this.thoughts = const [],
    this.hasMoreThoughts = false,
    this.nextCursor,
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
    );
  }
}

/// User Profile ViewModel
class UserProfileViewModel extends StateNotifier<UserProfileState> {
  final ProfileRepositoryAbstract _profileRepository;
  final ThoughtRepository _thoughtRepository;
  final String userId;

  UserProfileViewModel({
    required ProfileRepositoryAbstract profileRepository,
    required ThoughtRepository thoughtRepository,
    required this.userId,
  })  : _profileRepository = profileRepository,
        _thoughtRepository = thoughtRepository,
        super(UserProfileState.initial()) {
    loadUserProfile();
    loadUserThoughts();
  }

  /// Load user profile data
  Future<void> loadUserProfile() async {
    if (!mounted) return;
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, isError: false);

    final result = await _profileRepository.getUserById(userId);

    if (!mounted) return;
    if (result.isSuccess && result.data != null) {
      state = state.copyWith(
        isLoading: false,
        user: result.data,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: result.errorMessage ?? 'Failed to load user profile',
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
      state = state.copyWith(
        isLoadingThoughts: false,
        isError: true,
        errorMessage: result.errorMessage ?? 'Failed to load thoughts',
      );
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
