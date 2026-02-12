import 'package:metal/domain/entities/meetup_dto.dart';
import 'package:metal/data/models/user_preferences_model.dart';

/// Meetup response model from API
class MeetupModel {
  final String id;
  final String eventName;
  final String date;
  final String time;
  final String eventDateTime;
  final String placeName;
  final PlaceLocationModel? placeLocation;
  final String? description;
  final int maxParticipants;
  final String creatorId;
  final String? creatorUsername;
  final String? creatorPhoto;
  final String broadcastType;
  final int broadcastRadius;
  final List<String> selectedCommunityIds;
  final Map<String, dynamic>? preferences;
  final String? communityId;
  final String status;
  final int acceptedCount;
  final int rejectedCount;
  final int maybeCount;
  final List<String> invitedUserIds;
  final bool isPinned;
  final String createdAt;
  final String updatedAt;
  final double? distance;
  final String? userRsvpStatus;

  MeetupModel({
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

  factory MeetupModel.fromJson(Map<String, dynamic> json) {
    return MeetupModel(
      id: json['id'] as String,
      eventName: json['eventName'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      eventDateTime: json['eventDateTime'] as String,
      placeName: (json['placeName'] ?? json['placeUrl'] ?? '') as String,
      placeLocation: PlaceLocationModel.tryFromJson(
          json['placeLocation'] is Map<String, dynamic>
              ? json['placeLocation'] as Map<String, dynamic>
              : null),
      description: json['description'] as String?,
      maxParticipants: (json['maxParticipants'] as num).toInt(),
      creatorId: json['creatorId'] as String,
      creatorUsername: json['creatorUsername'] as String?,
      creatorPhoto: json['creatorPhoto'] as String?,
      broadcastType: json['broadcastType'] as String,
      broadcastRadius: (json['broadcastRadius'] as num).toInt(),
      selectedCommunityIds: (json['selectedCommunityIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      preferences: json['preferences'] as Map<String, dynamic>?,
      communityId: json['communityId'] as String?,
      status: json['status'] as String,
      acceptedCount: (json['acceptedCount'] as num?)?.toInt() ?? 0,
      rejectedCount: (json['rejectedCount'] as num?)?.toInt() ?? 0,
      maybeCount: (json['maybeCount'] as num?)?.toInt() ?? 0,
      invitedUserIds: (json['invitedUserIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isPinned: json['isPinned'] as bool? ?? false,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      distance: json['distance'] != null
          ? (json['distance'] as num).toDouble()
          : null,
      userRsvpStatus: json['userRsvpStatus'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventName': eventName,
      'date': date,
      'time': time,
      'eventDateTime': eventDateTime,
      'placeName': placeName,
      if (placeLocation != null) 'placeLocation': placeLocation!.toJson(),
      if (description != null) 'description': description,
      'maxParticipants': maxParticipants,
      'creatorId': creatorId,
      if (creatorUsername != null) 'creatorUsername': creatorUsername,
      if (creatorPhoto != null) 'creatorPhoto': creatorPhoto,
      'broadcastType': broadcastType,
      'broadcastRadius': broadcastRadius,
      'selectedCommunityIds': selectedCommunityIds,
      if (preferences != null) 'preferences': preferences,
      if (communityId != null) 'communityId': communityId,
      'status': status,
      'acceptedCount': acceptedCount,
      'rejectedCount': rejectedCount,
      'maybeCount': maybeCount,
      'invitedUserIds': invitedUserIds,
      'isPinned': isPinned,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (distance != null) 'distance': distance,
      if (userRsvpStatus != null) 'userRsvpStatus': userRsvpStatus,
    };
  }

  /// Convert to domain DTO
  MeetupDto toDomain() {
    return MeetupDto(
      id: id,
      eventName: eventName,
      date: date,
      time: time,
      eventDateTime: DateTime.parse(eventDateTime),
      placeName: placeName,
      placeLocation: placeLocation?.toDomain(),
      description: description,
      maxParticipants: maxParticipants,
      creatorId: creatorId,
      creatorUsername: creatorUsername,
      creatorPhoto: creatorPhoto,
      broadcastType: broadcastType,
      broadcastRadius: broadcastRadius,
      selectedCommunityIds: selectedCommunityIds,
      preferences: preferences != null
          ? UserPreferencesModel.fromJson(preferences)
          : null,
      communityId: communityId,
      status: status,
      acceptedCount: acceptedCount,
      rejectedCount: rejectedCount,
      maybeCount: maybeCount,
      invitedUserIds: invitedUserIds,
      isPinned: isPinned,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      distance: distance,
      userRsvpStatus: userRsvpStatus,
    );
  }
}

/// Place location model
class PlaceLocationModel {
  final double latitude;
  final double longitude;

  PlaceLocationModel({
    required this.latitude,
    required this.longitude,
  });

  factory PlaceLocationModel.fromJson(Map<String, dynamic> json) {
    return PlaceLocationModel(
      latitude: _parseDouble(json['latitude']) ?? 0.0,
      longitude: _parseDouble(json['longitude']) ?? 0.0,
    );
  }

  /// Returns null if lat/lng are missing or invalid (avoids crash when building map).
  static PlaceLocationModel? tryFromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final lat = _parseDouble(json['latitude']);
    final lng = _parseDouble(json['longitude']);
    if (lat == null || lng == null || !lat.isFinite || !lng.isFinite) return null;
    return PlaceLocationModel(latitude: lat, longitude: lng);
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  PlaceLocationDto toDomain() {
    return PlaceLocationDto(
      latitude: latitude,
      longitude: longitude,
    );
  }
}

/// Meetup RSVP model
class MeetupRsvpModel {
  final String userId;
  final String? username;
  final String? userPhoto;
  final String status;
  final String respondedAt;
  final String? invitedBy;

  MeetupRsvpModel({
    required this.userId,
    this.username,
    this.userPhoto,
    required this.status,
    required this.respondedAt,
    this.invitedBy,
  });

  factory MeetupRsvpModel.fromJson(Map<String, dynamic> json) {
    return MeetupRsvpModel(
      userId: json['userId'] as String,
      username: json['username'] as String?,
      userPhoto: json['userPhoto'] as String?,
      status: json['status'] as String,
      respondedAt: json['respondedAt'] as String,
      invitedBy: json['invitedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      if (username != null) 'username': username,
      if (userPhoto != null) 'userPhoto': userPhoto,
      'status': status,
      'respondedAt': respondedAt,
      if (invitedBy != null) 'invitedBy': invitedBy,
    };
  }

  MeetupRsvpDto toDomain() {
    return MeetupRsvpDto(
      userId: userId,
      username: username,
      userPhoto: userPhoto,
      status: status,
      respondedAt: DateTime.parse(respondedAt),
      invitedBy: invitedBy,
    );
  }
}
