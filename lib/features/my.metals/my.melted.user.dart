import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import 'package:gap/gap.dart';

import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/core/utils/constant/enums.dart';

import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/metal.properties.notifier.dart';
import 'package:metal/features/home_page/provider/check.melt.status.notifier.dart';

import 'package:metal/features/home_page/provider/get.user.notifier.dart';
import 'package:metal/features/home_page/provider/melt.user.notifier.dart';

import 'package:metal/features/my.metals/metal.tabs/metal.details.dart';

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
  const MyMeltedUser({super.key, required this.metalId});

  final String metalId;

  @override
  ConsumerState<MyMeltedUser> createState() => _MyMeltedUserState();
}

class _MyMeltedUserState extends ConsumerState<MyMeltedUser> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final checkMeltState = ref.watch(checkMeltProvider(widget.metalId));

    final myMelt = ref.watch(getUserProvider(widget.metalId));
    final meltState = ref.watch(meltUserProvider);

    ref.listen<CheckMeltState>(checkMeltProvider(widget.metalId),
        (prev, current) {
      if (current.isSuccess) {
        if (meltState.isSuccess && current.data == MeltRequestState.mutual) {
          Navigator.pushNamed(
            context,
            AppRoutes.meltMetal,
            arguments: widget.metalId,
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
                    ref.refresh(getUserProvider(widget.metalId));
                  }),
                )
              : ProfileHeader(
                  eye: false,
                  metalId: myMelt.data!.metal!,
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
                              topRight: Radius.circular(35))),
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
                              child:
                                  TextView(text: "@${myMelt.data!.username} "),
                            ),
                          ),
                          const Gap(20),
                          _buildMeltActionSection(
                              checkMeltState, meltState, context),
                          const Gap(10),
                          BaseTab(
                            tabs: [
                              BaseTabModel(
                                  child: MyThoughtTab(id: myMelt.data!.id),
                                  title: 'Metal Thought'),
                              BaseTabModel(
                                  child: MetalDetailsTab(
                                    melted: checkMeltState.data ==
                                        MeltRequestState.mutual,
                                    userModel: myMelt.data!,
                                  ),
                                  title: 'Metal Details '),
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
  Widget _buildMeltActionSection(BaseState<MeltRequestState> checkMeltState,
      MeltUsersState meltState, BuildContext context) {
    if (checkMeltState.data == MeltRequestState.pending) {
      return PlainButton(
        enabled: false,
        loading: meltState.isLoading,
        onPressed: null,
        fontSize: 15,
        textColor: Colors.grey,
        buttonText: "Melt Requested",
      );
    } else if (checkMeltState.data == MeltRequestState.mutual) {
      return Row(
        children: [
          Expanded(
            child: BaseButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.sendSpark,
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
                Navigator.pushNamed(context, AppRoutes.chatWindowsPage,
                    arguments: widget.metalId);
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
          ref.read(meltUserProvider.notifier).meltUser(widget.metalId);
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
}
