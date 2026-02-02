import 'package:metal/domain/entities/community_dto.dart';
import 'package:metal/data/models/thought_model.dart';

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
    // Backend returns 'isMember' but we use 'isJoined' in the model
    // Support both for backward compatibility
    final isJoined = json['isJoined'] as bool? ?? 
                     json['isMember'] as bool? ?? 
                     false;
    
    return CommunityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      bannerImage: json['bannerImage'] as String? ?? json['coverUrl'] as String?,
      creatorId: json['creatorId'] as String? ?? json['createdBy'] as String? ?? '',
      creatorName: json['creatorName'] as String? ?? 'Unknown',
      creatorProfilePhoto: json['creatorProfilePhoto'] as String?,
      memberCount: json['memberCount'] as int? ?? 0,
      type: json['type'] as String? ?? 'general',
      category: json['category'] as String?,
      isPublic: json['isPublic'] as bool? ?? true,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      rules: _parseRules(json['rules']),
      isJoined: isJoined,
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

  /// Parse rules field - backend may return as List or String
  static String? _parseRules(dynamic rules) {
    if (rules == null) return null;
    if (rules is String) return rules;
    if (rules is List) {
      // Join array of rules into a string (e.g., for display)
      final rulesList = rules.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
      return rulesList.isEmpty ? null : rulesList.join('\n');
    }
    return rules.toString();
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

/// Community details response model (includes community + recent posts)
class CommunityDetailsModel {
  final CommunityModel community;
  final List<ThoughtModel> recentPosts;

  CommunityDetailsModel({
    required this.community,
    required this.recentPosts,
  });

  factory CommunityDetailsModel.fromJson(Map<String, dynamic> json) {
    return CommunityDetailsModel(
      community: CommunityModel.fromJson(
        json['community'] as Map<String, dynamic>,
      ),
      recentPosts: (json['recentPosts'] as List<dynamic>?)
              ?.map((post) {
                // Backend returns posts with author field, need to map to ThoughtModel structure
                final postData = post as Map<String, dynamic>;
                // Ensure the post has the required ThoughtModel structure
                return ThoughtModel.fromJson(postData);
              })
              .toList() ??
          [],
    );
  }

  /// Convert to domain DTO
  CommunityDetailsDto toDomain() {
    return CommunityDetailsDto(
      community: community.toDomain(),
      recentPosts: recentPosts.map((post) => post.toDomain()).toList(),
    );
  }
}

/// Community member response model
class CommunityMemberModel {
  final String userId;
  final String? username;
  final String? fullname;
  final String? profilePhoto;
  final String role;
  final bool isVerified;
  final String? metal;
  final String joinedAt;

  CommunityMemberModel({
    required this.userId,
    this.username,
    this.fullname,
    this.profilePhoto,
    required this.role,
    this.isVerified = false,
    this.metal,
    required this.joinedAt,
  });

  factory CommunityMemberModel.fromJson(Map<String, dynamic> json) {
    return CommunityMemberModel(
      userId: json['userId'] as String,
      username: json['username'] as String?,
      fullname: json['fullname'] as String?,
      profilePhoto: json['profilePhoto'] as String?,
      role: json['role'] as String? ?? 'member',
      isVerified: json['isVerified'] as bool? ?? false,
      metal: json['metal'] as String?,
      joinedAt: json['joinedAt'] as String,
    );
  }

  /// Convert to domain DTO
  CommunityMemberDto toDomain(String communityId) {
    return CommunityMemberDto(
      communityId: communityId,
      userId: userId,
      userName: username ?? fullname ?? 'Unknown',
      userProfilePhoto: profilePhoto,
      userMetal: metal,
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

/// Community members list response model
class CommunityMembersListModel {
  final List<CommunityMemberModel> members;
  final PaginationInfo? pagination;

  CommunityMembersListModel({
    required this.members,
    this.pagination,
  });

  factory CommunityMembersListModel.fromJson(Map<String, dynamic> json) {
    return CommunityMembersListModel(
      members: (json['members'] as List<dynamic>?)
              ?.map((m) => CommunityMemberModel.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: json['pagination'] != null
          ? PaginationInfo.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert to domain DTOs
  List<CommunityMemberDto> toDomain(String communityId) {
    return members.map((m) => m.toDomain(communityId)).toList();
  }
}
