import 'package:metal/data/models/user_preferences_model.dart';

/// Meetup domain entity (DTO)
class MeetupDto {
  final String id;
  final String eventName;
  final String date;
  final String time;
  final DateTime eventDateTime;
  final String placeName;
  final PlaceLocationDto? placeLocation;
  final String? description;
  final int maxParticipants;
  final String creatorId;
  final String? creatorUsername;
  final String? creatorPhoto;
  final String broadcastType; // 'all' | 'preferences' | 'communities'
  final int broadcastRadius;
  final List<String> selectedCommunityIds;
  final UserPreferencesModel? preferences;
  final String? communityId;
  final String status; // 'open' | 'closed' | 'past'
  final int acceptedCount;
  final int rejectedCount;
  final int maybeCount;
  final List<String> invitedUserIds;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? distance; // Distance in km from current user
  final String? userRsvpStatus; // 'accepted' | 'rejected' | 'maybe' | null

  const MeetupDto({
    required this.id,
    required this.eventName,
    required this.date,
    required this.time,
    required this.eventDateTime,
    required this.placeName,
    this.placeLocation,
    this.description,
    required this.maxParticipants,
    required this.creatorId,
    this.creatorUsername,
    this.creatorPhoto,
    required this.broadcastType,
    required this.broadcastRadius,
    required this.selectedCommunityIds,
    this.preferences,
    this.communityId,
    required this.status,
    required this.acceptedCount,
    required this.rejectedCount,
    required this.maybeCount,
    required this.invitedUserIds,
    required this.isPinned,
    required this.createdAt,
    required this.updatedAt,
    this.distance,
    this.userRsvpStatus,
  });

  MeetupDto copyWith({
    String? id,
    String? eventName,
    String? date,
    String? time,
    DateTime? eventDateTime,
    String? placeName,
    PlaceLocationDto? placeLocation,
    String? description,
    int? maxParticipants,
    String? creatorId,
    String? creatorUsername,
    String? creatorPhoto,
    String? broadcastType,
    int? broadcastRadius,
    List<String>? selectedCommunityIds,
    UserPreferencesModel? preferences,
    String? communityId,
    String? status,
    int? acceptedCount,
    int? rejectedCount,
    int? maybeCount,
    List<String>? invitedUserIds,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? distance,
    String? userRsvpStatus,
  }) {
    return MeetupDto(
      id: id ?? this.id,
      eventName: eventName ?? this.eventName,
      date: date ?? this.date,
      time: time ?? this.time,
      eventDateTime: eventDateTime ?? this.eventDateTime,
      placeName: placeName ?? this.placeName,
      placeLocation: placeLocation ?? this.placeLocation,
      description: description ?? this.description,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      creatorId: creatorId ?? this.creatorId,
      creatorUsername: creatorUsername ?? this.creatorUsername,
      creatorPhoto: creatorPhoto ?? this.creatorPhoto,
      broadcastType: broadcastType ?? this.broadcastType,
      broadcastRadius: broadcastRadius ?? this.broadcastRadius,
      selectedCommunityIds: selectedCommunityIds ?? this.selectedCommunityIds,
      preferences: preferences ?? this.preferences,
      communityId: communityId ?? this.communityId,
      status: status ?? this.status,
      acceptedCount: acceptedCount ?? this.acceptedCount,
      rejectedCount: rejectedCount ?? this.rejectedCount,
      maybeCount: maybeCount ?? this.maybeCount,
      invitedUserIds: invitedUserIds ?? this.invitedUserIds,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      distance: distance ?? this.distance,
      userRsvpStatus: userRsvpStatus ?? this.userRsvpStatus,
    );
  }

  bool get isPast => status == 'past';
  bool get isClosed => status == 'closed';
  bool get isOpen => status == 'open';
  bool get isFull => acceptedCount >= maxParticipants;
  bool get isCreator => false; // Will be set by viewmodel based on current user
  bool get hasAccepted => userRsvpStatus == 'accepted';
  bool get hasRejected => userRsvpStatus == 'rejected';
  bool get hasMaybe => userRsvpStatus == 'maybe';
}

/// Place location DTO
class PlaceLocationDto {
  final double latitude;
  final double longitude;

  const PlaceLocationDto({
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

/// Meetup RSVP DTO
class MeetupRsvpDto {
  final String userId;
  final String? username;
  final String? userPhoto;
  final String status; // 'accepted' | 'rejected' | 'maybe'
  final DateTime respondedAt;
  final String? invitedBy;

  const MeetupRsvpDto({
    required this.userId,
    this.username,
    this.userPhoto,
    required this.status,
    required this.respondedAt,
    this.invitedBy,
  });

  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isMaybe => status == 'maybe';
}

/// Create meetup request DTO
class CreateMeetupDto {
  final String eventName;
  final String date;
  final String time;
  final String placeName;
  final PlaceLocationDto? placeLocation;
  final String? description;
  final int maxParticipants;
  final String broadcastType;
  final int broadcastRadius;
  final List<String> selectedCommunityIds;
  /// When broadcastType is 'friends', these are the connection user IDs to invite.
  final List<String> invitedUserIds;
  final UserPreferencesModel? preferences;
  final String? communityId;

  const CreateMeetupDto({
    required this.eventName,
    required this.date,
    required this.time,
    required this.placeName,
    this.placeLocation,
    this.description,
    required this.maxParticipants,
    required this.broadcastType,
    required this.broadcastRadius,
    required this.selectedCommunityIds,
    this.invitedUserIds = const [],
    this.preferences,
    this.communityId,
  });

  Map<String, dynamic> toJson() {
    return {
      'eventName': eventName,
      'date': date,
      'time': time,
      'placeName': placeName,
      if (placeLocation != null) 'placeLocation': placeLocation!.toJson(),
      if (description != null) 'description': description,
      'maxParticipants': maxParticipants,
      'broadcastType': broadcastType,
      'broadcastRadius': broadcastRadius,
      'selectedCommunityIds': selectedCommunityIds,
      if (invitedUserIds.isNotEmpty) 'invitedUserIds': invitedUserIds,
      if (preferences != null) 'preferences': preferences!.toJson(),
      if (communityId != null) 'communityId': communityId,
    };
  }
}

/// Update meetup request DTO
class UpdateMeetupDto {
  final String? eventName;
  final String? date;
  final String? time;
  final String? placeName;
  final PlaceLocationDto? placeLocation;
  final String? description;
  final int? maxParticipants;

  const UpdateMeetupDto({
    this.eventName,
    this.date,
    this.time,
    this.placeName,
    this.placeLocation,
    this.description,
    this.maxParticipants,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (eventName != null) json['eventName'] = eventName;
    if (date != null) json['date'] = date;
    if (time != null) json['time'] = time;
    if (placeName != null) json['placeName'] = placeName;
    if (placeLocation != null) json['placeLocation'] = placeLocation!.toJson();
    if (description != null) json['description'] = description;
    if (maxParticipants != null) json['maxParticipants'] = maxParticipants;
    return json;
  }
}
