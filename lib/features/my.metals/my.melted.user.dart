import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';

import 'package:metal/features/chat/presentation/chat.window/chat.window.argument.dart';

import 'package:metal/features/home_page/domain/entries/melt.user.model.dart';

import 'package:metal/features/home_page/provider/get.user.notifier.dart';
import 'package:metal/features/my.metals/provider/unmelt.user.notifier.dart';
import 'package:metal/features/profile/presentation/widget/profile.header.dart';
import 'package:metal/features/settings/provider/block.user.notifier.dart';
import 'package:metal/gen/assets.gen.dart';

import 'package:metal/features/profile/presentation/profile.page.dart';
import 'package:metal/features/profile/presentation/widget/edit.field.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/text_views.dart';

class MyMeltedUser extends ConsumerWidget {
  const MyMeltedUser(this.UserId, {super.key});

  final String UserId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myMelt = ref.watch(getUserProvider(UserId));

    return BaseScreen(
      Header: "My melted metals",
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
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: ShapeDecoration(
                                color: Color(0x0CD9197B),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                              child:
                                  TextView(text: "@${myMelt.data!.username}"),
                            ),
                            Gap(40),
                            EditField(
                              text:
                                  "Go to ${myMelt.data!.username} metal profile",
                              onTap: () {
                                Navigator.pushNamed(
                                    context, AppRoutes.userProfilePage,
                                    arguments: myMelt.data);
                              },
                              floatingLabel: " View profile",
                              suffixIcon: SvgPicture.asset(
                                Assets.icons.meltedMetalsArrowUpRight.path,
                                height: 21,
                                width: 21,
                              ),
                            ),
                            Gap(20),
                            EditField(
                              text: "Send and receive messages ",
                              onTap: () {
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
                              floatingLabel: "Start a conversation",
                              suffixIcon: Image.asset(
                                Assets.images.inactiveMessage.path,
                                height: 21,
                                width: 21,
                              ),
                            ),
                            Gap(20),
                            EditField(
                              text:
                                  "De-melt ${myMelt.data!.username}  from your metal list",
                              floatingLabel: "Remove from my list of metals",
                              suffixIcon: SvgPicture.asset(
                                Assets.icons.meltedMetalsTrash01.path,
                                height: 21,
                                width: 21,
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CustomDialog(
                                        content: _ceMeltDialog(
                                            context, myMelt.data!, ref));
                                  },
                                );
                              },
                            ),
                            Gap(20),
                            EditField(
                              text:
                                  "Block ${myMelt.data!.username}  from reaching you",
                              floatingLabel: "Block from viewing my profile",
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CustomDialog(
                                        content: _blockDialog(
                                            context, myMelt.data!, ref));
                                  },
                                );
                              },
                              suffixIcon: SvgPicture.asset(
                                Assets.icons.meltedMetalsSmileyXEyes.path,
                                height: 21,
                                width: 21,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )),
    );
  }

  Widget _blockDialog(BuildContext context, UserModel data, WidgetRef ref) {
    return Column(
      children: [
        Gap(38.h),
        SvgPicture.asset(
          Assets.icons.meltedMetalsSmileyXEyes.path,
          height: 45,
          width: 45,
        ),
        Gap(15.h),
        TextView(
          text: "Block  ${data.username} ",
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        Gap(15.h),
        TextView(
          text:
              "Blocked metals cannot call or send you messages. This Metal will not be notified",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        Gap(38.h),
        BaseButton(
            buttonText: "Block  ${data.username}",
            onPressed: () {
              ref
                  .read(blockUserProvider.notifier)
                  .BlockUser(data.username!, data.id!);
              Navigator.pop(context);
              Navigator.pop(context);
            }),
        Gap(23.h),
        TextView(
          text: "Cancel",
          fontSize: 16,
          fontWeight: FontWeight.w500,
          onTap: () => Navigator.pop(context),
        ),
        Gap(21.h),
      ],
    );
  }

  Widget _ceMeltDialog(BuildContext context, UserModel data, WidgetRef ref) {
    // ref.watch(unmeltUserProvider(data.id!));
    return Column(
      children: [
        Gap(38.h),
        SvgPicture.asset(
          Assets.icons.meltedMetalsTrash01.path,
          height: 45,
          width: 45,
        ),
        Gap(15.h),
        TextView(
          text: "De-melt  ${data.username}",
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        Gap(15.h),
        TextView(
          text: "De-melted metals will have to request to melt with you again",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        Gap(38.h),
        BaseButton(
            buttonText: "De-melt  ${data.username}",
            onPressed: () {
              ref.read(unmeltUserProvider(data.id!));
              Navigator.pop(context);
              Navigator.pop(context);
            }),
        Gap(23.h),
        TextView(
          text: "Cancel",
          fontSize: 16,
          fontWeight: FontWeight.w500,
          onTap: () => Navigator.pop(context),
        ),
        Gap(21.h),
      ],
    );
  }
}
