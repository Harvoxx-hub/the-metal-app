import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/core/services/auth.pref.service.dart';
import 'package:metal/core/utils/input/validators/validators.dart';
import 'package:metal/features/profile/provider/delete.user.notifier.dart';
import 'package:metal/features/settings/provider/get.block.user.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/settings/presentation%20/widget/blocked.card.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/button/plain.button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class DeleteScreen extends ConsumerWidget {
  DeleteScreen({super.key});
  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<DeleteUsersState>(deleteUserProvider, (prev, current) {
      if (current.isSuccess) {
        ref.read(authManagerProvider).deleteAccessToken();
        ref.read(authManagerProvider).deleteLoginState();
        ref.read(authManagerProvider).deleteRefreshToken();

        ZegoUIKitPrebuiltCallInvitationService().uninit();
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
                  height: 220.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment(0.00, -1.00),
                        end: Alignment(0, 1),
                        colors: [Color(0xFFDB217A), Color(0xFFF00E3E)],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(35.sp),
                        bottomRight: Radius.circular(35.sp),
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
                    Gap(13),
                    TextView(
                      text: "Deleting your account will:",
                      fontSize: 16,
                      color: AppColors.metalRed,
                      fontWeight: FontWeight.w600,
                    ),
                    TextView(
                      text: "-  Make you unavailable to other Metals \n" +
                          "-  Delete your account from Metal \n" +
                          "-  Erase your message history with all metals \n" +
                          "-  Delete all media from your account",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    Gap(47),
                    TextView(
                      text: "Unsatisfied with this account? Start again",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    Gap(10),
                    BaseButton(
                      buttonText: 'Create a new Metal account',
                      onPressed: () {
                        ref.read(authManagerProvider).deleteAccessToken();
                        ref.read(authManagerProvider).deleteLoginState();
                        ref.read(authManagerProvider).deleteRefreshToken();

                        ZegoUIKitPrebuiltCallInvitationService().uninit();
                        Navigator.pushNamedAndRemoveUntil(
                            context, AppRoutes.onboarding, (route) => false);
                      },
                    ),
                    Gap(10),
                    Divider(),
                    Gap(10),
                    TextView(
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
                    Gap(10),
                    Center(
                      child: TextView(
                        text: "It’s sad to see you go.",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Gap(10),
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
        Gap(38.h),
        Assets.icons.delete1.svg(),
        Gap(15.h),
        TextView(
          text: "Delete Account",
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        Gap(15.h),
        TextView(
          text: "Are you sure you want to delete your account?",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        Gap(38.h),
        BaseButton(
            buttonText: "Yes, Delete my account",
            onPressed: () {
              ref.read(deleteUserProvider.notifier).DeleteUser();
            }),
        Gap(23.h),
        TextView(
          text: "Not now",
          fontSize: 16,
          fontWeight: FontWeight.w500,
          onTap: () => Navigator.pop(context),
        ),
        Gap(21.h),
      ],
    );
  }

  Widget DeleteConfrim(BuildContext context) {
    return Column(
      children: [
        Gap(38.h),
        Assets.icons.delete2.svg(),
        Gap(15.h),
        TextView(
          text: "Account deleted",
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        Gap(15.h),
        TextView(
          text:
              "Your account and all associated data have been permanently removed from our system. In the meantime, we appreciate the time you spent with us and value your experience as a user.",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        Gap(38.h),
        BaseButton(
            buttonText: "Bye!",
            onPressed: () {
              Navigator.pop(context);
            }),
        Gap(23.h),
      ],
    );
  }
}
