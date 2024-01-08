import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/chat/widget/profile.image.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/text_views.dart';

class ChatWindowsAppBar extends StatefulWidget {
  const ChatWindowsAppBar({super.key});

  @override
  State<ChatWindowsAppBar> createState() => _ChatWindowsAppBarState();
}

class _ChatWindowsAppBarState extends State<ChatWindowsAppBar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: SvgPicture.asset(
            Assets.icons.chatsWindowactiveCaretLeft.path,
            height: 32,
            width: 32,
          ),
        ),
        Gap(3.w),
        const ProfileImage(
          width: 42,
          height: 42,
        ),
        Gap(3.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextView(
              text: "@seguncode",
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
            Gap(3.h),
            TextView(
              text: "Active now",
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.metalBlack50,
            ),
          ],
        ),
        const Spacer(),
        SvgPicture.asset(
          Assets.icons.chatsWindowactiveVideoRecorder.path,
          height: 30,
          width: 30,
        ),
        Gap(15.w),
        SvgPicture.asset(
          Assets.icons.chatsWindowactiveFill.path,
          height: 24,
          width: 24,
        ),
        Gap(15.w),
        PopupMenuButton(
          child: SvgPicture.asset(
            Assets.icons.chatsWindowactiveSrMenuVerticalLite.path,
            height: 24,
            width: 24,
          ),
          onSelected: (value) {
            if (value == "Unmetal") {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CustomDialog(
                    content: unmetalDialog(context),
                  );
                },
              );
            } else if (value == "settings") {
              // add desired output
            } else if (value == "logout") {
              // add desired output
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry>[
            PopupMenuItem(
              value: "View contact",
              child: TextView(
                text: 'View contact',
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            PopupMenuItem(
              value: "View eyes",
              child: TextView(
                text: 'View eyes',
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            PopupMenuItem(
              value: "Unmetal",
              child: TextView(
                text: 'Unmetal',
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            PopupMenuItem(
              value: "Unblock from audio call",
              child: TextView(
                text: 'Unblock from audio call',
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            PopupMenuItem(
              value: "Unblock from video call",
              child: TextView(
                text: 'Unblock from video call',
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            PopupMenuItem(
              value: "Clear chat",
              child: TextView(
                text: 'Clear chat',
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            PopupMenuItem(
              value: "Unblock",
              child: TextView(
                text: 'Unblock',
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget unmetalDialog(BuildContext context) {
    return Column(
      children: [
        Gap(38.h),
        TextView(
          text: "Want to Unmetal?",
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        Gap(15.h),
        TextView(
          text:
              "To Unmetal, we require a minimum of 30days and 10 sessions of conversations between you and @chi_aluminium",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        Gap(15.h),
        TextView(
          text: "You have had *16 days* and *3 interactions*",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        Gap(38.h),
        BaseButton(
            buttonText: "Return to chat",
            onPressed: () {
              context.pop();
            }),
        Gap(23.h),
      ],
    );
  }
}
