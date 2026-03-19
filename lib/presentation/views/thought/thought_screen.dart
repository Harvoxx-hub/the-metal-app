import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/presentation/views/thought/widgets/thought_card.dart';
// import 'package:metal/presentation/views/story/story_view.dart';
import 'package:metal/presentation/views/community/community_list_view.dart';
import 'package:metal/presentation/views/meetup/discover_meetups_view.dart';
import 'package:metal/presentation/viewmodels/thought/thought_feed_viewmodel.dart';
import 'package:metal/presentation/viewmodels/thought/thought_providers.dart';
import 'package:metal/presentation/viewmodels/meetup/meetup_viewmodel.dart';
import 'package:metal/domain/entities/thought_dto.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/shimmer/feed_shimmer_widget.dart';
import 'package:metal/widgets/state.handler/empty.state.dart';
import 'package:metal/widgets/state.handler/error.state.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/route/routes.dart';

/// New Thought Screen with 3 tabs: Thoughts, Community, Meetup
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
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    setState(() {
      // Rebuild to update FAB based on current tab
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
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
                _buildMeetupTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget? _buildFAB() {
    final currentTab = _tabController.index;

    switch (currentTab) {
      case 0: // Thoughts tab
        return FloatingActionButton(
          backgroundColor: AppColors.metalPinkColour,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.postThought)
              .then((result) {
            if (result is ThoughtDto) {
              ref.read(thoughtFeedViewModelProvider.notifier).addThought(result);
            }
          }),
          child: const Icon(Icons.add, color: Colors.white),
        );
      case 1: // Community tab
        return FloatingActionButton(
          backgroundColor: AppColors.metalPinkColour,
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.createCommunity),
          child: const Icon(Icons.add, color: Colors.white),
        );
      case 2: // Meetup tab
        return FloatingActionButton(
          backgroundColor: AppColors.metalPinkColour,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.createMeetup)
              .then((result) {
            if (result == true) {
              // Refresh meetups after creation
              ref.read(meetupFeedViewModelProvider.notifier).refresh();
            }
          }),
          child: const Icon(Icons.add, color: Colors.white),
        );
      default:
        return null;
    }
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
          Tab(text: 'Meetup'),
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
        itemCount: feedState.thoughts.length +
            (feedState.isLoadingMore ? 1 : 0), // StoryView commented out
        itemBuilder: (context, index) {
          // First item is StoryView
          // if (index == 0) {
          //   return const Column(
          //     children: [
          //       StoryView(),
          //       Gap(8),
          //     ],
          //   );
          // }

          // Loading indicator at the end
          if (index == feedState.thoughts.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          // Thought cards
          final thoughtIndex =
              index; // StoryView commented out, no adjustment needed
          final thought = feedState.thoughts[thoughtIndex];
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 16),
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

  /// Meetup Tab - Discover Meetups (map/list toggle, filters, nearby list, empty state)
  Widget _buildMeetupTab() {
    return const DiscoverMeetupsView();
  }
}
