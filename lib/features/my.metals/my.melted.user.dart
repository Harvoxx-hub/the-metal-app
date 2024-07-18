import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gap/gap.dart';

import 'package:metal/base/page/base_page_state.dart';

import 'package:metal/features/chat/presentation/chat.window/chat.window.argument.dart';

import 'package:metal/features/home_page/domain/entries/melt.user.model.dart';

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

import 'package:metal/widgets/tab/base.tab.dart';
import 'package:metal/widgets/text_views.dart';

class MyMeltedUser extends ConsumerStatefulWidget {
  const MyMeltedUser({super.key, required this.meltedUserAgurment});

  final MeltedUserAgurment meltedUserAgurment;

  @override
  ConsumerState<MyMeltedUser> createState() => _MyMeltedUserState();
}

class _MyMeltedUserState extends ConsumerState<MyMeltedUser> {
  bool melted = false;
  @override
  void initState() {
    // TODO: implement initState
    melted = widget.meltedUserAgurment.melted;
    super.initState();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final myMelt = ref.watch(getUserProvider(widget.meltedUserAgurment.userId));
    final meltState = ref.watch(meltUserProvider(widget.meltedUserAgurment.userId));
    ref.listen<MeltUsersState>(meltUserProvider(widget.meltedUserAgurment.userId),
        (prev, current) {
      if (current.isSuccess) {
        melted = true;
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
                      !melted
                          ? BaseButton(
                              loading: meltState.isLoading,
                              onPressed: () {
                                ref
                                    .read(meltUserProvider(widget.meltedUserAgurment.userId)
                                        .notifier)
                                    .meltUser();
                              },
                              fontSize: 15,
                              buttonText: "Metal",
                            )
                          : Row(
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
                                      Navigator.pushNamed(
                                          context, AppRoutes.chatWindowsPage,
                                          arguments: ChatWindowArgument(
                                            user: MeltUserModel(
                                                gender: myMelt.data!.gender,
                                                name: myMelt.data!.username,
                                                metal: myMelt.data!.metal,
                                                phone: myMelt.data!.phone,
                                                id: myMelt.data!.id),
                                          ));
                                    },
                                    fontSize: 15,
                                    buttonText: "Message",
                                  ),
                                ),
                              ],
                            ),
                      Gap(10),
                      BaseTab(
                        tabs: [
                          BaseTabModel(
                              child: MyThoughtTab(id: myMelt.data!.id),
                              title: 'Metal Thought'),
                          BaseTabModel(
                              child: MetalDetailsTab(
                                melted: melted,
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
