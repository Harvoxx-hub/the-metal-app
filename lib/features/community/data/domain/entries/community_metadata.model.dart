class CommunityMetadata {
  final String communityId;
  final String communityName;
  final List<String> categories;
  final String? communityImage;
  final bool isPublic;

  CommunityMetadata({
    required this.communityId,
    required this.communityName,
    required this.categories,
    this.communityImage,
    this.isPublic = true,
  });

  factory CommunityMetadata.fromJson(Map<String, dynamic> json) {
    return CommunityMetadata(
      communityId: json['communityId'] ?? '',
      communityName: json['communityName'] ?? '',
      categories: List<String>.from(json['categories'] ?? []),
      communityImage: json['communityImage'],
      isPublic: json['isPublic'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'communityId': communityId,
      'communityName': communityName,
      'categories': categories,
      'communityImage': communityImage,
      'isPublic': isPublic,
    };
  }

  CommunityMetadata copyWith({
    String? communityId,
    String? communityName,
    List<String>? categories,
    String? communityImage,
    bool? isPublic,
  }) {
    return CommunityMetadata(
      communityId: communityId ?? this.communityId,
      communityName: communityName ?? this.communityName,
      categories: categories ?? this.categories,
      communityImage: communityImage ?? this.communityImage,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}
