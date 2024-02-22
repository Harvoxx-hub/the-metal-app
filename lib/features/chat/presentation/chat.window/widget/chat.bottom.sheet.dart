import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/chat/presentation/games/games.page.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';

class ChatBottomSheet extends StatefulWidget {
  const ChatBottomSheet({super.key, required this.onSend});
  final Function(String) onSend;
  @override
  State<ChatBottomSheet> createState() => _ChatBottomSheetState();
}

class _ChatBottomSheetState extends State<ChatBottomSheet> {
  final TextEditingController _chatController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            Assets.icons.chatsWindowactiveEmojis.path,
            height: 42,
            width: 42,
          ),
          Gap(8),
          Expanded(
            child: EditFormField(
              label: 'Your Message',
              controller: _chatController,
              keyboardType: TextInputType.emailAddress,
              autoValidate: false,

              // validator: EmailValidator.validate(email),
              radius: 34,
              // fillColor: AppColors.appGrey,
            ),
          ),
          Gap(17),
          isChatControllerEmpty()
              ? Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pushNamed(GamePage.name),
                      child: SvgPicture.asset(
                        Assets.icons.chatsEmptyStateGamingPad01.path,
                        height: 30,
                        width: 30,
                      ),
                    ),
                    Gap(17),
                    SvgPicture.asset(
                      Assets.icons.chatsEmptyStateMicrophone.path,
                      height: 24,
                      width: 24,
                    ),
                  ],
                )
              : GestureDetector(
                  onTap: () {
                    widget.onSend(_chatController.text);
                    _chatController.clear();
                  },
                  child: Container(
                    height: 40.h,
                    width: 40.w,
                    decoration: ShapeDecoration(
                      color: Color(0xFFD9197B),
                      shape: OvalBorder(),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        Assets.icons.chatsWindowactiveSend.path,
                        height: 24,
                        width: 24,
                      ),
                    ),
                  ),
                )
        ],
      ),
    );
  }

  bool isChatControllerEmpty() {
    return _chatController.text.isEmpty;
  }

  @override
  void initState() {
    super.initState();
    // Add a listener to the text controller to trigger a rebuild when the text changes
    _chatController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Remove the listener to avoid memory leaks
    _chatController.dispose();
    super.dispose();
  }
}
