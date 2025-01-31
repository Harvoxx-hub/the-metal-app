import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/core/services/auth.pref.service.dart';
import 'package:metal/core/utils/input/validators/validators.dart';
import 'package:metal/features/profile/provider/delete.user.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/button/plain.button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class DeleteScreen extends ConsumerWidget {
  DeleteScreen({super.key});
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<DeleteUsersState>(deleteUserProvider, (prev, current) {
      if (current.isSuccess) {
        AuthManager.deleteAccessToken();
        AuthManager.deleteLoginState();
        AuthManager.deleteRefreshToken();

        // ZegoUIKitPrebuiltCallInvitationService().uninit();
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.onboarding, (route) => false);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialog(
              content: DeleteConfrim(context),
            );
          },
        );
      }
    });
    return BaseScreen(
      appBarState: AppBarState.BackWithHeader,
      Header: "Delete your account",
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0.00, -1.00),
                        end: Alignment(0, 1),
                        colors: [Color(0xFFDB217A), Color(0xFFF00E3E)],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(35),
                        bottomRight: Radius.circular(35),
                      )),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 24.0, right: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 29, left: 9, right: 9),
              child: Container(
                padding: const EdgeInsets.only(top: 55, left: 22, right: 22),
                decoration: const BoxDecoration(
                    color: AppColors.metalWhite,
                    borderRadius: BorderRadius.all(
                      Radius.circular(35),
                    )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Assets.icons.alertTriangle.svg(height: 35),
                    const Gap(13),
                    const TextView(
                      text: "Deleting your account will:",
                      fontSize: 16,
                      color: AppColors.metalRed,
                      fontWeight: FontWeight.w600,
                    ),
                    const TextView(
                      text:
                          "-  Make you unavailable to other Metals \n-  Delete your account from Metal \n-  Erase your message history with all metals \n-  Delete all media from your account",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    const Gap(47),
                    const TextView(
                      text: "Unsatisfied with this account? Start again",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    const Gap(10),
                    BaseButton(
                      buttonText: 'Create a new Metal account',
                      onPressed: () {
                        AuthManager.deleteAccessToken();
                        AuthManager.deleteLoginState();
                        AuthManager.deleteRefreshToken();

                        //     ZegoUIKitPrebuiltCallInvitationService().uninit();
                        Navigator.pushNamedAndRemoveUntil(
                            context, AppRoutes.onboarding, (route) => false);
                      },
                    ),
                    const Gap(10),
                    const Divider(),
                    const Gap(10),
                    const TextView(
                      text: "Can you tell us how to improve the app?",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    EditFormField(
                      floatingLabel: '',
                      label:
                          'Please share how you think we can make Metal app more safe and better for you or other users next time',
                      controller: _controller,
                      keyboardType: TextInputType.name,
                      minLines: 5,
                      maxLines: 5,
                      validator: Validators.validateString(),
                      autoValidate: true,
                    ),
                    const Gap(10),
                    const Center(
                      child: TextView(
                        text: "It’s sad to see you go.",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Gap(10),
                    PlainButton(
                      buttonText: "Delete my account",
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomDialog(
                              content: verifyDelete(context, ref),
                            );
                          },
                        );
                      },
                      textColor: AppColors.metalWhite,
                      color: AppColors.metalRed,
                      leftIcon: SvgPicture.asset(
                        Assets.icons.profileTrash.path,
                        height: 24,
                        width: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget verifyDelete(BuildContext context, ref) {
    return Column(
      children: [
        const Gap(38),
        Assets.icons.delete1.svg(),
        const Gap(15),
        const TextView(
          text: "Delete Account",
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        const Gap(15),
        const TextView(
          text: "Are you sure you want to delete your account?",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        const Gap(38),
        BaseButton(
          buttonText: "Yes, Delete my account",
          onPressed: () {
            ref.read(deleteUserProvider.notifier).deleteUser(context);
          },
        ),
        const Gap(23),
        TextView(
          text: "Not now",
          fontSize: 16,
          fontWeight: FontWeight.w500,
          onTap: () => Navigator.pop(context),
        ),
        const Gap(21),
      ],
    );
  }

  Widget DeleteConfrim(BuildContext context) {
    return Column(
      children: [
        const Gap(38),
        Assets.icons.delete2.svg(),
        const Gap(15),
        const TextView(
          text: "Account deleted",
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        const Gap(15),
        const TextView(
          text:
              "Your account and all associated data have been permanently removed from our system. In the meantime, we appreciate the time you spent with us and value your experience as a user.",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        const Gap(38),
        BaseButton(
            buttonText: "Bye!",
            onPressed: () {
              Navigator.pop(context);
            }),
        const Gap(23),
      ],
    );
  }
}
