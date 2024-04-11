import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/utils/screen.size.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/chat/domain/entries/message.model.dart';
import 'package:metal/res/res.dart';

class MessageBubble extends ConsumerWidget {
  final MessageModel message;

  MessageBubble({
    Key? key,
    required this.message,
  }) : super(key: key);
  var data;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    data = ref.watch(authProvider).data;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
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
            constraints: BoxConstraints(minWidth: 100, maxWidth: 200),
            decoration: BoxDecoration(
              color: message.senderId == data!.id!
                  ? Colors.grey[300]
                  : AppColors.metalPinkColour.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomLeft: message.senderId == data!.id!
                    ? Radius.circular(15)
                    : Radius.circular(0),
                bottomRight: message.senderId == data!.id!
                    ? Radius.circular(0)
                    : Radius.circular(15),
              ),
            ),
            padding: EdgeInsets.all(16),
            child: Text(
              message.message,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          Gap(10),
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
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomLeft: message.senderId == data!.id!
                ? Radius.circular(15)
                : Radius.circular(0),
            bottomRight: message.senderId == data!.id!
                ? Radius.circular(0)
                : Radius.circular(15),
          ),
        ),
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_arrow,
              color:
                  message.senderId == data!.id! ? Colors.white : Colors.black,
            ),
            SizedBox(width: 8),
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
        child: Text('Unsupported Message Type'),
      );
    }
  }
}
