import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/state/base.state.dart';

import 'package:metal/features/home_page/domain/entries/thought.model.dart';

import 'package:metal/features/home_page/provider/get.thoughts.explore.dart';
import 'package:metal/features/home_page/provider/get.thoughts.for.you.dart';

import 'package:metal/features/home_page/widget/thought_card.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/shimmer/custom_shimmer_loader.dart';
import 'package:metal/widgets/shimmer/feed_shimmer_widget.dart';
import 'package:metal/widgets/state.handler/empty.state.dart';
import 'package:metal/widgets/state.handler/error.state.dart';

import 'package:metal/widgets/text_views.dart';
import 'package:metal/features/dashboard.dart/widget/tutorial_overlay.dart';

class HomePage extends ConsumerStatefulWidget {
  final GlobalKey? newPostFabKey;
  final GlobalKey exploreTabKey = GlobalKey();
  final GlobalKey forYouTabKey = GlobalKey();
  final GlobalKey sparksTabKey = GlobalKey();
  final GlobalKey chatTabKey = GlobalKey();
  final GlobalKey profileKey;
  final GlobalKey commentKey;
  final GlobalKey reactionKey;

  HomePage({
    super.key,
    this.newPostFabKey,
    required this.profileKey,
    required this.commentKey,
    required this.reactionKey,
  });

  List<TutorialStep> getTutorialSteps(
    GlobalKey? fabKey,
    GlobalKey profileKey,
    GlobalKey commentKey,
    GlobalKey reactionKey,
  ) {
    return [
      // 1. Explore
      TutorialStep(
        targetKey: exploreTabKey,
        content: const Column(
          children: [
            TextView(
              text: "Explore Thoughts Posted",
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            SizedBox(height: 10),
            TextView(
              text:
                  "The *Explore* section highlights popular posts, new members, and trending conversations to keep you engaged with fresh content.",
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        onNext: () {},
      ),
      // 2. For You
      TutorialStep(
        targetKey: forYouTabKey,
        content: const Column(
          children: [
            TextView(
              text: "For You",
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            SizedBox(height: 10),
            TextView(
              text:
                  "Discover personalized content and conversations tailored to your interests and preferences.",
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        onNext: () {},
      ),
      // 3. View Metal Profile
      TutorialStep(
        targetKey: profileKey,
        content: const Column(
          children: [
            TextView(
              text: "View Metal Profile",
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            SizedBox(height: 10),
            TextView(
              text:
                  "Visit user profiles to learn more about them, see their thoughts, and start meaningful conversations.",
              fontSize: 16,
              color: Colors.white,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        onNext: () {},
      ),
      // 4. Comment
      TutorialStep(
        targetKey: commentKey,
        content: const Column(
          children: [
            TextView(
              text: "Comment & Connect",
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            SizedBox(height: 10),
            TextView(
              text:
                  "Share your thoughts and engage with others through comments. Start meaningful conversations before melting!",
              fontSize: 16,
              color: Colors.white,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        onNext: () {},
      ),
      // 5. Reaction
      TutorialStep(
        targetKey: reactionKey,
        content: const Column(
          children: [
            TextView(
              text: "React & Express",
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            SizedBox(height: 10),
            TextView(
              text:
                  "Show appreciation and express your feelings by reacting to thoughts with different emojis.",
              fontSize: 16,
              color: Colors.white,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        onNext: () {},
      ),
      // 6. Post Thought
      if (fabKey != null)
        TutorialStep(
          targetKey: fabKey,
          content: const Column(
            children: [
              TextView(
                text: "Share Your Thoughts",
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              SizedBox(height: 10),
              TextView(
                text:
                    "Express yourself anonymously and share your thoughts with the community. Start conversations and connect with like-minded people.",
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          onNext: () {},
        ),
      // 7. Sparks
      TutorialStep(
        targetKey: sparksTabKey,
        content: const Column(
          children: [
            TextView(
              text: "Sparks",
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            SizedBox(height: 10),
            TextView(
              text:
                  "Our in-app currency where 1 Dollar = 10 Sparks. Earn sparks by referring friends, or buy them to send to others and unlock special features.",
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        onNext: () {},
      ),
      // 8. Chat
      TutorialStep(
        targetKey: chatTabKey,
        content: const Column(
          children: [
            TextView(
              text: "Chat & Connect",
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            SizedBox(height: 10),
            TextView(
              text:
                  "Build genuine connections through anonymous chats for 15 days. Play games and use sparks to deepen your connections before revealing photos.",
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        onNext: () {},
      ),
    ];
  }

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int tabIndex = 0;
  bool _tutorialShown = false;

  @override
  void initState() {
    super.initState();
  }

  void _showTutorialIfNeeded() {
    if (_tutorialShown) return;
    _tutorialShown = true;

    showTutorial(
      context,
      widget.getTutorialSteps(
        widget.newPostFabKey,
        widget.profileKey,
        widget.commentKey,
        widget.reactionKey,
      ),
      'home_tutorial_key',
    );
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
          Expanded(
            child: tabIndex == 0
                ? _buildThoughtTab(getThoughtExploreState)
                : _buildThoughtTab(getThoughtForYouState),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    ref.refresh(getThoughtForYouProvider);
    ref.refresh(getThoughtExploreProvider);
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
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: TextView(
          text: "Share Your Thoughts Anonymously",
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.w400,
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
          key: widget.exploreTabKey,
          child: _buildFeedTabItem(
              "Explore", tabIndex == 0, () => _onTabChange(0)),
        ),
        const Gap(20),
        Container(
          key: widget.forYouTabKey,
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

  Widget _buildThoughtTab(BaseState<List<ThoughtModel>> thoughtState) {
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
            itemCount: thoughtState.data!.length,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Container(
                  child: ThoughtCard(
                    thoughtModel: thoughtState.data![index],
                    toughtProfileKey: widget.profileKey,
                    toughtCommentKey: widget.commentKey,
                    reactionKey: widget.reactionKey,
                  ),
                );
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
