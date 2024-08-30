import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gap/gap.dart';

import 'package:metal/base/page/base_page_state.dart';

import 'package:metal/features/chat/presentation/chat.window/chat.window.argument.dart';

import 'package:metal/features/home_page/domain/entries/melt.user.model.dart';
import 'package:metal/features/home_page/provider/check.melt.status.notifier.dart';

import 'package:metal/features/home_page/provider/get.user.notifier.dart';
import 'package:metal/features/home_page/provider/melt.user.notifier.dart';
import 'package:metal/features/my.metals/melted.user.agurment.dart';
import 'package:metal/features/my.metals/metal.tabs/metal.details.dart';

import 'package:metal/features/profile/presentation/tab.screen/thought.tab.dart';
import 'package:metal/features/profile/presentation/widget/profile.header.dart';

import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';

import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/button/outiline.button.dart';
import 'package:metal/widgets/button/plain.button.dart';

import 'package:metal/widgets/tab/base.tab.dart';
import 'package:metal/widgets/text_views.dart';

//enum meltState//
class MyMeltedUser extends ConsumerStatefulWidget {
  const MyMeltedUser({super.key, required this.meltedUserAgurment});

  final MeltedUserAgurment meltedUserAgurment;

  @override
  ConsumerState<MyMeltedUser> createState() => _MyMeltedUserState();
}

class _MyMeltedUserState extends ConsumerState<MyMeltedUser> {
  String? conversationId;
  @override
  void initState() {
    // TODO: implement initState

    conversationId = widget.meltedUserAgurment.conversationID.isEmpty
        ? null
        : widget.meltedUserAgurment.conversationID;
    super.initState();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final checkMeltState =
        ref.watch(checkMeltProvider(widget.meltedUserAgurment.userId));

    final myMelt = ref.watch(getUserProvider(widget.meltedUserAgurment.userId));
    final meltState = ref.watch(meltUserProvider);
    ref.listen<MeltUsersState>(meltUserProvider, (prev, current) {
      if (current.isSuccess) {
        ref
            .read(checkMeltProvider(widget.meltedUserAgurment.userId).notifier)
            .checkStatus();
        conversationId = current.data!["conversationId"];
        setState(() {});
      }
    });
    return BaseScreen(
      Header: "Metal Profile",
      body: myMelt.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ProfileHeader(
              eye: false,
              metal: myMelt.data!.metal!,
              child: Padding(
                padding: const EdgeInsets.only(top: 110, left: 20, right: 20),
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
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: ShapeDecoration(
                          color: const Color(0x0CD9197B),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                        ),
                        child: TextView(text: "@${myMelt.data!.username}"),
                      ),
                      Gap(20),
                      checkMeltState.isLoading
                          ? CircularProgressIndicator()
                          : checkMeltState.data == "⁠⁠melt-requested"
                              ? PlainButton(
                                  enabled: false,
                                  loading: meltState.isLoading,
                                  onPressed: () {
                                    // ref
                                    //     .read(meltUserProvider.notifier)
                                    //     .meltUser(widget.meltedUserAgurment.userId);
                                  },
                                  fontSize: 15,
                                  textColor: Colors.grey,
                                  buttonText: "Melt Requested",
                                )
                              : checkMeltState.data == "mutual"
                                  ? Row(
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
                                        Gap(30),
                                        Expanded(
                                          child: OutilineButton(
                                            onPressed: () {
                                              Navigator.pushNamed(context,
                                                  AppRoutes.chatWindowsPage,
                                                  arguments: ChatWindowArgument(
                                                    user: MeltUserModel(
                                                        gender:
                                                            myMelt.data!.gender,
                                                        name: myMelt
                                                            .data!.username,
                                                        username: myMelt
                                                            .data!.username,
                                                        fcmToken: myMelt
                                                            .data!.fcmToken,
                                                        conversationId:
                                                            conversationId!,
                                                        metal:
                                                            myMelt.data!.metal,
                                                        phone:
                                                            myMelt.data!.phone,
                                                        id: myMelt.data!.id),
                                                  ));
                                            },
                                            fontSize: 15,
                                            buttonText: "Message",
                                          ),
                                        ),
                                      ],
                                    )
                                  : BaseButton(
                                      loading: meltState.isLoading,
                                      onPressed: () {
                                        ref
                                            .read(meltUserProvider.notifier)
                                            .meltUser(widget
                                                .meltedUserAgurment.userId);
                                      },
                                      fontSize: 15,
                                      buttonText: "Melt",
                                    ),
                      Gap(10),
                      BaseTab(
                        tabs: [
                          BaseTabModel(
                              child: MyThoughtTab(id: myMelt.data!.id),
                              title: 'Metal Thought'),
                          BaseTabModel(
                              child: MetalDetailsTab(
                                melted: checkMeltState.data == "mutual",
                                userModel: myMelt.data!,
                              ),
                              title: 'Metal Details '),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
    );
  }
}
