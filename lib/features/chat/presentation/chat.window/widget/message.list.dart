import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/bubble/message.bubble.dart';
import 'package:metal/features/chat/provider/get.message.notifier.dart';
import 'package:metal/widgets/text_views.dart';

class MessageList extends ConsumerStatefulWidget {
  const MessageList(this.conversationId, {super.key});

  final String? conversationId;

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
                      return MessageBubble(
                        message: message,
                        connectionId: widget.conversationId!,
                      );
                    },
                  ),
      ),
    );
  }
}