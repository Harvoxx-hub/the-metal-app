import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/state/base.state.dart';

import 'package:metal/features/thought/data/domain/entries/thought.model.dart';
import 'package:metal/features/thought/data/domain/entries/explore_feed_model.dart';

import 'package:metal/features/thought/provider/get.thoughts.explore.dart';
import 'package:metal/features/thought/provider/get.thoughts.for.you.dart';
import 'package:metal/features/thought/provider/reaction.provider.dart';
import 'package:metal/features/thought/provider/comment.provider.dart';

import 'package:metal/features/thought/widget/thought_card.dart';
import 'package:metal/features/thought/widget/feed_divider_card.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/shimmer/custom_shimmer_loader.dart';
import 'package:metal/widgets/shimmer/feed_shimmer_widget.dart';
import 'package:metal/widgets/state.handler/empty.state.dart';
import 'package:metal/widgets/state.handler/error.state.dart';

import 'package:metal/widgets/text_views.dart';
import 'package:metal/features/dashboard.dart/widget/tutorial_overlay.dart';
import 'package:metal/route/routes.dart';

class ThoughtScreen extends ConsumerStatefulWidget {
  ThoughtScreen({
    super.key,
  });

  @override
  ConsumerState<ThoughtScreen> createState() => _ThoughtScreenState();
}

class _ThoughtScreenState extends ConsumerState<ThoughtScreen> {
  int tabIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final getThoughtForYouState = ref.watch(getThoughtForYouProvider);
    final getThoughtExploreState = ref.watch(getThoughtExploreProvider);

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Column(
        children: [
          _buildHeader(),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: _buildFeedTabs(),
          ),
          const Gap(24),
          // community discovery
          Container(
            child: _buildCommunityDiscovery(),
          ),
          const Gap(24),
          Expanded(
            child: tabIndex == 0
                ? _buildExploreFeedTab(getThoughtExploreState)
                : _buildForYouTab(getThoughtForYouState),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    ref.refresh(getThoughtForYouProvider);
    ref.refresh(getThoughtExploreProvider);

    // Refresh all reaction and comment providers for currently visible thoughts
    if (tabIndex == 0) {
      final exploreFeed = ref.read(getThoughtExploreProvider).data;
      if (exploreFeed != null) {
        final allThoughts = [
          ...exploreFeed.featuredThoughts,
          ...exploreFeed.unfeaturedThoughts,
        ];
        for (final thought in allThoughts) {
          ref.invalidate(reactionProvider(thought.id));
          ref.invalidate(commentProvider(thought.id));
        }
      }
    } else {
      final thoughts = ref.read(getThoughtForYouProvider).data ?? [];
      for (final thought in thoughts) {
        ref.invalidate(reactionProvider(thought.id));
        ref.invalidate(commentProvider(thought.id));
      }
    }
  }

  Widget _buildCommunityDiscovery() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.metalPinkColour.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.metalPinkColour.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextView(
            text: 'Community Discovery',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          const Gap(12),
          TextView(
            text:
                'One-tap to join communities based on interest and activities. No approval required for public communities.',
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          const Gap(12),
          BaseButton(
            buttonText: 'Explore Communities',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.communityDiscovery);
            },
            width: 180,
            height: 40,
            fontSize: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 53,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.00, -1.00),
          end: Alignment(0, 1),
          colors: [Color(0xFFDB217A), Color(0xFFF00E3E)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Row(
          children: [
            Expanded(
              child: TextView(
                text: "Share Your Thoughts Anonymously",
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
      ],
        ),
      ),
    );
  }

  Widget _buildFeedTabs() {
    return Row(
      children: [
        const TextView(
          text: "Feed",
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        const Spacer(),
        Container(
          child: _buildFeedTabItem(
              "Explore", tabIndex == 0, () => _onTabChange(0)),
        ),
        const Gap(20),
        Container(
          child: _buildFeedTabItem(
              "For You", tabIndex == 1, () => _onTabChange(1)),
        ),
      ],
    );
  }

  Widget _buildFeedTabItem(String title, bool selected, VoidCallback onPress) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.metalPinkColour40 : null,
          border: selected
              ? null
              : Border.all(color: AppColors.metalBlack, width: 1.0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextView(
          text: title,
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  void _onTabChange(int index) {
    _refreshData();
    setState(() {
      tabIndex = index;
    });
  }

  Widget _buildExploreFeedTab(BaseState<ExploreFeedModel> exploreState) {
    switch (exploreState.status) {
      case Status.loading:
        return CustomShimmerLoader(
          itemType: ShimmerItemType.list,
          loaderWidget: PostCardShimmer(),
        );
      case Status.success:
        final exploreFeed = exploreState.data!;
        if (exploreFeed.isEmpty) {
          return const EmptyState(text: "No thoughts were found");
        } else {
          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: exploreFeed.totalItemCount,
            itemBuilder: (context, index) {
              // Check if this is the divider position
              if (exploreFeed.isDividerIndex(index)) {
                return FeedDividerCard(
                  message: exploreFeed.featuredThoughts.isEmpty
                      ? "No thoughts were found, that match your preferences. Please update your preferences in Metal to get more personalized content."
                      : "🎯 You've reached the end of matched thoughts.\nHere are some suggested thoughts from the community.",
                  isButton: true,
                );
              }

              // Get the thought at this index
              final thought = exploreFeed.getThoughtAtIndex(index);
              if (thought == null) return const SizedBox.shrink();

              // Add keys for tutorial on the first thought
              if (index == 0) {
                return ThoughtCard(
                  thoughtModel: thought,
                );
              }
              return ThoughtCard(thoughtModel: thought);
            },
          );
        }
      case Status.error:
        return ErrorState(
          retry: () => _refreshData(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildForYouTab(BaseState<List<ThoughtModel>> thoughtState) {
    switch (thoughtState.status) {
      case Status.loading:
        return CustomShimmerLoader(
          itemType: ShimmerItemType.list,
          loaderWidget: PostCardShimmer(),
        );
      case Status.success:
        if (thoughtState.data!.isEmpty) {
          return const EmptyState(text: "No thoughts were found");
        } else {
          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: thoughtState.data!.length,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ThoughtCard(thoughtModel: thoughtState.data![index]);
              }
              return ThoughtCard(thoughtModel: thoughtState.data![index]);
            },
          );
        }
      case Status.error:
        return ErrorState(
          retry: () => _refreshData(),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
