import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';

import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/home_page/domain/entries/thought.model.dart'
    hide ReactionModel;

import 'package:metal/features/home_page/presentation/comment_bottom_sheet.dart';

import 'package:metal/features/home_page/provider/get.thought.by.id.dart';

import 'package:metal/features/home_page/widget/reaction_section.dart';

import 'package:metal/gen/assets.gen.dart';

import 'package:metal/route/routes.dart';
import 'package:metal/widgets/build_user_info.dart';

import 'package:metal/widgets/state.handler/empty.state.dart';
import 'package:metal/widgets/state.handler/error.state.dart';
import 'package:metal/widgets/state.handler/loading.state.dart';

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

  @override
  Widget build(BuildContext context) {
    final thoughtState = ref.watch(getThoughtByIdProvider);
    final userdata = ref.watch(authProvider).data;

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
                      BuildUserInfo(
                        userId: thoughtModel.userId,
                        thought: thoughtModel,
                      ),
                      const Gap(20),
                      TextView(
                        text: thoughtModel.content,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      Row(
                        children: [
                          IconButton(
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
                          ReactionSection(
                            thoughtId: thoughtModel.id,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
