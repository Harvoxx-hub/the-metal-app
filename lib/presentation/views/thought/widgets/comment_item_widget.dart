import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/domain/entities/comment_dto.dart';
import 'package:metal/domain/entities/thought_dto.dart';
import 'package:metal/presentation/views/thought/widgets/comment_reaction_section.dart';
import 'package:metal/widgets/build_user_info.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/res/colors/cr_colors.dart';

class CommentItemWidget extends ConsumerStatefulWidget {
  final CommentDto comment;
  final ThoughtDto thought;
  final Function(String)? onDeleteComment;
  final List<CommentDto>? replies;
  final bool showReplies;
  final VoidCallback? onToggleReplies;
  final Function(CommentDto)? onReplyToComment;

  const CommentItemWidget({
    super.key,
    required this.comment,
    required this.thought,
    this.onDeleteComment,
    this.replies,
    this.showReplies = false,
    this.onToggleReplies,
    this.onReplyToComment,
  });

  @override
  ConsumerState<CommentItemWidget> createState() => _CommentItemWidgetState();
}

class _CommentItemWidgetState extends ConsumerState<CommentItemWidget> {
  bool _showReplies = false;

  @override
  void initState() {
    super.initState();
    _showReplies = widget.showReplies;
  }

  void _handleReplyTap() {
    // Only allow replies to top-level comments
    if (widget.comment.isTopLevel) {
      widget.onReplyToComment?.call(widget.comment);
    }
  }

  void _toggleReplies() {
    setState(() {
      _showReplies = !_showReplies;
    });
    widget.onToggleReplies?.call();
  }

  @override
  Widget build(BuildContext context) {
    final replies = widget.replies ?? [];

    return Container(
          margin: EdgeInsets.only(
            bottom: 12,
            left: widget.comment.isReply ? 20 : 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main comment card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.comment.isReply
                      ? AppColors.metalTabBg.withOpacity(0.3)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: widget.comment.isReply
                      ? Border.all(
                          color: AppColors.metalPinkColour.withOpacity(0.2),
                          width: 1,
                        )
                      : Border.all(
                          color: Colors.grey.withOpacity(0.1),
                          width: 1,
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User info
                    BuildUserInfo(
                      userId: widget.comment.userId,
                      thought: widget.thought,
                      date: widget.comment.createdAt,
                      commentId: widget.comment.id,
                      onDeleteComment: widget.onDeleteComment,
                    ),

                    const SizedBox(height: 8),

                    // Comment content
                    TextView(
                      text: widget.comment.content,
                      fontSize: 15,
                      color: AppColors.metalBlack,
                    ),

                    const SizedBox(height: 12),

                    // Actions row - only show for top-level comments
                    if (widget.comment.isTopLevel)
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          CommentReactionSection(
                            thoughtId: widget.thought.id,
                            commentId: widget.comment.id,
                            reactions: widget.comment.reactions,
                          ),

                          if (widget.comment.canHaveReplies)
                            GestureDetector(
                              onTap: _handleReplyTap,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.reply,
                                    size: 18,
                                    color: AppColors.metalPinkColour,
                                  ),
                                  const SizedBox(width: 4),
                                  TextView(
                                    text: "Reply",
                                    fontSize: 14,
                                    color: AppColors.metalPinkColour,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              ),
                            ),

                          // Show replies button if there are replies
                          if (replies.isNotEmpty)
                            GestureDetector(
                              onTap: _toggleReplies,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _showReplies
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    size: 18,
                                    color: AppColors.metalBlack50,
                                  ),
                                  const SizedBox(width: 4),
                                  TextView(
                                    text:
                                        "${replies.length} ${replies.length == 1 ? 'reply' : 'replies'}",
                                    fontSize: 14,
                                    color: AppColors.metalBlack50,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),

              // Replies list
              if (_showReplies && replies.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(left: 20, top: 8),
                  child: Column(
                    children: replies
                        .map((reply) => CommentItemWidget(
                              comment: reply,
                              thought: widget.thought,
                              onDeleteComment: widget.onDeleteComment,
                            ))
                        .toList(),
                  ),
                ),
            ],
          ),
        );
  }
}
