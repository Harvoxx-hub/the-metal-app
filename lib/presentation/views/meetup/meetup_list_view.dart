import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/presentation/viewmodels/meetup/meetup_viewmodel.dart';
import 'package:metal/widgets/shimmer/feed_shimmer_widget.dart';
import 'package:metal/widgets/state.handler/empty.state.dart';
import 'package:metal/widgets/state.handler/error.state.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/presentation/views/meetup/widgets/meetup_card.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';

/// Meetup List View
/// Shows list of meetups in the Link Up tab
class MeetupListView extends ConsumerStatefulWidget {
  const MeetupListView({super.key});

  @override
  ConsumerState<MeetupListView> createState() => _MeetupListViewState();
}

class _MeetupListViewState extends ConsumerState<MeetupListView> {
  @override
  void initState() {
    super.initState();
    // Load meetups when view is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(meetupFeedViewModelProvider.notifier).loadMeetups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(meetupFeedViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Filter toggle
          if (feedState.meetups.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      ref
                          .read(meetupFeedViewModelProvider.notifier)
                          .toggleFilterByPreferences();
                    },
                    icon: Icon(
                      feedState.filterByPreferences
                          ? Icons.filter_list
                          : Icons.filter_list_outlined,
                      color: feedState.filterByPreferences
                          ? AppColors.metalPinkColour
                          : Colors.grey,
                    ),
                    label: TextView(
                      text: 'Filter by preferences',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: feedState.filterByPreferences
                          ? AppColors.metalPinkColour
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          // Meetup list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(meetupFeedViewModelProvider.notifier).refresh();
              },
              child: _buildContent(feedState),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateMeetup,
        backgroundColor: AppColors.metalPinkColour,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _navigateToCreateMeetup() {
    Navigator.pushNamed(
      context,
      AppRoutes.createMeetup,
    ).then((result) {
      if (result == true) {
        // Refresh meetups after creation
        ref.read(meetupFeedViewModelProvider.notifier).refresh();
      }
    });
  }

  Widget _buildContent(MeetupFeedState feedState) {
    if (feedState.isLoading && feedState.meetups.isEmpty) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => PostCardShimmer(),
      );
    }

    if (feedState.isError && feedState.meetups.isEmpty) {
      return ErrorState(
        text: feedState.errorMessage ?? 'Failed to load meetups',
        retry: () {
          ref.read(meetupFeedViewModelProvider.notifier).loadMeetups();
        },
      );
    }

    if (feedState.meetups.isEmpty) {
      return const EmptyState(
        text: 'No meetups yet\nBe the first to create a meetup!',
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          final metrics = notification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent - 200) {
            ref.read(meetupFeedViewModelProvider.notifier).loadMoreMeetups();
          }
        }
        return false;
      },
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount:
            feedState.meetups.length + (feedState.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Loading indicator at the end
          if (index == feedState.meetups.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final meetup = feedState.meetups[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 16),
            child: MeetupCard(
              meetup: meetup,
            ),
          );
        },
      ),
    );
  }
}
