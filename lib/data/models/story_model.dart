import 'package:metal/domain/entities/story_dto.dart';

/// Story response model from API
class StoryModel {
  final String id;
  final String userId;
  final String userName;
  final String? userProfilePhoto;
  final String mediaUrl;
  final String mediaType;
  final int? duration;
  final String? caption;
  final int viewCount;
  final bool isViewed;
  final String createdAt;
  final String expiresAt;

  StoryModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userProfilePhoto,
    required this.mediaUrl,
    required this.mediaType,
    this.duration,
    this.caption,
    required this.viewCount,
    this.isViewed = false,
    required this.createdAt,
    required this.expiresAt,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String? ?? 'Unknown',
      userProfilePhoto: json['userProfilePhoto'] as String?,
      mediaUrl: json['mediaUrl'] as String,
      mediaType: json['mediaType'] as String,
      duration: json['duration'] as int?,
      caption: json['caption'] as String?,
      viewCount: json['viewCount'] as int? ?? 0,
      isViewed: json['isViewed'] as bool? ?? false,
      createdAt: json['createdAt'] as String,
      expiresAt: json['expiresAt'] as String,
    );
  }

  /// Convert to domain DTO
  StoryDto toDomain() {
    return StoryDto(
      id: id,
      userId: userId,
      userName: userName,
      userProfilePhoto: userProfilePhoto,
      mediaUrl: mediaUrl,
      mediaType: _parseMediaType(mediaType),
      duration: duration,
      caption: caption,
      viewCount: viewCount,
      isViewed: isViewed,
      createdAt: DateTime.parse(createdAt),
      expiresAt: DateTime.parse(expiresAt),
    );
  }

  StoryMediaType _parseMediaType(String type) {
    switch (type.toLowerCase()) {
      case 'image':
        return StoryMediaType.image;
      case 'video':
        return StoryMediaType.video;
      default:
        return StoryMediaType.image;
    }
  }
}

/// Stories feed response model
class StoriesFeedModel {
  final List<StoryModel> stories;

  StoriesFeedModel({
    required this.stories,
  });

  factory StoriesFeedModel.fromJson(Map<String, dynamic> json) {
    return StoriesFeedModel(
      stories: (json['stories'] as List<dynamic>?)
              ?.map((s) => StoryModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Group stories by user
  List<StoryGroupDto> toGroupedDomain() {
    final Map<String, List<StoryDto>> grouped = {};

    for (final storyModel in stories) {
      final story = storyModel.toDomain();
      if (!grouped.containsKey(story.userId)) {
        grouped[story.userId] = [];
      }
      grouped[story.userId]!.add(story);
    }

    return grouped.entries.map((entry) {
      final userStories = entry.value;
      final hasUnviewed = userStories.any((s) => !s.isViewed);

      return StoryGroupDto(
        userId: entry.key,
        userName: userStories.first.userName,
        userProfilePhoto: userStories.first.userProfilePhoto,
        stories: userStories,
        hasUnviewed: hasUnviewed,
      );
    }).toList();
  }
}

/// Create story request model
class CreateStoryRequestModel {
  final String mediaUrl;
  final String mediaType;
  final int? duration;
  final String? caption;

  CreateStoryRequestModel({
    required this.mediaUrl,
    required this.mediaType,
    this.duration,
    this.caption,
  });

  Map<String, dynamic> toJson() {
    return {
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      if (duration != null) 'duration': duration,
      if (caption != null) 'caption': caption,
    };
  }
}

/// Create story response model
class CreateStoryResponseModel {
  final StoryModel story;

  CreateStoryResponseModel({
    required this.story,
  });

  factory CreateStoryResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateStoryResponseModel(
      story: StoryModel.fromJson(json['story'] as Map<String, dynamic>),
    );
  }
}
