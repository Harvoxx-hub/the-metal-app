import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/services/firebase.service.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/chat/presentation/chat.window/chat.window.dart';
import 'package:metal/features/home_page/domain/entries/all.user.model.dart';
import 'package:metal/features/home_page/melt.metal.dart';
import 'package:metal/features/home_page/provider/get.melt.users.notifier.dart';
import 'package:metal/features/home_page/provider/get.user.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/my.metals/user.profile.dart';
import 'package:metal/features/profile/profile.page.dart';
import 'package:metal/features/profile/widget/edit.field.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/zim.manager/zim.notifier.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

class MyMeltedUser extends ConsumerWidget {
  const MyMeltedUser(this.UserId, {super.key});
  static const name = 'meltedUserPage';
  static const route = '$name';
  final String UserId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myMelt = ref.watch(getUserProvider(UserId));
    final userData = ref.watch(authProvider);

    return BaseScreen(
      Header: "My melted metals",
      body: ProfileHeader(
          user: myMelt.data ?? UserModel(),
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
              child: myMelt.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
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
                                text: "Go to Felix metal profile",
                                ontap: () {
                                  Navigator.pushNamed(context,  AppRoutes.upgradePage, arguments: myMelt.data);
                                
                                },
                                floatingLabel: " View profile",
                                sufixIcon: SvgPicture.asset(
                                  Assets.icons.meltedMetalsArrowUpRight.path,
                                  height: 21,
                                  width: 21,
                                ),
                              ),
                              Gap(20),
                              EditField(
                                text: "Send and receive messages ",
                                ontap: () {
                                                    Navigator.pushNamed(context, AppRoutes.chatWindowsPage, arguments: myMelt.data!.phone
                );
 
                         
                                },
                                floatingLabel: "Start a conversation",
                                sufixIcon: Image.asset(
                                  Assets.images.inactiveMessage.path,
                                  height: 21,
                                  width: 21,
                                ),
                              ),
                              Gap(20),
                              EditField(
                                text: "De-melt Felix from your metal list",
                                onSubLabel: () {},
                                floatingLabel: "Remove from my list of metals",
                                sufixIcon: SvgPicture.asset(
                                  Assets.icons.meltedMetalsTrash01.path,
                                  height: 21,
                                  width: 21,
                                ),
                                ontap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CustomDialog(
                                          content: _ceMeltDialog(context));
                                    },
                                  );
                                },
                              ),
                              Gap(20),
                              EditField(
                                text: "Block Felix from reaching you",
                                onSubLabel: () {},
                                floatingLabel: "Block from viewing my profile",
                                ontap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CustomDialog(
                                          content: _blockDialog(context));
                                    },
                                  );
                                },
                                sufixIcon: SvgPicture.asset(
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

  Widget _blockDialog(BuildContext context) {
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
          text: "Block Felix_aluminium",
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
        BaseButton(buttonText: "Block Felix_aluminium", onPressed: () {}),
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

  Widget _ceMeltDialog(BuildContext context) {
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
          text: "De-melt Felix_aluminium",
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
        BaseButton(buttonText: "De-melt Felix_aluminium", onPressed: () {}),
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
