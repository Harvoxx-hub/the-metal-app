import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/error_handling/error_handler.dart';
import 'package:metal/data/repositories/thought/thought_repository.dart';
import 'package:metal/domain/entities/thought_dto.dart';
import 'package:metal/presentation/viewmodels/thought/thought_providers.dart';

/// Discovery User Thoughts State
class DiscoveryUserThoughtsState {
  final bool isLoading;
  final bool isError;
  final String? errorMessage;
  final List<ThoughtDto> thoughts;

  const DiscoveryUserThoughtsState({
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
    this.thoughts = const [],
  });

  factory DiscoveryUserThoughtsState.initial() => const DiscoveryUserThoughtsState();

  factory DiscoveryUserThoughtsState.loading() => const DiscoveryUserThoughtsState(
        isLoading: true,
      );

  factory DiscoveryUserThoughtsState.success(List<ThoughtDto> thoughts) =>
      DiscoveryUserThoughtsState(
        isLoading: false,
        thoughts: thoughts,
      );

  factory DiscoveryUserThoughtsState.error(String message) =>
      DiscoveryUserThoughtsState(
        isLoading: false,
        isError: true,
        errorMessage: message,
      );

  DiscoveryUserThoughtsState copyWith({
    bool? isLoading,
    bool? isError,
    String? errorMessage,
    List<ThoughtDto>? thoughts,
  }) {
    return DiscoveryUserThoughtsState(
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      thoughts: thoughts ?? this.thoughts,
    );
  }
}

/// Discovery User Thoughts ViewModel
class DiscoveryUserThoughtsViewModel extends StateNotifier<DiscoveryUserThoughtsState> {
  final ThoughtRepository _thoughtRepository;
  final String userId;

  DiscoveryUserThoughtsViewModel({
    required ThoughtRepository thoughtRepository,
    required this.userId,
  })  : _thoughtRepository = thoughtRepository,
        super(DiscoveryUserThoughtsState.initial()) {
    loadThoughts();
  }

  /// Load recent thoughts for the user
  Future<void> loadThoughts() async {
    if (state.isLoading) return;

    state = DiscoveryUserThoughtsState.loading();

    try {
      final response = await _thoughtRepository.getThoughts(
        userId: userId,
        limit: 10, // Fetch more to filter out voice thoughts
      );

      if (mounted) {
        if (response.isSuccess && response.data != null) {
          // Filter out voice thoughts and get up to 5 text thoughts
          final allThoughts = response.data!.thoughts;
          final textThoughts = allThoughts
              .where((thought) =>
                  thought.type != 'voice' && thought.content.isNotEmpty)
              .take(5)
              .toList();

          state = DiscoveryUserThoughtsState.success(textThoughts);
        } else {
          final errorMessage =
              response.errorMessage ?? 'Failed to load thoughts';
          state = DiscoveryUserThoughtsState.error(errorMessage);
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = ErrorHandler.handleErrorToString(e);
        state = DiscoveryUserThoughtsState.error(errorMessage);
      }
    }
  }

  /// Refresh thoughts
  Future<void> refresh() async {
    await loadThoughts();
  }
}

/// Provider for discovery user thoughts
/// Takes userId as parameter
final discoveryUserThoughtsProvider = StateNotifierProvider.family
    .autoDispose<DiscoveryUserThoughtsViewModel, DiscoveryUserThoughtsState, String>(
  (ref, userId) {
    final thoughtRepository = ref.watch(thoughtRepositoryProvider);
    return DiscoveryUserThoughtsViewModel(
      thoughtRepository: thoughtRepository,
      userId: userId,
    );
  },
);
