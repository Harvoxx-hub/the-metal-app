import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
 
import 'package:metal/core/state/base.state.dart';
 
import 'package:metal/features/home_page/domain/entries/thought.model.dart';
import 'package:metal/features/home_page/provider/get.thoughts.by.user.dart';
import 'package:metal/features/home_page/widget/thought_card.dart';
 
import 'package:metal/widgets/shimmer/custom_shimmer_loader.dart';
import 'package:metal/widgets/shimmer/feed_shimmer_widget.dart';
import 'package:metal/widgets/text_views.dart';

class MyThoughtTab extends ConsumerStatefulWidget {
  const MyThoughtTab({super.key, this.id, this.toughtID});
  final String? id;
  final String? toughtID;

  @override
  ConsumerState<MyThoughtTab> createState() => _MyThoughtTabState();
}

class _MyThoughtTabState extends ConsumerState<MyThoughtTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch thoughts when the widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(getThoughtByUserProvider.notifier).getThought(id: widget.id);
    });
  }

  @override
  void dispose() {
    // Dispose the ScrollController to avoid memory leaks
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myThoughtState = ref.watch(getThoughtByUserProvider);

    return getThoughtStateWidget(myThoughtState);
  }

  Widget getThoughtStateWidget(BaseState<List<ThoughtModel>> getThoughtState) {
    switch (getThoughtState.status) {
      case Status.loading:
        return CustomShimmerLoader(
          itemType: ShimmerItemType.list,
          loaderWidget: PostCardShimmer(),
        );

      case Status.success:
        if (getThoughtState.data!.isEmpty) {
          return Center(
            child: TextView(
              text: "No Thoughts Available",
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          );
        } else {
          // Find the index of the thought with the specified thoughtID
          int targetIndex = getThoughtState.data!
              .indexWhere((thought) => thought.id == widget.toughtID);

          // Scroll to the item with the matching thoughtID, if it exists
          if (targetIndex != -1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollController.animateTo(
                targetIndex * 100.0, // Adjust item height if different
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOut,
              );
            });
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: getThoughtState.data!.length,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              return ThoughtCard(
                thoughtModel: getThoughtState.data![index],
              );
            },
          );
        }

      case Status.error:
        return Center(
          child: TextView(
            text: "Error loading thoughts",
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        );

      default:
        return SizedBox.shrink();
    }
  }
}
