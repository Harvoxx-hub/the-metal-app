import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/bubble/message.bubble.dart';
import 'package:metal/features/chat/provider/get.message.notifier.dart';
import 'package:metal/features/chat/provider/send.message.notifier.dart';

class MessageList extends ConsumerStatefulWidget {
  const MessageList(this.conversationId, {super.key});

  final String? conversationId;

  @override
  ConsumerState<MessageList> createState() => _MessageListState();
}

class _MessageListState extends ConsumerState<MessageList> {
  String? conversationId;

  @override
  void initState() {
    conversationId = widget.conversationId;

    super.initState();
  }

  void _updateconversationId(String id) {
    conversationId = id;
    ref.read(getMessageList(conversationId ?? "").notifier).getMessageList();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SendMessageState>(sendMessageProvider, (prev, current) {
      if (current.isSuccess) {
        if (conversationId == null) {
          _updateconversationId(current.data!);
        }
      }
    });

    final messages = ref.watch(getMessageList(conversationId ?? ""));

    return Expanded(
        child: Padding(
            padding: EdgeInsets.only(left: 18, right: 18),
            child: messages.isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    reverse: true,
                    itemCount: messages.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      final message = messages.data![index];
                      return MessageBubble(
                        message: message,
                      );
                    },
                  )));
  }
}
