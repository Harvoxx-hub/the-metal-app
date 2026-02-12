import 'package:metal/core/state/base.state.dart';
import 'package:metal/domain/entities/meetup_dto.dart';

abstract class MeetupRepositoryAbstract {
  Future<BaseState<MeetupsResponseDto>> getMeetups({
    int limit = 20,
    String? cursor,
    bool filterByPreferences = false,
    bool showPast = false,
    String? communityId,
  });

  Future<BaseState<MeetupDto>> getMeetupById(String meetupId);

  Future<BaseState<MeetupDto>> createMeetup(CreateMeetupDto createData);

  Future<BaseState<MeetupDto>> updateMeetup({
    required String meetupId,
    required UpdateMeetupDto updateData,
  });

  Future<BaseState<void>> deleteMeetup(String meetupId);

  Future<BaseState<MeetupDto>> rsvpMeetup({
    required String meetupId,
    required String status,
  });

  Future<BaseState<void>> inviteUsers({
    required String meetupId,
    required List<String> usernames,
  });

  Future<BaseState<MeetupAttendeesResponseDto>> getMeetupAttendees({
    required String meetupId,
    String status = 'all',
    bool filterByPreferences = false,
  });

  Future<BaseState<void>> broadcastMeetup(String meetupId);
}

/// Meetups response DTO
class MeetupsResponseDto {
  final List<MeetupDto> meetups;
  final PaginationDto pagination;

  MeetupsResponseDto({
    required this.meetups,
    required this.pagination,
  });
}

/// Pagination DTO
class PaginationDto {
  final bool hasMore;
  final String? nextCursor;
  final int count;

  PaginationDto({
    required this.hasMore,
    this.nextCursor,
    required this.count,
  });
}

/// Meetup attendees response DTO
class MeetupAttendeesResponseDto {
  final List<MeetupRsvpDto> attendees;
  final int count;

  MeetupAttendeesResponseDto({
    required this.attendees,
    required this.count,
  });
}
