import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';

import 'package:metal/features/thought/data/domain/entries/thought.model.dart';

import 'package:metal/features/thought/presentation/comment_bottom_sheet.dart';

import 'package:metal/features/thought/provider/get.thought.by.id.dart';
import 'package:metal/features/thought/provider/comment.provider.dart';

import 'package:metal/features/thought/widget/reaction_section.dart';

import 'package:metal/gen/assets.gen.dart';

import 'package:metal/route/routes.dart';
import 'package:metal/widgets/build_user_info.dart';

import 'package:metal/widgets/state.handler/empty.state.dart';
import 'package:metal/widgets/state.handler/error.state.dart';
import 'package:metal/widgets/state.handler/loading.state.dart';

import 'package:metal/widgets/text_views.dart';
import 'package:audioplayers/audioplayers.dart';

class ThoughtDetailsPage extends ConsumerStatefulWidget {
  const ThoughtDetailsPage({super.key});
  static const name = 'thoughtDetails';
  static const route = name;

  @override
  ConsumerState<ThoughtDetailsPage> createState() => _ThoughtDetailsPageState();
}

class _ThoughtDetailsPageState extends ConsumerState<ThoughtDetailsPage> {
  late String thoughtId;
  final AudioPlayer _player = AudioPlayer();

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
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thoughtState = ref.watch(getThoughtByIdProvider);
    final userdata = ref.watch(userStateProvider).data;

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
          final commentsState = ref.watch(commentProvider(thoughtModel.id));
          final commentCount = commentsState.data?.length ?? 0;

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
                      if (thoughtModel.type == 'voice') ...[
                        _buildVoicePlayer(thoughtModel),
                        if (thoughtModel.content.isNotEmpty) ...[
                          const Gap(8),
                          TextView(
                            text: thoughtModel.content,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                      ] else ...[
                        TextView(
                          text: thoughtModel.content,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                          Row(
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
                                    builder: (context) => CommentBottomSheet(
                                        thought: thoughtModel),
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
                            ),
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

  Widget _buildVoicePlayer(ThoughtModel thoughtModel) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          // Play/Pause toggle based on player state
          StreamBuilder<PlayerState>(
            stream: _player.onPlayerStateChanged,
            builder: (context, stateSnap) {
              final isPlaying = stateSnap.data == PlayerState.playing;
              return IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () async {
                  final url = thoughtModel.audioUrl;
                  if (url == null || url.isEmpty) return;
                  if (isPlaying) {
                    await _player.pause();
                  } else {
                    await _player.play(UrlSource(url));
                  }
                },
              );
            },
          ),
          const Gap(8),
          // Current / Total label
          Expanded(
            child: StreamBuilder<Duration>(
              stream: _player.onDurationChanged,
              builder: (context, durSnap) {
                final totalSeconds = durSnap.data?.inSeconds ??
                    (thoughtModel.audioDuration ?? 0);
                return StreamBuilder<Duration>(
                  stream: _player.onPositionChanged,
                  builder: (context, posSnap) {
                    final currentSeconds =
                        (posSnap.data?.inSeconds ?? 0).clamp(0, totalSeconds);
                    return StreamBuilder<PlayerState>(
                      stream: _player.onPlayerStateChanged,
                      builder: (context, stateSnap) {
                        final isPlaying = stateSnap.data == PlayerState.playing;
                        final label = isPlaying
                            ? '${_formatDuration(currentSeconds)} / ${_formatDuration(totalSeconds)}'
                            : _formatDuration(totalSeconds);
                        return TextView(
                          text: 'Preview • $label',
                          fontSize: 12,
                          color: Colors.black54,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString();
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
