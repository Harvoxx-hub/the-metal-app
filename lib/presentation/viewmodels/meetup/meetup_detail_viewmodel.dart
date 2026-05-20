import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/meetup/meetup_repository.dart';
import 'package:metal/data/repositories/meetup/meetup_repository_providers.dart';
import 'package:metal/domain/entities/meetup_dto.dart';

/// Meetup Detail State
class MeetupDetailState {
  final bool isLoading;
  final bool isSuccess;
  final bool isError;
  /// True when the meetup was deleted or never existed (404). Distinct from
  /// generic errors so the UI can show a "meetup deleted" prompt instead of
  /// a retry screen.
  final bool isNotFound;
  final String? errorMessage;
  final MeetupDto? meetup;
  final List<MeetupRsvpDto> attendees;
  /// Accepted attendees only (for "People that are attending" section).
  final List<MeetupRsvpDto> acceptedAttendees;
  final bool isLoadingAttendees;
  final String attendeeStatus; // 'all', 'accepted', 'maybe'
  final bool filterByPreferences;

  const MeetupDetailState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isError = false,
    this.isNotFound = false,
    this.errorMessage,
    this.meetup,
    this.attendees = const [],
    this.acceptedAttendees = const [],
    this.isLoadingAttendees = false,
    this.attendeeStatus = 'accepted',
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

  factory MeetupDetailState.notFound() {
    return const MeetupDetailState(
      isError: true,
      isNotFound: true,
      errorMessage: 'This meetup has been deleted',
    );
  }

  MeetupDetailState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? isError,
    bool? isNotFound,
    String? errorMessage,
    MeetupDto? meetup,
    List<MeetupRsvpDto>? attendees,
    List<MeetupRsvpDto>? acceptedAttendees,
    bool? isLoadingAttendees,
    String? attendeeStatus,
    bool? filterByPreferences,
  }) {
    return MeetupDetailState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
      isNotFound: isNotFound ?? this.isNotFound,
      errorMessage: errorMessage ?? this.errorMessage,
      meetup: meetup ?? this.meetup,
      attendees: attendees ?? this.attendees,
      acceptedAttendees: acceptedAttendees ?? this.acceptedAttendees,
      isLoadingAttendees: isLoadingAttendees ?? this.isLoadingAttendees,
      attendeeStatus: attendeeStatus ?? this.attendeeStatus,
      filterByPreferences: filterByPreferences ?? this.filterByPreferences,
    );
  }
}

/// Meetup Detail ViewModel
class MeetupDetailViewModel extends StateNotifier<MeetupDetailState> {
  final MeetupRepository _repository;

  MeetupDetailViewModel({
    required MeetupRepository repository,
  })  : _repository = repository,
        super(MeetupDetailState.initial());

  /// [silentRefresh] when true: do not set loading state (keeps current UI, e.g. after RSVP).
  Future<void> loadMeetup(String meetupId, {bool silentRefresh = false}) async {
    if (state.isLoading && !silentRefresh) return;

    if (!silentRefresh) {
      state = MeetupDetailState.loading();
    }

    final result = await _repository.getMeetupById(meetupId);

    if (result.isSuccess && result.data != null) {
      state = MeetupDetailState.success(result.data!).copyWith(attendeeStatus: 'accepted');
      await loadAttendees(meetupId);
    } else if (!silentRefresh) {
      final is404 = result.errorHttpStatus == 404 ||
          (result.errorMessage?.toLowerCase().contains('not found') == true);
      if (is404) {
        state = MeetupDetailState.notFound();
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

    if (result.isSuccess && result.data != null) {
      final list = result.data!.attendees;
      state = state.copyWith(
        attendees: list,
        acceptedAttendees: state.attendeeStatus == 'accepted' ? list : state.acceptedAttendees,
        isLoadingAttendees: false,
      );
    } else {
      state = state.copyWith(
        isLoadingAttendees: false,
      );
    }
  }

  Future<bool> rsvpMeetup(String meetupId, String status) async {
    final result = await _repository.rsvpMeetup(
      meetupId: meetupId,
      status: status,
    );

    if (result.isSuccess || result.errorMessage?.contains('refresh') == true) {
      final currentMeetup = state.meetup;
      if (currentMeetup != null) {
        // Optimistic update: show new RSVP state immediately
        final oldStatus = currentMeetup.userRsvpStatus;
        int newAccepted = currentMeetup.acceptedCount;
        int newRejected = currentMeetup.rejectedCount;
        int newMaybe = currentMeetup.maybeCount;
        if (oldStatus == 'accepted') newAccepted = (newAccepted - 1).clamp(0, 999);
        else if (oldStatus == 'rejected') newRejected = (newRejected - 1).clamp(0, 999);
        else if (oldStatus == 'maybe') newMaybe = (newMaybe - 1).clamp(0, 999);
        if (status == 'accepted') newAccepted++;
        else if (status == 'rejected') newRejected++;
        else if (status == 'maybe') newMaybe++;
        state = state.copyWith(
          meetup: currentMeetup.copyWith(
            userRsvpStatus: status,
            acceptedCount: newAccepted,
            rejectedCount: newRejected,
            maybeCount: newMaybe,
          ),
        );
      }
      // Reload meetup from server in background (no loading spinner)
      await loadMeetup(meetupId, silentRefresh: true);
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
    state = state.copyWith(
      attendeeStatus: status,
      attendees: status == 'waitlist' ? [] : state.attendees,
    );
    if (status != 'waitlist' && state.meetup != null) {
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

  /// Re-broadcast the meetup to reach more users (creator only). Returns true on success.
  Future<bool> broadcastMeetup(String meetupId) async {
    final result = await _repository.broadcastMeetup(meetupId);
    if (result.isSuccess) {
      await loadMeetup(meetupId);
      return true;
    }
    return false;
  }

}

/// Meetup Detail ViewModel Provider (parameterized by meetupId)
final meetupDetailViewModelProvider =
    StateNotifierProvider.family<MeetupDetailViewModel, MeetupDetailState, String>((ref, meetupId) {
  return MeetupDetailViewModel(
    repository: ref.read(meetupRepositoryProvider),
  );
});
