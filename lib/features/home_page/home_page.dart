import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/state/base.state.dart';

import 'package:metal/features/dashboard.dart/widget/complete.profile.dialog.dart';
import 'package:metal/features/home_page/domain/entries/thought.model.dart';

import 'package:metal/features/home_page/provider/get.thoughts.explore.dart';
import 'package:metal/features/home_page/provider/get.thoughts.for.you.dart';

import 'package:metal/features/home_page/widget/thought_card.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/outiline.button.dart';
import 'package:metal/widgets/button/plain.button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/shimmer/custom_shimmer_loader.dart';
import 'package:metal/widgets/shimmer/feed_shimmer_widget.dart';
import 'package:metal/widgets/state.handler/empty.state.dart';
import 'package:metal/widgets/state.handler/error.state.dart';

import 'package:metal/widgets/text_views.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int tabIndex = 0;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final getThoughtForYouState = ref.watch(getThoughtForYouProvider);
    final getThoughtExploreState = ref.watch(getThoughtExploreProvider);

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(),
            const Gap(20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildFeedTabs(),
                  const Gap(20),
                  tabIndex == 0
                      ? _forYouThoughtTab(getThoughtExploreState)
                      : _forYouThoughtTab(getThoughtForYouState),
                ],
              ),
            ),
          ],
        ),
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
        _buildFeedTabItem("Explore", tabIndex == 0, () => _onTabChange(0)),
        const Gap(20),
        _buildFeedTabItem("For You", tabIndex == 1, () => _onTabChange(1)),
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
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
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
