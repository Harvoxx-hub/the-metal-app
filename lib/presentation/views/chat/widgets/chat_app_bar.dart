import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/services/firebase.remote.config.service.dart';
import 'package:metal/core/utils/image_picker_util.dart';
import 'package:metal/domain/entities/message_dto.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/presentation/viewmodels/connection/connection_providers.dart';
import 'package:metal/presentation/viewmodels/profile/profile_photo_viewmodel.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/dialog/metal_dialog.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';

/// App bar for chat window showing user info
class ChatAppBar extends ConsumerWidget {
  final ChatConnectionDto connection;
  final ChatUserDto otherUser;

  const ChatAppBar({
    super.key,
    required this.connection,
    required this.otherUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  imgUrl:
                      connection.isAnonymous ? null : otherUser.profilePhoto,
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
                    text:
                        '@${otherUser.displayName.toLowerCase().replaceAll(' ', '_')}',
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
            color: AppColors.metalWhite,
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
            onSelected: (value) => _handleMenuAction(context, ref, value),
            itemBuilder: (context) {
              // Calculate remaining days for unmelt
              final remoteConfig = FirebaseRemoteConfigService();
              final requiredDays = remoteConfig.getDaysRequiredToUnMelt();
              final daysSinceConnection = _getDaysSinceConnection();
              final remainingDays = requiredDays - daysSinceConnection;
              final canUnmeltByDays = remainingDays <= 0;

              // Check if already unmelted (identities revealed)
              final isAlreadyUnmelted = !connection.isAnonymous;

              return [
                const PopupMenuItem(
                  value: 'view_contact',
                  child: Text('View contact'),
                ),
                // Only show unmelt option if still anonymous
                if (!isAlreadyUnmelted)
                  PopupMenuItem(
                    value: 'unmelt',
                    child: Text(
                      canUnmeltByDays
                          ? 'Unmelt'
                          : 'Unmelt ($remainingDays ${remainingDays == 1 ? 'day' : 'days'} left)',
                    ),
                  ),
                const PopupMenuItem(
                  value: 'clear_chat',
                  child: Text('Clear chat'),
                ),
                const PopupMenuItem(
                  value: 'unblock',
                  child: Text('Unblock'),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }

  void _viewProfile(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.userProfile,
      arguments: otherUser.id,
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'view_contact':
        _viewProfile(context);
        break;
      case 'unmelt':
        _handleUnmelt(context, ref);
        break;
      case 'clear_chat':
        _showClearChatDialog(context);
        break;
      case 'unblock':
        _handleUnblock(context);
        break;
    }
  }

  /// Calculate days since connection was created
  int _getDaysSinceConnection() {
    if (connection.connectedOn == null) return 0;
    final now = DateTime.now();
    final difference = now.difference(connection.connectedOn!);
    return difference.inDays;
  }

  /// Handle unmelt action - check if required days have passed
  void _handleUnmelt(BuildContext context, WidgetRef ref) {
    // Get required days from remote config
    final remoteConfig = FirebaseRemoteConfigService();
    final requiredDays = remoteConfig.getDaysRequiredToUnMelt();
    final daysSinceConnection = _getDaysSinceConnection();

    // Check if required days have passed
    if (daysSinceConnection < requiredDays) {
      final remainingDays = requiredDays - daysSinceConnection;
      _showNotEnoughDaysDialog(context, remainingDays);
      return;
    }

    // Proceed with unmelt dialog
    _showUnmeltDialog(context, ref);
  }

  /// Show dialog when user hasn't met the required days to unmelt
  void _showNotEnoughDaysDialog(BuildContext context, int remainingDays) {
    MetalDialog.show(
      context: context,
      icon: Icon(
        Icons.timer_outlined,
        size: 48,
        color: AppColors.metalPinkColour,
      ),
      title: 'Not Yet!',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextView(
            text:
                'You need to wait $remainingDays more ${remainingDays == 1 ? 'day' : 'days'} before you can unmelt with this connection.',
            fontSize: 14,
            textAlign: TextAlign.center,
            color: Colors.black87,
          ),
          const Gap(16),
          const TextView(
            text:
                'Take your time to know each other better before revealing your identities.',
            fontSize: 12,
            textAlign: TextAlign.center,
            color: Colors.black54,
          ),
        ],
      ),
      primaryButtonText: 'Got it',
      onPrimaryPressed: () => Navigator.pop(context),
    );
  }

  void _showUnmeltDialog(BuildContext context, WidgetRef ref) {
    final currentUser = ref.read(currentUserProvider);
    final hasProfilePhoto = currentUser?.profilePhoto != null &&
        currentUser!.profilePhoto!.isNotEmpty;

    // If user already has a profile photo, show regular unmelt dialog
    if (hasProfilePhoto) {
      MetalDialog.show(
        context: context,
        title: 'Want to Unmelt?',
        content: const TextView(
          text:
              'Unmelting means that the two profiles can view each others photos. This action cannot be undone.',
          fontSize: 14,
          textAlign: TextAlign.center,
          color: Colors.black87,
        ),
        secondaryButtonText: 'Cancel',
        onSecondaryPressed: () => Navigator.pop(context),
        primaryButtonText: 'Unmelt',
        onPrimaryPressed: () {
          Navigator.pop(context);
          _requestUnmelt(context, ref);
        },
      );
      return;
    }

    // If user doesn't have a profile photo, show upload dialog
    MetalDialog.show(
      context: context,
      title: 'Want to Unmelt?',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const TextView(
            text:
                'Wait a minute, we are missing your photo! To unmelt means that the two profiles can view each others photos',
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
        ],
      ),
      primaryButtonText: 'Upload your photo',
      primaryButtonFullWidth: true,
      onPrimaryPressed: () {
        Navigator.pop(context);
        _handlePhotoUpload(context, ref);
      },
    );
  }

  Future<void> _handlePhotoUpload(BuildContext context, WidgetRef ref) async {
    final photoState = ref.read(profilePhotoViewModelProvider);

    // Show loading indicator if already uploading
    if (photoState.isUploading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload in progress...')),
      );
      return;
    }

    // Use the centralized image picker utility
    await ImagePickerUtil.pickImage(context, ref);

    // Listen to state changes to show success/error messages
    ref.listen<ProfilePhotoState>(
      profilePhotoViewModelProvider,
      (previous, next) {
        if (previous?.isUploading == true && !next.isUploading) {
          if (next.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(next.successMessage!),
                backgroundColor: Colors.green,
              ),
            );
            // Clear the success message
            ref.read(profilePhotoViewModelProvider.notifier).clearMessages();
          } else if (next.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(next.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
            // Clear the error message
            ref.read(profilePhotoViewModelProvider.notifier).clearMessages();
          }
        }
      },
    );
  }

  /// Request to unmelt (reveal identities) - sends an unmelt request
  Future<void> _requestUnmelt(BuildContext context, WidgetRef ref) async {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sending unmelt request...')),
    );

    try {
      final repository = ref.read(connectionRepositoryProvider);
      final result = await repository.requestUnmelt(connection.id);

      if (context.mounted) {
        if (result.isSuccess) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unmelt request sent! Waiting for approval.'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(result.errorMessage ?? 'Failed to send unmelt request'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showClearChatDialog(BuildContext context) {
    MetalDialog.show(
      context: context,
      title: 'Clear chat',
      content: const TextView(
        text:
            'Are you sure you want to clear all messages in this chat? This action cannot be undone.',
        fontSize: 14,
        textAlign: TextAlign.center,
        color: Colors.black87,
      ),
      secondaryButtonText: 'Cancel',
      onSecondaryPressed: () => Navigator.pop(context),
      primaryButtonText: 'Clear',
      primaryButtonColor: AppColors.metalRed,
      onPrimaryPressed: () {
        Navigator.pop(context);
        _clearChat(context);
      },
    );
  }

  void _clearChat(BuildContext context) {
    // TODO: Implement clear chat functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chat cleared')),
    );
  }

  void _handleUnblock(BuildContext context) {
    MetalDialog.show(
      context: context,
      title: 'Unblock user',
      content: TextView(
        text: 'Are you sure you want to unblock ${otherUser.displayName}?',
        fontSize: 14,
        textAlign: TextAlign.center,
        color: Colors.black87,
      ),
      secondaryButtonText: 'Cancel',
      onSecondaryPressed: () => Navigator.pop(context),
      primaryButtonText: 'Unblock',
      onPrimaryPressed: () {
        Navigator.pop(context);
        _performUnblock(context);
      },
    );
  }

  void _performUnblock(BuildContext context) {
    // TODO: Implement unblock functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User unblocked')),
    );
  }
}
