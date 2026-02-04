import 'package:metal/domain/entities/thought_dto.dart';

/// Community data transfer object
class CommunityDto {
  final String id;
  final String name;
  final String description;
  final String? bannerImage;
  final String creatorId;
  final String creatorName;
  final String? creatorProfilePhoto;
  final int memberCount;
  final CommunityType type;
  final String? category;
  final bool isPublic;
  final List<String> tags;
  final String? rules;
  final bool isJoined;
  final DateTime createdAt;

  CommunityDto({
    required this.id,
    required this.name,
    required this.description,
    this.bannerImage,
    required this.creatorId,
    required this.creatorName,
    this.creatorProfilePhoto,
    required this.memberCount,
    this.type = CommunityType.general,
    this.category,
    required this.isPublic,
    required this.tags,
    this.rules,
    this.isJoined = false,
    required this.createdAt,
  });

  CommunityDto copyWith({
    String? id,
    String? name,
    String? description,
    String? bannerImage,
    String? creatorId,
    String? creatorName,
    String? creatorProfilePhoto,
    int? memberCount,
    CommunityType? type,
    String? category,
    bool? isPublic,
    List<String>? tags,
    String? rules,
    bool? isJoined,
    DateTime? createdAt,
  }) {
    return CommunityDto(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      bannerImage: bannerImage ?? this.bannerImage,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      creatorProfilePhoto: creatorProfilePhoto ?? this.creatorProfilePhoto,
      memberCount: memberCount ?? this.memberCount,
      type: type ?? this.type,
      category: category ?? this.category,
      isPublic: isPublic ?? this.isPublic,
      tags: tags ?? this.tags,
      rules: rules ?? this.rules,
      isJoined: isJoined ?? this.isJoined,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Community types
enum CommunityType {
  general,
  interest,
  professional,
  local,
}

/// Community member data transfer object
class CommunityMemberDto {
  final String communityId;
  final String userId;
  final String userName;
  final String? userProfilePhoto;

  /// Metal id for displaying member's metal icon (not profile photo)
  final String? userMetal;
  final CommunityMemberRole role;
  final DateTime joinedAt;

  CommunityMemberDto({
    required this.communityId,
    required this.userId,
    required this.userName,
    this.userProfilePhoto,
    this.userMetal,
    this.role = CommunityMemberRole.member,
    required this.joinedAt,
  });
}

/// Community member roles
enum CommunityMemberRole {
  creator,
  admin,
  member,
}

/// Community details DTO (includes community + recent posts)
class CommunityDetailsDto {
  final CommunityDto community;
  final List<ThoughtDto> recentPosts;

  CommunityDetailsDto({
    required this.community,
    required this.recentPosts,
  });
}

/// Create community request DTO
class CreateCommunityDto {
  final String name;
  final String description;
  final String? bannerImage;
  final CommunityType type;
  final String? category;
  final bool isPublic;
  final List<String> tags;
  final String? rules;

  CreateCommunityDto({
    required this.name,
    required this.description,
    this.bannerImage,
    this.type = CommunityType.general,
    this.category,
    this.isPublic = true,
    this.tags = const [],
    this.rules,
  });
}
