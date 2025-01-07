import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:gap/gap.dart';

import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/chat/domain/entries/message.model.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/bubble/wave.bubble.dart';
import 'package:metal/features/chat/provider/send.message.notifier.dart';
import 'package:metal/features/home_page/domain/entries/connection.model.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/res.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';

import 'package:audio_waveforms/audio_waveforms.dart';

import 'package:path_provider/path_provider.dart';

class ChatBottomSheet extends ConsumerStatefulWidget {
  const ChatBottomSheet({
    super.key,
    required this.onGameClick,
    required this.meltUserModel,
    required this.connectionModel,
  });

  final Function() onGameClick;
  final UserModel meltUserModel;
  final ConnectionModel connectionModel;

  @override
  ConsumerState<ChatBottomSheet> createState() => _ChatBottomSheetState();
}

class _ChatBottomSheetState extends ConsumerState<ChatBottomSheet> {
  final TextEditingController _chatController = TextEditingController();
  final tooltipController = JustTheController();
  final _scrollController = ScrollController();

  bool _hasText = true;
  late final RecorderController recorderController;

  String? path;
  String? musicFile;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _initialiseControllers();
  }

  void _initialiseControllers() {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
  }

  @override
  void dispose() {
    recorderController.dispose();
    super.dispose();
  }

  var currentUserData;
  @override
  Widget build(BuildContext context) {
    int dayRemaining = daysRemaining(widget.connectionModel.connectedOn, 0);
    currentUserData = ref.watch(authProvider).data;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(left: 18, right: 18),
        child: Column(
          children: [
            isRecordingCompleted
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _refreshWave();
                          isRecordingCompleted = false;
                          setState(() {});
                        },
                        child: SvgPicture.asset(
                          Assets.icons.profileTrash.path,
                          color: Color(0xFFD9197B),
                          height: 30,
                          width: 30,
                        ),
                      ),
                      WaveBubble(
                        width: MediaQuery.of(context).size.width / 1.5,
                        path: path,
                        isSender: true,
                      ),
                      GestureDetector(
                        onTap: sendAudioMessage,
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
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: isRecording
                            ? AudioWaveforms(
                                enableGesture: true,
                                size: Size(
                                    MediaQuery.of(context).size.width / 1.6,
                                    50),
                                recorderController: recorderController,
                                waveStyle: const WaveStyle(
                                  waveColor: AppColors.metalPinkColour,
                                  extendWaveform: true,
                                  showMiddleLine: false,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  color: AppColors.metalWhite20,
                                ),
                                padding: const EdgeInsets.only(left: 18),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 15),
                              )
                            : Row(
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 1.4,
                                    child: EditFormField(
                                      onChange: (va) {
                                        isChatControllerEmpty();
                                      },
                                      onTapped: () {},
                                      label: 'Your Message',
                                      controller: _chatController,
                                      keyboardType: TextInputType.text,
                                      autoValidate: false,
                                      radius: 34,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      const Gap(4),
                      isRecording
                          ? IconButton(
                              onPressed: _startOrStopRecording,
                              icon: Icon(isRecording ? Icons.stop : Icons.mic),
                              color: AppColors.metalPinkColour,
                              iconSize: 28,
                            )
                          : _hasText
                              ? Row(
                                  children: [
                                    GestureDetector(
                                      onTap: widget.onGameClick,
                                      child: SvgPicture.asset(
                                        Assets.icons.chatsEmptyStateGamingPad01
                                            .path,
                                        height: 30,
                                        width: 30,
                                      ),
                                    ),
                                    const Gap(17),
                                    JustTheTooltip(
                                      controller: tooltipController,
                                      content: SizedBox(
                                        width: 180,
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'Voice note features are enabled after 5 days. $dayRemaining remaining of chatting with this metal. Please contact them through messages',
                                          ),
                                        ),
                                      ),
                                      child: Material(
                                        color: Colors.white,
                                        shape: const CircleBorder(),
                                        child: GestureDetector(
                                          onTap: () {
                                            hasDurationReached(
                                                    widget.connectionModel
                                                        .connectedOn,
                                                    0)
                                                ? _startOrStopRecording()
                                                : tooltipController
                                                    .showTooltip();
                                          },
                                          child: SvgPicture.asset(
                                            Assets.icons
                                                .chatsEmptyStateMicrophone.path,
                                            height: 24,
                                            width: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : GestureDetector(
                                  onTap: sendTextMessage,
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
          ],
        ),
      ),
    );
  }

  void _startOrStopRecording() async {
    try {
      if (isRecording) {
        recorderController.reset();

        path = await recorderController.stop(false);

        if (path != null) {
          isRecordingCompleted = true;
          debugPrint(path);
          debugPrint("Recorded file size: ${File(path!).lengthSync()}");
        }
      } else {
        // Generate a new path for each recording to avoid overwriting
        final directory = await getApplicationDocumentsDirectory();
        path =
            '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await recorderController.record(path: path);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        isRecording = !isRecording;
      });
    }
  }

  void sendAudioMessage() {
    if (path == null || path!.isEmpty) {
      debugPrint("No audio file to send");
      return;
    }

    final message = MessageModel(
      senderId: currentUserData!.id!,
      type: MessageType.audio,
      timestamp: DateTime.now().toIso8601String(),
      isRead: false,
      content: path,
      message: "voice note",
    );

    ref
        .read(sendMessageProvider.notifier)
        .sendMessage(message, widget.connectionModel.connectionId);

    _refreshWave();

    // Reset state for next recording
    setState(() {
      isRecordingCompleted = false;
      path = null;
    });
  }

  void _refreshWave() {
    if (isRecording) recorderController.refresh();
  }

  isChatControllerEmpty() {
    _hasText = _chatController.text.isEmpty;
    setState(() {});
  }

  void sendTextMessage() {
    _hasText = true;
    final message = MessageModel(
      senderId: currentUserData!.id!,
      type: MessageType.text,
      timestamp: DateTime.now().toIso8601String(),
      isRead: false,
      message: _chatController.text.trim(),
    );

    ref
        .read(sendMessageProvider.notifier)
        .sendMessage(message, widget.connectionModel.connectionId);

    _chatController.clear();
  }
}
