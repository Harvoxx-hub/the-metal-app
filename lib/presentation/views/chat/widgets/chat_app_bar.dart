import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/domain/entities/message_dto.dart';
import 'package:metal/gen/assets.gen.dart';
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
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Assets.icons.chatsWindowactiveCaretLeft.svg(
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  AppColors.metalBlack,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const Gap(8),
          // Profile photo with online indicator
          GestureDetector(
            onTap: () => _viewProfile(context),
            child: Stack(
              children: [
                ProfilePhoto(
                  meltId: otherUser.metal ?? '',
                  imgUrl: connection.isAnonymous ? null : otherUser.profilePhoto,
                  size: 44,
                ),
                // Online indicator
                if (otherUser.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Gap(12),
          // User info
          Expanded(
            child: GestureDetector(
              onTap: () => _viewProfile(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextView(
                    text: '@${otherUser.displayName.toLowerCase().replaceAll(' ', '_')}',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.metalBlack,
                  ),
                  if (otherUser.isOnline)
                    const TextView(
                      text: 'Active now',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                ],
              ),
            ),
          ),
          // Video call icon
          GestureDetector(
            onTap: () {
              // TODO: Implement video call
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Assets.icons.chatsWindowactiveVideoRecorder.svg(
                width: 28,
                height: 28,
                colorFilter: const ColorFilter.mode(
                  AppColors.metalBlack,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const Gap(4),
          // Phone call icon
          GestureDetector(
            onTap: () {
              // TODO: Implement audio call
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Assets.icons.profilePhone.svg(
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  AppColors.metalBlack,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          // Three-dot menu
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            icon: Assets.icons.chatsWindowactiveSrMenuVerticalLite.svg(
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.metalBlack,
                BlendMode.srcIn,
              ),
            ),
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view_contact',
                child: Text('View contact'),
              ),
              PopupMenuItem(
                value: 'unmetal',
                child: Text(
                  connection.isMeltPending ? 'Unmetal (after 30 days)' : 'Unmetal',
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'clear_chat',
                child: Text('Clear chat'),
              ),
              const PopupMenuItem(
                value: 'unblock',
                child: Text('Unblock'),
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
      case 'view_contact':
        _viewProfile(context);
        break;
      case 'unmetal':
        _showUnmetalDialog(context);
        break;
      case 'clear_chat':
        _showClearChatDialog(context);
        break;
      case 'unblock':
        _handleUnblock(context);
        break;
    }
  }

  void _showUnmetalDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TextView(
                text: 'Want to Unmetal?',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
              const Gap(20),
              const TextView(
                text: 'Wait a minute, we are missing your photo! To unmetal means that the two profiles can view each others photos',
                fontSize: 14,
                textAlign: TextAlign.center,
                color: Colors.black87,
              ),
              const Gap(24),
              const TextView(
                text: 'To continue',
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.black54,
              ),
              const Gap(12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handlePhotoUpload(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.metalPinkColour,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Upload your photo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handlePhotoUpload(BuildContext context) {
    // TODO: Implement photo upload
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo upload feature coming soon')),
    );
  }

  void _showClearChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Clear chat'),
        content: const Text(
          'Are you sure you want to clear all messages in this chat? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearChat(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _clearChat(BuildContext context) {
    // TODO: Implement clear chat functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chat cleared')),
    );
  }

  void _handleUnblock(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Unblock user'),
        content: Text('Are you sure you want to unblock ${otherUser.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performUnblock(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.metalPinkColour),
            child: const Text('Unblock'),
          ),
        ],
      ),
    );
  }

  void _performUnblock(BuildContext context) {
    // TODO: Implement unblock functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User unblocked')),
    );
  }
}
