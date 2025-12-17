import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:gap/gap.dart';

import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';

import 'package:metal/features/chat/domain/entries/message.model.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/bubble/wave.bubble.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/reply_preview_widget.dart';
import 'package:metal/features/chat/provider/send.message.notifier.dart';
import 'package:metal/features/thought/data/domain/entries/connection.model.dart';
import 'package:metal/features/thought/provider/melt.user.notifier.dart';
import 'package:metal/features/thought/provider/get.melt.users.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/res.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

import 'package:audio_waveforms/audio_waveforms.dart';

import 'package:path_provider/path_provider.dart';

class ChatBottomSheet extends ConsumerStatefulWidget {
  const ChatBottomSheet({
    super.key,
    required this.onGameClick,
    required this.meltUserModel,
    required this.connectionModel,
    this.onReplyCallback,
  });

  final Function() onGameClick;
  final UserModel meltUserModel;
  final ConnectionModel connectionModel;
  final Function(Function(MessageModel))? onReplyCallback;

  @override
  ConsumerState<ChatBottomSheet> createState() => _ChatBottomSheetState();
}

class _ChatBottomSheetState extends ConsumerState<ChatBottomSheet> {
  final TextEditingController _chatController = TextEditingController();

  bool _hasText = true;
  late final RecorderController recorderController;

  String? path;
  String? musicFile;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  bool isLoading = true;

  // Reply functionality
  MessageModel? _replyingToMessage;

  @override
  void initState() {
    super.initState();

    _initialiseControllers();

    // Register the reply callback
    widget.onReplyCallback?.call(setReplyingToMessage);
  }

  void _initialiseControllers() {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100
      ..bitRate = 128000;
  }

  @override
  void dispose() {
    recorderController.dispose();
    super.dispose();
  }

  /// Set the message to reply to
  void setReplyingToMessage(MessageModel message) {
    setState(() {
      _replyingToMessage = message;
    });
  }

  /// Cancel the current reply
  void cancelReply() {
    setState(() {
      _replyingToMessage = null;
    });
  }

  var currentUserData;
  @override
  Widget build(BuildContext context) {
    currentUserData = ref.watch(userStateProvider).data;
    
    // Check if user can send messages (receiver in pending connection)
    final canSend = widget.connectionModel.canUserSendMessage(currentUserData!.id!);
    final isReceiver = widget.connectionModel.isUserReceiver(currentUserData!.id!);
    
    return Padding(
      padding: EdgeInsets.only(left: 18, right: 18, bottom: 18),
      child: Column(
        children: [
          // WhatsApp-style reply preview widget
          if (_replyingToMessage != null)
            ReplyPreviewWidget(
              replyToMessage: _replyingToMessage!,
              onCancel: cancelReply,
            ),
          // Show "Melt & Reply" button if user is receiver in pending connection
          if (!canSend && isReceiver)
            _buildMeltToReplyButton()
          else
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
                        path: path ?? "",
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
                                  MediaQuery.of(context).size.width / 1.6, 50),
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
                                      MediaQuery.of(context).size.width / 1.45,
                                  child: EditFormField(
                                    onChange: (va) {
                                      isChatControllerEmpty();
                                    },
                                    onTapped: () {},
                                    label: canSend ? 'Your Message' : 'Melt to reply',
                                    controller: _chatController,
                                    keyboardType: TextInputType.text,
                                    autoValidate: false,
                                    radius: 34,
                                    enabled: canSend,
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const Gap(4),
                    if (canSend)
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
                                    Material(
                                      color: Colors.white,
                                      shape: const CircleBorder(),
                                      child: GestureDetector(
                                        onTap: () {
                                          _startOrStopRecording();
                                        },
                                        child: SvgPicture.asset(
                                          Assets.icons.chatsEmptyStateMicrophone
                                              .path,
                                          height: 24,
                                          width: 24,
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
      // Add reply data if replying to a message - point to the direct message being replied to
      replyToMessageId: _replyingToMessage?.id,
      replyToMessageText: _replyingToMessage?.message,
      replyToSenderId: _replyingToMessage?.senderId,
      replyToMessageType: _replyingToMessage?.type.name,
    );

    ref
        .read(sendMessageProvider.notifier)
        .sendMessage(message, widget.connectionModel.connectionId);

    _refreshWave();

    // Reset state for next recording
    setState(() {
      isRecordingCompleted = false;
      path = null;
      _replyingToMessage = null; // Clear reply after sending
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
    // Don't send if the message is empty or only whitespace
    if (_chatController.text.trim().isEmpty) {
      return;
    }

    _hasText = true;
    final message = MessageModel(
      senderId: currentUserData!.id!,
      type: MessageType.text,
      timestamp: DateTime.now().toIso8601String(),
      isRead: false,
      message: _chatController.text.trim(),
      // Add reply data if replying to a message - point to the direct message being replied to
      replyToMessageId: _replyingToMessage?.id,
      replyToMessageText: _replyingToMessage?.message,
      replyToSenderId: _replyingToMessage?.senderId,
      replyToMessageType: _replyingToMessage?.type.name,
    );

    ref
        .read(sendMessageProvider.notifier)
        .sendMessage(message, widget.connectionModel.connectionId);

    _chatController.clear();

    // Clear reply after sending
    setState(() {
      _replyingToMessage = null;
    });
  }

  Widget _buildMeltToReplyButton() {
    final meltState = ref.watch(meltUserProvider);
    final otherUserId = widget.meltUserModel.id;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.metalPinkColour.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.metalPinkColour,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          TextView(
            text: "Melt with ${widget.meltUserModel.username ?? 'this user'} to reply",
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.metalPinkColour,
            textAlign: TextAlign.center,
          ),
          const Gap(12),
          GestureDetector(
            onTap: meltState.isLoading
                ? null
                : () {
                    if (otherUserId != null) {
                      ref.read(meltUserProvider.notifier).meltUser(otherUserId);
                      // Refresh connections after melting
                      ref.read(getMeltUserProvider.notifier).getMeltUsers();
                    }
                  },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.metalPinkColour,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: meltState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const TextView(
                        text: "Melt & Reply",
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
