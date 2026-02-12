import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Story Circle Widget - Represents a user's stories in the horizontal list
class StoryCircle extends StatelessWidget {
  final String? userName;
  final String? userProfilePhoto;
  final bool hasUnviewed;
  final int storyCount;
  final bool isAddStory;
  final VoidCallback onTap;

  const StoryCircle({
    super.key,
    this.userName,
    this.userProfilePhoto,
    this.hasUnviewed = false,
    this.storyCount = 0,
    this.isAddStory = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCircleAvatar(context),
          const SizedBox(height: 4),
          _buildUserName(context),
        ],
      ),
    );
  }

  Widget _buildCircleAvatar(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasUnviewed && !isAddStory
            ? LinearGradient(
                colors: [
                  Colors.purple,
                  Colors.orange,
                  Colors.pink,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        border: !hasUnviewed && !isAddStory
            ? Border.all(
                color: Colors.grey[300]!,
                width: 2,
              )
            : null,
      ),
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(2),
        child: _buildAvatarContent(context),
      ),
    );
  }

  Widget _buildAvatarContent(BuildContext context) {
    if (isAddStory) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).primaryColor,
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
        ),
      );
    }

    if (userProfilePhoto != null && userProfilePhoto!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: userProfilePhoto!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) => _buildDefaultAvatar(context),
        ),
      );
    }

    return _buildDefaultAvatar(context);
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
      ),
      child: Center(
        child: Text(
          userName != null && userName!.isNotEmpty
              ? userName![0].toUpperCase()
              : '?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildUserName(BuildContext context) {
    return SizedBox(
      width: 70,
      child: Text(
        isAddStory ? 'Add Story' : (userName ?? 'Unknown'),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[800],
          fontWeight: hasUnviewed ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}
