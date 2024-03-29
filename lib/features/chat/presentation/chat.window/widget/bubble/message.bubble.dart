import 'package:flutter/material.dart';
import 'package:metal/features/chat/domain/entries/message.model.dart';
 

class MessageBubble extends StatelessWidget {
  final MessageModel message;

  const MessageBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment: message.senderId == 'currentUserId'
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
      return Container(
        decoration: BoxDecoration(
          color: message.senderId == 'currentUserId'
              ? Colors.blueAccent
              : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomLeft: message.senderId == 'currentUserId'
                ? Radius.circular(15)
                : Radius.circular(0),
            bottomRight: message.senderId == 'currentUserId'
                ? Radius.circular(0)
                : Radius.circular(15),
          ),
        ),
        padding: EdgeInsets.all(10),
        child: Text(
          message.message,
          style: TextStyle(
            color: message.senderId == 'currentUserId'
                ? Colors.white
                : Colors.black,
          ),
        ),
      );
    } else if (message.type == MessageType.audio) {
      return Container(
        decoration: BoxDecoration(
          color: message.senderId == 'currentUserId'
              ? Colors.blueAccent
              : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomLeft: message.senderId == 'currentUserId'
                ? Radius.circular(15)
                : Radius.circular(0),
            bottomRight: message.senderId == 'currentUserId'
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
              color: message.senderId == 'currentUserId'
                  ? Colors.white
                  : Colors.black,
            ),
            SizedBox(width: 8),
            Text(
              'Audio Message',
              style: TextStyle(
                color: message.senderId == 'currentUserId'
                    ? Colors.white
                    : Colors.black,
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
