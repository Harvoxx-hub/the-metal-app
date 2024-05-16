import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/chat/domain/entries/conversations.model.dart';
import 'package:metal/features/chat/domain/entries/game.model.dart';
import 'package:metal/features/chat/domain/entries/message.model.dart';
import 'package:metal/features/chat/presentation/chat.window/chat.window.argument.dart';

import 'package:metal/features/chat/presentation/chat.window/widget/chat.input.sheet.dart';

import 'package:metal/features/chat/presentation/chat.window/widget/chat.appbar.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/game.tile.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/message.list.dart';
import 'package:metal/features/chat/provider/check.conversation.notifier.dart';
import 'package:metal/features/chat/provider/game.conversation.notifier.dart';
import 'package:metal/features/chat/provider/get.converation.notifier.dart';

import 'package:metal/features/chat/provider/send.message.notifier.dart';

import 'package:metal/res/res.dart';
import 'package:metal/route/routes.dart';

import 'package:metal/widgets/text_views.dart';

class ChatWindowsPage extends ConsumerStatefulWidget {
  const ChatWindowsPage({super.key, required this.argument});
  static const name = 'chatWindowsPage';
  static const route = name;

  final ChatWindowArgument argument;

  @override
  ConsumerState<ChatWindowsPage> createState() => _ChatWindowsPageState();
}

class _ChatWindowsPageState extends ConsumerState<ChatWindowsPage> {
  GameModel? game;
  String? conversationId;
  bool checkId = false;

  @override
  void initState() {
    conversationId = widget.argument.conversationId;

    super.initState();
  }

  UserModel? currentUserData;
  ConversationsModel? conversationData;
  void _updateconversationId(String id) {
    setState(() {
      conversationId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CheckConversationState>(
        checkConversationProvider(widget.argument.user.id!), (prev, current) {
      if (current.isSuccess) {
        if (conversationId == null) {
          _updateconversationId(current.data!);
        }
        checkId = true;
        setState(() {});
      }
    });
    currentUserData = ref.watch(authProvider).data;
    conversationId != null
        ? conversationData =
            ref.watch(getConverationProvider(conversationId!)).data
        : null;
    ref.listen<SendMessageState>(sendMessageProvider, (prev, current) {
      if (current.isSuccess) {
        if (conversationId == null) {
          _updateconversationId(current.data!);
        }
      }
    });
    return BaseScreen(
      appBarEnabled: false,
      body: Container(
        padding: const EdgeInsets.only(top: 50),
        color: AppColors.metalPinkColour,
        child: Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(13), topRight: Radius.circular(13)),
              color: AppColors.metalWhite),
          child: Column(
            children: [
              const Gap(20),
              ChatWindowsAppBar(
                key: widget.key,
                meltUserModel: widget.argument.user,
              ),
              conversationData == null
                  ? const SizedBox()
                  : GameTile(
                      conversationsModel: conversationData!,
                    ),
              checkId
                  ? MessageList(conversationId)
                  : const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
              ChatBottomSheet(
                onSend: (p0) {
                  sendTextMessage(p0);
                },
                onGameClick: () async {
                  final gameModel = await Navigator.pushNamed(
                    context,
                    AppRoutes.gamePage,
                  );
                  setState(() {
                    game = gameModel as GameModel?;
                  });
                  if (game != null) {
                    ref
                        .read(gameConversationProvider.notifier)
                        .updateGameConversation(conversationId!, game!.title);
                  }
                },
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
        const TextView(text: "Today"),
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
