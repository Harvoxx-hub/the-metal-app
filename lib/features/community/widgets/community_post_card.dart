import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/features/community/data/domain/entries/community.model.dart';

class CommunityPostCard extends StatelessWidget {
  final CommunityPostModel post;
  final VoidCallback? onReact;
  final VoidCallback? onComment;
  final VoidCallback? onReport;

  const CommunityPostCard({
    super.key,
    required this.post,
    this.onReact,
    this.onComment,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.metalWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.metalBlack.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Row(
            children: [
              // Author Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.metalPinkColour.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: post.authorProfilePhoto != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          post.authorProfilePhoto!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.person,
                        color: AppColors.metalPinkColour,
                        size: 20,
                      ),
              ),

              const Gap(12),

              // Author Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.metalBrownColourForText,
                      ),
                    ),
                    const Gap(2),
                    Row(
                      children: [
                        Text(
                          'Posted in: ',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.metalBrownColourForText
                                .withOpacity(0.5),
                          ),
                        ),
                        Text(
                          post.communityName,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.metalPinkColour,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // More Options
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'report') {
                    onReport?.call();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(
                          Icons.flag_outlined,
                          size: 16,
                          color: AppColors.metalRed,
                        ),
                        const Gap(8),
                        Text(
                          'Report',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.metalRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                child: Icon(
                  Icons.more_vert,
                  color: AppColors.metalBrownColourForText.withOpacity(0.5),
                  size: 20,
                ),
              ),
            ],
          ),

          const Gap(12),

          // Post Content
          Text(
            post.content,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.metalBrownColourForText,
              height: 1.4,
            ),
          ),

          const Gap(16),

          // Post Actions
          Row(
            children: [
              // Reaction Button
              GestureDetector(
                onTap: onReact,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: post.hasUserReacted
                        ? AppColors.metalPinkColour.withOpacity(0.1)
                        : AppColors.metalTabBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        post.hasUserReacted
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 16,
                        color: post.hasUserReacted
                            ? AppColors.metalPinkColour
                            : AppColors.metalBrownColourForText
                                .withOpacity(0.6),
                      ),
                      const Gap(4),
                      Text(
                        post.reactionCount.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: post.hasUserReacted
                              ? AppColors.metalPinkColour
                              : AppColors.metalBrownColourForText
                                  .withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Gap(16),

              // Comment Button
              GestureDetector(
                onTap: onComment,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.metalTabBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 16,
                        color:
                            AppColors.metalBrownColourForText.withOpacity(0.6),
                      ),
                      const Gap(4),
                      Text(
                        post.commentCount.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.metalBrownColourForText
                              .withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Timestamp
              Text(
                _formatTimestamp(post.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.metalBrownColourForText.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }
}
