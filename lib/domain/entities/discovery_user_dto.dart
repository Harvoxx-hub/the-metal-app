import 'package:metal/domain/entities/prompt_dto.dart';

/// Discovery User DTO
/// Simplified user entity for discovery/swipe cards
/// Contains only the data needed for the swipe interface
class DiscoveryUserDto {
  final String id;
  final String? username;
  final String? fullname;
  final String? gender;
  final String? dob;
  final String? metal;
  final String? bio;
  final String? profilePhoto;
  final List<String>? passion;
  final List<String>? connectionOption;
  final String? connectWith;
  final LocationDto? location;
  final bool isVerified;
  final bool isOnline;
  final String? lastActive;
  final double? distance; // Calculated distance in km
  final List<UserPromptDto>? prompts;

  const DiscoveryUserDto({
    required this.id,
    this.username,
    this.fullname,
    this.gender,
    this.dob,
    this.metal,
    this.bio,
    this.profilePhoto,
    this.passion,
    this.connectionOption,
    this.connectWith,
    this.location,
    this.isVerified = false,
    this.isOnline = false,
    this.lastActive,
    this.distance,
    this.prompts,
  });

  factory DiscoveryUserDto.fromJson(Map<String, dynamic> json) {
    return DiscoveryUserDto(
      id: json['id'] as String,
      username: json['username'] as String?,
      fullname: json['fullname'] as String?,
      gender: json['gender'] as String?,
      dob: json['dob'] as String?,
      metal: json['metal'] as String?,
      bio: json['bio'] as String?,
      profilePhoto: json['profilePhoto'] as String?,
      passion: (json['passion'] as List<dynamic>?)?.cast<String>(),
      connectionOption: (json['connectionOption'] as List<dynamic>?)?.cast<String>(),
      connectWith: json['connectWith'] as String?,
      location: json['location'] != null
          ? LocationDto.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      isVerified: json['isVerified'] as bool? ?? false,
      isOnline: json['isOnline'] as bool? ?? false,
      lastActive: json['lastActive'] as String?,
      distance: (json['distance'] as num?)?.toDouble(),
      prompts: (json['prompts'] as List<dynamic>?)
          ?.map((item) => UserPromptDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullname': fullname,
      'gender': gender,
      'dob': dob,
      'metal': metal,
      'bio': bio,
      'profilePhoto': profilePhoto,
      'passion': passion,
      'connectionOption': connectionOption,
      'connectWith': connectWith,
      'location': location?.toJson(),
      'isVerified': isVerified,
      'isOnline': isOnline,
      'lastActive': lastActive,
      'distance': distance,
      'prompts': prompts?.map((p) => p.toJson()).toList(),
    };
  }

  /// Calculate age from date of birth
  int? get age {
    if (dob == null) return null;
    try {
      DateTime birthDate;
      if (dob!.contains('/')) {
        // DD/MM/YYYY format
        final parts = dob!.split('/');
        if (parts.length == 3) {
          birthDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        } else {
          return null;
        }
      } else {
        // ISO format
        birthDate = DateTime.parse(dob!);
      }
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return null;
    }
  }
}

/// Location data for discovery users
class LocationDto {
  final double? lat;
  final double? lng;
  final String? address;

  const LocationDto({
    this.lat,
    this.lng,
    this.address,
  });

  factory LocationDto.fromJson(Map<String, dynamic> json) {
    return LocationDto(
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'address': address,
    };
  }
}

/// Swipe action enum
enum SwipeAction {
  like,
  pass,
}

/// Extension to convert SwipeAction to/from string
extension SwipeActionExtension on SwipeAction {
  String get value {
    switch (this) {
      case SwipeAction.like:
        return 'like';
      case SwipeAction.pass:
        return 'pass';
    }
  }

  static SwipeAction fromString(String value) {
    switch (value.toLowerCase()) {
      case 'like':
        return SwipeAction.like;
      case 'pass':
        return SwipeAction.pass;
      case 'superlike':
        return SwipeAction.like; // backwards compat: treat as like
      default:
        throw ArgumentError('Invalid swipe action: $value');
    }
  }
}

/// Swipe result DTO
class SwipeResultDto {
  final SwipeAction action;
  final String targetUserId;
  final bool isMatch;
  final String? connectionId;

  const SwipeResultDto({
    required this.action,
    required this.targetUserId,
    required this.isMatch,
    this.connectionId,
  });

  factory SwipeResultDto.fromJson(Map<String, dynamic> json) {
    return SwipeResultDto(
      action: SwipeActionExtension.fromString(json['action'] as String),
      targetUserId: json['targetUserId'] as String,
      isMatch: json['isMatch'] as bool? ?? false,
      connectionId: json['connectionId'] as String?,
    );
  }
}

/// Discovery pagination info
class DiscoveryPaginationDto {
  final bool hasMore;
  final String? nextCursor;
  final int count;

  const DiscoveryPaginationDto({
    required this.hasMore,
    this.nextCursor,
    required this.count,
  });

  factory DiscoveryPaginationDto.fromJson(Map<String, dynamic> json) {
    return DiscoveryPaginationDto(
      hasMore: json['hasMore'] as bool? ?? false,
      nextCursor: json['nextCursor'] as String?,
      count: json['count'] as int? ?? 0,
    );
  }
}

