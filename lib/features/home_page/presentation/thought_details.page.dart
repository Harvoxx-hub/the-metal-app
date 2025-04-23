import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/utils/date.formart.dart';

import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/home_page/domain/entries/thought.model.dart';
import 'package:metal/features/home_page/provider/delete.thoughts.dart';
import 'package:metal/features/home_page/provider/get.thought.by.id.dart';
import 'package:metal/features/home_page/provider/get.user.notifier.dart';
import 'package:metal/features/home_page/provider/react.thoughts.notifier.dart';
import 'package:metal/features/home_page/widget/reaction.listtile.dart';
import 'package:metal/features/settings/provider/block.user.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/res.dart';
import 'package:metal/route/routes.dart';

import 'package:metal/widgets/dialog/enhanced.dialog.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/state.handler/empty.state.dart';
import 'package:metal/widgets/state.handler/error.state.dart';
import 'package:metal/widgets/state.handler/loading.state.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

class ThoughtDetailsPage extends ConsumerStatefulWidget {
  const ThoughtDetailsPage({super.key});
  static const name = 'thoughtDetails';
  static const route = name;

  @override
  ConsumerState<ThoughtDetailsPage> createState() => _ThoughtDetailsPageState();
}

class _ThoughtDetailsPageState extends ConsumerState<ThoughtDetailsPage> {
  bool _showReactions = false;
  late String thoughtId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Extract the thought ID from the route arguments
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is String) {
      // If args is a direct string, use it as the ID
      thoughtId = args;
    } else if (args is Map<String, dynamic>) {
      // If args is a map, extract the thoughtId key
      thoughtId = args['thoughtId'] as String;
    } else if (args is ThoughtModel) {
      // For backward compatibility, if a ThoughtModel is passed directly
      thoughtId = args.id;
    } else {
      // Handle the error case
      throw ArgumentError('ThoughtDetailsPage requires a valid thoughtId');
    }

    // Fetch the thought data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(getThoughtByIdProvider.notifier).getThought(thoughtId);
    });
  }

  void _toggleReactions() {
    setState(() {
      _showReactions = !_showReactions;
    });
  }

  @override
  Widget build(BuildContext context) {
    final thoughtState = ref.watch(getThoughtByIdProvider);

    return BaseScreen(
      bgImage: Assets.images.bg2.path,
      appBarEnabled: true,
      Header: "Thought Details",
      authFlow: false,
      body: Builder(
        builder: (context) {
          if (thoughtState.isLoading) {
            return const LoadingState();
          } else if (thoughtState.isError) {
            return ErrorState(
              retry: () {
                ref.read(getThoughtByIdProvider.notifier).getThought(thoughtId);
              },
              text:
                  thoughtState.errorMessage ?? "Failed to load thought details",
            );
          } else if (thoughtState.data == null) {
            return const EmptyState(text: "Thought not found");
          }

          // We have the thought data, display it
          final thoughtModel = thoughtState.data!;

          return Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserInfo(context, ref, thoughtModel),
                      const Gap(20),
                      TextView(
                        text: thoughtModel.content,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      const Gap(20),
                      _buildReactionsSection(thoughtModel),
                    ],
                  ),
                ),
              ),
              if (_showReactions) _buildReactionsSelector(thoughtModel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReactionsSection(ThoughtModel thoughtModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReactionsRow(thoughtModel),
        IconButton(
          onPressed: _toggleReactions,
          icon: const Icon(Icons.favorite_border),
        ),
      ],
    );
  }

  Widget _buildUserInfo(
      BuildContext context, WidgetRef ref, ThoughtModel thoughtModel) {
    final creatorUserState = ref.watch(getUserProvider(thoughtModel.userId));

    if (creatorUserState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (creatorUserState.isError || creatorUserState.data == null) {
      return const SizedBox();
    }

    final creatorUserdata = creatorUserState.data!;
    final userdata = ref.watch(authProvider).data;

    return GestureDetector(
      onTap: () {
        if (thoughtModel.userId != userdata?.id) {
          Navigator.pushNamed(
            context,
            AppRoutes.myMeltedUser,
            arguments: {"metalId": thoughtModel.userId},
          );
        }
      },
      child: Row(
        children: [
          ProfilePhoto(
            verfly: false,
            size: 40,
            meltId: creatorUserdata.metal ?? "",
          ),
          const Gap(10),
          _buildUserDetails(creatorUserdata, thoughtModel),
          const Spacer(),
          _buildOptionsButton(context, thoughtModel, ref),
        ],
      ),
    );
  }

  Column _buildUserDetails(UserModel user, ThoughtModel thoughtModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TextView(fontSize: 13.5, text: "${user.username}"),
            const Gap(5),
            if (user.isVerified ?? false)
              Assets.icons.checkVerified.svg(height: 16),
          ],
        ),
        TextView(
          text: formatTime(isoDateString: thoughtModel.createdAt),
          color: Colors.grey,
        ),
      ],
    );
  }

  Widget _buildOptionsButton(
      BuildContext context, ThoughtModel thoughtModel, WidgetRef ref) {
    return IconButton(
      onPressed: () {
        showModalBottomSheet(
          backgroundColor: Colors.white,
          context: context,
          builder: (BuildContext context) =>
              _buildOptionsBottomSheet(context, thoughtModel, ref),
        );
      },
      icon: const Icon(Icons.more_vert),
    );
  }

  Widget _buildOptionsBottomSheet(
      BuildContext context, ThoughtModel thoughtModel, WidgetRef ref) {
    return SafeArea(
      child: Wrap(
        children: <Widget>[
          if (thoughtModel.userId == ref.watch(authProvider).data!.id)
            ListTile(
              title: const TextView(text: 'Edit Thoughts'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  AppRoutes.postThought,
                  arguments: thoughtModel,
                );
              },
            ),
          if (thoughtModel.userId == ref.watch(authProvider).data!.id)
            ListTile(
              title: const TextView(text: 'Delete Thoughts'),
              onTap: () {
                ref
                    .read(deleteThoughtProvider.notifier)
                    .deleteThought(thoughtModel.id);
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          if (thoughtModel.userId != ref.watch(authProvider).data!.id)
            ListTile(
              title: const TextView(text: 'Block Metal'),
              onTap: () {
                Navigator.pop(context);
                _showDialog(
                  context,
                  _blockDialog(context, thoughtModel, ref),
                );
              },
            ),
          if (thoughtModel.userId != ref.watch(authProvider).data!.id)
            ListTile(
              title: const TextView(text: 'Block and Report'),
              onTap: () {
                Navigator.pop(context);
                _showDialog(
                  context,
                  _blockAndReportDialog(context, thoughtModel, ref),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _reactionList(BuildContext context, ThoughtModel thoughtModel) {
    return SafeArea(
      child: Wrap(
        children: <Widget>[
          for (var element in thoughtModel.reactions)
            ReactionListTile(
              reactionModel: element,
            )
        ],
      ),
    );
  }

  Widget _buildReactionsRow(ThoughtModel thoughtModel) {
    final userdata = ref.watch(authProvider).data;
    String userid = userdata!.id!;

    // Check if the thought has any reactions
    if (thoughtModel.reactions.isEmpty) {
      return Container(); // or any other fallback widget when there are no reactions
    }

    // Initialize variables to track reactions
    int totalReactions = thoughtModel.reactions.length;

    // Check if the user has reacted
    bool userHasReacted =
        thoughtModel.reactions.any((reaction) => reaction.userId == userid);

    // Build the display text based on the user's reaction status
    String reactionText;
    if (userHasReacted) {
      if (totalReactions > 1) {
        reactionText = 'You and ${totalReactions - 1} others reacted';
      } else {
        reactionText = 'You reacted';
      }
    } else {
      reactionText = '$totalReactions reacted';
    }

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          backgroundColor: Colors.white,
          context: context,
          builder: (BuildContext context) =>
              _reactionList(context, thoughtModel),
        );
      },
      child: Row(
        children: [
          for (var reaction in thoughtModel.reactions)
            TextView(
              text: reaction.emoji,
            ),
          TextView(text: reactionText),
        ],
      ),
    );
  }

  Widget _buildReactionsSelector(ThoughtModel thoughtModel) {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.metalTabBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _buildReactionIcons(thoughtModel),
        ),
      ),
    );
  }

  List<Widget> _buildReactionIcons(ThoughtModel thoughtModel) {
    final reactions = ["😍", "👍", "😂", "😢", "😡"];
    return reactions.map((emoji) {
      return GestureDetector(
        onTap: () {
          final userdata = ref.watch(authProvider).data;
          String userid = userdata!.id!;

          ref.read(reactThoughtProvider.notifier).reactThought(
                thoughtModel.id,
                emoji,
              );

          setState(() {
            _showReactions = false;
          });
        },
        child: TextView(
          text: emoji,
          fontSize: 24,
        ),
      );
    }).toList();
  }

  void _showDialog(BuildContext context, Widget dialog) {
    showDialog(
      context: context,
      builder: (BuildContext context) => dialog,
    );
  }

  Widget _blockDialog(
      BuildContext context, ThoughtModel thoughtModel, WidgetRef ref) {
    final userdata = ref.watch(authProvider).data;

    return EnhancedDialog(
      title: "Block Metal",
      content: const TextView(
        text:
            "Are you sure you want to block this Metal? You will no longer see their thoughts and other activity.",
      ),
      primaryButtonText: "Block",
      onPrimaryButtonPressed: () {
        ref.read(blockUserProvider.notifier).blockUser(
              "User", // We don't have username here, so use a placeholder
              thoughtModel.userId,
            );
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
      secondaryButtonText: "Cancel",
      onSecondaryButtonPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  Widget _blockAndReportDialog(
      BuildContext context, ThoughtModel thoughtModel, WidgetRef ref) {
    final TextEditingController reportReasonController =
        TextEditingController();
    final formKey = GlobalKey<FormState>();
    final userdata = ref.watch(authProvider).data;

    return EnhancedDialog(
      title: "Block and Report",
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextView(
              text: "Please provide a reason for reporting this Metal:",
              fontSize: 16,
            ),
            const Gap(10),
            EditFormField(
              controller: reportReasonController,
              label: "Reason",
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty || value.trim().isEmpty) {
                  return "Reason is required";
                }
                return null;
              },
            ),
          ],
        ),
      ),
      primaryButtonText: "Submit",
      onPrimaryButtonPressed: () {
        if (formKey.currentState!.validate()) {
          // First block the user
          ref.read(blockUserProvider.notifier).blockUser(
                "User", // We don't have username here, so use a placeholder
                thoughtModel.userId,
              );

          // Then report them with the reason
          // TODO: Implement report functionality

          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      },
      secondaryButtonText: "Cancel",
      onSecondaryButtonPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
}
