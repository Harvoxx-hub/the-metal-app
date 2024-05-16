import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';

class ChatBottomSheet extends StatefulWidget {
  const ChatBottomSheet(
      {super.key, required this.onSend, required this.onGameClick});
  final Function(String) onSend;
  final Function() onGameClick;
  @override
  State<ChatBottomSheet> createState() => _ChatBottomSheetState();
}

class _ChatBottomSheetState extends State<ChatBottomSheet> {
  final TextEditingController _chatController = TextEditingController();
  final tooltipController = JustTheController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.0, left: 18.w, right: 18.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            Assets.icons.chatsWindowactiveEmojis.path,
            height: 42,
            width: 42,
          ),
          const Gap(8),
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
          const Gap(17),
          isChatControllerEmpty()
              ? Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onGameClick,
                      child: SvgPicture.asset(
                        Assets.icons.chatsEmptyStateGamingPad01.path,
                        height: 30,
                        width: 30,
                      ),
                    ),
                    const Gap(17),
                    JustTheTooltip(
                      controller: tooltipController,
                      content: const SizedBox(
                        width: 180,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Voice note features are enabled after 30 days of chatting with this metal. Please contact them through messages',
                          ),
                        ),
                      ),
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        child: GestureDetector(
                          onTap: () {
                            tooltipController.showTooltip();
                          },
                          child: SvgPicture.asset(
                            Assets.icons.chatsEmptyStateMicrophone.path,
                            height: 24,
                            width: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : GestureDetector(
                  onTap: () {
                    widget.onSend(_chatController.text);
                    _chatController.clear();
                  },
                  child: Container(
                    height: 40,
                    width: 40.w,
                    decoration: const ShapeDecoration(
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
