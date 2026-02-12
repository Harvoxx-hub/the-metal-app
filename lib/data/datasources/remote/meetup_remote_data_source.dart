import 'package:metal/core/network/api_routes.dart';
import 'package:metal/core/network/dio_client.dart';
import 'package:metal/data/models/meetup_model.dart';
import 'package:metal/domain/entities/meetup_dto.dart';

/// Remote data source for meetup operations
class MeetupRemoteDataSource {
  final DioClient _client;

  MeetupRemoteDataSource(this._client);

  /// Get meetups list with pagination and filters
  Future<MeetupsResponseModel> getMeetups({
    int limit = 20,
    String? cursor,
    bool filterByPreferences = false,
    bool showPast = false,
    String? communityId,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      if (cursor != null) 'cursor': cursor,
      if (filterByPreferences) 'filterByPreferences': 'true',
      if (showPast) 'showPast': 'true',
      if (communityId != null) 'communityId': communityId,
    };

    final response = await _client.get(
      ApiRoutes.buildPath(ApiRoutes.meetups),
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
      return MeetupsResponseModel.fromJson(data);
    }

    throw Exception(response.data?['error'] ?? 'Failed to get meetups');
  }

  /// Get single meetup by ID
  Future<MeetupModel> getMeetupById(String meetupId) async {
    final response = await _client.get(
      ApiRoutes.buildPathWithId(ApiRoutes.meetupById, meetupId),
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
      return MeetupModel.fromJson(data['meetup'] ?? data);
    }

    throw Exception(response.data?['error'] ?? 'Failed to get meetup');
  }

  /// Create a new meetup
  Future<MeetupModel> createMeetup(CreateMeetupDto createData) async {
    final response = await _client.post(
      ApiRoutes.buildPath(ApiRoutes.meetups),
      data: createData.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.data != null) {
        final responseData = response.data['data'] as Map<String, dynamic>? ?? response.data;
        return MeetupModel.fromJson(responseData['meetup'] ?? responseData);
      }
    }

    throw Exception(response.data?['error'] ?? 'Failed to create meetup');
  }

  /// Update a meetup
  Future<MeetupModel> updateMeetup({
    required String meetupId,
    required UpdateMeetupDto updateData,
  }) async {
    final response = await _client.put(
      ApiRoutes.buildPathWithId(ApiRoutes.meetupById, meetupId),
      data: updateData.toJson(),
    );

    if (response.statusCode == 200 && response.data != null) {
      final responseData = response.data['data'] as Map<String, dynamic>? ?? response.data;
      return MeetupModel.fromJson(responseData);
    }

    throw Exception(response.data?['error'] ?? 'Failed to update meetup');
  }

  /// Delete a meetup
  Future<void> deleteMeetup(String meetupId) async {
    final response = await _client.delete(
      ApiRoutes.buildPathWithId(ApiRoutes.meetupById, meetupId),
    );

    if (response.statusCode != 200) {
      throw Exception(response.data?['error'] ?? 'Failed to delete meetup');
    }
  }

  /// RSVP to a meetup. API returns 200 with optional meetup; caller should refresh meetup after success.
  Future<void> rsvpMeetup({
    required String meetupId,
    required String status, // 'accepted', 'rejected', 'maybe'
  }) async {
    final response = await _client.post(
      '${ApiRoutes.buildPathWithId(ApiRoutes.meetupRsvp, meetupId)}/rsvp',
      data: {'status': status},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }

    throw Exception(response.data?['error'] ?? 'Failed to RSVP');
  }

  /// Invite users to a meetup
  Future<void> inviteUsers({
    required String meetupId,
    required List<String> usernames,
  }) async {
    final response = await _client.post(
      '${ApiRoutes.buildPathWithId(ApiRoutes.meetupInvite, meetupId)}/invite',
      data: {'usernames': usernames},
    );

    if (response.statusCode != 200) {
      throw Exception(response.data?['error'] ?? 'Failed to invite users');
    }
  }

  /// Get meetup attendees
  Future<MeetupAttendeesResponseModel> getMeetupAttendees({
    required String meetupId,
    String status = 'all', // 'all', 'accepted', 'maybe'
    bool filterByPreferences = false,
  }) async {
    final queryParams = <String, dynamic>{
      if (status != 'all') 'status': status,
      if (filterByPreferences) 'filterByPreferences': 'true',
    };

    final response = await _client.get(
      '${ApiRoutes.buildPathWithId(ApiRoutes.meetupAttendees, meetupId)}/attendees',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
      return MeetupAttendeesResponseModel.fromJson(data);
    }

    throw Exception(response.data?['error'] ?? 'Failed to get attendees');
  }

  /// Broadcast meetup (manual trigger)
  Future<void> broadcastMeetup(String meetupId) async {
    final response = await _client.post(
      '${ApiRoutes.buildPathWithId(ApiRoutes.meetupBroadcast, meetupId)}/broadcast',
    );

    if (response.statusCode != 200) {
      throw Exception(response.data?['error'] ?? 'Failed to broadcast meetup');
    }
  }
}

/// Meetups response model
class MeetupsResponseModel {
  final List<MeetupModel> meetups;
  final PaginationModel pagination;

  MeetupsResponseModel({
    required this.meetups,
    required this.pagination,
  });

  factory MeetupsResponseModel.fromJson(Map<String, dynamic> json) {
    return MeetupsResponseModel(
      meetups: (json['meetups'] as List<dynamic>?)
              ?.map((e) => MeetupModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: PaginationModel.fromJson(
          json['pagination'] as Map<String, dynamic>? ?? {}),
    );
  }
}

/// Pagination model
class PaginationModel {
  final bool hasMore;
  final String? nextCursor;
  final int count;

  PaginationModel({
    required this.hasMore,
    this.nextCursor,
    required this.count,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      hasMore: json['hasMore'] as bool? ?? false,
      nextCursor: json['nextCursor'] as String?,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Meetup attendees response model
class MeetupAttendeesResponseModel {
  final List<MeetupRsvpModel> attendees;
  final int count;

  MeetupAttendeesResponseModel({
    required this.attendees,
    required this.count,
  });

  factory MeetupAttendeesResponseModel.fromJson(Map<String, dynamic> json) {
    return MeetupAttendeesResponseModel(
      attendees: (json['attendees'] as List<dynamic>?)
              ?.map((e) => MeetupRsvpModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}
