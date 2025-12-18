import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/domain/entities/message_dto.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

/// List of chat messages
class ChatMessageList extends StatelessWidget {
  final List<MessageDto> messages;
  final String currentUserId;
  final ScrollController scrollController;
  final bool isLoadingMore;
  final Function(MessageDto)? onReply;
  final Function(String)? onDelete;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.currentUserId,
    required this.scrollController,
    this.isLoadingMore = false,
    this.onReply,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: messages.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (isLoadingMore && index == 0) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final messageIndex = isLoadingMore ? index - 1 : index;
        final message = messages[messageIndex];
        final isMe = message.senderId == currentUserId;

        return _MessageBubble(
          message: message,
          isMe: isMe,
          onReply: onReply != null ? () => onReply!(message) : null,
          onDelete: isMe && onDelete != null ? () => onDelete!(message.id) : null,
        );
      },
    );
  }
}

/// Individual message bubble
class _MessageBubble extends StatelessWidget {
  final MessageDto message;
  final bool isMe;
  final VoidCallback? onReply;
  final VoidCallback? onDelete;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    this.onReply,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showOptions(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (isMe) const Spacer(flex: 1),
            Flexible(
              flex: 3,
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // Reply preview
                  if (message.replyToMessageId != null) _buildReplyPreview(),
                  // Message bubble
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isMe
                          ? AppColors.metalPinkColour
                          : Colors.grey[200],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Message content
                        _buildMessageContent(),
                        const Gap(4),
                        // Timestamp and status
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextView(
                              text: formatTime(
                                isoDateString: message.timestamp.toIso8601String(),
                              ),
                              fontSize: 10,
                              color: isMe ? Colors.white70 : Colors.grey,
                            ),
                            if (isMe) ...[
                              const Gap(4),
                              _buildStatusIcon(),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (!isMe) const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    if (message.isAudio) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_circle_fill,
            color: isMe ? Colors.white : AppColors.metalPinkColour,
            size: 32,
          ),
          const Gap(8),
          Container(
            width: 120,
            height: 30,
            decoration: BoxDecoration(
              color: isMe ? Colors.white24 : Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: TextView(
                text: '🎵 Voice message',
                fontSize: 12,
                color: isMe ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      );
    }

    return TextView(
      text: message.message,
      fontSize: 14,
      color: isMe ? Colors.white : Colors.black87,
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.metalPinkColour.withOpacity(0.7)
            : Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: isMe ? Colors.white : AppColors.metalPinkColour,
            width: 2,
          ),
        ),
      ),
      child: Text(
        message.replyToMessageType == 'audio'
            ? '🎵 Voice message'
            : message.replyToMessageText ?? 'Message',
        style: TextStyle(
          fontSize: 12,
          color: isMe ? Colors.white70 : Colors.black54,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (message.isSending) {
      return const SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          color: Colors.white70,
        ),
      );
    }

    if (message.hasError) {
      return const Icon(
        Icons.error_outline,
        size: 14,
        color: Colors.red,
      );
    }

    return Icon(
      message.isRead ? Icons.done_all : Icons.done,
      size: 14,
      color: message.isRead ? Colors.blue[200] : Colors.white70,
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onReply != null)
              ListTile(
                leading: const Icon(Icons.reply),
                title: const Text('Reply'),
                onTap: () {
                  Navigator.pop(context);
                  onReply!();
                },
              ),
            if (onDelete != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  onDelete!();
                },
              ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement copy
              },
            ),
          ],
        ),
      ),
    );
  }
}
