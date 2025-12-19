import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/presentation/viewmodels/community/community_viewmodel_providers.dart';
import 'package:metal/presentation/views/community/widgets/community_card.dart';

class CommunityListView extends ConsumerWidget {
  const CommunityListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communityState = ref.watch(communityViewModelProvider);

    if (communityState.isLoading && communityState.communities.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (communityState.isError && communityState.communities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(communityState.errorMessage ?? 'Failed to load communities'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(communityViewModelProvider.notifier).loadCommunities(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (communityState.communities.isEmpty) {
      return const Center(
        child: Text('No communities found\nBe the first to create one!'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(communityViewModelProvider.notifier).loadCommunities(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: communityState.communities.length,
        itemBuilder: (context, index) {
          final community = communityState.communities[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CommunityCard(
              community: community,
              onJoin: () => ref.read(communityViewModelProvider.notifier).joinCommunity(community.id),
              onLeave: () => ref.read(communityViewModelProvider.notifier).leaveCommunity(community.id),
            ),
          );
        },
      ),
    );
  }
}
