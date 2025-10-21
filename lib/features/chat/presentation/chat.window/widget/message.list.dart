import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/features/chat/domain/entries/message.model.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/bubble/swipeable_message_bubble.dart';
import 'package:metal/features/chat/provider/get.message.notifier.dart';
import 'package:metal/widgets/text_views.dart';

class MessageList extends ConsumerStatefulWidget {
  const MessageList(this.conversationId,
      {super.key, this.onApproved, this.onReply});

  final String? conversationId;
  final Function()? onApproved;
  final Function(MessageModel)? onReply;

  @override
  ConsumerState<MessageList> createState() => _MessageListState();
}

class _MessageListState extends ConsumerState<MessageList> {
  String? conversationId;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    conversationId = widget.conversationId;
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Scroll to a specific message by its ID
  void _scrollToMessage(String messageId) {
    print('MessageList: Attempting to scroll to message ID: $messageId');

    final messages = ref.read(getMessageList(conversationId!)).data;
    if (messages == null || !_scrollController.hasClients) {
      print('MessageList: No messages or scroll controller not ready');
      return;
    }

    // Find the index of the message with the given ID
    int targetIndex = -1;
    for (int i = 0; i < messages.length; i++) {
      if (messages[i].id == messageId) {
        targetIndex = i;
        break;
      }
    }

    if (targetIndex == -1) {
      print('MessageList: Message with ID $messageId not found');
      return;
    }

    print('MessageList: Found message at index $targetIndex');

    // Use a more accurate approach: scroll to a position that should bring the message into view
    final double screenHeight = MediaQuery.of(context).size.height;
    final double estimatedMessageHeight = 80.0; // Conservative estimate
    final double targetOffset =
        (targetIndex * estimatedMessageHeight) - (screenHeight * 0.3);

    // Ensure we don't scroll beyond the bounds
    final double maxScroll = _scrollController.position.maxScrollExtent;
    final double clampedOffset = targetOffset.clamp(0.0, maxScroll);

    print(
        'MessageList: Scrolling to offset $clampedOffset (target: $targetOffset, max: $maxScroll)');

    _scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  // Method to scroll to the bottom
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(getMessageList(conversationId!));

    // Scroll to the bottom when the list is updated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 18, right: 18),
        child: messages.isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : messages.isError
                ? const Center(child: TextView(text: "No message"))
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      final message = messages.data![index];

                      return SwipeableMessageBubble(
                        message: message,
                        connectionId: widget.conversationId!,
                        onApproved: () {
                          widget.onApproved?.call();
                        },
                        onReply: widget.onReply,
                        onScrollToMessage: _scrollToMessage,
                      );
                    },
                  ),
      ),
    );
  }
}
