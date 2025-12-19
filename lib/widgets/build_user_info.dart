import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/domain/entities/thought_dto.dart';
 
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';

/// Widget to display user info in thoughts and comments
class BuildUserInfo extends ConsumerWidget {
  final String userId;
  final ThoughtDto thought;
  final DateTime? date;
  final String? commentId;
  final Function(String)? onDeleteComment;

  const BuildUserInfo({
    super.key,
    required this.userId,
    required this.thought,
    this.date,
    this.commentId,
    this.onDeleteComment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(userStateProvider).user;
    final isOwnContent = currentUser?.id == userId;

    // Use author metadata from thought if available, otherwise fetch user
    final authorMetadata = thought.authorMetadata;

    if (authorMetadata != null && authorMetadata.authorId == userId) {
      return _buildUserInfoRow(
        context: context,
        name: authorMetadata.authorName ?? 'Anonymous',
        profilePhoto: authorMetadata.authorProfilePhoto,
        isVerified: authorMetadata.authorIsVerified ?? false,
        isOwnContent: isOwnContent,
        metalId: userId,
      );
    }

    // Fallback to fetching user data if author metadata not available
    final userState = ref.watch(userStateProvider);

    if (userState.isLoading) {
      return _buildLoadingState();
    }

    if ( userState.user == null) {
      return _buildUserInfoRow(
        context: context,
        name: 'Anonymous',
        profilePhoto: null,
        isVerified: false,
        isOwnContent: isOwnContent,
        metalId: userId,
      );
    }

    final user = userState.user!;
    return _buildUserInfoRow(
      context: context,
      name: user.username ?? user.fullname ?? 'Anonymous',
      profilePhoto: user.profilePhoto,
      isVerified: user.isVerified ?? false,
      isOwnContent: isOwnContent,
      metalId: user.metal ?? userId,
    );
  }

  Widget _buildLoadingState() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            shape: BoxShape.circle,
          ),
        ),
        const Gap(8),
        Container(
          width: 100,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoRow({
    required BuildContext context,
    required String name,
    String? profilePhoto,
    required bool isVerified,
    required bool isOwnContent,
    required String metalId,
  }) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (!isOwnContent) {
              Navigator.pushNamed(
                context,
                AppRoutes.myMeltedUser,
                arguments: {"metalId": userId},
              );
            }
          },
          child: ProfilePhoto(
            verfly: isVerified,
            size: 40,
            meltId: metalId,
          ),
        ),
        const Gap(8),
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (!isOwnContent) {
                Navigator.pushNamed(
                  context,
                  AppRoutes.myMeltedUser,
                  arguments: {"metalId": userId},
                );
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: TextView(
                        text: name,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        maxLines: 1,
                        textOverflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isVerified) ...[
                      const Gap(4),
                      Icon(
                        Icons.verified,
                        size: 14,
                        color: AppColors.metalPinkColour,
                      ),
                    ],
                  ],
                ),
                if (date != null) ...[
                  const Gap(2),
                  TextView(
                    text: _formatDate(date!),
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ],
              ],
            ),
          ),
        ),
        // Show delete option for own comments
        if (isOwnContent && commentId != null && onDeleteComment != null)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 18),
            onSelected: (value) {
              if (value == 'delete') {
                onDeleteComment!(commentId!);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    Gap(8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
