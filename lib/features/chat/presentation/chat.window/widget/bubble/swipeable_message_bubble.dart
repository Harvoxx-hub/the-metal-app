import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';
import 'package:metal/features/chat/domain/entries/message.model.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/bubble/message.bubble.dart';

class SwipeableMessageBubble extends ConsumerStatefulWidget {
  final MessageModel message;
  final String connectionId;
  final Function()? onApproved;
  final Function(MessageModel)? onReply;
  final Function(String)? onScrollToMessage;

  const SwipeableMessageBubble({
    super.key,
    required this.message,
    required this.connectionId,
    this.onApproved,
    this.onReply,
    this.onScrollToMessage,
  });

  @override
  ConsumerState<SwipeableMessageBubble> createState() =>
      _SwipeableMessageBubbleState();
}

class _SwipeableMessageBubbleState extends ConsumerState<SwipeableMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleSwipeLeft() {
    _animationController.forward();
    widget.onReply?.call(widget.message);
  }

  void _handleSwipeRight() {
    _animationController.forward();
    widget.onReply?.call(widget.message);
  }

  void _resetSwipe() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // Check if this is the current user's message
    final userData = ref.watch(userStateProvider).data;
    final isCurrentUser = widget.message.senderId == userData?.id;

    return GestureDetector(
      onPanUpdate: (details) {
        // Detect swipe gestures based on message ownership

        if (isCurrentUser) {
          // For current user's messages: swipe LEFT to reply
          if (details.delta.dx < -5) {
            _handleSwipeLeft();
          }
        } else {
          // For other user's messages: swipe RIGHT to reply
          if (details.delta.dx > 5) {
            _handleSwipeRight();
          }
        }
      },
      onTap: _resetSwipe,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
                isCurrentUser ? -_animation.value * 50 : _animation.value * 50,
                0),
            child: Opacity(
              opacity: 1.0 - (_animation.value * 0.3),
              child: Stack(
                children: [
                  // Reply indicator that appears on swipe
                  if (_animation.value > 0)
                    Positioned(
                      right: isCurrentUser ? 0 : null,
                      left: isCurrentUser ? null : 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 50,
                        decoration: BoxDecoration(
                          color:
                              Colors.green.withOpacity(_animation.value * 0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.reply,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),

                  // Main message bubble
                  MessageBubble(
                    message: widget.message,
                    connectionId: widget.connectionId,
                    onApproved: widget.onApproved,
                    onReply: widget.onReply,
                    onScrollToMessage: widget.onScrollToMessage,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
