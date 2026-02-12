import 'package:metal/domain/entities/base_entity.dart';

/// Thought domain entity (DTO)
class ThoughtDto extends BaseEntity {
  final String id;
  final String userId;
  final String content;
  final String type; // "text" | "voice" | "repost"
  final String? audioUrl;
  final int? audioDuration;
  final DateTime createdAt;
  final bool connectionOnly;
  final AuthorMetadataDto? authorMetadata;
  final CommunityMetadataDto? communityMetadata;

  // Repost-specific fields
  final String? originalThoughtId;
  final String? originalUserId;
  final DateTime? repostedAt;
  final ThoughtDto? originalThought;

  const ThoughtDto({
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

  ThoughtDto copyWith({
    String? id,
    String? userId,
    String? content,
    String? type,
    String? audioUrl,
    int? audioDuration,
    DateTime? createdAt,
    bool? connectionOnly,
    AuthorMetadataDto? authorMetadata,
    CommunityMetadataDto? communityMetadata,
    String? originalThoughtId,
    String? originalUserId,
    DateTime? repostedAt,
    ThoughtDto? originalThought,
  }) {
    return ThoughtDto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      type: type ?? this.type,
      audioUrl: audioUrl ?? this.audioUrl,
      audioDuration: audioDuration ?? this.audioDuration,
      createdAt: createdAt ?? this.createdAt,
      connectionOnly: connectionOnly ?? this.connectionOnly,
      authorMetadata: authorMetadata ?? this.authorMetadata,
      communityMetadata: communityMetadata ?? this.communityMetadata,
      originalThoughtId: originalThoughtId ?? this.originalThoughtId,
      originalUserId: originalUserId ?? this.originalUserId,
      repostedAt: repostedAt ?? this.repostedAt,
      originalThought: originalThought ?? this.originalThought,
    );
  }

  bool get isRepost => type == 'repost' && originalThoughtId != null;
  bool get isVoice => type == 'voice';
  bool get isText => type == 'text';
}

/// Author metadata DTO
class AuthorMetadataDto extends BaseEntity {
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

  const AuthorMetadataDto({
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
}

/// Community metadata DTO
class CommunityMetadataDto extends BaseEntity {
  final String communityId;
  final String communityName;
  final List<String> categories;
  final String? communityImage;
  final bool isPublic;

  const CommunityMetadataDto({
    required this.communityId,
    required this.communityName,
    this.categories = const [],
    this.communityImage,
    this.isPublic = true,
  });
}
