import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/domain/entities/thought_dto.dart';
import 'package:metal/presentation/viewmodels/community/community_detail_viewmodel_providers.dart';
import 'package:metal/presentation/views/thought/widgets/thought_card.dart';
import 'package:metal/widgets/state.handler/empty.state.dart';

/// Community Posts Tab - displays thoughts posted in the community
class CommunityPostsTab extends ConsumerWidget {
  final String communityId;
  final List<ThoughtDto> initialPosts;

  const CommunityPostsTab({
    super.key,
    required this.communityId,
    required this.initialPosts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(
      communityDetailViewModelProvider(communityId),
    );

    final posts = detailState.posts.isNotEmpty ? detailState.posts : initialPosts;

    if (posts.isEmpty) {
      return const EmptyState(
        text: 'No posts yet\nBe the first to share something in this community!',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(communityDetailViewModelProvider(communityId).notifier)
            .loadCommunityDetails(communityId);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final thought = posts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ThoughtCard(
              thoughtModel: thought,
            ),
          );
        },
      ),
    );
  }
}
