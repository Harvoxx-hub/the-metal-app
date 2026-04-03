import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'dart:async';

import 'package:metal/domain/entities/thought_dto.dart';
import 'package:metal/widgets/audio_player.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/presentation/viewmodels/thought/comment_viewmodel.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/gen/assets.gen.dart';

import 'package:metal/route/routes.dart';
import 'package:metal/widgets/build_user_info.dart';

import 'package:metal/widgets/text_views.dart';
import 'package:metal/widgets/read_more_text.dart';

import 'package:metal/presentation/views/thought/widgets/comment_bottom_sheet.dart';
import 'package:metal/presentation/views/thought/widgets/reaction_section.dart';
import 'package:metal/presentation/viewmodels/thought/thought_providers.dart';
import 'package:metal/presentation/viewmodels/thought/reaction_viewmodel.dart';
import 'package:metal/data/datasources/remote/remote_data_source_providers.dart';
import 'package:metal/domain/entities/report_dto.dart';
import 'package:metal/domain/entities/reaction_dto.dart';
import 'package:metal/res/res.dart';

import 'package:share_plus/share_plus.dart';
import 'package:metal/core/services/deep_link_service.dart';
import 'package:metal/presentation/viewmodels/community/community_detail_viewmodel_providers.dart';

class ThoughtCard extends ConsumerStatefulWidget {
  final ThoughtDto thoughtModel;

  /// When set, delete will update this community's local state first (optimistic delete).
  final String? communityId;

  const ThoughtCard({
    super.key,
    required this.thoughtModel,
    this.communityId,
  });

  @override
  ConsumerState<ThoughtCard> createState() => _ThoughtCardState();
}

class _ThoughtCardState extends ConsumerState<ThoughtCard> {
  late ThoughtDto thoughtModel;
  ThoughtDto? originalThought;
  bool isLoadingRepost = false;
  bool _showReactions = false;

  @override
  void initState() {
    super.initState();
    thoughtModel = widget.thoughtModel;
    if (thoughtModel.type == "repost") {
      loadRepost(thoughtModel.originalThoughtId!);
    }
  }

  @override
  void didUpdateWidget(ThoughtCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(widget.thoughtModel, thoughtModel)) return;
    thoughtModel = widget.thoughtModel;
    if (thoughtModel.type == 'repost' &&
        thoughtModel.originalThoughtId != null) {
      final oldOid = oldWidget.thoughtModel.originalThoughtId;
      final newOid = thoughtModel.originalThoughtId;
      if (oldOid != newOid) {
        loadRepost(newOid!);
      }
    }
  }

  loadRepost(String originalId) async {
    setState(() {
      isLoadingRepost = true;
    });

    try {
      final repository = ref.read(thoughtRepositoryProvider);
      final result = await repository.getThoughtById(originalId);

      if (result.isSuccess && result.data != null) {
        originalThought = result.data;
        print('Repost loaded successfully: ${originalThought!.content}');
      } else {
        print('Original thought not found or deleted: $originalId');
        originalThought = null;
      }
    } catch (e) {
      print('Error loading repost: $e');
      originalThought = null;
    } finally {
      if (!mounted) return;
      if (mounted) {
        setState(() {
          isLoadingRepost = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hide deleted thoughts by default (unless it's a repost or in thought details)
    if (thoughtModel.authorMetadata == null) {
      return const SizedBox.shrink();
    }

    // For reposts, show the card even if original is deleted (we'll handle that in _buildRepostCard)
    if (thoughtModel.type == "repost") {
      return _buildThoughtCard(context, thoughtModel.id);
    }

    // For regular thoughts, check if they're deleted
    if (_isThoughtDeleted(thoughtModel)) {
      return const SizedBox.shrink();
    }

    return _buildThoughtCard(context, thoughtModel.id);
  }

  /// Check if a thought is deleted
  bool _isThoughtDeleted(ThoughtDto thought) {
    // A thought is considered deleted if:
    // 1. It has no content and no audio file
    // 2. It has empty or null content
    // 3. It's missing essential fields
    return (thought.content.isEmpty || thought.content.trim().isEmpty) &&
        (thought.audioUrl == null || thought.audioUrl!.isEmpty) &&
        thought.type != "voice";
  }

  Widget _buildThoughtCard(BuildContext context, String thoughtId) {
    final commentsState = ref.watch(commentViewModelProvider(thoughtId));
    final commentCount = commentsState.comments.length;
    final reactionState = ref.watch(reactionViewModelProvider(thoughtId));
    final reactions = reactionState.reactions;

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade100.withOpacity(0.7),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                showThoughtMenu: true,
                onDeleteThought: () => _handleDeleteThought(context),
                onEditThought: thoughtModel.type == 'text'
                    ? () => _handleEditThought(context)
                    : null,
                onReportThought: () => _handleReportThought(context),
                onBlockUser: () => _handleBlockUser(context),
              ),
              const Gap(10),
              // Community tag if this is a community post
              if (thoughtModel.communityMetadata != null) ...[
                /// get community from id from community provider

                GestureDetector(
                  // onTap: () {
                  //   Navigator.pushNamed(
                  //     context,
                  //     Communi.communityDetails,
                  //     arguments: thoughtModel.communityMetadata!.communityId,
                  //   );
                  // },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        Expanded(
                          child: TextView(
                            text:
                                'Posted in: ${thoughtModel.communityMetadata!.communityName}',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.metalPinkColour,
                            maxLines: 1,
                            textOverflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(8),
              ],
              // Show audio player when thought has audio (voice-only or text+audio)
              if (thoughtModel.audioUrl != null &&
                  thoughtModel.audioUrl!.isNotEmpty) ...[
                AudioPlayer(
                  audioUrl: thoughtModel.audioUrl!,
                  theme: AudioPlayerTheme.thought,
                ),
                const Gap(6),
              ],
              // Show text when thought has content
              if (thoughtModel.content.isNotEmpty) ...[
                ReadMoreText(
                  text: thoughtModel.content,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.thoughtDetails,
                      arguments: thoughtModel.id,
                    );
                  },
                ),
              ],
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.userProfile,
                      arguments: thoughtModel.userId,
                    );
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
                    onToggleReactions: () {
                      setState(() {
                        _showReactions = !_showReactions;
                      });
                    },
                  ),
                ),
              ],
            ),
          ]),
        ),
        if (_showReactions) _buildReactionsSelector(reactions, thoughtId),
      ],
    );
  }

  Widget _buildReactionsSelector(
      List<ReactionDto> reactions, String thoughtId) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.metalTabBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _buildReactionIcons(reactions, thoughtId),
        ),
      ),
    );
  }

  List<Widget> _buildReactionIcons(
      List<ReactionDto> reactions, String thoughtId) {
    final userdata = ref.watch(userStateProvider).user;
    final userReaction = userdata?.id != null
        ? reactions
            .where((reaction) => reaction.userId == userdata!.id)
            .firstOrNull
        : null;

    final emojis = ["😍", "👍", "😂", "😢", "😡"];
    return emojis.map((emoji) {
      final isCurrentReaction = userReaction?.emoji == emoji;
      return GestureDetector(
        onTap: () async {
          final currentUserId = ref.read(userStateProvider).user?.id;
          final viewModel =
              ref.read(reactionViewModelProvider(thoughtId).notifier);
          await viewModel.addReaction(emoji, currentUserId: currentUserId);

          if (mounted) {
            setState(() {
              _showReactions = false;
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: isCurrentReaction
              ? BoxDecoration(
                  color: AppColors.metalPinkColour.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          child: TextView(
            text: emoji,
            fontSize: 24,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildRepostCard(BuildContext context) {
    if (isLoadingRepost) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final original = originalThought;
    if (original == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextView(
              text: 'This thought has been deleted',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            TextView(
              text: 'The original author removed this content',
              fontSize: 12,
              color: Colors.grey.shade500,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BuildUserInfo(
          userId: original.userId,
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
                Expanded(
                  child: TextView(
                    text:
                        'Posted in: ${original.communityMetadata!.communityName}',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.metalPinkColour,
                    maxLines: 1,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Gap(8),
        ],
        // Show audio when reposted thought has audio
        if (original.audioUrl != null && original.audioUrl!.isNotEmpty) ...[
          AudioPlayer(
            audioUrl: original.audioUrl!,
            theme: AudioPlayerTheme.thought,
          ),
          const Gap(6),
        ],
        // Show text when reposted thought has content
        if (original.content.isNotEmpty) ...[
          ReadMoreText(
            text: original.content,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.thoughtDetails,
                arguments: original.id,
              );
            },
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
                  // Create repost via API
                  final repository = ref.read(thoughtRepositoryProvider);
                  await repository.createThought(
                    content: '',
                    type: 'repost',
                    originalThoughtId: thoughtModel.id,
                  );
                  // Refresh the feed
                  ref.read(thoughtFeedViewModelProvider.notifier).refresh();
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

  Future<void> _handleDeleteThought(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const TextView(
          text: 'Delete Thought',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        content: const TextView(
          text:
              'Are you sure you want to delete this thought? This action cannot be undone.',
          fontSize: 14,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const TextView(
              text: 'Cancel',
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const TextView(
              text: 'Delete',
              fontSize: 14,
              color: AppColors.metalWhite,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final feedViewModel = ref.read(thoughtFeedViewModelProvider.notifier);
      ThoughtDto? removedForRollback;
      if (widget.communityId != null) {
        final communityVm = ref.read(
          communityDetailViewModelProvider(widget.communityId!).notifier,
        );
        removedForRollback = communityVm.removePost(thoughtModel.id);
      }
      final success = await feedViewModel.deleteThought(thoughtModel.id);

      if (mounted) {
        if (success) {
          Fluttertoast.showToast(msg: 'Thought deleted successfully');
        } else {
          if (widget.communityId != null && removedForRollback != null) {
            ref
                .read(communityDetailViewModelProvider(widget.communityId!)
                    .notifier)
                .addPost(removedForRollback);
          }
          Fluttertoast.showToast(msg: 'Failed to delete thought');
        }
      }
    }
  }

  Future<void> _handleEditThought(BuildContext context) async {
    // Backend update endpoint currently supports content updates.
    // To keep UX consistent and avoid failed updates, only allow editing text thoughts for now.
    if (thoughtModel.type != 'text') return;

    final communityMeta = thoughtModel.communityMetadata;
    final communityMetadataMap = communityMeta == null
        ? null
        : {
            'communityId': communityMeta.communityId,
            'communityName': communityMeta.communityName,
            'communityImage': communityMeta.communityImage,
            'isPublic': communityMeta.isPublic,
            'categories': communityMeta.categories,
          };

    final editArgs = {
      'communityMetadata': communityMetadataMap,
      'editThoughtId': thoughtModel.id,
      'editText': thoughtModel.content,
      'editConnectionOnly': thoughtModel.connectionOnly,
    };

    final result = await Navigator.pushNamed(
      context,
      AppRoutes.postThought,
      arguments: editArgs,
    );

    if (!mounted) return;
    if (result is! ThoughtDto) return;

    // Update local timeline state immediately (no full refresh).
    if (widget.communityId != null) {
      ref
          .read(
            communityDetailViewModelProvider(widget.communityId!).notifier,
          )
          .updatePost(result);
    } else {
      ref.read(thoughtFeedViewModelProvider.notifier).updateThought(result);
    }
  }

  Future<void> _handleReportThought(BuildContext context) async {
    // Show report dialog
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _ReportThoughtDialog(thoughtId: thoughtModel.id),
    );

    if (result != null && mounted) {
      // Report submitted
      Fluttertoast.showToast(
          msg: 'Thank you for reporting. We will review this thought.');
    }
  }

  Future<void> _handleBlockUser(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const TextView(
          text: 'Block User',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        content: TextView(
          text:
              'Are you sure you want to block ${thoughtModel.authorMetadata?.authorName ?? "this user"}? You will no longer see their thoughts or be able to interact with them.',
          fontSize: 14,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const TextView(
              text: 'Cancel',
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const TextView(
              text: 'Block',
              fontSize: 14,
              color: AppColors.metalWhite,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final profileDataSource = ref.read(profileRemoteDataSourceProvider);
        await profileDataSource.blockUser(userId: thoughtModel.userId);

        if (mounted) {
          Fluttertoast.showToast(msg: 'User blocked successfully');
          // Remove all thoughts from this user from the feed
          ref
              .read(thoughtFeedViewModelProvider.notifier)
              .removeThoughtsByUserId(thoughtModel.userId);
        }
      } catch (e) {
        if (mounted) {
          Fluttertoast.showToast(msg: 'Failed to block user: ${e.toString()}');
        }
      }
    }
  }
}

/// Report Thought Dialog
class _ReportThoughtDialog extends ConsumerStatefulWidget {
  final String thoughtId;

  const _ReportThoughtDialog({required this.thoughtId});

  @override
  ConsumerState<_ReportThoughtDialog> createState() =>
      _ReportThoughtDialogState();
}

class _ReportThoughtDialogState extends ConsumerState<_ReportThoughtDialog> {
  String? selectedReason;
  final TextEditingController _detailsController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _reportReasons = [
    'Spam',
    'Harassment',
    'Hate speech',
    'Inappropriate content',
    'False information',
    'Other',
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const TextView(
        text: 'Report Thought',
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextView(
              text: 'Why are you reporting this thought?',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            const Gap(12),
            ..._reportReasons.map((reason) => RadioListTile<String>(
                  title: TextView(text: reason, fontSize: 14),
                  value: reason,
                  groupValue: selectedReason,
                  onChanged: (value) {
                    setState(() {
                      selectedReason = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                )),
            if (selectedReason == 'Other') ...[
              const Gap(12),
              TextField(
                controller: _detailsController,
                decoration: const InputDecoration(
                  hintText: 'Please provide details...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const TextView(
            text: 'Cancel',
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        ElevatedButton(
          onPressed: _isSubmitting || selectedReason == null
              ? null
              : () => _submitReport(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.metalPinkColour,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const TextView(
                  text: 'Submit',
                  fontSize: 14,
                  color: AppColors.metalWhite,
                ),
        ),
      ],
    );
  }

  Future<void> _submitReport(BuildContext context) async {
    if (selectedReason == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final reportDataSource = ref.read(reportRemoteDataSourceProvider);
      await reportDataSource.reportContent(
        report: ContentReportDto(
          contentType: ReportContentType.thought,
          contentId: widget.thoughtId,
          reason: selectedReason!,
          additionalInfo: _detailsController.text.isNotEmpty
              ? _detailsController.text
              : null,
        ),
      );

      if (mounted) {
        Navigator.of(context).pop({
          'success': true,
          'reason': selectedReason,
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        Fluttertoast.showToast(msg: 'Failed to submit report: ${e.toString()}');
      }
    }
  }
}
