import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:metal/features/thought/data/domain/entries/comment.model.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';

class CommentReplyInputWidget extends ConsumerStatefulWidget {
  final CommentModel replyToComment;
  final Function(String content) onSendReply;
  final VoidCallback? onCancel;

  const CommentReplyInputWidget({
    super.key,
    required this.replyToComment,
    required this.onSendReply,
    this.onCancel,
  });

  @override
  ConsumerState<CommentReplyInputWidget> createState() =>
      _CommentReplyInputWidgetState();
}

class _CommentReplyInputWidgetState
    extends ConsumerState<CommentReplyInputWidget> {
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus the input field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendReply() {
    final content = _replyController.text.trim();
    if (content.isNotEmpty) {
      widget.onSendReply(content);
      _replyController.clear();
      widget.onCancel?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.metalPinkColour.withOpacity(0.3),
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
          // Reply preview
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.metalPinkColour.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(
                  color: AppColors.metalPinkColour,
                  width: 3,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.reply,
                  size: 14,
                  color: AppColors.metalPinkColour,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.replyToComment.replyPreviewText,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.metalBlack75,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Reply input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _replyController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Write a reply...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: AppColors.metalBlack50,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendReply(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _sendReply,
                icon: SvgPicture.asset(
                  Assets.icons.send.path,
                  color: AppColors.metalPinkColour,
                  height: 20,
                  width: 20,
                ),
              ),
              if (widget.onCancel != null)
                IconButton(
                  onPressed: widget.onCancel,
                  icon: Icon(
                    Icons.close,
                    color: AppColors.metalBlack50,
                    size: 20,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

