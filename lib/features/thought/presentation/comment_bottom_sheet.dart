import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:metal/features/thought/data/domain/entries/comment.model.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/features/thought/data/domain/entries/thought.model.dart';
import 'package:metal/features/thought/provider/comment.provider.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/thought/widget/comment_item_widget.dart';

class CommentBottomSheet extends ConsumerStatefulWidget {
  final ThoughtModel thought;
  final String? targetCommentId;

  const CommentBottomSheet({
    Key? key,
    required this.thought,
    this.targetCommentId,
  }) : super(key: key);

  @override
  ConsumerState<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends ConsumerState<CommentBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  CommentModel? _replyingToComment;
  bool _hasScrolledToTarget = false;

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Scroll to a specific comment by its ID
  void _scrollToComment(String commentId) {
    if (!_scrollController.hasClients) return;

    final commentsState = ref.read(commentProvider(widget.thought.id));
    final comments = commentsState.data ?? [];

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
    const double estimatedCommentHeight = 100.0;
    final double targetOffset = targetIndex * estimatedCommentHeight;

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  void _handleReplyToComment(CommentModel comment) {
    setState(() {
      _replyingToComment = comment;
    });
    // Focus the input field
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _cancelReply() {
    setState(() {
      _replyingToComment = null;
    });
    _commentController.clear();
  }

  void _sendComment() {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    if (_replyingToComment != null) {
      // Send reply
      ref.read(commentProvider(widget.thought.id).notifier).addComment(
            CommentModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              userId: ref.read(userStateProvider).data?.id ?? '',
              thoughtId: widget.thought.id,
              content: content,
              createdAt: DateTime.now().toIso8601String(),
              reactions: [],
              replyToCommentId: _replyingToComment!.id,
              replyToUserId: _replyingToComment!.userId,
              replyToContent: _replyingToComment!.content,
              replyLevel: _replyingToComment!.replyLevel + 1,
              isDeleted: false,
            ),
          );
      _cancelReply();
    } else {
      // Send regular comment
      ref
          .read(commentProvider(widget.thought.id).notifier)
          .addCommentFromText(content);
      _commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsState = ref.watch(commentProvider(widget.thought.id));
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header with pink gradient
          Container(
            height: 60,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.00, -1.00),
                end: Alignment(0, 1),
                colors: [Color(0xFFDB217A), Color(0xFFF00E3E)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: TextView(
                    text: "Comments",
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Balance the close button
              ],
            ),
          ),

          // Comments list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(commentProvider(widget.thought.id).notifier)
                    .getComments();
              },
              child: commentsState.isLoading
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : commentsState.isError
                      ? Center(
                          child: TextView(
                              text: commentsState.errorMessage ??
                                  "Error loading comments"))
                      : commentsState.data == null ||
                              commentsState.data!.isEmpty
                          ? const Center(
                              child: TextView(text: "No comments yet"))
                          : Builder(
                              builder: (context) {
                                // Scroll to target comment when comments are loaded (only once)
                                if (widget.targetCommentId != null &&
                                    commentsState.data != null &&
                                    commentsState.data!.isNotEmpty &&
                                    !_hasScrolledToTarget) {
                                  print(
                                      'Scrolling to comment: ${widget.targetCommentId}');
                                  _hasScrolledToTarget = true;
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    _scrollToComment(widget.targetCommentId!);
                                  });
                                }

                                return ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(16),
                                  itemCount: commentsState.data!
                                      .where((comment) => !comment.isReply)
                                      .length,
                                  itemBuilder: (context, index) {
                                    // Get only top-level comments
                                    final topLevelComments = commentsState.data!
                                        .where((comment) => !comment.isReply)
                                        .toList();
                                    final comment = topLevelComments[index];

                                    // Get replies for this comment
                                    final replies = commentsState.data!
                                        .where((c) =>
                                            c.replyToCommentId == comment.id)
                                        .toList();

                                    return CommentItemWidget(
                                      comment: comment,
                                      thought: widget.thought,
                                      replies: replies,
                                      onDeleteComment: (commentId) {
                                        ref
                                            .read(commentProvider(
                                                    widget.thought.id)
                                                .notifier)
                                            .deleteComment(commentId);
                                      },
                                      onReplyToComment: _handleReplyToComment,
                                    );
                                  },
                                );
                              },
                            ),
            ),
          ),

          // Comment input
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16 + bottomPadding,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Reply indicator
                  if (_replyingToComment != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD2128B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFD2128B).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.reply,
                            size: 16,
                            color: const Color(0xFFD2128B),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextView(
                              text:
                                  "Replying to ${_replyingToComment!.content}", // You might want to get the actual username here
                              fontSize: 14,
                              color: const Color(0xFFD2128B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: _cancelReply,
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: const Color(0xFFD2128B),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Input row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: _replyingToComment != null
                                  ? const Color(0xFFD2128B).withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: _replyingToComment != null
                                  ? 'Write a reply...'
                                  : 'Write a comment...',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              hintStyle: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                              ),
                            ),
                            maxLines: null,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) {
                              FocusScope.of(context).unfocus();
                              _sendComment();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFD2128B),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: IconButton(
                          icon: SvgPicture.asset(
                            Assets.icons.send.path,
                            color: Colors.white,
                            height: 20,
                            width: 20,
                          ),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            _sendComment();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
