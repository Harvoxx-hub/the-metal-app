import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/home_page/domain/entries/thought.model.dart';
import 'package:metal/features/home_page/provider/get.all.users.notifier.dart';
import 'package:metal/features/home_page/provider/get.thoughts.explore.dart';
import 'package:metal/features/home_page/provider/get.thoughts.for.you.dart';
import 'package:metal/features/home_page/provider/send.thoughts.dart';
import 'package:metal/features/home_page/widget/thought_card.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/plain.button.dart';
import 'package:metal/widgets/shimmer/custom_shimmer_loader.dart';
import 'package:metal/widgets/shimmer/feed_shimmer_widget.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
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
    final sendThoughtState = ref.watch(sendThoughtProvider);
    final getThoughtForYouState = ref.watch(getThoughtForYouProvider);
    final getThoughtExploreState = ref.watch(getThoughtExploreProvider);

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.metalPinkColour,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: TextView(
                  text: "Share Your Thought Anonymously",
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Gap(20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const TextView(
                        text: "Feeds",
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      const Spacer(),
                      FeedTabItem(
                        selected: tabIndex == 0,
                        onPress: () {
                          setState(() {
                            tabIndex = 0;
                          });
                        },
                        title: "Explore",
                      ),
                      const Gap(20),
                      FeedTabItem(
                        selected: tabIndex == 1,
                        onPress: () {
                          setState(() {
                            tabIndex = 1;
                          });
                        },
                        title: "For You",
                      ),
                    ],
                  ),
                  EditFormField(
                    floatingLabel: '',
                    label: "Write your thoughts",
                    controller: _controller,
                    keyboardType: TextInputType.text,
                    suffixWidget: PlainButton(
                      loading: sendThoughtState.isLoading,
                      width: 70,
                      buttonText: "Post",
                      onPressed: sendMessage,
                    ),
                  ),
                  const Gap(20),
                  tabIndex == 0
                      ? buildExploreTab(getThoughtExploreState)
                      : buildForYouTab(getThoughtForYouState),
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

  void sendMessage() {
    ref.read(sendThoughtProvider.notifier).sendThought(_controller.text);
    _controller.text = "";
  }

  Widget buildExploreTab(BaseState<List<ThoughtModel>> getThoughtExploreState) {
    switch (getThoughtExploreState.status) {
      case Status.loading:
        return CustomShimmerLoader(
          itemType: ShimmerItemType.list,
          loaderWidget: PostCardShimmer(),
        );
      case Status.success:
        if (getThoughtExploreState.data!.isEmpty) {
          return const Center(
            child: TextView(
              text: "No Thoughts In Your Explore Feed",
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          );
        } else {
          return ListView.builder(
            itemCount: getThoughtExploreState.data!.length,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              return ThoughtCard(
                thoughtModel: getThoughtExploreState.data![index],
                melted: false,
              );
            },
          );
        }
      case Status.error:
        return Center(
          child: Column(
            children: [
              TextView(
                text: "Error loading thoughts",
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              const Gap(10),
              PlainButton(
                buttonText: "Retry",
                onPressed: _refreshData,
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget buildForYouTab(BaseState<List<ThoughtModel>> getThoughtForYouState) {
    switch (getThoughtForYouState.status) {
      case Status.loading:
        return CustomShimmerLoader(
          itemType: ShimmerItemType.list,
          loaderWidget: PostCardShimmer(),
        );
      case Status.success:
        if (getThoughtForYouState.data!.isEmpty) {
          return const Center(
            child: TextView(
              text: "No thoughts in your For-You feed, Connect with Other metal to get thoughts",
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          );
        } else {
          return ListView.builder(
            itemCount: getThoughtForYouState.data!.length,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              return ThoughtCard(
                thoughtModel: getThoughtForYouState.data![index],
                melted: true,
              );
            },
          );
        }
      case Status.error:
        return Center(
          child: Column(
            children: [
              TextView(
                text:  "Error loading thoughts",
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              const Gap(10),
              PlainButton(
                buttonText: "Retry",
                onPressed: _refreshData,
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class FeedTabItem extends StatelessWidget {
  const FeedTabItem({
    super.key,
    required this.selected,
    required this.title,
    required this.onPress,
  });

  final bool selected;
  final String title;
  final Function() onPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? AppColors.metalPinkColour40 : null,
          border: selected ? null : Border.all(color: AppColors.metalBlack, width: 1.0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextView(
          text: title,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
