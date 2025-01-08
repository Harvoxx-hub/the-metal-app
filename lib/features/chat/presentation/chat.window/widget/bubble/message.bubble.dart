import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/utils/date.formart.dart';

import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/chat/domain/entries/message.model.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/bubble/wave.bubble.dart';
import 'package:metal/features/chat/provider/unmelt.notifier.dart';
import 'package:metal/res/res.dart';
import 'package:metal/widgets/button/outiline.button.dart';
import 'package:metal/widgets/text_views.dart';

class MessageBubble extends ConsumerWidget {
  final MessageModel message;
  final String connectionId;

  const MessageBubble({
    super.key,
    required this.message,
    required this.connectionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(authProvider).data;

    if (userData == null) {
      return const SizedBox.shrink();
    }

    final isSender = message.senderId == userData.id;
    final isAdmin = message.senderId == "admin";

    // Mark message as read when displayed
    if (!message.isRead && !isSender) {
      ref
          .read(unMeltProvider.notifier)
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

  Widget _buildAudioMessage(bool isSender) {
    return Column(
      crossAxisAlignment:
          isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        WaveBubble(
          path: message.content,
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
        ? const TextView(text: "Un-melt Request Cancelled")
        : message.message == "approved"
            ? const TextView(text: "Un-melt Request Approved")
            : message.message == "rejected"
                ? const TextView(text: "Un-melt Request Rejected")
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextView(
                        text:
                            isSender ? 'Un-Melt Requested' : 'Un-Melt Request',
                      ),
                      const Gap(10),
                      isSender
                          ? OutilineButton(
                              buttonText: 'Cancel',
                              onPressed: () {
                                ref.read(unMeltProvider.notifier).updateMessage(
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
                                      ref
                                          .read(unMeltProvider.notifier)
                                          .unmelter(
                                        connectionId,
                                        message.id,
                                        {"message": "approved"},
                                      );
                                    },
                                  ),
                                ),
                                const Gap(10),
                                Expanded(
                                  child: OutilineButton(
                                    buttonText: 'Reject',
                                    onPressed: () {
                                      ref
                                          .read(unMeltProvider.notifier)
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
                ref.read(unMeltProvider.notifier).deleteMessage(
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
