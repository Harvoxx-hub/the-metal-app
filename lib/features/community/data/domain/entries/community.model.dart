class CommunityModel {
  final String id;
  final String name;
  final String description;
  final String? bannerImage;
  final String creatorId;
  final String creatorName;
  final String? creatorProfilePhoto;
  final int memberCount;
  final bool isPublic;
  final List<String> tags;
  final String createdAt;
  final String? rules;
  final bool isJoined;

  CommunityModel({
    required this.id,
    required this.name,
    required this.description,
    this.bannerImage,
    required this.creatorId,
    required this.creatorName,
    this.creatorProfilePhoto,
    required this.memberCount,
    required this.isPublic,
    required this.tags,
    required this.createdAt,
    this.rules,
    this.isJoined = false,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      bannerImage: json['bannerImage'],
      creatorId: json['creatorId'] ?? '',
      creatorName: json['creatorName'] ?? '',
      creatorProfilePhoto: json['creatorProfilePhoto'],
      memberCount: json['memberCount'] ?? 0,
      isPublic: json['isPublic'] ?? true,
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: json['createdAt'] ?? '',
      rules: json['rules'],
      isJoined: json['isJoined'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'bannerImage': bannerImage,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'creatorProfilePhoto': creatorProfilePhoto,
      'memberCount': memberCount,
      'isPublic': isPublic,
      'tags': tags,
      'createdAt': createdAt,
      'rules': rules,
      'isJoined': isJoined,
    };
  }

  CommunityModel copyWith({
    String? id,
    String? name,
    String? description,
    String? bannerImage,
    String? creatorId,
    String? creatorName,
    String? creatorProfilePhoto,
    int? memberCount,
    bool? isPublic,
    List<String>? tags,
    String? createdAt,
    String? rules,
    bool? isJoined,
  }) {
    return CommunityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      bannerImage: bannerImage ?? this.bannerImage,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      creatorProfilePhoto: creatorProfilePhoto ?? this.creatorProfilePhoto,
      memberCount: memberCount ?? this.memberCount,
      isPublic: isPublic ?? this.isPublic,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      rules: rules ?? this.rules,
      isJoined: isJoined ?? this.isJoined,
    );
  }
}

class CommunityMemberModel {
  final String communityId;
  final String userId;
  final String userName;
  final String? userProfilePhoto;
  final String joinedAt;
  final String role; // "member", "admin", "creator"

  CommunityMemberModel({
    required this.communityId,
    required this.userId,
    required this.userName,
    this.userProfilePhoto,
    required this.joinedAt,
    required this.role,
  });

  factory CommunityMemberModel.fromJson(Map<String, dynamic> json) {
    return CommunityMemberModel(
      communityId: json['communityId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userProfilePhoto: json['userProfilePhoto'],
      joinedAt: json['joinedAt'] ?? '',
      role: json['role'] ?? 'member',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'communityId': communityId,
      'userId': userId,
      'userName': userName,
      'userProfilePhoto': userProfilePhoto,
      'joinedAt': joinedAt,
      'role': role,
    };
  }
}

class CommunityPostModel {
  final String id;
  final String communityId;
  final String userId;
  final String content;
  final String createdAt;
  final String authorName;
  final String? authorProfilePhoto;
  final String communityName;
  final int reactionCount;
  final int commentCount;
  final bool hasUserReacted;

  CommunityPostModel({
    required this.id,
    required this.communityId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.authorName,
    this.authorProfilePhoto,
    required this.communityName,
    required this.reactionCount,
    required this.commentCount,
    required this.hasUserReacted,
  });

  factory CommunityPostModel.fromJson(Map<String, dynamic> json) {
    return CommunityPostModel(
      id: json['id'] ?? '',
      communityId: json['communityId'] ?? '',
      userId: json['userId'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
      authorName: json['authorName'] ?? '',
      authorProfilePhoto: json['authorProfilePhoto'],
      communityName: json['communityName'] ?? '',
      reactionCount: json['reactionCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      hasUserReacted: json['hasUserReacted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'communityId': communityId,
      'userId': userId,
      'content': content,
      'createdAt': createdAt,
      'authorName': authorName,
      'authorProfilePhoto': authorProfilePhoto,
      'communityName': communityName,
      'reactionCount': reactionCount,
      'commentCount': commentCount,
      'hasUserReacted': hasUserReacted,
    };
  }
}
