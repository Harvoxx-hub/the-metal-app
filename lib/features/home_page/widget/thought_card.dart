import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

import 'package:metal/features/authentication/domain/entries/user.model.dart';

import 'package:metal/features/home_page/domain/entries/thought.model.dart'
    hide ReactionModel;
import 'package:metal/features/home_page/provider/comment.provider.dart';
import 'package:metal/features/home_page/provider/get.user.notifier.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';
import 'package:metal/gen/assets.gen.dart';

import 'package:metal/route/routes.dart';
import 'package:metal/widgets/build_user_info.dart';

import 'package:metal/widgets/text_views.dart';

import 'package:metal/features/home_page/presentation/comment_bottom_sheet.dart';
import 'package:metal/features/home_page/widget/reaction_section.dart';

class ThoughtCard extends ConsumerStatefulWidget {
  final ThoughtModel thoughtModel;

  final GlobalKey? toughtProfileKey;
  final GlobalKey? toughtCommentKey;
  final GlobalKey? reactionKey;

  const ThoughtCard({
    super.key,
    required this.thoughtModel,
    this.toughtProfileKey,
    this.toughtCommentKey,
    this.reactionKey,
  });

  @override
  ConsumerState<ThoughtCard> createState() => _ThoughtCardState();
}

class _ThoughtCardState extends ConsumerState<ThoughtCard> {
  late ThoughtModel thoughtModel;

  @override
  void initState() {
    super.initState();
    thoughtModel = widget.thoughtModel;
  }

  @override
  Widget build(BuildContext context) {
    return thoughtModel.authorMetadata == null
        ? const SizedBox.shrink()
        : _buildThoughtCard(context);
  }

  Widget _buildThoughtCard(BuildContext context) {
    final userdata = ref.watch(userStateProvider).data;
    final commentsState = ref.watch(commentProvider(thoughtModel.id));
    final commentCount = commentsState.data?.length ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BuildUserInfo(
            userId: thoughtModel.userId,
            thought: thoughtModel,
          ),
          const Gap(10),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.thoughtDetails,
                arguments: thoughtModel.id,
              );
            },
            child: TextView(
              text: thoughtModel.content,
              maxLines: 4,
              textOverflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                key: widget.toughtProfileKey,
                onPressed: () {
                  if (thoughtModel.userId != userdata?.id) {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.myMeltedUser,
                      arguments: {"metalId": thoughtModel.userId},
                    );
                  }
                },
                icon: SvgPicture.asset(
                  Assets.icons.thoughtProfile.path,
                  height: 24,
                  width: 24,
                ),
              ),
              Row(
                key: widget.toughtCommentKey,
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      Assets.icons.thoughComment.path,
                      height: 24,
                      width: 24,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                            CommentBottomSheet(thought: thoughtModel),
                      );
                    },
                  ),
                  TextView(
                    text: commentCount.toString(),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
              Expanded(
                child: ReactionSection(
                  thoughtId: thoughtModel.id,
                  reactionKey: widget.reactionKey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
