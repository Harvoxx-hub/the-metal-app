import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/features/community/data/domain/entries/community.model.dart';
import 'package:metal/features/thought/widget/thought_card.dart';
import 'package:metal/features/thought/data/domain/entries/thought.model.dart';
import 'package:metal/features/community/provider/community_thoughts_notifier.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/widgets/shimmer/custom_shimmer_loader.dart';
import 'package:metal/widgets/shimmer/feed_shimmer_widget.dart';
import 'package:metal/widgets/state.handler/error.state.dart';

class CommunityFeedScreen extends ConsumerStatefulWidget {
  final CommunityModel community;

  const CommunityFeedScreen({
    super.key,
    required this.community,
  });

  @override
  ConsumerState<CommunityFeedScreen> createState() =>
      _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends ConsumerState<CommunityFeedScreen> {
  @override
  void initState() {
    super.initState();
    // Load community thoughts when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(communityThoughtsProvider(widget.community.id).notifier)
          .getCommunityThoughts(widget.community.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final communityThoughtsState =
        ref.watch(communityThoughtsProvider(widget.community.id));

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(communityThoughtsProvider(widget.community.id).notifier)
            .refreshCommunityThoughts(widget.community.id);
      },
      child: _buildCommunityFeed(communityThoughtsState),
    );
  }

  Widget _buildCommunityFeed(BaseState<List<ThoughtModel>> thoughtsState) {
    switch (thoughtsState.status) {
      case Status.loading:
        return CustomShimmerLoader(
          itemType: ShimmerItemType.list,
          loaderWidget: PostCardShimmer(),
        );
      case Status.success:
        final thoughts = thoughtsState.data ?? [];
        if (thoughts.isEmpty) {
          return _buildEmptyState();
        } else {
          return SingleChildScrollView(
            child: Column(
              children: thoughts.map((thought) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ThoughtCard(
                    thoughtModel: thought,
                  ),
                );
              }).toList(),
            ),
          );
        }
      case Status.error:
        return ErrorState(
          retry: () {
            ref
                .read(communityThoughtsProvider(widget.community.id).notifier)
                .getCommunityThoughts(widget.community.id);
          },
        );
      default:
        return _buildEmptyState();
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.forum_outlined,
            size: 64,
            color: AppColors.metalBrownColourForText.withOpacity(0.3),
          ),
          const Gap(16),
          Text(
            'No posts yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.metalBrownColourForText,
            ),
          ),
          const Gap(8),
          Text(
            'Be the first to share something with this community!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.metalBrownColourForText.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
