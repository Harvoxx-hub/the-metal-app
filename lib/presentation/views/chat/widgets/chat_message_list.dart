import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  final Function(String messageId, String action)? onUnmeltAction;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.currentUserId,
    required this.scrollController,
    this.isLoadingMore = false,
    this.onReply,
    this.onDelete,
    this.onUnmeltAction,
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
          onUnmeltAction: onUnmeltAction,
        );
      },
    );
  }
}

/// Individual message bubble with swipe-to-reply
class _MessageBubble extends StatefulWidget {
  final MessageDto message;
  final bool isMe;
  final VoidCallback? onReply;
  final VoidCallback? onDelete;
  final Function(String messageId, String action)? onUnmeltAction;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    this.onReply,
    this.onDelete,
    this.onUnmeltAction,
  });

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _dragOffset = 0;
  static const double _maxDragDistance = 80.0;
  static const double _triggerDistance = 60.0;
  bool _hasTriggeredHaptic = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _controller.stop();
    _hasTriggeredHaptic = false;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      // Allow swipe right for all messages (like WhatsApp)
      _dragOffset += details.delta.dx;
      // Clamp to only allow right swipe with max distance
      _dragOffset = _dragOffset.clamp(0, _maxDragDistance);

      // Haptic feedback when reaching trigger distance
      if (_dragOffset >= _triggerDistance && !_hasTriggeredHaptic) {
        HapticFeedback.lightImpact();
        _hasTriggeredHaptic = true;
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    // If dragged past trigger distance, trigger reply
    if (_dragOffset >= _triggerDistance && widget.onReply != null) {
      HapticFeedback.mediumImpact();
      widget.onReply!();
    }

    // Animate back to original position
    _animation = Tween<double>(begin: _dragOffset, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward(from: 0).then((_) {
      if (mounted) {
        setState(() {
          _dragOffset = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showOptions(context),
      onHorizontalDragStart:
          widget.onReply != null ? _onHorizontalDragStart : null,
      onHorizontalDragUpdate:
          widget.onReply != null ? _onHorizontalDragUpdate : null,
      onHorizontalDragEnd: widget.onReply != null ? _onHorizontalDragEnd : null,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final offset =
              _controller.isAnimating ? _animation.value : _dragOffset;
          final progress = (offset / _maxDragDistance).clamp(0.0, 1.0);

          return Stack(
            alignment:
                widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
            children: [
              // Reply icon that appears behind the message
              if (offset > 0)
                Positioned(
                  left: widget.isMe ? null : 8,
                  right: widget.isMe ? null : null,
                  child: Opacity(
                    opacity: progress,
                    child: Transform.scale(
                      scale: 0.5 + (progress * 0.5),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color:
                              AppColors.metalPinkColour.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.reply,
                          color: AppColors.metalPinkColour,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              // The message bubble
              Transform.translate(
                offset: Offset(offset, 0),
                child: _buildBubbleContent(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBubbleContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (widget.isMe) const Spacer(flex: 1),
          Flexible(
            flex: 3,
            child: Column(
              crossAxisAlignment: widget.isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Reply preview
                if (widget.message.replyToMessageId != null)
                  _buildReplyPreview(),
                // Message bubble
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: widget.message.isPromptReactionMessage
                        ? (widget.isMe
                            ? AppColors.metalPinkColour.withOpacity(0.15)
                            : AppColors.metalPinkColour.withOpacity(0.1))
                        : (widget.isMe
                            ? const Color(0xFFE8E8E8)
                            : const Color(0xFFF5E6F5)),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(widget.isMe ? 18 : 4),
                      bottomRight: Radius.circular(widget.isMe ? 4 : 18),
                    ),
                    border: widget.message.isPromptReactionMessage
                        ? Border.all(
                            color: AppColors.metalPinkColour.withOpacity(0.3),
                            width: 1.5,
                          )
                        : null,
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
                          isoDateString:
                              widget.message.timestamp.toIso8601String(),
                        ),
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                      if (widget.isMe) ...[
                        const Gap(4),
                        _buildStatusIcon(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!widget.isMe) const Spacer(flex: 1),
        ],
      ),
    );
  }

  Widget _buildMessageContent() {
    if (widget.message.isAudio) {
      // Use the audio player widget
      return SizedBox(
        width: 220,
        child: AudioPlayerWidget(
          audioUrl: widget.message.content ?? '',
          isMe: widget.isMe,
        ),
      );
    }

    // Handle prompt reaction message type
    if (widget.message.isPromptReactionMessage) {
      return _buildPromptReactionMessage();
    }

    // Handle unmelt message type
    if (widget.message.isUnmelt) {
      return _buildUnmeltMessage();
    }

    return TextView(
      text: widget.message.message,
      fontSize: 14,
      color: Colors.black87,
    );
  }

  /// Build the prompt reaction message UI
  Widget _buildPromptReactionMessage() {
    final questionText = widget.message.promptQuestionText ?? '';
    final answerText = widget.message.promptAnswer ?? '';
    final comment = widget.message.comment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with icon and label
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.metalPinkColour.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 16,
                color: AppColors.metalPinkColour,
              ),
            ),
            const Gap(8),
            const TextView(
              text: 'Prompt Reaction',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ],
        ),
        const Gap(12),

        // Prompt question
        if (questionText.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextView(
                  text: questionText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                if (answerText.isNotEmpty) ...[
                  const Gap(6),
                  TextView(
                    text: '\u201C$answerText\u201D',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ],
              ],
            ),
          ),
          const Gap(12),
        ],

        // Comment (if provided)
        if (comment != null && comment.isNotEmpty) ...[
          TextView(
            text: comment,
            fontSize: 14,
            color: Colors.black87,
          ),
        ] else if (questionText.isEmpty && answerText.isEmpty) ...[
          // Fallback to message text if structured data is missing
          TextView(
            text: widget.message.message,
            fontSize: 14,
            color: Colors.black87,
          ),
        ],
      ],
    );
  }

  /// Build the unmelt request message UI
  Widget _buildUnmeltMessage() {
    // Check the unmelt status from message metadata (if available)
    final unmeltStatus = widget.message.unmeltStatus;
    final isCurrentUserSender = widget.isMe;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.visibility,
              size: 16,
              color: AppColors.metalPinkColour,
            ),
            const Gap(8),
            const TextView(
              text: 'Unmelt Request',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ],
        ),
        const Gap(8),
        if (unmeltStatus == 'pending') ...[
          if (!isCurrentUserSender) ...[
            // Show approve/reject buttons for receiver
            const TextView(
              text: 'Do you want to reveal your identities to each other?',
              fontSize: 12,
              color: Colors.black54,
            ),
            const Gap(12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildUnmeltActionButton(
                  'Approve',
                  AppColors.metalPinkColour,
                  Colors.white,
                  () => _handleUnmeltAction('approve'),
                ),
                const Gap(8),
                _buildUnmeltActionButton(
                  'Reject',
                  Colors.grey[300]!,
                  Colors.black87,
                  () => _handleUnmeltAction('reject'),
                ),
              ],
            ),
          ] else ...[
            const TextView(
              text: 'Waiting for approval...',
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.black54,
            ),
          ],
        ] else if (unmeltStatus == 'approved') ...[
          const TextView(
            text: '✓ Identities revealed!',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.green,
          ),
        ] else if (unmeltStatus == 'rejected') ...[
          const TextView(
            text: '✗ Request declined',
            fontSize: 12,
            color: Colors.red,
          ),
        ] else ...[
          const TextView(
            text: 'Request to reveal identities',
            fontSize: 12,
            color: Colors.black54,
          ),
        ],
      ],
    );
  }

  Widget _buildUnmeltActionButton(
    String text,
    Color bgColor,
    Color textColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextView(
          text: text,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  void _handleUnmeltAction(String action) {
    // This will be called when user approves/rejects unmelt
    widget.onUnmeltAction?.call(widget.message.id, action);
  }

  Widget _buildReplyPreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: widget.isMe ? const Color(0xFFD0D0D0) : const Color(0xFFE8D4E8),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: AppColors.metalPinkColour,
            width: 2,
          ),
        ),
      ),
      child: Text(
        widget.message.replyToMessageType == 'audio'
            ? '🎵 Voice message'
            : widget.message.replyToMessageText ?? 'Message',
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
    if (widget.message.isSending) {
      return const SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          color: Colors.grey,
        ),
      );
    }

    if (widget.message.hasError) {
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
        widget.message.isRead ? AppColors.metalPinkColour : Colors.grey,
        BlendMode.srcIn,
      ),
    );
  }

  void _copyMessage(BuildContext context) {
    final textToCopy = widget.message.message.trim();
    if (textToCopy.isEmpty) {
      Fluttertoast.showToast(
        msg: 'No text to copy',
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    Clipboard.setData(ClipboardData(text: textToCopy));
    Fluttertoast.showToast(
      msg: 'Message copied to clipboard',
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.onReply != null)
              ListTile(
                leading: const Icon(Icons.reply),
                title: const Text('Reply'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onReply!();
                },
              ),
            if (widget.onDelete != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  widget.onDelete!();
                },
              ),
            if (!widget.message.isAudio)
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy'),
                onTap: () {
                  Navigator.pop(context);
                  _copyMessage(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}
