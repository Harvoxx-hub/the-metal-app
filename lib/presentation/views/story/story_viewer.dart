import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:metal/domain/entities/story_dto.dart';
import 'package:metal/presentation/viewmodels/story/story_viewmodel_providers.dart';

/// Full-screen Story Viewer - Instagram/Facebook style story viewer
class StoryViewer extends ConsumerStatefulWidget {
  final int initialGroupIndex;
  final List<StoryGroupDto> storyGroups;

  const StoryViewer({
    super.key,
    required this.initialGroupIndex,
    required this.storyGroups,
  });

  @override
  ConsumerState<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends ConsumerState<StoryViewer> {
  late PageController _pageController;
  int currentGroupIndex = 0;
  int currentStoryIndex = 0;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    currentGroupIndex = widget.initialGroupIndex;
    _pageController = PageController(initialPage: widget.initialGroupIndex);
    _markCurrentStoryAsViewed();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _markCurrentStoryAsViewed() {
    final currentGroup = widget.storyGroups[currentGroupIndex];
    final currentStory = currentGroup.stories[currentStoryIndex];

    if (!currentStory.isViewed) {
      ref.read(storyViewModelProvider.notifier).markAsViewed(currentStory.id);
    }
  }

  void _nextStory() {
    final currentGroup = widget.storyGroups[currentGroupIndex];

    if (currentStoryIndex < currentGroup.stories.length - 1) {
      // Next story in same group
      setState(() {
        currentStoryIndex++;
      });
      _markCurrentStoryAsViewed();
    } else {
      // Next group
      _nextGroup();
    }
  }

  void _previousStory() {
    if (currentStoryIndex > 0) {
      // Previous story in same group
      setState(() {
        currentStoryIndex--;
      });
    } else {
      // Previous group
      _previousGroup();
    }
  }

  void _nextGroup() {
    if (currentGroupIndex < widget.storyGroups.length - 1) {
      setState(() {
        currentGroupIndex++;
        currentStoryIndex = 0;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _markCurrentStoryAsViewed();
    } else {
      // End of stories
      Navigator.pop(context);
    }
  }

  void _previousGroup() {
    if (currentGroupIndex > 0) {
      setState(() {
        currentGroupIndex--;
        currentStoryIndex = 0;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.storyGroups.length,
          onPageChanged: (index) {
            setState(() {
              currentGroupIndex = index;
              currentStoryIndex = 0;
            });
            _markCurrentStoryAsViewed();
          },
          itemBuilder: (context, groupIndex) {
            return _buildStoryGroupView(widget.storyGroups[groupIndex]);
          },
        ),
      ),
    );
  }

  Widget _buildStoryGroupView(StoryGroupDto group) {
    final story = group.stories[currentStoryIndex];

    return GestureDetector(
      onTapUp: (details) {
        final screenWidth = MediaQuery.of(context).size.width;
        if (details.globalPosition.dx < screenWidth / 2) {
          _previousStory();
        } else {
          _nextStory();
        }
      },
      child: Stack(
        children: [
          _buildStoryContent(story),
          _buildStoryHeader(group, story),
          _buildStoryProgressIndicators(group),
        ],
      ),
    );
  }

  Widget _buildStoryContent(StoryDto story) {
    if (story.mediaType == StoryMediaType.video) {
      return Center(
        child: Text(
          'Video player not implemented yet',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: story.mediaUrl,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      errorWidget: (context, url, error) => const Center(
        child: Icon(Icons.error, color: Colors.white, size: 50),
      ),
    );
  }

  Widget _buildStoryHeader(StoryGroupDto group, StoryDto story) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: group.userProfilePhoto != null
                  ? CachedNetworkImageProvider(group.userProfilePhoto!)
                  : null,
              child: group.userProfilePhoto == null
                  ? Text(group.userName[0].toUpperCase())
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _formatTimestamp(story.createdAt),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryProgressIndicators(StoryGroupDto group) {
    return Positioned(
      top: 50,
      left: 8,
      right: 8,
      child: Row(
        children: List.generate(
          group.stories.length,
          (index) => Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index < currentStoryIndex
                    ? Colors.white
                    : index == currentStoryIndex
                        ? Colors.white.withOpacity(0.7)
                        : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
