import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/features/chat/chat.window/widget/chat.bottom.sheet.dart';
import 'package:metal/features/chat/chat.window/widget/chat.bubble.dart';
import 'package:metal/features/chat/chat.window/widget/chat.windows.appbar.dart';
import 'package:metal/res/res.dart';
import 'package:metal/core/utils/utils/screen.size.dart';
import 'package:metal/widgets/text_views.dart';

class ChatWindowsPage extends StatefulWidget {
  const ChatWindowsPage({super.key});
  static const name = 'chatWindows';
  static const route = '$name';
  @override
  State<ChatWindowsPage> createState() => _ChatWindowsPageState();
}

class _ChatWindowsPageState extends State<ChatWindowsPage> {
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      appBarEnabled: false,
      body: Container(
        padding: const EdgeInsets.only(top: 50),
        color: AppColors.metalPinkColour,
        child: Container(
          padding: EdgeInsets.only(left: 18.w, right: 18.w),
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(13), topRight: Radius.circular(13)),
              color: AppColors.metalWhite),
          child: Column(
            children: [
              Gap(20.h),
              ChatWindowsAppBar(
                key: widget.key,
              ),
              Gap(20.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      dateDivider(),
                      ChatBubble(
                        message: "Sure, let’s do it! 😊",
                        isme: true,
                        time: DateTime.now(),
                      ),
                      ChatBubble(
                        message: "Sure, let’s do it! 😊",
                        isme: false,
                        time: DateTime.now(),
                      ),
                      ChatBubble(
                        message: "Sure, let’s do it! 😊",
                        isme: true,
                        time: DateTime.now(),
                      ),
                      ChatBubble(
                        message: "Sure, let’s do it! 😊",
                        isme: true,
                        time: DateTime.now(),
                      ),
                      ChatBubble(
                        message: "Sure, let’s do it! 😊",
                        isme: true,
                        time: DateTime.now(),
                      ),
                      ChatBubble(
                        message: "Sure, let’s do it! 😊",
                        isme: true,
                        time: DateTime.now(),
                      ),
                      ChatBubble(
                        message: "Sure, let’s do it! 😊",
                        isme: true,
                        time: DateTime.now(),
                      ),
                      ChatBubble(
                        message: "Sure, let’s do it! 😊",
                        isme: true,
                        time: DateTime.now(),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ChatBottomSheet(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class dateDivider extends StatelessWidget {
  const dateDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
            child: Divider(
          color: AppColors.metalButtonStroke,
          thickness: 1.5,
        )),
        Gap(10.w),
        TextView(text: "Today"),
        Gap(10.w),
        const Expanded(
            child: Divider(
          color: AppColors.metalButtonStroke,
          thickness: 1.5,
        )),
      ],
    );
  }
}
