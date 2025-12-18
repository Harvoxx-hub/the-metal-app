import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/data/models/user_model.dart';
import 'package:metal/presentation/viewmodels/profile/metal_properties_provider.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/presentation/views/dashboard/widgets/complete.profile.dialog.dart';
import 'package:metal/presentation/viewmodels/connection/connection_providers.dart';
import 'package:metal/presentation/viewmodels/connection/melt_viewmodel.dart';
import 'package:metal/features/thought/provider/get.user.notifier.dart';
import 'package:metal/features/chat/data/repositories/message.repository.dart';
import 'package:metal/presentation/views/connection/widgets/metal_details_tab.dart';
import 'package:metal/features/settings/provider/get.blocked.user.notifier.dart';
import 'package:metal/features/settings/provider/block.user.notifier.dart';
import 'package:metal/features/profile/presentation/tab.screen/thought.tab.dart';
import 'package:metal/presentation/widgets/profile/profile_header.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/button/outiline.button.dart';
import 'package:metal/widgets/button/plain.button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/tab/base.tab.dart';
import 'package:metal/widgets/text_views.dart';

/// Screen displaying details of a connection/melt
class ConnectionDetailScreen extends ConsumerStatefulWidget {
  const ConnectionDetailScreen({super.key, required this.metalDetails});

  final Map<String, dynamic> metalDetails;

  static const name = 'connectionDetailPage';
  static const route = name;

  @override
  ConsumerState<ConnectionDetailScreen> createState() =>
      _ConnectionDetailScreenState();
}

class _ConnectionDetailScreenState
    extends ConsumerState<ConnectionDetailScreen> {
  UserModel? userData;
  bool _hasShownBlockedDialog = false;

  String get metalId => widget.metalDetails["metalId"] ?? '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userDto = ref.watch(userStateProvider).user;
      if (userDto != null) {
        userData = UserModel(
          id: userDto.id,
          email: userDto.email,
          completedProfile: userDto.profileUpdated,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch melt status using the new API-based provider
    final meltStatusState = ref.watch(meltStatusProvider(metalId));
    final meltActionState = ref.watch(meltActionProvider);

    // Get connection from the centralized connection list
    final connectionState = ref.watch(connectionViewModelProvider);
    final connection = ref.read(connectionViewModelProvider.notifier)
        .getConnectionByUserId(metalId);

    // Get user data (still using the existing provider for now)
    final userState = ref.watch(getUserProvider(metalId));

    // Check if the user is blocked
    final blockedUsers = ref.watch(getBlockUserProvider).data ?? [];
    final isUserBlocked =
        blockedUsers.any((blockedUser) => blockedUser['id'] == metalId);

    // Show non-dismissible blocked user dialog if user is blocked
    if (isUserBlocked && userState.data != null && !_hasShownBlockedDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNonDismissibleBlockedDialog(context, userState.data!);
      });
    }

    // Listen for successful melt action to navigate
    ref.listen<MeltActionState>(meltActionProvider, (prev, current) async {
      if (current.isSuccess && prev?.isLoading == true) {
        // If melt resulted in a connection, navigate to meltMetal route
        if (current.response?.status == 'connected') {
          Navigator.pushNamed(
            context,
            AppRoutes.meltMetal,
            arguments: metalId,
          );
        }
        // Refresh melt status and connections
        ref.invalidate(meltStatusProvider(metalId));
        ref.read(connectionViewModelProvider.notifier).refresh();
      }
    });

    return BaseScreen(
      Header: "Metal Profile",
      body: userState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : userState.isError
              ? Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: _buildErrorSection(
                    userState.errorMessage.toString(),
                    () => ref.invalidate(getUserProvider(metalId)),
                  ),
                )
              : ProfileHeader(
                  eye: false,
                  metalId: userState.data!.metal!,
                  profileUrl: connection != null
                      ? connection.isAnonymous
                          ? null
                          : userState.data!.profilePhoto
                      : null,
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
                        children: [
                          _buildUserInfoSection(userState.data!),
                          const Gap(20),
                          _buildMeltActionSection(
                            meltStatusState,
                            meltActionState,
                            context,
                            connectionState.connections.length,
                            userState.data,
                          ),
                          const Gap(10),
                          BaseTab(
                            tabs: [
                              BaseTabModel(
                                child: MyThoughtTab(
                                  id: userState.data!.id,
                                  toughtID: widget.metalDetails["toughtId"],
                                ),
                                title: 'Metal Thought',
                              ),
                              BaseTabModel(
                                child: MetalDetailsTabNew(
                                  connectedOn: connection?.connectedOn ?? '',
                                  connectionId: connection?.id ?? '',
                                  isConnected: meltStatusState.isConnected,
                                  userModel: userState.data ?? UserModel(id: '', email: ''),
                                  isAnonymous: connection?.isAnonymous ?? true,
                                ),
                                title: 'Metal Details',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildUserInfoSection(UserModel user) {
    final getMetalProperties = ref.watch(metalPropertiesProvider);

    return GestureDetector(
      onTap: () {
        if (getMetalProperties.data?.metals != null) {
          showDialog(
            context: context,
            builder: (BuildContext context) => CustomDialog(
              content: _buildMetalDialog(user: user),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: ShapeDecoration(
          color: const Color(0x0CD9197B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: Column(
          children: [
            TextView(
              text: "@${user.username} ",
              fontWeight: FontWeight.bold,
            ),
            const Gap(5),
            TextView(
              text: user.location?.address ?? "",
              fontWeight: FontWeight.w400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeltActionSection(
    MeltStatusState meltStatusState,
    MeltActionState meltActionState,
    BuildContext context,
    int connectionCount,
    UserModel? recipient,
  ) {
    // Pending state - show disabled melt button
    if (meltStatusState.isPending) {
      return PlainButton(
        loading: meltActionState.isLoading,
        onPressed: () {},
        fontSize: 15,
        color: AppColors.metalPinkColour40,
        buttonText: "Melt",
      );
    }

    // Connected state - show Send Spark and Message buttons
    if (meltStatusState.isConnected) {
      return Row(
        children: [
          Expanded(
            child: BaseButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.sendSpark,
                  arguments: recipient,
                );
              },
              fontSize: 15,
              buttonText: "Send Spark",
            ),
          ),
          const Gap(30),
          Expanded(
            child: OutilineButton(
              onPressed: () {
                final connectionId = meltStatusState.status?.connectionId;
                if (connectionId != null) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.chatWindowsPage,
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

    // No connection - show Melt and Message buttons
    return Row(
      children: [
        Expanded(
          child: BaseButton(
            loading: meltActionState.isLoading,
            onPressed: () => _handleMeltAction(connectionCount, recipient),
            fontSize: 15,
            buttonText: "Melt",
          ),
        ),
        const Gap(12),
        Expanded(
          child: OutilineButton(
            onPressed: () => _handleMessageAction(recipient),
            fontSize: 15,
            buttonText: "Message",
          ),
        ),
      ],
    );
  }

  void _handleMeltAction(int connectionCount, UserModel? recipient) {
    if (userData != null && !(userData!.completedProfile ?? false)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const CustomDialog(content: ComplecteProfileDialog());
        },
      );
    } else if (connectionCount <= 10) {
      ref.read(meltActionProvider.notifier).meltUser(metalId);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) =>
            CustomDialog(content: _meltLimitDialog()),
      );
    }
  }

  Future<void> _handleMessageAction(UserModel? recipient) async {
    final currentUserId = userData?.id;
    final recipientId = recipient?.id;

    if (currentUserId == null || recipientId == null) return;

    if (currentUserId == recipientId) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You cannot message yourself'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Show loading dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.metalPinkColour,
                  ),
                ),
                SizedBox(height: 16),
                TextView(
                  text: 'Opening chat...',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final messageRepository = ref.read(messageRepositoryProvider);
      final connectionId = await messageRepository
          .createOrGetConnectionForDirectMessage(
        senderId: currentUserId,
        recipientId: recipientId,
      );

      if (connectionId.isEmpty) {
        throw Exception('Failed to create connection');
      }

      // Refresh connections
      ref.read(connectionViewModelProvider.notifier).refresh();
      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      if (!mounted) return;
      Navigator.pushNamed(
        context,
        AppRoutes.chatWindowsPage,
        arguments: connectionId,
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to open chat: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildErrorSection(String errorMessage, VoidCallback onRetry) {
    return Center(
      child: Column(
        children: [
          const Gap(10),
          Assets.gifs.error.image(),
          const Gap(30),
          const TextView(
            text: "Error",
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          const Gap(10),
          const TextView(
            text: "Connection Could not be made",
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          const Gap(10),
          OutilineButton(
            buttonText: "Try Again",
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }

  Widget _buildMetalDialog({required UserModel user}) {
    final getMetalProperties = ref.watch(metalPropertiesProvider);

    final metal = getMetalProperties.data!.metals!.firstWhere(
      (element) => element.id == user.metal,
      orElse: () => getMetalProperties.data!.metals![0],
    );

    return Column(
      children: [
        const Gap(38),
        SvgPicture.asset(
          Assets.icons.meltedMetalsSmileyXEyes.path,
          height: 45,
          width: 45,
        ),
        const Gap(15),
        TextView(
          text: metal.title,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        const Gap(8),
        TextView(
          text: metal.desc,
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

  void _showNonDismissibleBlockedDialog(
      BuildContext context, UserModel blockedUser) {
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
                    "You have blocked @${blockedUser.username ?? 'this user'}",
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
                      onPressed: () {
                        ref
                            .read(blockUserProvider.notifier)
                            .unBlockUser(metalId);
                        Navigator.of(context).pop();
                        setState(() {
                          _hasShownBlockedDialog = false;
                        });
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
