import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/core/utils/image_picker_util.dart';

import 'package:metal/features/authentication/provider/user_state_notifier.dart';
import 'package:metal/features/chat/domain/entries/message.model.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/bubble/wave.bubble.dart';
import 'package:metal/features/chat/provider/manage.message.notifier.dart';
import 'package:metal/features/chat/provider/unmelt.notifier.dart';
import 'package:metal/features/home_page/provider/check.melt.status.notifier.dart';
import 'package:metal/features/home_page/provider/get.connection.notifier.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/button/outiline.button.dart';

import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/text_views.dart';

class MessageBubble extends ConsumerWidget {
  final MessageModel message;
  final String connectionId;
  final Function()? onApproved;

  const MessageBubble({
    super.key,
    required this.message,
    required this.connectionId,
    this.onApproved,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userStateProvider).data;

    if (userData == null) {
      return const SizedBox.shrink();
    }

    final isSender = message.senderId == userData.id;
    final isAdmin = message.senderId == "admin";

    // Mark message as read when displayed
    if (!message.isRead && !isSender) {
      ref
          .read(managerMessageProvider.notifier)
          .markMessageAsRead(connectionId, message.id!);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment: isSender
            ? MainAxisAlignment.end
            : isAdmin
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: () => _showDeleteDialog(context, ref),
            child: _buildMessageContent(isSender, isAdmin, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(bool isSender, bool isAdmin, WidgetRef ref) {
    switch (message.type) {
      case MessageType.text:
        return _buildTextMessage(isSender, isAdmin);
      case MessageType.audio:
        return _buildAudioMessage(isSender);
      case MessageType.calls:
        return _buildCallMessage(isSender);
      default:
        return _buildUnsupportedMessage(isSender, isAdmin, ref);
    }
  }

  Widget _buildTextMessage(bool isSender, bool isAdmin) {
    return Column(
      crossAxisAlignment:
          isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
          decoration: BoxDecoration(
            color: _getMessageBubbleColor(isSender, isAdmin),
            borderRadius: _getMessageBubbleBorderRadius(isSender, isAdmin),
          ),
          padding: isAdmin ? const EdgeInsets.all(5) : const EdgeInsets.all(16),
          child: TextView(
            text: message.message,
          ),
        ),
        const Gap(10),
        if (!isAdmin)
          TextView(
            text: formatTime(isoDateString: message.timestamp),
            fontSize: 10,
            color: AppColors.metalBlack50,
          ),
        _buildReadReceipt(isSender),
      ],
    );
  }

  Widget _buildCallMessage(bool isSender) {
    final bool isVideoCall = message.content == "Video call";
    final String callTypeText = isVideoCall ? "Video Call" : "Voice Call";
    final IconData callIcon = isVideoCall ? Icons.videocam : Icons.call;

    return Column(
      crossAxisAlignment:
          isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          constraints: const BoxConstraints(minWidth: 100, maxWidth: 220),
          decoration: BoxDecoration(
            color: isSender ? Colors.green.shade700 : Colors.green.shade800,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(callIcon, size: 22, color: Colors.white70),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextView(
                    text: callTypeText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  const TextView(
                    text: "Call initiated",
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        TextView(
          text: formatTime(isoDateString: message.timestamp),
          fontSize: 10,
          color: AppColors.metalBlack50,
        ),
        _buildReadReceipt(isSender),
      ],
    );
  }

  Widget _buildAudioMessage(bool isSender) {
    print(message.content);
    return Column(
      crossAxisAlignment:
          isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        WaveBubble(
          path: message.content ?? "",
          isSender: isSender,
        ),
        TextView(
          text: formatTime(isoDateString: message.timestamp),
          fontSize: 10,
        ),
        _buildReadReceipt(isSender),
      ],
    );
  }

  Widget _buildUnsupportedMessage(bool isSender, bool isAdmin, WidgetRef ref) {
    return Column(
      crossAxisAlignment:
          isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
          decoration: BoxDecoration(
            color: _getMessageBubbleColor(isSender, isAdmin),
            borderRadius: _getMessageBubbleBorderRadius(isSender, isAdmin),
          ),
          child: _buildUnmeltContent(isSender, ref),
        ),
        TextView(
          text: formatTime(isoDateString: message.timestamp),
          fontSize: 10,
          color: AppColors.metalBlack50,
        ),
        _buildReadReceipt(isSender),
      ],
    );
  }

  Widget _buildUnmeltContent(bool isSender, WidgetRef ref) {
    return message.message == "cancel"
        ? const TextView(text: "Un-metal Request Cancelled")
        : message.message == "approved"
            ? const TextView(text: "Un-metal Request Approved")
            : message.message == "rejected"
                ? const TextView(text: "Un-metal Request Rejected")
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextView(
                        text: isSender
                            ? 'Un-Metal Requested'
                            : 'Un-Metal Request',
                      ),
                      const Gap(10),
                      isSender
                          ? OutilineButton(
                              buttonText: 'Cancel',
                              onPressed: () {
                                ref
                                    .read(managerMessageProvider.notifier)
                                    .updateMessage(
                                  connectionId,
                                  message.id,
                                  {"message": "cancel"},
                                );
                              },
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: OutilineButton(
                                    buttonText: 'Approve',
                                    onPressed: () {
                                      // Check if the current user has a profile photo
                                      final currentUser =
                                          ref.read(userStateProvider).data;
                                      final hasProfilePhoto =
                                          currentUser?.profilePhoto != null &&
                                              currentUser!
                                                  .profilePhoto!.isNotEmpty &&
                                              currentUser.profilePhoto!
                                                  .trim()
                                                  .isNotEmpty;

                                      if (!hasProfilePhoto) {
                                        // Show dialog to upload profile photo first
                                        showDialog(
                                          context: ref.context,
                                          builder: (BuildContext context) {
                                            return CustomDialog(
                                              content: Column(
                                                children: [
                                                  const Gap(38),
                                                  const TextView(
                                                    text:
                                                        "Upload Photo Required",
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                  const Gap(15),
                                                  const TextView(
                                                    text:
                                                        "To complete the unmetal process, you need to upload a profile photo. This allows both users to see each other's photos.",
                                                    fontSize: 16,
                                                    textAlign: TextAlign.center,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                  const Gap(38),
                                                  BaseButton(
                                                    buttonText: "Upload Photo",
                                                    onPressed: () async {
                                                      Navigator.pop(context);

                                                      ImagePickerUtil.pickImage(
                                                          context, ref);
                                                    },
                                                  ),
                                                  const Gap(23),
                                                  TextView(
                                                    text: "Cancel",
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    onTap: () =>
                                                        Navigator.pop(context),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      } else {
                                        // User has a profile photo, proceed normally
                                        ref
                                            .read(unMeltProvider.notifier)
                                            .unmelter(
                                          connectionId,
                                          message.id,
                                          {"message": "approved"},
                                        ).then((_) {
                                          onApproved?.call();
                                        });
                                      }
                                    },
                                  ),
                                ),
                                const Gap(10),
                                Expanded(
                                  child: OutilineButton(
                                    buttonText: 'Reject',
                                    onPressed: () {
                                      ref
                                          .read(managerMessageProvider.notifier)
                                          .updateMessage(
                                        connectionId,
                                        message.id,
                                        {"message": "rejected"},
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                    ],
                  );
  }

  Widget _buildReadReceipt(bool isSender) {
    if (isSender) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            message.isRead ? Icons.done_all : Icons.check,
            color: message.isRead ? Colors.blue : Colors.grey,
            size: 16,
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Message"),
          content: const Text("Are you sure you want to delete this message?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                ref.read(managerMessageProvider.notifier).deleteMessage(
                      connectionId,
                      message.id,
                    );
                Navigator.of(context).pop();
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getMessageBubbleColor(bool isSender, bool isAdmin) {
    if (isSender) {
      return Colors.grey[300]!;
    } else if (isAdmin) {
      return AppColors.metalPinkColour.withOpacity(0.03);
    } else {
      return AppColors.metalPinkColour.withOpacity(0.1);
    }
  }

  BorderRadius _getMessageBubbleBorderRadius(bool isSender, bool isAdmin) {
    if (isAdmin) {
      return BorderRadius.circular(15);
    } else {
      return BorderRadius.only(
        topLeft: const Radius.circular(15),
        topRight: const Radius.circular(15),
        bottomLeft:
            isSender ? const Radius.circular(15) : const Radius.circular(0),
        bottomRight:
            isSender ? const Radius.circular(0) : const Radius.circular(15),
      );
    }
  }
}
