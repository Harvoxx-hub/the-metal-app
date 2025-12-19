/// Story (Eyes) data transfer object
class StoryDto {
  final String id;
  final String userId;
  final String userName;
  final String? userProfilePhoto;
  final String mediaUrl;
  final StoryMediaType mediaType;
  final int? duration; // Duration in seconds for videos
  final String? caption;
  final int viewCount;
  final bool isViewed;
  final DateTime createdAt;
  final DateTime expiresAt;

  StoryDto({
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

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isOwn => false; // Will be determined by comparing with current user

  StoryDto copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userProfilePhoto,
    String? mediaUrl,
    StoryMediaType? mediaType,
    int? duration,
    String? caption,
    int? viewCount,
    bool? isViewed,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return StoryDto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfilePhoto: userProfilePhoto ?? this.userProfilePhoto,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      duration: duration ?? this.duration,
      caption: caption ?? this.caption,
      viewCount: viewCount ?? this.viewCount,
      isViewed: isViewed ?? this.isViewed,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

/// Story media types
enum StoryMediaType {
  image,
  video,
}

/// Grouped stories by user
class StoryGroupDto {
  final String userId;
  final String userName;
  final String? userProfilePhoto;
  final List<StoryDto> stories;
  final bool hasUnviewed;

  StoryGroupDto({
    required this.userId,
    required this.userName,
    this.userProfilePhoto,
    required this.stories,
    required this.hasUnviewed,
  });

  StoryDto? get latestStory => stories.isNotEmpty ? stories.first : null;
  int get unviewedCount => stories.where((s) => !s.isViewed).length;

  StoryGroupDto copyWith({
    String? userId,
    String? userName,
    String? userProfilePhoto,
    List<StoryDto>? stories,
    bool? hasUnviewed,
  }) {
    return StoryGroupDto(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfilePhoto: userProfilePhoto ?? this.userProfilePhoto,
      stories: stories ?? this.stories,
      hasUnviewed: hasUnviewed ?? this.hasUnviewed,
    );
  }
}
