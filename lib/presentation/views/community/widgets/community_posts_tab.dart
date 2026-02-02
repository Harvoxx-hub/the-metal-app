import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/presentation/viewmodels/community/community_detail_viewmodel_providers.dart';
import 'package:metal/presentation/views/thought/widgets/thought_card.dart';
import 'package:metal/widgets/state.handler/empty.state.dart';

/// Community Posts Tab – list is driven only by [communityDetailViewModelProvider].state.posts.
/// Add/remove in that state and the list updates (no scroll or extra state).
class CommunityPostsTab extends ConsumerWidget {
  final String communityId;
  final ScrollController? scrollController;

  const CommunityPostsTab({
    super.key,
    required this.communityId,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(
      communityDetailViewModelProvider(communityId),
    );
    final posts = detailState.posts;

    if (posts.isEmpty) {
      return Center(
        child: 
       RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(communityDetailViewModelProvider(communityId).notifier)
              .refreshAll(communityId);
        },
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: 300,
            child: EmptyState(
              text: 'No posts yet\nBe the first to share something in this community!',
            ),
          ),
        ),
      ));
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(communityDetailViewModelProvider(communityId).notifier)
            .refreshAll(communityId);
      },
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final thought = posts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ThoughtCard(
              thoughtModel: thought,
              communityId: communityId,
            ),
          );
        },
      ),
    );
  }
}
