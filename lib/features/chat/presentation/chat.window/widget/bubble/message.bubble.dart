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

  MessageBubble({
    Key? key,
    required this.message,
    required this.connectionId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(authProvider).data;

    if (userData == null) {
      return const SizedBox.shrink();
    }

    final isSender = message.senderId == userData.id;
    final isAdmin = message.senderId == "admin";

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
            onLongPress: () {
              // Show a confirmation dialog before deleting
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Delete Message"),
                    content:
                        Text("Are you sure you want to delete this message?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          // Delete the message using your provider or state management logic
                          ref.read(unMeltProvider.notifier).deleteMessage(
                                connectionId,
                                message.id,
                              );
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: Text(
                          "Delete",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            child: _buildMessageContent(isSender, isAdmin, userData.id!, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(bool isSender, bool isAdmin, String userId, ref) {
    switch (message.type) {
      case MessageType.text:
        return _buildTextMessage(isSender, isAdmin);
      case MessageType.audio:
        return _buildAudioMessage(isSender);
      case MessageType.un_melt:
        return _buildUnsupportedMessage(isSender, isAdmin, ref);
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
      ],
    );
  }

  Widget _buildUnsupportedMessage(bool isSender, bool isAdmin, WidgetRef ref) {
    return Column(
      crossAxisAlignment:
          isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
          decoration: BoxDecoration(
            color: _getMessageBubbleColor(isSender, isAdmin),
            borderRadius: _getMessageBubbleBorderRadius(isSender, isAdmin),
          ),
          child: message.message == "cancel"
              ? TextView(
                  text: "Un-melt Request Cancel",
                )
              : message.message == "approved"
                  ? TextView(
                      text: "Un-melt Request Approved",
                    )
                  : message.message == "rejeted"
                      ? TextView(
                          text: "Un-melt Request Rejeted",
                        )
                      : Column(
                          children: [
                            TextView(
                                text: isSender
                                    ? 'Un-Melt Requested'
                                    : 'Un-Melt Request'),
                            const Gap(10),
                            TextView(
                              text: isSender
                                  ? "Requesting un-melt request, you will gain access to the rest of your currently hidden information and will also be able to make video and audio calls."
                                  : 'By accepting this un-melt request, the user will gain access to the rest of your currently hidden information and will also be able to make video and audio calls.',
                              fontSize: 12,
                            ),
                            const Gap(10),
                            isSender
                                ? OutilineButton(
                                    buttonText: 'Cancel',
                                    onPressed: () {
                                      ref
                                          .read(unMeltProvider.notifier)
                                          .updateMessage(
                                              connectionId,
                                              message.id,
                                              {"message": "cancel"});
                                    },
                                  )
                                : Column(
                                    children: [
                                      OutilineButton(
                                        buttonText: 'Un-metal',
                                        onPressed: () {
                                          ref
                                              .read(unMeltProvider.notifier)
                                              .unmelter(
                                                  connectionId,
                                                  message.id,
                                                  {"message": "approved"});
                                        },
                                      ),
                                      const Gap(10),
                                      OutilineButton(
                                        buttonText: 'Reject',
                                        onPressed: () {
                                          ref
                                              .read(unMeltProvider.notifier)
                                              .updateMessage(
                                                  connectionId,
                                                  message.id,
                                                  {"message": "rejeted"});
                                        },
                                      ),
                                    ],
                                  ),
                          ],
                        ),
        ),
        TextView(
          text: formatTime(isoDateString: message.timestamp),
          fontSize: 10,
          color: AppColors.metalBlack50,
        ),
      ],
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
