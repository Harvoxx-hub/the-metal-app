import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/home_page/domain/entries/thought.model.dart';
import 'package:metal/features/home_page/provider/get.thoughts.by.user.dart';
import 'package:metal/features/home_page/widget/thought_card.dart';
import 'package:metal/features/profile/presentation/widget/edit.field.dart';
import 'package:metal/widgets/shimmer/custom_shimmer_loader.dart';
import 'package:metal/widgets/shimmer/feed_shimmer_widget.dart';
import 'package:metal/widgets/text_views.dart';

class MyThoughtTab extends ConsumerStatefulWidget {
  const MyThoughtTab({super.key, this.id});
  final String? id;

  @override
  ConsumerState<MyThoughtTab> createState() => _MyThoughtTabState();
}

class _MyThoughtTabState extends ConsumerState<MyThoughtTab> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
  
        ref.read(getThoughtByUserProvider.notifier).getThought( id: widget.id);
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final myThoughtState = ref.watch(getThoughtByUserProvider);

    return getThoughtStategetThoughtState(myThoughtState);
  }

  Widget getThoughtStategetThoughtState(
      BaseState<List<ThoughtModel>> getThoughtState) {
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
          return ListView.builder(
            itemCount: getThoughtState.data!.length,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              return ThoughtCard(thoughtModel: getThoughtState.data![index], );
            },
          );
        }
      case Status.error:
        return Center(
          child: TextView(
            text: getThoughtState.errorMessage ?? "Error loading thoughts",
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        );
      default:
        return SizedBox.shrink();
    }
  }
}
