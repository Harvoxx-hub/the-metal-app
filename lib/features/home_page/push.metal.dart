import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';

import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/core/utils/screen.size.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';

import 'package:metal/features/home_page/domain/entries/all.user.model.dart';
import 'package:metal/features/home_page/provider/get.all.users.notifier.dart';
import 'package:metal/features/home_page/provider/push.user.notifier.dart';
import 'package:metal/gen/assets.gen.dart';

import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';

import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/button/outiline.button.dart';
import 'package:metal/widgets/text_views.dart';

class PushMetal extends ConsumerWidget {
  const PushMetal({super.key, required this.user});
  static const name = 'pushMetal';
  static const route = name;

  final ALLUserModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final push = ref.watch(pushUserProvider);
    final userData = ref.watch(authProvider);

    ref.listen<PushUsersState>(pushUserProvider, (prev, current) {
      if (current.isSuccess) {
        ref.read(getAllUserProvider.notifier).removeUser(user.id!);
        Fluttertoast.showToast(
          msg: "Your Profile has been pushed to @${user.username}",
        );
        Navigator.pop(context);
      }
    });
    return BaseScreen(
        appBarState: AppBarState.BackWithHeader,
        Header: "Push profile",
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                        color: AppColors.metalPinkColour,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(35),
                          bottomRight: Radius.circular(35),
                        )),
                  ),

                  // This container is for the background image decoration
                  Container()
                ],
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                        color: AppColors.metalWhite,
                        borderRadius: BorderRadius.circular(13)),
                    child: Column(
                      children: [
                        const Gap(28),
                        Image.asset(Assets.images.pushMelt.path),
                        const Gap(20),
                        TextView(
                          textAlign: TextAlign.center,
                          text: "Push my profile to \n @${user.username}",
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        const Gap(16),
                        SizedBox(
                          width: 288,
                          child: TextView(
                            text:
                                "Pushing would get your profile noticed by @ ${user.username}t. You will be ranked top in her dashboard view, which indicates that you are ready to melt!",
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Gap(19),
                        const TextView(
                          text:
                              "Push is a paid feature and it is \nfor a specific metal per time",
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          textAlign: TextAlign.center,
                        ),
                        const Gap(29),
                        Container(
                          width: 200,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              color: AppColors.metalTabBg,
                              borderRadius: BorderRadius.circular(5)),
                          child: Column(
                            children: [
                              const TextView(
                                text: "Price per push",
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              const Gap(8),
                              const TextView(
                                text: "2.00 Spark",
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                              const Gap(8),
                              TextView(
                                text:
                                    "Balance Spark: ${userData.data!.sparkBalance!} ",
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                              )
                            ],
                          ),
                        ),
                        Gap(getDeviceHeight(context) * 0.1),
                        BaseButton(
                          loading: push.isLoading,
                          buttonText: "Pay to Push",
                          onPressed: () {
                            print(userData.data!.sparkBalance!);
                            userData.data!.sparkBalance! >= 2.0
                                ? ref
                                    .read(pushUserProvider.notifier)
                                    .pushUser(user.id!)
                                : Fluttertoast.showToast(
                                    msg:
                                        "Spark Balance is low, refer to earn sparks",
                                  );
                          },
                        ),
                        const Gap(16),
                        OutilineButton(
                          buttonText: "Melt for free",
                          onPressed: () {
                            !user.pushedMe
                                ? {
                                    ref
                                        .read(getAllUserProvider.notifier)
                                        .removeUser(user.id!),
                                    Navigator.pop(context)
                                  }
                                : Navigator.pushNamed(
                                    context,
                                    AppRoutes.meltMetal,
                                    arguments: user,
                                  );
                          },
                        ),
                      ],
                    ),
                  ))
            ],
          ),
        ));
  }
}
