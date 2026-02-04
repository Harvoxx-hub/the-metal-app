import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/presentation/viewmodels/user/user_profile_viewmodel_providers.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/data/repositories/chat/chat_repository_providers.dart';
import 'package:metal/presentation/viewmodels/connection/connection_providers.dart';
import 'package:metal/presentation/viewmodels/connection/melt_viewmodel.dart';
import 'package:metal/presentation/viewmodels/settings/blocked_users_viewmodel.dart';
import 'package:metal/presentation/views/user/widgets/user_thoughts_tab.dart';
import 'package:metal/presentation/views/connection/widgets/metal_details_tab.dart';
import 'package:metal/presentation/views/dashboard/widgets/complete.profile.dialog.dart';
import 'package:metal/presentation/widgets/profile/profile_header.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/button/outiline.button.dart';
import 'package:metal/widgets/button/plain.button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/state.handler/error.state.dart';
import 'package:metal/widgets/state.handler/loading.state.dart';
import 'package:metal/widgets/tab/base.tab.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/gen/assets.gen.dart';

/// Metal Profile View
///
/// Centralized screen for viewing any user's profile with connection/melt relationship management.
/// Shows:
/// - User's public profile information
/// - Thoughts feed
/// - Connection/melt status and actions (Melt, Send Spark, Message)
/// - Connection details (when connected)
///
/// Accessed from:
/// - Connection cards (from connections list)
/// - Thought cards (clicking on any user's profile)
/// - Melted metals list
/// - Anywhere a user profile needs to be viewed
class UserProfileView extends ConsumerStatefulWidget {
  final String userId;

  const UserProfileView({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends ConsumerState<UserProfileView> {
  bool _hasShownBlockedDialog = false;

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileViewModelProvider(widget.userId));
    final profileViewModel =
        ref.read(userProfileViewModelProvider(widget.userId).notifier);

    // Watch melt action state for melt operations
    final meltActionState = ref.watch(meltActionProvider);

    // Get connection count for melt limit check (only watch when needed)
    final connectionState = ref.watch(connectionViewModelProvider);

    // Get current user data for profile completion check
    final currentUserDto = ref.watch(userStateProvider).user;

    // Check if the user is blocked
    final blockedUsersState = ref.watch(blockedUsersViewModelProvider);
    final blockedUsers = blockedUsersState.blockedUsers;
    final isUserBlocked = blockedUsers.any(
      (blockedUser) => blockedUser.userId == widget.userId,
    );

    // Show non-dismissible blocked user dialog if user is blocked
    if (isUserBlocked && profileState.user != null && !_hasShownBlockedDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNonDismissibleBlockedDialog(context, profileState.user!);
      });
    }

    // Listen for successful melt action
    ref.listen<MeltActionState>(meltActionProvider, (prev, current) async {
      if (current.isSuccess && prev?.isLoading == true) {
        // Refresh user profile to get updated connection/melt status
        profileViewModel.refresh();
        ref.read(connectionViewModelProvider.notifier).refresh();

        // If melt resulted in a connection (mutual melt), navigate to meltMetal route
        if (current.response?.status == 'connected' &&
            current.response?.mutual == true) {
          // Pass both userId and connectionId to the melt screen
          Navigator.pushNamed(
            context,
            AppRoutes.meltMetal,
            arguments: {
              'userId': widget.userId,
              'connectionId': current.response?.connectionId,
            },
          );
        }
      }
    });

    if (profileState.isLoading && profileState.user == null) {
      return BaseScreen(
        Header: 'Metal Profile',
        appBarState: AppBarState.BackWithHeader,
        body: const LoadingState(),
      );
    }

    if (profileState.isError && profileState.user == null) {
      return BaseScreen(
        Header: 'Metal Profile',
        appBarState: AppBarState.BackWithHeader,
        body: ErrorState(
          text: profileState.errorMessage ?? 'Failed to load user profile',
          retry: () => profileViewModel.refresh(),
        ),
      );
    }

    if (profileState.user == null) {
      return BaseScreen(
        Header: 'Metal Profile',
        appBarState: AppBarState.BackWithHeader,
        body: const Center(child: TextView(text: 'User not found')),
      );
    }

    final user = profileState.user!;
    final metalId =
        user.metal ?? 'default'; // Metal type for profile photo display

    // Determine profile picture: show user photo only if connected AND not anonymous
    // Otherwise show melt picture (when anonymous or not connected)
    final shouldShowProfilePhoto =
        (user.isConnected == true) && (user.isAnonymous == false);
    final profileUrl = shouldShowProfilePhoto ? user.profilePhoto : null;

    return BaseScreen(
      Header: 'Metal Profile',
      appBarState: AppBarState.BackWithHeader,
      body: ProfileHeader(
        eye: false,
        metalId: metalId,
        profileUrl: profileUrl,
        child: Padding(
          padding: const EdgeInsets.only(top: 110, left: 20, right: 20),
          child: Container(
            padding: const EdgeInsets.only(top: 122),
            decoration: const BoxDecoration(
              color: AppColors.metalWhite,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35),
                topRight: Radius.circular(35),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildUserInfoSection(user),
                const Gap(20),
                _buildMeltActionSection(
                  meltActionState,
                  connectionState.connections.length,
                  user,
                  currentUserDto,
                ),
                const Gap(10),
                SizedBox(
                  height: MediaQuery.of(context).size.height - 500,
                  child: BaseTab(
                    tabs: [
                      BaseTabModel(
                        title: 'Metal Thought',
                        child: UserThoughtsTab(
                          userId: widget.userId,
                          thoughts: profileState.thoughts,
                          isLoading: profileState.isLoadingThoughts,
                          hasMore: profileState.hasMoreThoughts,
                          onLoadMore: ({bool isLoadMore = false}) {
                            if (isLoadMore) {
                              profileViewModel.loadMoreThoughts();
                            } else {
                              profileViewModel.loadUserThoughts();
                            }
                          },
                          onRefresh: profileViewModel.refresh,
                        ),
                      ),
                      BaseTabModel(
                        title: 'Metal Details',
                        child: _buildDetailsTab(
                          user: user,
                          isConnected: user.isConnected ?? false,
                          connectionId: user.connectionId ?? '',
                          connectedOn: user.connectedOn ?? '',
                          isAnonymous: user.isAnonymous ?? true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build user info section with username in light pink box and location
  Widget _buildUserInfoSection(user) {
    // Build location text from city and country
    String locationText = '';
    if (user.location != null) {
      final parts = <String>[];
      if (user.location!.city != null && user.location!.city!.isNotEmpty) {
        parts.add(user.location!.city!);
      }
      if (user.location!.country != null &&
          user.location!.country!.isNotEmpty) {
        parts.add(user.location!.country!);
      }
      locationText = parts.join(', ');
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        color: const Color(0x0CD9197B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      child: Column(
        children: [
          TextView(
            text: '@${user.username ?? user.fullname ?? 'Unknown'}',
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.metalBrownColourForText,
          ),
          if (locationText.isNotEmpty) ...[
            const Gap(5),
            TextView(
              text: locationText,
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: AppColors.metalBrownColourForText,
            ),
          ],
        ],
      ),
    );
  }

  /// Build melt action section with status-based buttons
  Widget _buildMeltActionSection(
    MeltActionState meltActionState,
    int connectionCount,
    user,
    currentUserDto,
  ) {
    // Check if viewing own profile
    final isOwnProfile =
        currentUserDto != null && currentUserDto.id == widget.userId;

    // If viewing own profile, don't show action buttons
    if (isOwnProfile) {
      return const SizedBox.shrink();
    }

    // Connected state - show "Send Spark" and "Message" buttons
    if (user.isConnected == true) {
      return Row(
        children: [
          Expanded(
            child: BaseButton(
              loading: false,
              onPressed: () => _handleSendSparkAction(user),
              fontSize: 15,
              buttonText: "Send Spark",
            ),
          ),
          const Gap(12),
          Expanded(
            child: OutilineButton(
              onPressed: () {
                final connectionId = user.connectionId;
                if (connectionId != null && connectionId.isNotEmpty) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.chatWindowView,
                    arguments: connectionId,
                  );
                }
              },
              fontSize: 15,
              buttonText: "Message",
            ),
          ),
        ],
      );
    }

    // Not connected - check melt status
    final meltStatus = user.meltStatus ?? 'none';

    // Pending outgoing melt request - show "Melt pending" (disabled)
    if (meltStatus == 'pending_outgoing') {
      return PlainButton(
        loading: false,
        onPressed: () {},
        fontSize: 15,
        color: AppColors.metalPinkColour40,
        buttonText: "Melt pending",
      );
    }

    // No connection or pending incoming - show Melt and Message buttons
    return Row(
      children: [
        Expanded(
          child: BaseButton(
            loading: meltActionState.isLoading,
            onPressed: () => _handleMeltAction(
              connectionCount,
              user,
              currentUserDto,
            ),
            fontSize: 15,
            buttonText: "Melt",
          ),
        ),
        const Gap(12),
        Expanded(
          child: OutilineButton(
            onPressed: () => _handleMessageAction(user),
            fontSize: 15,
            buttonText: "Message",
          ),
        ),
      ],
    );
  }

  /// Handle melt action
  void _handleMeltAction(
    int connectionCount,
    user,
    currentUserDto,
  ) {
    if (currentUserDto != null && !(currentUserDto.profileUpdated ?? false)) {
      showDialog(
        context: context,
        builder: (context) {
          return const CustomDialog(content: ComplecteProfileDialog());
        },
      );
    } else if (connectionCount <= 10) {
      ref.read(meltActionProvider.notifier).meltUser(widget.userId);
    } else {
      showDialog(
        context: context,
        builder: (context) => CustomDialog(content: _meltLimitDialog()),
      );
    }
  }

  /// Handle send spark action
  void _handleSendSparkAction(user) {
    // Navigate to send spark screen with pre-selected user
    Navigator.pushNamed(
      context,
      AppRoutes.sendSpark,
      arguments: user,
    );
  }

  /// Handle message action (when not connected: send DM, recipient must accept to create connection)
  Future<void> _handleMessageAction(user) async {
    final currentUserId = ref.read(userStateProvider).user?.id;

    if (currentUserId == null) return;

    if (currentUserId == widget.userId) {
      if (mounted) {
        Fluttertoast.showToast(msg: 'You cannot message yourself');
      }
      return;
    }

    final userName = user.username ?? user.fullname ?? 'User';
    if (!mounted) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (dialogContext) => _ProfileDirectMessageDialog(
        userName: userName,
        recipientId: widget.userId,
        onCancel: () => Navigator.pop(dialogContext),
        onSent: () {
          Navigator.pop(dialogContext);
          Fluttertoast.showToast(
            msg: 'Message sent! They can accept to start chatting.',
          );
        },
      ),
    );
  }

  /// Build details tab - shows MetalDetailsTabNew if connected, otherwise UserDetailsTab
  Widget _buildDetailsTab({
    required user,
    required bool isConnected,
    required String connectionId,
    required String connectedOn,
    required bool isAnonymous,
  }) {
    return MetalDetailsTabNew(
      connectedOn: connectedOn,
      connectionId: connectionId,
      isConnected: isConnected,
      user: user,
      isAnonymous: isAnonymous,
    );
  }

  /// Melt limit dialog
  Widget _meltLimitDialog() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Gap(38),
        SvgPicture.asset(
          Assets.icons.meltedMetalsSmileyXEyes.path,
          height: 45,
          width: 45,
        ),
        const Gap(15),
        const TextView(
          text: "You are limited to a total of 10 Connection",
          fontSize: 20,
          fontWeight: FontWeight.w800,
          textAlign: TextAlign.center,
        ),
        const Gap(8),
        const TextView(
          text:
              "De-melt from previous connection to be able to connect to more metals",
          maxLines: 3,
          textAlign: TextAlign.center,
        ),
        const Gap(38),
        TextView(
          text: "Cancel",
          fontSize: 16,
          fontWeight: FontWeight.w500,
          onTap: () => Navigator.pop(context),
        ),
        const Gap(21),
      ],
    );
  }

  /// Show non-dismissible blocked user dialog
  void _showNonDismissibleBlockedDialog(context, user) {
    if (_hasShownBlockedDialog) return;
    _hasShownBlockedDialog = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: CustomDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(20),
              SvgPicture.asset(
                Assets.icons.meltedMetalsSmileyXEyes.path,
                height: 45,
                width: 45,
              ),
              const Gap(15),
              const TextView(
                text: "User Blocked",
                fontSize: 20,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.center,
              ),
              const Gap(16),
              TextView(
                text:
                    "You have blocked @${user.username ?? user.fullname ?? 'this user'}",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                textAlign: TextAlign.center,
              ),
              const Gap(8),
              const TextView(
                text:
                    "You will not see their content and they cannot interact with you. You need to unblock this user to view their profile or interact with them.",
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
                textAlign: TextAlign.center,
              ),
              const Gap(24),
              Row(
                children: [
                  Expanded(
                    child: OutilineButton(
                      buttonText: "Go Back",
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.dashboardPage,
                          (route) => false,
                        );
                      },
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: BaseButton(
                      buttonText: "Unblock User",
                      onPressed: () async {
                        final success = await ref
                            .read(blockedUsersViewModelProvider.notifier)
                            .unblockUser(userId: widget.userId);

                        if (success) {
                          // Refresh the blocked users list
                          await ref
                              .read(blockedUsersViewModelProvider.notifier)
                              .refreshBlockedUsers();
                          // Refresh the user profile to get updated status
                          ref
                              .read(userProfileViewModelProvider(widget.userId)
                                  .notifier)
                              .refresh();
                          Navigator.of(context).pop();
                          setState(() {
                            _hasShownBlockedDialog = false;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog for sending a direct message from profile (no connection until recipient accepts)
class _ProfileDirectMessageDialog extends ConsumerStatefulWidget {
  final String userName;
  final String recipientId;
  final VoidCallback onCancel;
  final VoidCallback onSent;

  const _ProfileDirectMessageDialog({
    required this.userName,
    required this.recipientId,
    required this.onCancel,
    required this.onSent,
  });

  @override
  ConsumerState<_ProfileDirectMessageDialog> createState() =>
      _ProfileDirectMessageDialogState();
}

class _ProfileDirectMessageDialogState
    extends ConsumerState<_ProfileDirectMessageDialog> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a message'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_isSending) return;

    setState(() => _isSending = true);

    try {
      final dataSource = ref.read(chatRemoteDataSourceProvider);
      await dataSource.sendDirectMessage(
        recipientId: widget.recipientId,
        message: message,
      );

      if (mounted) {
        widget.onSent();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: TextView(
                text: 'Message ${widget.userName}',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextView(
                text:
                    'Send a quick message. They can accept to start chatting.',
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Write your message...',
                  hintStyle: TextStyle(
                    color: Colors.grey.withOpacity(0.6),
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                maxLines: 4,
                maxLength: 500,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isSending ? null : widget.onCancel,
                      child: TextView(
                        text: 'Cancel',
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _isSending ? null : _handleSend,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _isSending
                              ? Colors.grey.shade300
                              : AppColors.metalPinkColour,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: _isSending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const TextView(
                                  text: 'Send Message',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
