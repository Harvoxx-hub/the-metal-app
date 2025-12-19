import 'package:metal/domain/entities/community_dto.dart';

/// Community response model from API
class CommunityModel {
  final String id;
  final String name;
  final String description;
  final String? bannerImage;
  final String creatorId;
  final String creatorName;
  final String? creatorProfilePhoto;
  final int memberCount;
  final String type;
  final String? category;
  final bool isPublic;
  final List<String> tags;
  final String? rules;
  final bool isJoined;
  final String createdAt;

  CommunityModel({
    required this.id,
    required this.name,
    required this.description,
    this.bannerImage,
    required this.creatorId,
    required this.creatorName,
    this.creatorProfilePhoto,
    required this.memberCount,
    required this.type,
    this.category,
    required this.isPublic,
    required this.tags,
    this.rules,
    this.isJoined = false,
    required this.createdAt,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      bannerImage: json['bannerImage'] as String?,
      creatorId: json['creatorId'] as String,
      creatorName: json['creatorName'] as String? ?? 'Unknown',
      creatorProfilePhoto: json['creatorProfilePhoto'] as String?,
      memberCount: json['memberCount'] as int? ?? 0,
      type: json['type'] as String? ?? 'general',
      category: json['category'] as String?,
      isPublic: json['isPublic'] as bool? ?? true,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      rules: json['rules'] as String?,
      isJoined: json['isJoined'] as bool? ?? false,
      createdAt: json['createdAt'] as String,
    );
  }

  /// Convert to domain DTO
  CommunityDto toDomain() {
    return CommunityDto(
      id: id,
      name: name,
      description: description,
      bannerImage: bannerImage,
      creatorId: creatorId,
      creatorName: creatorName,
      creatorProfilePhoto: creatorProfilePhoto,
      memberCount: memberCount,
      type: _parseCommunityType(type),
      category: category,
      isPublic: isPublic,
      tags: tags,
      rules: rules,
      isJoined: isJoined,
      createdAt: DateTime.parse(createdAt),
    );
  }

  CommunityType _parseCommunityType(String type) {
    switch (type.toLowerCase()) {
      case 'general':
        return CommunityType.general;
      case 'interest':
        return CommunityType.interest;
      case 'professional':
        return CommunityType.professional;
      case 'local':
        return CommunityType.local;
      default:
        return CommunityType.general;
    }
  }
}

/// Communities list response model
class CommunitiesListModel {
  final List<CommunityModel> communities;
  final PaginationInfo? pagination;

  CommunitiesListModel({
    required this.communities,
    this.pagination,
  });

  factory CommunitiesListModel.fromJson(Map<String, dynamic> json) {
    return CommunitiesListModel(
      communities: (json['communities'] as List<dynamic>?)
              ?.map((c) => CommunityModel.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: json['pagination'] != null
          ? PaginationInfo.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert to domain DTOs
  List<CommunityDto> toDomain() {
    return communities.map((c) => c.toDomain()).toList();
  }
}

/// Pagination info model
class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasMore;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasMore,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['currentPage'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? 1,
      totalItems: json['totalItems'] as int? ?? 0,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}

/// Create community request model
class CreateCommunityRequestModel {
  final String name;
  final String description;
  final String? bannerImage;
  final String type;
  final String? category;
  final bool isPublic;
  final List<String> tags;
  final String? rules;

  CreateCommunityRequestModel({
    required this.name,
    required this.description,
    this.bannerImage,
    this.type = 'general',
    this.category,
    this.isPublic = true,
    this.tags = const [],
    this.rules,
  });

  factory CreateCommunityRequestModel.fromDto(CreateCommunityDto dto) {
    return CreateCommunityRequestModel(
      name: dto.name,
      description: dto.description,
      bannerImage: dto.bannerImage,
      type: _communityTypeToString(dto.type),
      category: dto.category,
      isPublic: dto.isPublic,
      tags: dto.tags,
      rules: dto.rules,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      if (bannerImage != null) 'bannerImage': bannerImage,
      'type': type,
      if (category != null) 'category': category,
      'isPublic': isPublic,
      'tags': tags,
      if (rules != null) 'rules': rules,
    };
  }

  static String _communityTypeToString(CommunityType type) {
    switch (type) {
      case CommunityType.general:
        return 'general';
      case CommunityType.interest:
        return 'interest';
      case CommunityType.professional:
        return 'professional';
      case CommunityType.local:
        return 'local';
    }
  }
}

/// Community member response model
class CommunityMemberModel {
  final String communityId;
  final String userId;
  final String userName;
  final String? userProfilePhoto;
  final String role;
  final String joinedAt;

  CommunityMemberModel({
    required this.communityId,
    required this.userId,
    required this.userName,
    this.userProfilePhoto,
    required this.role,
    required this.joinedAt,
  });

  factory CommunityMemberModel.fromJson(Map<String, dynamic> json) {
    return CommunityMemberModel(
      communityId: json['communityId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userProfilePhoto: json['userProfilePhoto'] as String?,
      role: json['role'] as String? ?? 'member',
      joinedAt: json['joinedAt'] as String,
    );
  }

  /// Convert to domain DTO
  CommunityMemberDto toDomain() {
    return CommunityMemberDto(
      communityId: communityId,
      userId: userId,
      userName: userName,
      userProfilePhoto: userProfilePhoto,
      role: _parseMemberRole(role),
      joinedAt: DateTime.parse(joinedAt),
    );
  }

  CommunityMemberRole _parseMemberRole(String role) {
    switch (role.toLowerCase()) {
      case 'creator':
        return CommunityMemberRole.creator;
      case 'admin':
        return CommunityMemberRole.admin;
      case 'member':
        return CommunityMemberRole.member;
      default:
        return CommunityMemberRole.member;
    }
  }
}
