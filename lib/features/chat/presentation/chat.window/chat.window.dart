import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';
import 'package:metal/features/chat/domain/entries/game.model.dart';
import 'package:metal/features/chat/domain/entries/message.model.dart';

import 'package:metal/features/chat/presentation/chat.window/widget/chat.input.sheet.dart';

import 'package:metal/features/chat/presentation/chat.window/widget/chat.appbar.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/game.tile.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/message.list.dart';

import 'package:metal/features/chat/provider/game.conversation.notifier.dart';

import 'package:metal/features/home_page/domain/entries/connection.model.dart';
import 'package:metal/features/home_page/provider/get.connection.notifier.dart';

import 'package:metal/features/home_page/provider/get.melt.users.notifier.dart';

import 'package:metal/res/res.dart';
import 'package:metal/route/routes.dart';

import 'package:metal/widgets/text_views.dart';

class ChatWindowsPage extends ConsumerStatefulWidget {
  const ChatWindowsPage({super.key, required this.metalId});
  static const name = 'chatWindowsPage';
  static const route = name;

  final String metalId;

  @override
  ConsumerState<ChatWindowsPage> createState() => _ChatWindowsPageState();
}

class _ChatWindowsPageState extends ConsumerState<ChatWindowsPage> {
  GameModel? game;

  ConnectionModel? _connectionModdel;
  @override
  void initState() {
    getConnection();
    super.initState();
  }

  getConnection() {
    _connectionModdel =
        ref.read(getMeltUserProvider.notifier).getMeltUserById(widget.metalId)!;
    print("CONNECTION MODEL:${_connectionModdel?.isAnonymous}");
  }

  UserModel? currentUserData;

  @override
  Widget build(BuildContext context) {
    currentUserData = ref.watch(userStateProvider).data;

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
                meltUserModel: _connectionModdel!.otherUser!,
                connectionModel: _connectionModdel!,
              ),
              GameTile(
                conversationsModel: _connectionModdel!,
              ),
              MessageList(_connectionModdel!.connectionId, onApproved: () {
                ref
                    .read(getConnectionProvider(_connectionModdel!.connectionId)
                        .notifier)
                    .getConnection();
              }),
              ChatBottomSheet(
                meltUserModel: _connectionModdel!.otherUser!,
                connectionModel: _connectionModdel!,
                onGameClick: () async {
                  final gameModel = await Navigator.pushNamed(
                    context,
                    AppRoutes.gamePage,
                  );
                  setState(() {
                    game = gameModel as GameModel?;
                  });
                  if (game != null) {
                    final message = MessageModel(
                      senderId: currentUserData!.id!,
                      type: MessageType.text,
                      timestamp: DateTime.now().toIso8601String(),
                      isRead: false,
                      message: game!.title,
                    );
                    ref
                        .read(gameConversationProvider.notifier)
                        .updateGameConversation(
                            conversatioId: _connectionModdel!.connectionId,
                            gameTitle: game!.title,
                            message: message);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DateDivider extends StatelessWidget {
  const DateDivider({
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
