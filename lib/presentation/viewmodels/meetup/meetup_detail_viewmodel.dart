import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/meetup/meetup_repository.dart';
import 'package:metal/data/repositories/meetup/meetup_repository_providers.dart';
import 'package:metal/domain/entities/meetup_dto.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';

/// Meetup Detail State
class MeetupDetailState {
  final bool isLoading;
  final bool isSuccess;
  final bool isError;
  final String? errorMessage;
  final MeetupDto? meetup;
  final List<MeetupRsvpDto> attendees;
  final bool isLoadingAttendees;
  final String attendeeStatus; // 'all', 'accepted', 'maybe'
  final bool filterByPreferences;

  const MeetupDetailState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage,
    this.meetup,
    this.attendees = const [],
    this.isLoadingAttendees = false,
    this.attendeeStatus = 'all',
    this.filterByPreferences = false,
  });

  factory MeetupDetailState.initial() => const MeetupDetailState();

  factory MeetupDetailState.loading() => const MeetupDetailState(isLoading: true);

  factory MeetupDetailState.success(MeetupDto meetup) {
    return MeetupDetailState(
      isSuccess: true,
      meetup: meetup,
    );
  }

  factory MeetupDetailState.error(String message) {
    return MeetupDetailState(
      isError: true,
      errorMessage: message,
    );
  }

  MeetupDetailState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? isError,
    String? errorMessage,
    MeetupDto? meetup,
    List<MeetupRsvpDto>? attendees,
    bool? isLoadingAttendees,
    String? attendeeStatus,
    bool? filterByPreferences,
  }) {
    return MeetupDetailState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      meetup: meetup ?? this.meetup,
      attendees: attendees ?? this.attendees,
      isLoadingAttendees: isLoadingAttendees ?? this.isLoadingAttendees,
      attendeeStatus: attendeeStatus ?? this.attendeeStatus,
      filterByPreferences: filterByPreferences ?? this.filterByPreferences,
    );
  }
}

/// Meetup Detail ViewModel
class MeetupDetailViewModel extends StateNotifier<MeetupDetailState> {
  final MeetupRepository _repository;
  final String _currentUserId;

  MeetupDetailViewModel({
    required MeetupRepository repository,
    required String currentUserId,
  })  : _repository = repository,
        _currentUserId = currentUserId,
        super(MeetupDetailState.initial());

  Future<void> loadMeetup(String meetupId) async {
    if (state.isLoading) return;

    state = MeetupDetailState.loading();

    final result = await _repository.getMeetupById(meetupId);

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        state = MeetupDetailState.success(result.data!);
        // Load attendees
        await loadAttendees(meetupId);
      } else {
        state = MeetupDetailState.error(
          result.errorMessage ?? 'Failed to load meetup',
        );
      }
    }
  }

  Future<void> loadAttendees(String meetupId) async {
    state = state.copyWith(isLoadingAttendees: true);

    final result = await _repository.getMeetupAttendees(
      meetupId: meetupId,
      status: state.attendeeStatus,
      filterByPreferences: state.filterByPreferences,
    );

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        state = state.copyWith(
          attendees: result.data!.attendees,
          isLoadingAttendees: false,
        );
      } else {
        state = state.copyWith(
          isLoadingAttendees: false,
        );
      }
    }
  }

  Future<bool> rsvpMeetup(String meetupId, String status) async {
    final result = await _repository.rsvpMeetup(
      meetupId: meetupId,
      status: status,
    );

    if (result.isSuccess || result.errorMessage?.contains('refresh') == true) {
      // Reload meetup to get updated counts and RSVP status
      await loadMeetup(meetupId);
      return true;
    }

    return false;
  }

  Future<bool> inviteUsers(String meetupId, List<String> usernames) async {
    final result = await _repository.inviteUsers(
      meetupId: meetupId,
      usernames: usernames,
    );

    return result.isSuccess;
  }

  Future<bool> deleteMeetup(String meetupId) async {
    final result = await _repository.deleteMeetup(meetupId);
    return result.isSuccess;
  }

  Future<bool> updateMeetup(String meetupId, UpdateMeetupDto updateData) async {
    final result = await _repository.updateMeetup(
      meetupId: meetupId,
      updateData: updateData,
    );

    if (result.isSuccess && result.data != null) {
      state = state.copyWith(meetup: result.data!);
      return true;
    }

    return false;
  }

  void setAttendeeStatus(String status) {
    state = state.copyWith(attendeeStatus: status);
    if (state.meetup != null) {
      loadAttendees(state.meetup!.id);
    }
  }

  void toggleFilterByPreferences() {
    final newFilter = !state.filterByPreferences;
    state = state.copyWith(filterByPreferences: newFilter);
    if (state.meetup != null) {
      loadAttendees(state.meetup!.id);
    }
  }

  Future<void> refresh(String meetupId) async {
    await loadMeetup(meetupId);
  }

  bool get isCreator {
    return state.meetup?.creatorId == _currentUserId;
  }
}

/// Meetup Detail ViewModel Provider (parameterized by meetupId)
final meetupDetailViewModelProvider =
    StateNotifierProvider.family<MeetupDetailViewModel, MeetupDetailState, String>((ref, meetupId) {
  final currentUser = ref.watch(currentUserProvider);
  return MeetupDetailViewModel(
    repository: ref.read(meetupRepositoryProvider),
    currentUserId: currentUser?.id ?? '',
  );
});
