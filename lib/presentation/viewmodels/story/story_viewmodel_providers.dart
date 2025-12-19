import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/story/story_repository_providers.dart';
import 'package:metal/presentation/viewmodels/story/story_viewmodel.dart';

/// Story ViewModel Provider
final storyViewModelProvider =
    StateNotifierProvider.autoDispose<StoryViewModel, StoryState>((ref) {
  final repository = ref.watch(storyRepositoryProvider);
  final viewModel = StoryViewModel(repository: repository);
  viewModel.loadStories(); // Auto-load on creation
  return viewModel;
});

/// User-specific story ViewModel Provider (family)
/// Use this to load stories for a specific user
final userStoryViewModelProvider = StateNotifierProvider.autoDispose
    .family<StoryViewModel, StoryState, String>((ref, userId) {
  final repository = ref.watch(storyRepositoryProvider);
  final viewModel = StoryViewModel(repository: repository);
  viewModel.loadUserStories(userId); // Auto-load user's stories
  return viewModel;
});
