import 'package:metal/domain/entities/thought_dto.dart';

/// Thought response model from API
class ThoughtModel {
  final String id;
  final String userId;
  final String content;
  final String type;
  final String? audioUrl;
  final int? audioDuration;
  final String createdAt;
  final bool connectionOnly;
  final AuthorMetadataModel? authorMetadata;
  final CommunityMetadataModel? communityMetadata;

  // Repost fields
  final String? originalThoughtId;
  final String? originalUserId;
  final String? repostedAt;
  final ThoughtModel? originalThought;

  ThoughtModel({
    required this.id,
    required this.userId,
    required this.content,
    this.type = 'text',
    this.audioUrl,
    this.audioDuration,
    required this.createdAt,
    this.connectionOnly = false,
    this.authorMetadata,
    this.communityMetadata,
    this.originalThoughtId,
    this.originalUserId,
    this.repostedAt,
    this.originalThought,
  });

  factory ThoughtModel.fromJson(Map<String, dynamic> json) {
    return ThoughtModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      type: (json['type'] as String?) ?? 'text',
      audioUrl: json['audioUrl'] as String?,
      audioDuration: json['audioDuration'] is int
          ? json['audioDuration'] as int
          : (json['audioDuration'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String,
      connectionOnly: json['connectionOnly'] as bool? ?? false,
      authorMetadata: json['authorMetadata'] != null
          ? AuthorMetadataModel.fromJson(
              json['authorMetadata'] as Map<String, dynamic>)
          : null,
      communityMetadata: json['communityMetadata'] != null
          ? CommunityMetadataModel.fromJson(
              json['communityMetadata'] as Map<String, dynamic>)
          : null,
      originalThoughtId: json['originalThoughtId'] as String?,
      originalUserId: json['originalUserId'] as String?,
      repostedAt: json['repostedAt'] as String?,
      originalThought: json['originalThought'] != null
          ? ThoughtModel.fromJson(
              json['originalThought'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'type': type,
      if (audioUrl != null) 'audioUrl': audioUrl,
      if (audioDuration != null) 'audioDuration': audioDuration,
      'createdAt': createdAt,
      'connectionOnly': connectionOnly,
      if (authorMetadata != null) 'authorMetadata': authorMetadata!.toJson(),
      if (communityMetadata != null)
        'communityMetadata': communityMetadata!.toJson(),
      if (originalThoughtId != null) 'originalThoughtId': originalThoughtId,
      if (originalUserId != null) 'originalUserId': originalUserId,
      if (repostedAt != null) 'repostedAt': repostedAt,
      if (originalThought != null) 'originalThought': originalThought!.toJson(),
    };
  }

  /// Convert to domain DTO
  ThoughtDto toDomain() {
    return ThoughtDto(
      id: id,
      userId: userId,
      content: content,
      type: type,
      audioUrl: audioUrl,
      audioDuration: audioDuration,
      createdAt: DateTime.parse(createdAt),
      connectionOnly: connectionOnly,
      authorMetadata: authorMetadata?.toDomain(),
      communityMetadata: communityMetadata?.toDomain(),
      originalThoughtId: originalThoughtId,
      originalUserId: originalUserId,
      repostedAt: repostedAt != null ? DateTime.parse(repostedAt!) : null,
      originalThought: originalThought?.toDomain(),
    );
  }
}

/// Author metadata model
class AuthorMetadataModel {
  final String authorId;
  final String? authorName;
  final String? authorGender;
  final int? authorAge;
  final String? authorLocationName;
  final double? authorLatitude;
  final double? authorLongitude;
  final String? authorRelationshipType;
  final String? authorCommunity;
  final bool? authorIsVerified;
  final String? authorProfilePhoto;

  AuthorMetadataModel({
    required this.authorId,
    this.authorName,
    this.authorGender,
    this.authorAge,
    this.authorLocationName,
    this.authorLatitude,
    this.authorLongitude,
    this.authorRelationshipType,
    this.authorCommunity,
    this.authorIsVerified,
    this.authorProfilePhoto,
  });

  factory AuthorMetadataModel.fromJson(Map<String, dynamic> json) {
    return AuthorMetadataModel(
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String?,
      authorGender: json['authorGender'] as String?,
      authorAge: json['authorAge'] is int
          ? json['authorAge'] as int
          : (json['authorAge'] as num?)?.toInt(),
      authorLocationName: json['authorLocationName'] as String?,
      authorLatitude: json['authorLatitude'] is double
          ? json['authorLatitude'] as double
          : (json['authorLatitude'] as num?)?.toDouble(),
      authorLongitude: json['authorLongitude'] is double
          ? json['authorLongitude'] as double
          : (json['authorLongitude'] as num?)?.toDouble(),
      authorRelationshipType: json['authorRelationshipType'] as String?,
      authorCommunity: json['authorCommunity'] as String?,
      authorIsVerified: json['authorIsVerified'] as bool?,
      authorProfilePhoto: json['authorProfilePhoto'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorId': authorId,
      if (authorName != null) 'authorName': authorName,
      if (authorGender != null) 'authorGender': authorGender,
      if (authorAge != null) 'authorAge': authorAge,
      if (authorLocationName != null) 'authorLocationName': authorLocationName,
      if (authorLatitude != null) 'authorLatitude': authorLatitude,
      if (authorLongitude != null) 'authorLongitude': authorLongitude,
      if (authorRelationshipType != null)
        'authorRelationshipType': authorRelationshipType,
      if (authorCommunity != null) 'authorCommunity': authorCommunity,
      if (authorIsVerified != null) 'authorIsVerified': authorIsVerified,
      if (authorProfilePhoto != null) 'authorProfilePhoto': authorProfilePhoto,
    };
  }

  AuthorMetadataDto toDomain() {
    return AuthorMetadataDto(
      authorId: authorId,
      authorName: authorName,
      authorGender: authorGender,
      authorAge: authorAge,
      authorLocationName: authorLocationName,
      authorLatitude: authorLatitude,
      authorLongitude: authorLongitude,
      authorRelationshipType: authorRelationshipType,
      authorCommunity: authorCommunity,
      authorIsVerified: authorIsVerified,
      authorProfilePhoto: authorProfilePhoto,
    );
  }
}

/// Community metadata model
class CommunityMetadataModel {
  final String communityId;
  final String communityName;
  final List<String> categories;
  final String? communityImage;
  final bool isPublic;

  CommunityMetadataModel({
    required this.communityId,
    required this.communityName,
    this.categories = const [],
    this.communityImage,
    this.isPublic = true,
  });

  factory CommunityMetadataModel.fromJson(Map<String, dynamic> json) {
    return CommunityMetadataModel(
      communityId: json['communityId'] as String? ?? '',
      communityName: json['communityName'] as String? ?? '',
      categories: (json['categories'] as List<dynamic>?)?.cast<String>() ?? [],
      communityImage: json['communityImage'] as String?,
      isPublic: json['isPublic'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'communityId': communityId,
      'communityName': communityName,
      'categories': categories,
      if (communityImage != null) 'communityImage': communityImage,
      'isPublic': isPublic,
    };
  }

  CommunityMetadataDto toDomain() {
    return CommunityMetadataDto(
      communityId: communityId,
      communityName: communityName,
      categories: categories,
      communityImage: communityImage,
      isPublic: isPublic,
    );
  }
}
