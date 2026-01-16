import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/domain/entities/thought_dto.dart';
import 'package:metal/domain/entities/comment_dto.dart';
import 'package:metal/presentation/viewmodels/thought/thought_providers.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/widgets/build_user_info.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/state.handler/error.state.dart';
import 'package:metal/widgets/state.handler/empty.state.dart';
import 'package:metal/presentation/views/thought/widgets/reaction_section.dart';
import 'package:metal/presentation/viewmodels/thought/comment_viewmodel.dart';
import 'package:metal/presentation/views/thought/widgets/comment_item_widget.dart';
import 'package:metal/data/datasources/remote/remote_data_source_providers.dart';
import 'package:metal/domain/entities/report_dto.dart';

/// Thought Detail View
/// Displays a single thought with full content and comments below
/// Accessible via:
/// - Feed: Clicking on a thought
/// - Deep link: /thought/:id
/// - Notification: When clicking on a thought notification
class ThoughtDetailView extends ConsumerStatefulWidget {
  final String thoughtId;
  final String?
      targetCommentId; // For scrolling to a specific comment (from notifications)

  const ThoughtDetailView({
    super.key,
    required this.thoughtId,
    this.targetCommentId,
  });

  @override
  ConsumerState<ThoughtDetailView> createState() => _ThoughtDetailViewState();
}

class _ThoughtDetailViewState extends ConsumerState<ThoughtDetailView> {
  ThoughtDto? _thought;
  bool _isLoading = true;
  String? _errorMessage;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _commentsSectionKey = GlobalKey();
  bool _hasScrolledToComment = false;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  CommentDto? _replyingToComment;

  @override
  void initState() {
    super.initState();
    _loadThought();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadThought() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(thoughtRepositoryProvider);
      final result = await repository.getThoughtById(widget.thoughtId);

      if (mounted) {
        if (result.isSuccess && result.data != null) {
          setState(() {
            _thought = result.data;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = result.errorMessage ?? 'Failed to load thought';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'An error occurred: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.metalBlack),
        onPressed: () => Navigator.pop(context),
      ),
      title: const TextView(
        text: 'Thought',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.metalBlack,
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }

    if (_errorMessage != null) {
      return ErrorState(
        text: _errorMessage!,
        retry: _loadThought,
      );
    }

    if (_thought == null) {
      return const EmptyState(
        text: 'Thought not found',
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await _loadThought();
              if (_thought != null) {
                await ref
                    .read(commentViewModelProvider(_thought!.id).notifier)
                    .refresh();
              }
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildThoughtSection(),
                  const Divider(height: 1),
                  _buildCommentsSection(),
                ],
              ),
            ),
          ),
        ),
        _buildCommentInput(),
      ],
    );
  }

  Widget _buildThoughtSection() {
    final thought = _thought!;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info
          BuildUserInfo(
            userId: thought.userId,
            thought: thought,
            showThoughtMenu: true,
            onDeleteThought: () => _handleDeleteThought(),
            onReportThought: () => _handleReportThought(),
            onBlockUser: () => _handleBlockUser(),
          ),
          const Gap(12),

          // Community tag if applicable
          if (thought.communityMetadata != null) ...[
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
                        'Posted in: ${thought.communityMetadata!.communityName}',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.metalPinkColour,
                  ),
                ],
              ),
            ),
            const Gap(12),
          ],

          // Thought content
          if (thought.type == 'voice') ...[
            // Voice thought - use ThoughtCard for audio player
            _buildVoiceThoughtContent(thought),
            const Gap(12),
          ] else if (thought.type == 'repost') ...[
            // Repost - show repost header and original thought
            _buildRepostContent(thought),
          ] else ...[
            // Regular text thought
            TextView(
              text: thought.content,
              fontSize: 16,
              color: AppColors.metalBlack,
              fontWeight: FontWeight.w400,
            ),
          ],

          const Gap(16),

          // Actions row (reactions, comments, share)
          _buildActionsRow(thought),
        ],
      ),
    );
  }

  Widget _buildVoiceThoughtContent(ThoughtDto thought) {
    // For voice thoughts, show a simplified player
    // In production, you might want to extract the voice player from ThoughtCard
    final audioUrl = thought.audioUrl;
    if (audioUrl == null || audioUrl.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: TextView(
            text: 'Audio not available',
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.metalPinkColour,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 24,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextView(
                  text: 'Voice Thought',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                if (thought.audioDuration != null)
                  TextView(
                    text: '${thought.audioDuration}s',
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepostContent(ThoughtDto thought) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextView(
          text:
              'Reposted by ${thought.authorMetadata?.authorName ?? "Someone"}',
          fontSize: 12,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
        const Gap(8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (thought.originalThought != null) ...[
                BuildUserInfo(
                  userId: thought.originalThought!.userId,
                  thought: thought.originalThought!,
                ),
                const Gap(8),
                TextView(
                  text: thought.originalThought!.content,
                  fontSize: 15,
                  color: AppColors.metalBlack,
                ),
              ] else ...[
                TextView(
                  text: 'Original thought has been deleted',
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionsRow(ThoughtDto thought) {
    final userdata = ref.watch(userStateProvider).user;
    final commentsState = ref.watch(commentViewModelProvider(thought.id));
    final commentCount = commentsState.comments.length;

    return Row(
      children: [
        // Profile button
        IconButton(
          onPressed: () {
            if (thought.userId != userdata?.id) {
              // Navigate to user profile
              // TODO: Implement navigation
            }
          },
          icon: const Icon(Icons.person_outline, size: 24),
        ),

        // Comments button
        GestureDetector(
          onTap: () {
            // Scroll to comments section
            _scrollToComments();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.comment_outlined, size: 24),
              const SizedBox(width: 4),
              TextView(
                text: commentCount.toString(),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ),

        // Share button
        IconButton(
          onPressed: () {
            // TODO: Implement share
          },
          icon: const Icon(Icons.share_outlined, size: 24),
        ),

        // Reactions
        Expanded(
          child: ReactionSection(thoughtId: thought.id),
        ),
      ],
    );
  }

  Widget _buildCommentsSection() {
    if (_thought == null) return const SizedBox.shrink();

    final commentsState = ref.watch(commentViewModelProvider(_thought!.id));

    // Scroll to target comment when comments are loaded (only once)
    if (widget.targetCommentId != null &&
        commentsState.comments.isNotEmpty &&
        !_hasScrolledToComment) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToComment(widget.targetCommentId!);
        _hasScrolledToComment = true;
      });
    }

    return Container(
      key: _commentsSectionKey,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comments header
          Row(
            children: [
              TextView(
                text: 'Comments',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.metalBlack,
              ),
              const SizedBox(width: 8),
              if (commentsState.comments.isNotEmpty)
                TextView(
                  text: '(${commentsState.comments.length})',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
            ],
          ),
          const Gap(16),

          // Comments list
          if (commentsState.isLoading && commentsState.comments.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator.adaptive(),
              ),
            )
          else if (commentsState.isError)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    TextView(
                      text: commentsState.errorMessage ??
                          'Failed to load comments',
                      fontSize: 14,
                      color: Colors.red,
                    ),
                    const Gap(8),
                    TextButton(
                      onPressed: () {
                        ref
                            .read(
                                commentViewModelProvider(_thought!.id).notifier)
                            .refresh();
                      },
                      child: const TextView(
                        text: 'Retry',
                        fontSize: 14,
                        color: AppColors.metalPinkColour,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (commentsState.comments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: TextView(
                  text: 'No comments yet\nBe the first to comment!',
                  fontSize: 14,
                  color: Colors.grey[600],
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ..._buildCommentsList(commentsState.comments),

          // Load more button
          if (commentsState.hasMore && !commentsState.isLoadingMore)
            Center(
              child: TextButton(
                onPressed: () {
                  ref
                      .read(commentViewModelProvider(_thought!.id).notifier)
                      .loadMoreComments();
                },
                child: const TextView(
                  text: 'Load more comments',
                  fontSize: 14,
                  color: AppColors.metalPinkColour,
                ),
              ),
            )
          else if (commentsState.isLoadingMore)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildCommentsList(List<CommentDto> comments) {
    // Filter top-level comments (not replies)
    final topLevelComments =
        comments.where((comment) => !comment.isReply).toList();

    return topLevelComments.map((comment) {
      // Get replies for this comment
      final replies = comments
          .where((c) =>
              c.replyToCommentId != null && c.replyToCommentId == comment.id)
          .toList();

      return CommentItemWidget(
        comment: comment,
        thought: _thought!,
        replies: replies,
        onDeleteComment: (commentId) {
          ref
              .read(commentViewModelProvider(_thought!.id).notifier)
              .deleteComment(commentId);
        },
        onReplyToComment: _handleReplyToComment,
      );
    }).toList();
  }

  void _scrollToComments() {
    if (!_scrollController.hasClients) return;

    final context = _commentsSectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToComment(String commentId) {
    if (!_scrollController.hasClients) return;

    final commentsState = ref.read(commentViewModelProvider(_thought!.id));
    final comments = commentsState.comments;

    // Find the index of the comment
    int targetIndex = -1;
    for (int i = 0; i < comments.length; i++) {
      if (comments[i].id == commentId) {
        targetIndex = i;
        break;
      }
    }

    if (targetIndex == -1) return;

    // Estimate comment height and scroll to position
    const double estimatedCommentHeight = 120.0;
    final double targetOffset = targetIndex * estimatedCommentHeight +
        400; // Offset for thought section

    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  void _handleReplyToComment(CommentDto comment) {
    setState(() {
      _replyingToComment = comment;
    });
    // Focus the input field
    _commentFocusNode.requestFocus();
    // Scroll to input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _cancelReply() {
    setState(() {
      _replyingToComment = null;
    });
    _commentController.clear();
    _commentFocusNode.unfocus();
  }

  Future<void> _sendComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty || _thought == null) return;

    final viewModel = ref.read(commentViewModelProvider(_thought!.id).notifier);

    if (_replyingToComment != null) {
      // Send reply
      await viewModel.addComment(content,
          replyToCommentId: _replyingToComment!.id);
      _cancelReply();
    } else {
      // Send regular comment
      await viewModel.addComment(content);
      _commentController.clear();
    }

    // Scroll to bottom to show new comment
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _buildCommentInput() {
    if (_thought == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reply indicator
          if (_replyingToComment != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.metalPinkColour.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.metalPinkColour.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextView(
                          text: 'Replying to ${_replyingToComment!.userId}',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.metalPinkColour,
                        ),
                        const SizedBox(height: 2),
                        TextView(
                          text: _replyingToComment!.content.length > 50
                              ? '${_replyingToComment!.content.substring(0, 50)}...'
                              : _replyingToComment!.content,
                          fontSize: 11,
                          color: Colors.grey[600],
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    color: AppColors.metalPinkColour,
                    onPressed: _cancelReply,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

          // Input field
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  focusNode: _commentFocusNode,
                  decoration: InputDecoration(
                    hintText: _replyingToComment != null
                        ? 'Write a reply...'
                        : 'Write a comment...',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: AppColors.metalPinkColour,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendComment(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.metalPinkColour,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendComment,
                  tooltip: 'Send comment',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteThought() async {
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
      try {
        final repository = ref.read(thoughtRepositoryProvider);
        final result = await repository.deleteThought(_thought!.id);

        if (mounted) {
          if (result.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thought deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(); // Go back to previous screen
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(result.errorMessage ?? 'Failed to delete thought'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete thought: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleReportThought() async {
    if (_thought == null) return;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _ReportThoughtDialog(thoughtId: _thought!.id),
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Thank you for reporting. We will review this thought.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _handleBlockUser() async {
    if (_thought == null) return;

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
              'Are you sure you want to block ${_thought!.authorMetadata?.authorName ?? "this user"}? You will no longer see their thoughts or be able to interact with them.',
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
        await profileDataSource.blockUser(userId: _thought!.userId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User blocked successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(); // Go back to previous screen
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to block user: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit report: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
