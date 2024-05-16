import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/utils/screen.size.dart';

import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/chat/domain/entries/message.model.dart';
import 'package:metal/res/res.dart';

class MessageBubble extends ConsumerWidget {
  final MessageModel message;

  MessageBubble({
    super.key,
    required this.message,
  });
  var data;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    data = ref.watch(authProvider).data;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment: message.senderId == data!.id!
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          _buildMessageContent(),
        ],
      ),
    );
  }

  Widget _buildMessageContent() {
    if (message.type == MessageType.text) {
      return Column(
        crossAxisAlignment: message.senderId == data!.id!
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
            decoration: BoxDecoration(
              color: message.senderId == data!.id!
                  ? Colors.grey[300]
                  : AppColors.metalPinkColour.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(15),
                topRight: const Radius.circular(15),
                bottomLeft: message.senderId == data!.id!
                    ? const Radius.circular(15)
                    : const Radius.circular(0),
                bottomRight: message.senderId == data!.id!
                    ? const Radius.circular(0)
                    : const Radius.circular(15),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Text(
              message.message,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          const Gap(10),
          Text(
            formatChatTime(message.timestamp),
            style: TextStyle(
              color: Colors.black.withOpacity(0.4),
            ),
          ),
        ],
      );
    } else if (message.type == MessageType.audio) {
      return Container(
        decoration: BoxDecoration(
          color: message.senderId == data!.id!
              ? Colors.blueAccent
              : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: message.senderId == data!.id!
                ? const Radius.circular(15)
                : const Radius.circular(0),
            bottomRight: message.senderId == data!.id!
                ? const Radius.circular(0)
                : const Radius.circular(15),
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_arrow,
              color:
                  message.senderId == data!.id! ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 8),
            Text(
              'Audio Message',
              style: TextStyle(
                color:
                    message.senderId == data!.id! ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      );
    } else {
      // Handle unsupported message types
      return Container(
        child: const Text('Unsupported Message Type'),
      );
    }
  }
}
