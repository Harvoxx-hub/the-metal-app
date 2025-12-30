import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/domain/entities/message_dto.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/presentation/views/chat/widgets/audio_player_widget.dart';
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
      itemCount:
          messages.length + (isLoadingMore ? 1 : 0) + 1, // +1 for date divider
      itemBuilder: (context, index) {
        if (isLoadingMore && index == 0) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        // Show "Today" divider after loading indicator (or at start)
        final dividerIndex = isLoadingMore ? 1 : 0;
        if (index == dividerIndex) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: TextView(
                text: 'Today',
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        final messageIndex = (isLoadingMore ? index - 2 : index - 1);
        final message = messages[messageIndex];
        final isMe = message.senderId == currentUserId;

        return _MessageBubble(
          message: message,
          isMe: isMe,
          onReply: onReply != null ? () => onReply!(message) : null,
          // Only allow delete if message has a valid ID (not temp ID and not empty)
          onDelete: isMe &&
                  onDelete != null &&
                  message.id.isNotEmpty &&
                  !message.id.startsWith('temp_')
              ? () => onDelete!(message.id)
              : null,
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
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
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
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isMe
                          ? const Color(0xFFE8E8E8)
                          : const Color(0xFFF5E6F5),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isMe ? 18 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 18),
                      ),
                    ),
                    child: _buildMessageContent(),
                  ),
                  const Gap(4),
                  // Timestamp and status below bubble
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextView(
                          text: formatTime(
                            isoDateString: message.timestamp.toIso8601String(),
                          ),
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                        if (isMe) ...[
                          const Gap(4),
                          _buildStatusIcon(),
                        ],
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
      // Use the audio player widget
      return SizedBox(
        width: 220,
        child: AudioPlayerWidget(
          audioUrl: message.content ?? '',
          isMe: isMe,
        ),
      );
    }

    return TextView(
      text: message.message,
      fontSize: 14,
      color: Colors.black87,
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFD0D0D0) : const Color(0xFFE8D4E8),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: AppColors.metalPinkColour,
            width: 2,
          ),
        ),
      ),
      child: Text(
        message.replyToMessageType == 'audio'
            ? '🎵 Voice message'
            : message.replyToMessageText ?? 'Message',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black54,
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
          color: Colors.grey,
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

    return Assets.icons.chatsWindowactiveDoneAll.svg(
      width: 14,
      height: 14,
      colorFilter: ColorFilter.mode(
        message.isRead ? AppColors.metalPinkColour : Colors.grey,
        BlendMode.srcIn,
      ),
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
                title:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
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
