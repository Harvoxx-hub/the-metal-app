import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/domain/entities/message_dto.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';

/// App bar for chat window showing user info
class ChatAppBar extends StatelessWidget {
  final ChatConnectionDto connection;
  final ChatUserDto otherUser;

  const ChatAppBar({
    super.key,
    required this.connection,
    required this.otherUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
            color: AppColors.metalBlack,
          ),
          // Profile photo
          GestureDetector(
            onTap: () => _viewProfile(context),
            child: ProfilePhoto(
              meltId: otherUser.metal ?? '',
              imgUrl: connection.isAnonymous ? null : otherUser.profilePhoto,
              size: 40,
            ),
          ),
          const Gap(12),
          // User info
          Expanded(
            child: GestureDetector(
              onTap: () => _viewProfile(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextView(
                    text: otherUser.displayName,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  if (otherUser.isOnline)
                    const TextView(
                      text: 'Online',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.green,
                    ),
                ],
              ),
            ),
          ),
          // More options
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.metalBlack),
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view_profile',
                child: Text('View Profile'),
              ),
              const PopupMenuItem(
                value: 'clear_chat',
                child: Text('Clear Chat'),
              ),
              const PopupMenuItem(
                value: 'block',
                child: Text('Block User', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _viewProfile(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.userProfilePage,
      arguments: otherUser,
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'view_profile':
        _viewProfile(context);
        break;
      case 'clear_chat':
        _showClearChatDialog(context);
        break;
      case 'block':
        _showBlockDialog(context);
        break;
    }
  }

  void _showClearChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to delete all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement clear chat
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: Text('Are you sure you want to block ${otherUser.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement block user
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

}
