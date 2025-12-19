import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/presentation/views/thought/widgets/thought_card.dart';
import 'package:metal/presentation/views/story/story_view.dart';
import 'package:metal/presentation/views/community/community_list_view.dart';
import 'package:metal/presentation/viewmodels/thought/thought_feed_viewmodel.dart';
import 'package:metal/presentation/viewmodels/thought/thought_providers.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/shimmer/feed_shimmer_widget.dart';
import 'package:metal/widgets/state.handler/empty.state.dart';
import 'package:metal/widgets/state.handler/error.state.dart';
import 'package:metal/widgets/text_views.dart';

/// New Thought Screen with 3 tabs: Thoughts, Community, Link Up
class ThoughtScreen extends ConsumerStatefulWidget {
  const ThoughtScreen({super.key});

  @override
  ConsumerState<ThoughtScreen> createState() => _ThoughtScreenState();
}

class _ThoughtScreenState extends ConsumerState<ThoughtScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        const Gap(8),
        _buildTabBar(),
        const Gap(8),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildThoughtsTab(),
              _buildCommunityTab(),
              _buildLinkUpTab(),
            ],
          ),
        ),
      ],
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
      child: const Center(
        child: TextView(
          text: 'Share Your Thoughts Anonymously',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.metalPinkColour,
          borderRadius: BorderRadius.circular(25),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Thoughts'),
          Tab(text: 'Community'),
          Tab(text: 'Link Up'),
        ],
      ),
    );
  }

  /// Thoughts Tab - Shows all thoughts feed
  Widget _buildThoughtsTab() {
    final feedState = ref.watch(thoughtFeedViewModelProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(thoughtFeedViewModelProvider.notifier).refresh();
      },
      child: _buildThoughtsFeedContent(feedState),
    );
  }

  Widget _buildThoughtsFeedContent(ThoughtFeedState feedState) {
    if (feedState.isLoading && feedState.thoughts.isEmpty) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => PostCardShimmer(),
      );
    }

    if (feedState.isError && feedState.thoughts.isEmpty) {
      return ErrorState(
        text: feedState.errorMessage ?? 'Failed to load thoughts',
        retry: () {
          ref.read(thoughtFeedViewModelProvider.notifier).refresh();
        },
      );
    }

    if (feedState.thoughts.isEmpty) {
      return const EmptyState(
        text: 'No thoughts yet\nBe the first to share your thoughts!',
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          final metrics = notification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent - 200) {
            // Load more when near the bottom
            ref.read(thoughtFeedViewModelProvider.notifier).loadMoreThoughts();
          }
        }
        return false;
      },
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount:
            1 + feedState.thoughts.length + (feedState.isLoadingMore ? 1 : 0), // +1 for StoryView
        itemBuilder: (context, index) {
          // First item is StoryView
          if (index == 0) {
            return const Column(
              children: [
                StoryView(),
                Gap(8),
              ],
            );
          }

          // Loading indicator at the end
          if (index == feedState.thoughts.length + 1) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          // Thought cards
          final thoughtIndex = index - 1; // Adjust for StoryView at index 0
          final thought = feedState.thoughts[thoughtIndex];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 16),
            child: ThoughtCard(
              thoughtModel: thought,
            ),
          );
        },
      ),
    );
  }

  /// Community Tab - Shows communities list
  Widget _buildCommunityTab() {
    return const CommunityListView();
  }

  /// Link Up Tab - Placeholder for now
  Widget _buildLinkUpTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.link,
            size: 80,
            color: Colors.grey[400],
          ),
          const Gap(16),
          TextView(
            text: 'Link Up',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
          const Gap(8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: TextView(
              text: 'Find and connect with people for events, activities, and more.',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey[500],
              textAlign: TextAlign.center,
            ),
          ),
          const Gap(24),
          TextView(
            text: 'Coming Soon',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.metalPinkColour,
          ),
        ],
      ),
    );
  }
}
