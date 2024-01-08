import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/chat/chat.window/chat.window.dart';
import 'package:metal/features/chat/widget/profile.image.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                child: Padding(
                  padding: const EdgeInsets.only(left: 24.0, right: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EditFormField(
                        label: 'Search',
                        // controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autoValidate: false,
                        prefixWidget: SvgPicture.asset(
                          Assets.icons.chatsSearch.path,
                          height: 24,
                          width: 24,
                        ),
                        // validator: EmailValidator.validate(email),
                        radius: 34,
                        // fillColor: AppColors.appGrey,
                      ),
                      Gap(10.h),
                      TextView(
                        text: "My Metals",
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.metalWhite,
                      ),
                      Gap(10.h),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            chat("you"),
                            chat("Musa"),
                            chat("Segun"),
                            chat("Muda"),
                            chat("Dave"),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Gap(26.h),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextView(
                      text: "Messages",
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    Gap(16.h),
                    const chatMessageItem(),
                    const chatMessageItem(),
                    const chatMessageItem(),
                    const chatMessageItem(),
                    const chatMessageItem(),
                    const chatMessageItem(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget chat(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Column(
        children: [
          const ProfileImage(),
          TextView(
            text: title,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.metalWhite,
          ),
        ],
      ),
    );
  }
}

class chatMessageItem extends StatelessWidget {
  const chatMessageItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(ChatWindowsPage.name),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          children: [
            Image.asset(Assets.images.chatsPhoto.path),
            Gap(19.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextView(
                  text: "Felix August_titanium",
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
                TextView(
                  text: "ok, see you then.",
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w300,
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextView(
                  text: "23 min",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.metalBrownColourForText.withOpacity(0.3),
                ),
                const Gap(3),
                Container(
                  width: 20,
                  height: 20,
                  decoration: const ShapeDecoration(
                    color: Color(0xFFD9197B),
                    shape: OvalBorder(),
                  ),
                  child: Center(
                    child: TextView(
                      text: "1",
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.metalWhite,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
