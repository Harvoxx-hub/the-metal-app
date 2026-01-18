import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/meetup/meetup_repository.dart';
import 'package:metal/data/repositories/meetup/meetup_repository_providers.dart';
import 'package:metal/domain/entities/meetup_dto.dart';

/// Meetup Feed State
class MeetupFeedState {
  final bool isLoading;
  final bool isLoadingMore;
  final bool isSuccess;
  final bool isError;
  final String? errorMessage;
  final List<MeetupDto> meetups;
  final bool hasMore;
  final String? nextCursor;
  final bool filterByPreferences;

  const MeetupFeedState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage,
    this.meetups = const [],
    this.hasMore = true,
    this.nextCursor,
    this.filterByPreferences = false,
  });

  factory MeetupFeedState.initial() => const MeetupFeedState();

  factory MeetupFeedState.loading({
    List<MeetupDto>? existingMeetups,
  }) =>
      MeetupFeedState(
        isLoading: true,
        meetups: existingMeetups ?? [],
      );

  factory MeetupFeedState.success(
    List<MeetupDto> meetups, {
    bool hasMore = true,
    String? nextCursor,
    bool filterByPreferences = false,
  }) {
    return MeetupFeedState(
      isSuccess: true,
      meetups: meetups,
      hasMore: hasMore,
      nextCursor: nextCursor,
      filterByPreferences: filterByPreferences,
    );
  }

  factory MeetupFeedState.error(
    String message, {
    List<MeetupDto>? existingMeetups,
  }) =>
      MeetupFeedState(
        isError: true,
        errorMessage: message,
        meetups: existingMeetups ?? [],
      );

  MeetupFeedState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSuccess,
    bool? isError,
    String? errorMessage,
    List<MeetupDto>? meetups,
    bool? hasMore,
    String? nextCursor,
    bool? filterByPreferences,
  }) {
    return MeetupFeedState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      meetups: meetups ?? this.meetups,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
      filterByPreferences: filterByPreferences ?? this.filterByPreferences,
    );
  }
}

/// Meetup Feed ViewModel
class MeetupFeedViewModel extends StateNotifier<MeetupFeedState> {
  final MeetupRepository _repository;

  MeetupFeedViewModel({
    required MeetupRepository repository,
  })  : _repository = repository,
        super(MeetupFeedState.initial());

  Future<void> loadMeetups({
    bool filterByPreferences = false,
    bool showPast = false,
    String? communityId,
  }) async {
    if (state.isLoading) return;

    state = MeetupFeedState.loading();

    final result = await _repository.getMeetups(
      limit: 20,
      filterByPreferences: filterByPreferences,
      showPast: showPast,
      communityId: communityId,
    );

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        state = MeetupFeedState.success(
          result.data!.meetups,
          hasMore: result.data!.pagination.hasMore,
          nextCursor: result.data!.pagination.nextCursor,
          filterByPreferences: filterByPreferences,
        );
      } else {
        state = MeetupFeedState.error(
          result.errorMessage ?? 'Failed to load meetups',
        );
      }
    }
  }

  Future<void> loadMoreMeetups({
    bool showPast = false,
    String? communityId,
  }) async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    final result = await _repository.getMeetups(
      limit: 20,
      cursor: state.nextCursor,
      filterByPreferences: state.filterByPreferences,
      showPast: showPast,
      communityId: communityId,
    );

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        final allMeetups = [...state.meetups, ...result.data!.meetups];

        state = state.copyWith(
          isLoadingMore: false,
          isSuccess: true,
          meetups: allMeetups,
          hasMore: result.data!.pagination.hasMore,
          nextCursor: result.data!.pagination.nextCursor,
        );
      } else {
        state = state.copyWith(
          isLoadingMore: false,
          isError: true,
          errorMessage: result.errorMessage,
        );
      }
    }
  }

  Future<void> refresh({
    bool showPast = false,
    String? communityId,
  }) async {
    await loadMeetups(
      filterByPreferences: state.filterByPreferences,
      showPast: showPast,
      communityId: communityId,
    );
  }

  void toggleFilterByPreferences({
    bool showPast = false,
    String? communityId,
  }) {
    final newFilter = !state.filterByPreferences;
    loadMeetups(
      filterByPreferences: newFilter,
      showPast: showPast,
      communityId: communityId,
    );
  }
}

/// Meetup Feed ViewModel Provider
final meetupFeedViewModelProvider =
    StateNotifierProvider<MeetupFeedViewModel, MeetupFeedState>((ref) {
  return MeetupFeedViewModel(
    repository: ref.read(meetupRepositoryProvider),
  );
});
