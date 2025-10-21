import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/features/thought/data/domain/entries/comment.model.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

class CommentReplyPreviewWidget extends ConsumerWidget {
  final CommentModel replyToComment;
  final VoidCallback? onCancel;
  final VoidCallback? onTap;

  const CommentReplyPreviewWidget({
    super.key,
    required this.replyToComment,
    this.onCancel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userStateProvider).data;
    final isCurrentUser = replyToComment.userId == userData?.id;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.metalTabBg,
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
            // Reply icon
            Icon(
              Icons.reply,
              size: 16,
              color: AppColors.metalPinkColour,
            ),
            const SizedBox(width: 8),

            // Reply content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextView(
                    text: isCurrentUser ? "You" : "Comment",
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.metalPinkColour,
                  ),
                  const SizedBox(height: 2),
                  TextView(
                    text: replyToComment.replyPreviewText,
                    fontSize: 13,
                    color: AppColors.metalBlack75,
                    maxLines: 1,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Cancel button
            if (onCancel != null)
              GestureDetector(
                onTap: onCancel,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.metalBlack.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: AppColors.metalBlack50,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

