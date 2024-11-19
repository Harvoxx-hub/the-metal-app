import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:metal/features/home_page/domain/entries/melt.user.model.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';

class ChatBottomSheet extends StatefulWidget {
  const ChatBottomSheet(
      {super.key,
      required this.onSend,
      required this.onGameClick,
      required this.meltUserModel});
  final Function(String) onSend;
  final Function() onGameClick;
  final MeltUserModel meltUserModel;
  @override
  State<ChatBottomSheet> createState() => _ChatBottomSheetState();
}

class _ChatBottomSheetState extends State<ChatBottomSheet> {
  final TextEditingController _chatController = TextEditingController();
  final tooltipController = JustTheController();
  final _scrollController = ScrollController();
  bool _emojiShowing = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.0, left: 18, right: 18),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _emojiShowing = !_emojiShowing;
                  });
                },
                child: SvgPicture.asset(
                  Assets.icons.chatsWindowactiveEmojis.path,
                  height: 42,
                  width: 42,
                ),
              ),
              const Gap(8),
              Expanded(
                child: EditFormField(
                  onTapped: () {
                    setState(() {
                      _emojiShowing = false;
                    });
                  },
                  label: 'Your Message',
                  controller: _chatController,
                  keyboardType: TextInputType.emailAddress,
                  autoValidate: false,

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
                                'Voice note features are enabled after 5 days (--- remaining) of chatting with this metal. Please contact them through messages',
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
                        width: 40,
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
          Offstage(
            offstage: !_emojiShowing,
            child: EmojiPicker(
              textEditingController: _chatController,
              scrollController: _scrollController,
              config: Config(
                height: 256,
                checkPlatformCompatibility: true,
                emojiViewConfig: EmojiViewConfig(
                  // Issue: https://github.com/flutter/flutter/issues/28894
                  emojiSizeMax: 18 *
                      (foundation.defaultTargetPlatform == TargetPlatform.iOS
                          ? 1.2
                          : 1.0),
                ),
              ),
            ),
          ),
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
