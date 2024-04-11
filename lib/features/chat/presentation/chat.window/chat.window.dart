import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/chat/domain/entries/message.model.dart';
import 'package:metal/features/chat/presentation/chat.window/chat.window.argument.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/bubble/message.bubble.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/chat.input.sheet.dart';

import 'package:metal/features/chat/presentation/chat.window/widget/chat.appbar.dart';
import 'package:metal/features/chat/provider/get.message.notifier.dart';
import 'package:metal/features/chat/provider/send.message.notifier.dart';
import 'package:metal/features/home_page/domain/entries/melt.user.model.dart';

import 'package:metal/res/res.dart';

import 'package:metal/widgets/text_views.dart';

class ChatWindowsPage extends ConsumerStatefulWidget {
  ChatWindowsPage({super.key, required this.argument}) {}
  static const name = 'chatWindowsPage';
  static const route = '$name';

  final ChatWindowArgument argument;

  @override
  ConsumerState<ChatWindowsPage> createState() => _ChatWindowsPageState();
}

class _ChatWindowsPageState extends ConsumerState<ChatWindowsPage> {
  String? conversationId;
  late Stream<List<MessageModel>> _messagesStream;
  late bool _isMessagesStreamInitialized;
  @override
  void initState() {
    _isMessagesStreamInitialized = false;
    conversationId = widget.argument.conversationId;
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _fetchMessages();
    });

    super.initState();
  }

  void _fetchMessages() async {
    try {
      final messageNotifier = ref.read(getMessageProvider.notifier);

      if (conversationId != null) {
        await messageNotifier.getMessage(conversationId!);
      }

      _messagesStream = ref.read(getMessageProvider).data ?? Stream.empty();

      setState(() {
        _isMessagesStreamInitialized = true;
      });
    } catch (e) {
      print('Failed to fetch messages: $e');
    }
  }

 
 

  

  void _updateconversationId(String id) {
    conversationId = id;
    _fetchMessages();
  }

  UserModel? currentUserData;

  @override
  Widget build(BuildContext context) {
    ref.listen<SendMessageState>(sendMessageProvider, (prev, current) {
      if (current.isSuccess) {
        if (conversationId == null) {
          _updateconversationId(current.data!);
        }
      }
    });
    currentUserData = ref.watch(authProvider).data;

    return BaseScreen(
      appBarEnabled: false,
      body: Container(
        padding: const EdgeInsets.only(top: 50),
        color: AppColors.metalPinkColour,
        child: Container(
          padding: EdgeInsets.only(left: 18.w, right: 18.w),
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(13), topRight: Radius.circular(13)),
              color: AppColors.metalWhite),
          child: Column(
            children: [
              Gap(20.h),
              ChatWindowsAppBar(
                key: widget.key,
                meltUserModel: widget.argument.user,
              ),
              !_isMessagesStreamInitialized
                  ? CircularProgressIndicator()
                  : // or any loading indicator you prefer

                  Expanded(
                      child: StreamBuilder<List<MessageModel>>(
                        stream: _messagesStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else {
                            final messages = snapshot.data ?? [];
                            return ListView.builder(
                              reverse: true,
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];
                                return MessageBubble(
                                  message: message,
                                  // Add any additional parameters needed for customization
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ChatBottomSheet(
                  onSend: (p0) {
                    print(p0);
                    sendTextMessage(p0);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void sendTextMessage(String text) {
    final message = MessageModel(
        senderId: currentUserData!.id!,
        type: MessageType.text,
        timestamp: DateTime.now(),
        state: MessageState.sending,
        message: text,
        recipientId: widget.argument.user.id!);

    ref.read(sendMessageProvider.notifier).sendMessage(message, conversationId);
  }

  //   ZIMEventHandler.onReceivePeerMessage = null;
  //   ZIMEventHandler.onMessageSentStatusChanged = null;
  // }
}

class dateDivider extends StatelessWidget {
  const dateDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
            child: Divider(
          color: AppColors.metalButtonStroke,
          thickness: 1.5,
        )),
        Gap(10.w),
        TextView(text: "Today"),
        Gap(10.w),
        const Expanded(
            child: Divider(
          color: AppColors.metalButtonStroke,
          thickness: 1.5,
        )),
      ],
    );
  }
}
