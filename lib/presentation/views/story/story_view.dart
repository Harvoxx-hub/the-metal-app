import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/presentation/viewmodels/story/story_viewmodel_providers.dart';
import 'package:metal/presentation/views/story/widgets/story_circle.dart';
import 'package:metal/presentation/views/story/story_creator.dart';
import 'package:metal/presentation/views/story/story_viewer.dart';

/// Main Story View - Displays horizontal list of story circles
/// This view is typically embedded at the top of the feed or dashboard
class StoryView extends ConsumerWidget {
  const StoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyState = ref.watch(storyViewModelProvider);

    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: storyState.isLoading && !storyState.hasStories
          ? _buildLoadingState()
          : _buildStoryList(context, ref, storyState),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 60,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStoryList(BuildContext context, WidgetRef ref, dynamic storyState) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: storyState.storyGroups.length + 1, // +1 for "Add Story" button
      itemBuilder: (context, index) {
        if (index == 0) {
          // First item is "Add Story" button
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: StoryCircle(
              isAddStory: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StoryCreator(),
                  ),
                );
              },
            ),
          );
        }

        final groupIndex = index - 1;
        final storyGroup = storyState.storyGroups[groupIndex];

        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: StoryCircle(
            userName: storyGroup.userName,
            userProfilePhoto: storyGroup.userProfilePhoto,
            hasUnviewed: storyGroup.hasUnviewed,
            storyCount: storyGroup.stories.length,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoryViewer(
                    initialGroupIndex: groupIndex,
                    storyGroups: storyState.storyGroups,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
