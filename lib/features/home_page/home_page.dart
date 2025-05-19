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
  static final GlobalKey exploreTabKey = GlobalKey();
  static final GlobalKey forYouTabKey = GlobalKey();
  static final GlobalKey sparksTabKey = GlobalKey();
  static final GlobalKey chatTabKey = GlobalKey();
  final GlobalKey profileKey;
  final GlobalKey commentKey;
  final GlobalKey reactionKey;

  const HomePage({
    super.key,
    this.newPostFabKey,
    required this.profileKey,
    required this.commentKey,
    required this.reactionKey,
  });

  static List<TutorialStep> getTutorialSteps(
    GlobalKey? fabKey,
    GlobalKey profileKey,
    GlobalKey commentKey,
    GlobalKey reactionKey,
  ) {
    return [
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
                  "The *Explore* section highlight popular posts, new members, or trending conversations to keep users engaged with fresh content.",
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        onNext: () {},
      ),
      TutorialStep(
        targetKey: forYouTabKey,
        content: const Column(
          children: [
            TextView(
              text: "Personalized Thoughts",
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            SizedBox(height: 10),
            TextView(
              text:
                  "The *For You* section helps you discover new connections, conversations, and content tailored to your personality, preferences, and past behaviors on the app.",
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        onNext: () {},
      ),
      TutorialStep(
        targetKey: sparksTabKey,
        content: const Column(
          children: [
            TextView(
              text: "About Sparks!",
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            SizedBox(height: 10),
            TextView(
              text:
                  "Our point payment in-app system. 1 Dollar = 10 Sparks. You can refer friends and earn more sparks. You can also send and buy Sparks.",
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        onNext: () {},
      ),
      TutorialStep(
        targetKey: chatTabKey,
        content: const Column(
          children: [
            TextView(
              text: "About Chats!",
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            SizedBox(height: 10),
            TextView(
              text:
                  "Send and receive messages to build real connections with metals for the next 15days without showing your pictures. Play games to deepen conversations and sparks to ignite connections",
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        onNext: () {},
      ),
      TutorialStep(
        targetKey: profileKey,
        content: const Column(
          children: [
            TextView(
              text: "View Metal",
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            TextView(
              text:
                  "Go to the user profile to chat with Metal and to see other thoughts from this Metal",
              fontSize: 16,
              color: Colors.white,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        onNext: () {},
      ),
      TutorialStep(
        targetKey: commentKey,
        content: const Column(
          children: [
            TextView(
              text: "Comment to Connect",
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            TextView(
              text:
                  " Drop a thoughtful comment on a profile to spark meaningful conversation and stand out from the crowd. It’s a great way to show genuine interest before a melt happens!",
              fontSize: 16,
              color: Colors.white,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        onNext: () {},
      ),
      TutorialStep(
        targetKey: reactionKey,
        content: const Column(
          children: [
            TextView(
              text: "Tap to Like or React",
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            TextView(
              text:
                  "Show appreciation by liking or reacting to each other’s thoughts.",
              fontSize: 16,
              color: Colors.white,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        onNext: () {},
      ),
      if (fabKey != null)
        TutorialStep(
          targetKey: fabKey,
          content: const Column(
            children: [
              TextView(
                text: "Post Your Thoughts Anonymously",
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              SizedBox(height: 10),
              TextView(
                text:
                    "A simple and intuitive posting tool that allows you to share your thoughts, feelings, or introduce yourself to the community.",
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
      HomePage.getTutorialSteps(
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
    final thoughts = tabIndex == 0
        ? getThoughtExploreState.data ?? []
        : getThoughtForYouState.data ?? [];

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
            child: ListView.builder(
              itemCount: thoughts.length,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(
                    child: ThoughtCard(
                      thoughtModel: thoughts[index],
                      toughtProfileKey: widget.profileKey,
                      toughtCommentKey: widget.commentKey,
                      reactionIconKey: widget.reactionKey,
                    ),
                  );
                }
                return ThoughtCard(thoughtModel: thoughts[index]);
              },
            ),
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
          key: HomePage.exploreTabKey,
          child: _buildFeedTabItem(
              "Explore", tabIndex == 0, () => _onTabChange(0)),
        ),
        const Gap(20),
        Container(
          key: HomePage.forYouTabKey,
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

  Widget _forYouThoughtTab(BaseState<List<ThoughtModel>> thoughtState) {
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
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
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
