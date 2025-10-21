import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:metal/features/thought/data/domain/entries/thought.model.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/features/thought/provider/comment.provider.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';
import 'package:metal/gen/assets.gen.dart';

import 'package:metal/route/routes.dart';
import 'package:metal/widgets/build_user_info.dart';

import 'package:metal/widgets/text_views.dart';

import 'package:metal/features/thought/presentation/comment_bottom_sheet.dart';
import 'package:metal/features/thought/widget/reaction_section.dart';
import 'package:metal/features/thought/provider/get.thought.by.id.dart';
import 'package:metal/features/thought/provider/send.thoughts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:metal/core/services/deep_link_service.dart';

class ThoughtCard extends ConsumerStatefulWidget {
  final ThoughtModel thoughtModel;

  const ThoughtCard({
    super.key,
    required this.thoughtModel,
  });

  @override
  ConsumerState<ThoughtCard> createState() => _ThoughtCardState();
}

class _ThoughtCardState extends ConsumerState<ThoughtCard> {
  late ThoughtModel thoughtModel;
  ThoughtModel? originalThought;
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    thoughtModel = widget.thoughtModel;
    if (thoughtModel.type == "repost") {
      loadRepost(thoughtModel.originalThoughtId!);
    }
  }

  loadRepost(String originalId) async {
    originalThought = await ref
        .read(getThoughtByIdProvider.notifier)
        .getThoughtById(originalId);
    setState(() {});
    print(originalThought!.content);
  }

  @override
  Widget build(BuildContext context) {
    return thoughtModel.authorMetadata == null
        ? const SizedBox.shrink()
        : _buildThoughtCard(context, thoughtModel.id);
  }

  Widget _buildThoughtCard(BuildContext context, String thoughtId) {
    final userdata = ref.watch(userStateProvider).data;
    final commentsState = ref.watch(commentProvider(thoughtId));
    final commentCount = commentsState.data?.length ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (thoughtModel.type == 'repost') ...[
          TextView(
            text:
                'Reposted by ${thoughtModel.authorMetadata?.authorName ?? ''}',
            fontSize: 12,
            color: Colors.grey[700],
          ),
          _buildRepostCard(context),
          const Gap(10),
        ] else ...[
          BuildUserInfo(
            userId: thoughtModel.userId,
            thought: thoughtModel,
          ),
          const Gap(10),
          // Community tag if this is a community post
          if (thoughtModel.communityMetadata != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.metalPinkColour.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.metalPinkColour.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.group,
                    size: 14,
                    color: AppColors.metalPinkColour,
                  ),
                  const Gap(4),
                  TextView(
                    text:
                        'Posted in: ${thoughtModel.communityMetadata!.communityName}',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.metalPinkColour,
                  ),
                ],
              ),
            ),
            const Gap(8),
          ],
          if (thoughtModel.type == 'voice') ...[
            _buildVoicePlayer(context, thoughtModel),
            if (thoughtModel.content.isNotEmpty) ...[
              const Gap(6),
              TextView(text: thoughtModel.content),
            ],
            const Gap(4),
          ] else ...[
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
          ],
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
            IconButton(
              tooltip: 'Share',
              onPressed: () {
                _showShareOptions(context);
              },
              icon: const Icon(Icons.ios_share),
            ),
            Expanded(
              child: ReactionSection(
                thoughtId: thoughtModel.id,
              ),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _buildRepostCard(BuildContext context) {
    final original = originalThought;
    if (original == null) {
      return const TextView(text: 'This thought is no longer available.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BuildUserInfo(
          userId: original.userId ?? '',
          thought: original,
        ),
        const Gap(10),
        // Community tag if this is a community post
        if (original.communityMetadata != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.metalPinkColour.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.metalPinkColour.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.group,
                  size: 14,
                  color: AppColors.metalPinkColour,
                ),
                const Gap(4),
                TextView(
                  text:
                      'Posted in: ${original.communityMetadata!.communityName}',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.metalPinkColour,
                ),
              ],
            ),
          ),
          const Gap(8),
        ],
        if (original.type == 'voice') ...[
          _buildVoicePlayer(context, original),
          if (original.content.isNotEmpty) ...[
            const Gap(6),
            TextView(text: original.content),
          ],
          const Gap(4),
        ] else ...[
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.thoughtDetails,
                arguments: original.id,
              );
            },
            child: TextView(
              text: original.content,
              maxLines: 4,
              textOverflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.repeat),
                title: const Text('Repost'),
                onTap: () async {
                  Navigator.pop(context);
                  final notifier = ref.read(sendThoughtProvider.notifier);
                  await notifier.repostThought(
                      originalThoughtId: thoughtModel.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.ios_share),
                title: const Text('Share externally'),
                onTap: () async {
                  Navigator.pop(context);
                  await _shareExternally();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _shareExternally() async {
    try {
      // Generate deep link URL
      final shareUrl = DeepLinkService.generateThoughtUrl(thoughtModel.id);

      // Build share text depending on type
      final author = thoughtModel.authorMetadata?.authorName ?? '';
      final baseText = author.isNotEmpty
          ? '${thoughtModel.content}\n— ${author}'
          : thoughtModel.content;

      String shareText = '';

      if (thoughtModel.type == 'voice') {
        // For voice thoughts, share the caption if available, otherwise generic message
        shareText = baseText.isNotEmpty
            ? '$baseText\n\nListen to this voice thought on Metal: $shareUrl'
            : 'Check out this voice thought on Metal: $shareUrl';
      } else if (thoughtModel.type == 'repost') {
        // For reposts, share the original content with attribution
        shareText = baseText.isNotEmpty
            ? '$baseText\n\nShared on Metal: $shareUrl'
            : 'Check out this reposted thought on Metal: $shareUrl';
      } else {
        // For regular text thoughts
        shareText = baseText.isNotEmpty
            ? '$baseText\n\nShared on Metal: $shareUrl'
            : 'Check out this thought on Metal: $shareUrl';
      }

      // Add community context if applicable
      if (thoughtModel.communityMetadata != null) {
        shareText +=
            '\n\nPosted in: ${thoughtModel.communityMetadata!.communityName}';
      }

      // Share with the generated text and URL
      await Share.share(shareText);
    } catch (e) {
      print('Error sharing thought: $e');
      // Fallback to simple share without deep link
      await Share.share(thoughtModel.content.isNotEmpty
          ? thoughtModel.content
          : 'Check out this thought on Metal app');
    }
  }

  Widget _buildVoicePlayer(BuildContext context, ThoughtModel original) {
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
                  final url = original.audioUrl;
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
                final totalSeconds =
                    durSnap.data?.inSeconds ?? (original.audioDuration ?? 0);
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
