import 'package:metal/core/error_handling/error_handler.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/data/datasources/remote/meetup_remote_data_source.dart';
import 'package:metal/data/repositories/meetup/meetup_repository_abstract.dart';
import 'package:metal/domain/entities/meetup_dto.dart';

/// Implementation of meetup repository
class MeetupRepository implements MeetupRepositoryAbstract {
  final MeetupRemoteDataSource _remoteDataSource;

  MeetupRepository({
    required MeetupRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<BaseState<MeetupsResponseDto>> getMeetups({
    int limit = 20,
    String? cursor,
    bool filterByPreferences = false,
    bool showPast = false,
    String? communityId,
  }) async {
    try {
      final response = await _remoteDataSource.getMeetups(
        limit: limit,
        cursor: cursor,
        filterByPreferences: filterByPreferences,
        showPast: showPast,
        communityId: communityId,
      );

      final meetupDtos = response.meetups.map((model) => model.toDomain()).toList();

      return BaseState.success(MeetupsResponseDto(
        meetups: meetupDtos,
        pagination: PaginationDto(
          hasMore: response.pagination.hasMore,
          nextCursor: response.pagination.nextCursor,
          count: response.pagination.count,
        ),
      ));
    } catch (e) {
      return ErrorHandler.handleError<MeetupsResponseDto>(e);
    }
  }

  @override
  Future<BaseState<MeetupDto>> getMeetupById(String meetupId) async {
    try {
      final response = await _remoteDataSource.getMeetupById(meetupId);
      return BaseState.success(response.toDomain());
    } catch (e) {
      return ErrorHandler.handleError<MeetupDto>(e);
    }
  }

  @override
  Future<BaseState<MeetupDto>> createMeetup(CreateMeetupDto createData) async {
    try {
      final response = await _remoteDataSource.createMeetup(createData);
      return BaseState.success(response.toDomain());
    } catch (e) {
      return ErrorHandler.handleError<MeetupDto>(e);
    }
  }

  @override
  Future<BaseState<MeetupDto>> updateMeetup({
    required String meetupId,
    required UpdateMeetupDto updateData,
  }) async {
    try {
      final response = await _remoteDataSource.updateMeetup(
        meetupId: meetupId,
        updateData: updateData,
      );
      return BaseState.success(response.toDomain());
    } catch (e) {
      return ErrorHandler.handleError<MeetupDto>(e);
    }
  }

  @override
  Future<BaseState<void>> deleteMeetup(String meetupId) async {
    try {
      await _remoteDataSource.deleteMeetup(meetupId);
      return  BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<void>(e);
    }
  }

  @override
  Future<BaseState<MeetupDto>> rsvpMeetup({
    required String meetupId,
    required String status,
  }) async {
    try {
      // RSVP might not return full meetup, so we'll just return success
      // Frontend should refresh the meetup after RSVP
      await _remoteDataSource.rsvpMeetup(
        meetupId: meetupId,
        status: status,
      );
      // Return empty meetup DTO - frontend will refresh
      // This is a limitation, but we'll handle it by refreshing after RSVP
      return BaseState.error('RSVP successful but need to refresh meetup');
    } catch (e) {
      return ErrorHandler.handleError<MeetupDto>(e);
    }
  }

  @override
  Future<BaseState<void>> inviteUsers({
    required String meetupId,
    required List<String> usernames,
  }) async {
    try {
      await _remoteDataSource.inviteUsers(
        meetupId: meetupId,
        usernames: usernames,
      );
      return  BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<void>(e);
    }
  }

  @override
  Future<BaseState<MeetupAttendeesResponseDto>> getMeetupAttendees({
    required String meetupId,
    String status = 'all',
    bool filterByPreferences = false,
  }) async {
    try {
      final response = await _remoteDataSource.getMeetupAttendees(
        meetupId: meetupId,
        status: status,
        filterByPreferences: filterByPreferences,
      );

      final attendeeDtos = response.attendees.map((model) => model.toDomain()).toList();

      return BaseState.success(MeetupAttendeesResponseDto(
        attendees: attendeeDtos,
        count: response.count,
      ));
    } catch (e) {
      return ErrorHandler.handleError<MeetupAttendeesResponseDto>(e);
    }
  }

  @override
  Future<BaseState<void>> broadcastMeetup(String meetupId) async {
    try {
      await _remoteDataSource.broadcastMeetup(meetupId);
      return  BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<void>(e);
    }
  }
}
