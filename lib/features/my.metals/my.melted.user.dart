import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/core/utils/connection_helper.dart';
import 'package:metal/core/utils/constant/enums.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';

import 'package:metal/features/authentication/provider/metal.properties.notifier.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';
import 'package:metal/features/dashboard.dart/widget/complete.profile.dialog.dart';
import 'package:metal/features/thought/repositories/home.repository.dart';
import 'package:metal/features/thought/provider/check.melt.status.notifier.dart';
import 'package:metal/features/thought/provider/get.melt.users.notifier.dart';
import 'package:metal/features/thought/provider/get.user.notifier.dart';
import 'package:metal/features/thought/provider/melt.user.notifier.dart';
import 'package:metal/features/my.metals/metal.tabs/metal.details.dart';
import 'package:metal/features/settings/provider/get.blocked.user.notifier.dart';
import 'package:metal/features/settings/provider/block.user.notifier.dart';

import 'package:metal/features/profile/presentation/tab.screen/thought.tab.dart';
import 'package:metal/features/profile/presentation/widget/profile.header.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/button/outiline.button.dart';
import 'package:metal/widgets/button/plain.button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/tab/base.tab.dart';
import 'package:metal/widgets/text_views.dart';

class MyMeltedUser extends ConsumerStatefulWidget {
  const MyMeltedUser({super.key, required this.metalDetials});

  final Map<String, dynamic> metalDetials;

  @override
  ConsumerState<MyMeltedUser> createState() => _MyMeltedUserState();
}

class _MyMeltedUserState extends ConsumerState<MyMeltedUser> {
  UserModel? userData;
  bool _hasShownBlockedDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userData = ref.watch(userStateProvider).data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final checkMeltState =
        ref.watch(checkMeltProvider(widget.metalDetials["metalId"]));
    final connection = ref
        .watch(getMeltUserProvider.notifier)
        .getMeltUserById(widget.metalDetials["metalId"]);
    final connectionList = ref.watch(getMeltUserProvider).data;
    final myMelt = ref.watch(getUserProvider(widget.metalDetials["metalId"]));
    final meltState = ref.watch(meltUserProvider);

    // Check if the user is blocked
    final blockedUsers = ref.watch(getBlockUserProvider).data ?? [];
    final isUserBlocked = blockedUsers.any(
        (blockedUser) => blockedUser['id'] == widget.metalDetials["metalId"]);

    // Show non-dismissible blocked user dialog if user is blocked
    if (isUserBlocked && myMelt.data != null && !_hasShownBlockedDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNonDismissibleBlockedDialog(context, myMelt.data!);
      });
    }

    // Listen for successful melt action to navigate to meltMetal route
    ref.listen<MeltUsersState>(meltUserProvider, (prev, current) async {
      if (current.isSuccess && prev?.isLoading == true) {
        // Only navigate if melt was just completed (loading -> success)
        final connectionStatus = await ConnectionHelper(
          ref.read(homeRepositoryProvider),
        ).getConnectionStatus(userData!.id!, widget.metalDetials["metalId"]);

        if (connectionStatus) {
          Navigator.pushNamed(
            context,
            AppRoutes.meltMetal,
            arguments: widget.metalDetials["metalId"],
          );
        }
      }
    });

    return BaseScreen(
      Header: "Metal Profile",
      body: myMelt.isLoading
          ? const Center(child: CircularProgressIndicator())
          : myMelt.isError
              ? Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: _buildErrorSection(myMelt.errorMessage.toString(), () {
                    // Retry the request by refreshing the notifier
                    ref.invalidate(
                        getUserProvider(widget.metalDetials["metalId"]));
                  }),
                )
              : ProfileHeader(
                  eye: false,
                  metalId: myMelt.data!.metal!,
                  profileUrl: connection != null
                      ? connection.isAnonymous
                          ? null
                          : myMelt.data!.profilePhoto
                      : null,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 110, left: 20, right: 20),
                    child: Container(
                      padding: const EdgeInsets.only(
                        top: 122,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.metalWhite,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(35),
                          topRight: Radius.circular(35),
                        ),
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => CustomDialog(
                                    content: _buildDialog(user: myMelt.data!)),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: ShapeDecoration(
                                color: const Color(0x0CD9197B),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                              child: Column(
                                children: [
                                  TextView(
                                    text:  
                                         "@${myMelt.data!.username} ",
                                    fontWeight: FontWeight.bold,
                                  ),
                                  const Gap(5),
                                  TextView(
                                    text: myMelt.data?.location != null
                                        ? myMelt.data!.location?.address ?? ""
                                        : "No Address Found",
                                    fontWeight: FontWeight.w400,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Gap(20),
                          _buildMeltActionSection(
                            checkMeltState,
                            meltState,
                            context,
                            connectionList?.length ?? 0,
                            myMelt.data,
                          ),
                          const Gap(10),
                          BaseTab(
                            tabs: [
                              BaseTabModel(
                                  child: MyThoughtTab(
                                    id: myMelt.data!.id,
                                    toughtID: widget.metalDetials["toughtId"],
                                  ),
                                  title: 'Metal Thought'),
                              BaseTabModel(
                                child: MetalDetailsTab(
                                  connectedOn: connection?.connectedOn ?? '',
                                  connectionModel:
                                      connection?.connectionId ?? '',
                                  melted: checkMeltState.data ==
                                      MeltRequestState.connected,
                                  userModel: myMelt.data ?? UserModel(),
                                  isUnmelted: connection?.isAnonymous == false,
                                ),
                                title: 'Metal Details ',
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

  // Widget to handle and display error with retry button
  Widget _buildErrorSection(String errorMessage, VoidCallback onRetry) {
    return Center(
      child: Column(
        children: [
          const Gap(10),
          Assets.gifs.error.image(),
          const Gap(30),
          const TextView(
            text: "Error ",
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

  // Widget to handle melt-related actions
  Widget _buildMeltActionSection(
      BaseState<MeltRequestState> checkMeltState,
      MeltUsersState meltState,
      BuildContext context,
      int connectionInt,
      UserModel? recipient) {
    if (checkMeltState.data == MeltRequestState.pending) {
      return PlainButton(
        loading: meltState.isLoading,
        onPressed: () {},
        fontSize: 15,
        color: AppColors.metalPinkColour40,
        buttonText: "Melt",
      );
    } else if (checkMeltState.data == MeltRequestState.connected) {
      return Row(
        children: [
          Expanded(
            child: BaseButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.sendSpark,
                    arguments: recipient);
              },
              fontSize: 15,
              buttonText: "Send Spark",
            ),
          ),
          const Gap(30),
          Expanded(
            child: OutilineButton(
              onPressed: () {
                final connection = ref
                    .read(getMeltUserProvider.notifier)
                    .getMeltUserById(widget.metalDetials["metalId"]);
                if (connection != null) {
                  Navigator.pushNamed(context, AppRoutes.chatWindowsPage,
                      arguments: connection.connectionId);
                }
              },
              fontSize: 15,
              buttonText: "Message",
            ),
          ),
        ],
      );
    } else {
      return BaseButton(
        loading: meltState.isLoading,
        onPressed: () {
          if (userData != null && !(userData!.completedProfile ?? false)) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const CustomDialog(
                  content: ComplecteProfileDialog(),
                );
              },
            );
          } else if (connectionInt <= 10) {
            ref
                .read(meltUserProvider.notifier)
                .meltUser(widget.metalDetials["metalId"]);
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) =>
                  CustomDialog(content: _meltLimitDialog()),
            );
          }
        },
        fontSize: 15,
        buttonText: "Melt",
      );
    }
  }

  Widget _buildDialog({required UserModel user}) {
    final getMetalProperties = ref.watch(metalPropertiesProvider);

    final metal = getMetalProperties.data!.metals!.firstWhere(
      (element) => element.id == user.metal,
      orElse: () => getMetalProperties
          .data!.metals![0], // Fallback in case no match is found
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
          text: metal
              .desc, // Assuming `description` contains details about the metal
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
              "De-melt from previous connection to be able to connect to more metals", // Assuming `description` contains details about the metal
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
      barrierDismissible: false, // Make it non-dismissible
      builder: (context) => WillPopScope(
        onWillPop: () async => false, // Prevent back button dismissal
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
                            context, AppRoutes.dashboardPage, (route) => false);
                      },
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: BaseButton(
                      buttonText: "Unblock User",
                      onPressed: () {
                        ref.read(blockUserProvider.notifier).unBlockUser(
                              widget.metalDetials["metalId"],
                            );
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
