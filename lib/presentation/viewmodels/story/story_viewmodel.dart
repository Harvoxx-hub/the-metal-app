import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/story/story_repository.dart';
import 'package:metal/presentation/viewmodels/story/story_viewmodel_providers.dart';
import 'package:metal/domain/entities/story_dto.dart';

/// Story State
class StoryState {
  final bool isLoading;
  final bool isCreating;
  final bool isSuccess;
  final bool isError;
  final String? errorMessage;
  final List<StoryGroupDto> storyGroups;
  final int? currentViewingGroupIndex;
  final int? currentViewingStoryIndex;

  const StoryState({
    this.isLoading = false,
    this.isCreating = false,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage,
    this.storyGroups = const [],
    this.currentViewingGroupIndex,
    this.currentViewingStoryIndex,
  });

  /// Initial state
  factory StoryState.initial() => const StoryState();

  /// Loading state
  factory StoryState.loading({
    List<StoryGroupDto>? existingGroups,
  }) =>
      StoryState(
        isLoading: true,
        storyGroups: existingGroups ?? [],
      );

  /// Success state
  factory StoryState.success({
    required List<StoryGroupDto> storyGroups,
  }) =>
      StoryState(
        isSuccess: true,
        storyGroups: storyGroups,
      );

  /// Error state
  factory StoryState.error(
    String message, {
    List<StoryGroupDto>? existingGroups,
  }) =>
      StoryState(
        isError: true,
        errorMessage: message,
        storyGroups: existingGroups ?? [],
      );

  /// Copy with
  StoryState copyWith({
    bool? isLoading,
    bool? isCreating,
    bool? isSuccess,
    bool? isError,
    String? errorMessage,
    List<StoryGroupDto>? storyGroups,
    int? currentViewingGroupIndex,
    int? currentViewingStoryIndex,
  }) {
    return StoryState(
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      storyGroups: storyGroups ?? this.storyGroups,
      currentViewingGroupIndex:
          currentViewingGroupIndex ?? this.currentViewingGroupIndex,
      currentViewingStoryIndex:
          currentViewingStoryIndex ?? this.currentViewingStoryIndex,
    );
  }

  bool get hasStories => storyGroups.isNotEmpty;
  bool get hasUnviewedStories =>
      storyGroups.any((group) => group.hasUnviewed);
}

/// Story ViewModel
/// Handles loading, creating, and viewing stories
class StoryViewModel extends StateNotifier<StoryState> {
  final StoryRepository _repository;

  StoryViewModel({
    required StoryRepository repository,
  })  : _repository = repository,
        super(StoryState.initial());

  /// Load all stories
  Future<void> loadStories({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = StoryState.loading();
    } else {
      state = state.copyWith(isLoading: true);
    }

    final result = await _repository.getStories();

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        state = StoryState.success(
          storyGroups: result.data!,
        );
      } else {
        state = StoryState.error(
          result.errorMessage ?? 'Failed to load stories',
          existingGroups: state.storyGroups,
        );
      }
    }
  }

  /// Load stories for specific user
  Future<void> loadUserStories(String userId) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    final result = await _repository.getStories(userId: userId);

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        state = StoryState.success(
          storyGroups: result.data!,
        );
      } else {
        state = StoryState.error(
          result.errorMessage ?? 'Failed to load user stories',
          existingGroups: state.storyGroups,
        );
      }
    }
  }

  /// Create a new story
  Future<bool> createStory({
    required File file,
    required String mediaType,
    required String contentType,
    int? duration,
    String? caption,
  }) async {
    if (state.isCreating) return false;

    state = state.copyWith(isCreating: true);

    final result = await _repository.createStory(
      file: file,
      mediaType: mediaType,
      contentType: contentType,
      duration: duration,
      caption: caption,
    );

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        // Refresh stories to show the new story
        state = state.copyWith(isCreating: false);
        await loadStories(refresh: true);
        return true;
      } else {
        state = state.copyWith(
          isCreating: false,
          isError: true,
          errorMessage: result.errorMessage ?? 'Failed to create story',
        );
        return false;
      }
    }

    return false;
  }

  /// Mark a story as viewed
  Future<void> markAsViewed(String storyId) async {
    await _repository.markStoryAsViewed(storyId);

    // Update local state to mark story as viewed
    if (mounted) {
      final updatedGroups = state.storyGroups.map((group) {
        final updatedStories = group.stories.map((story) {
          if (story.id == storyId) {
            return story.copyWith(isViewed: true);
          }
          return story;
        }).toList();

        final hasUnviewed = updatedStories.any((s) => !s.isViewed);

        return group.copyWith(
          stories: updatedStories,
          hasUnviewed: hasUnviewed,
        );
      }).toList();

      state = state.copyWith(storyGroups: updatedGroups);
    }
  }

  /// Delete a story
  Future<bool> deleteStory(String storyId) async {
    final result = await _repository.deleteStory(storyId);

    if (mounted) {
      if (result.isSuccess) {
        // Remove story from local state
        final updatedGroups = state.storyGroups
            .map((group) {
              final updatedStories =
                  group.stories.where((s) => s.id != storyId).toList();

              if (updatedStories.isEmpty) {
                return null; // Mark group for removal
              }

              final hasUnviewed = updatedStories.any((s) => !s.isViewed);

              return group.copyWith(
                stories: updatedStories,
                hasUnviewed: hasUnviewed,
              );
            })
            .whereType<StoryGroupDto>() // Remove null groups
            .toList();

        state = state.copyWith(storyGroups: updatedGroups);
        return true;
      } else {
        state = state.copyWith(
          isError: true,
          errorMessage: result.errorMessage ?? 'Failed to delete story',
        );
        return false;
      }
    }

    return false;
  }

  /// Set currently viewing story (for tracking pagination)
  void setCurrentViewing(int groupIndex, int storyIndex) {
    state = state.copyWith(
      currentViewingGroupIndex: groupIndex,
      currentViewingStoryIndex: storyIndex,
    );
  }

  /// Refresh stories
  Future<void> refreshStories() async {
    await loadStories(refresh: true);
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(isError: false, errorMessage: null);
  }
}
