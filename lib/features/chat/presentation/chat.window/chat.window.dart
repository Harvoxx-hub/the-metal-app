import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';
import 'package:metal/features/chat/domain/entries/message.model.dart';
import 'package:metal/features/chat/domain/entries/game.model.dart';

import 'package:metal/features/chat/presentation/chat.window/widget/chat.input.sheet.dart';

import 'package:metal/features/chat/presentation/chat.window/widget/chat.appbar.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/game.tile.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/message.list.dart';

import 'package:metal/features/chat/provider/game.conversation.notifier.dart';

import 'package:metal/features/thought/data/domain/entries/connection.model.dart';
import 'package:metal/features/thought/provider/get.connection.notifier.dart';
import 'package:metal/features/thought/provider/get.melt.users.notifier.dart';

import 'package:metal/res/res.dart';
import 'package:metal/route/routes.dart';

import 'package:metal/widgets/text_views.dart';
import 'package:metal/widgets/state.handler/loading.state.dart';
import 'package:metal/widgets/state.handler/error.state.dart';
import 'package:metal/widgets/state.handler/empty.state.dart';

class ChatWindowsPage extends ConsumerStatefulWidget {
  const ChatWindowsPage({super.key, required this.connectionId});
  static const name = 'chatWindowsPage';
  static const route = name;

  final String connectionId;

  @override
  ConsumerState<ChatWindowsPage> createState() => _ChatWindowsPageState();
}

class _ChatWindowsPageState extends ConsumerState<ChatWindowsPage> {
  UserModel? currentUserData;
  Function(MessageModel)? _onReplyCallback;

  @override
  Widget build(BuildContext context) {
    currentUserData = ref.watch(userStateProvider).data;

    // Get connection from existing data instead of fetching again
    final connectionsState = ref.watch(getMeltUserProvider);
    ConnectionModel? connection;
    if (connectionsState.data != null) {
      try {
        connection = connectionsState.data!.firstWhere(
          (conn) => conn.connectionId == widget.connectionId,
        );
      } catch (e) {
        connection = null;
      }
    }

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
          child: Builder(
            builder: (context) {
              if (connectionsState.isLoading) {
                return const LoadingState();
              } else if (connectionsState.isError) {
                return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ErrorState(
                      retry: () {
                        ref.read(getMeltUserProvider.notifier).getMeltUsers();
                      },
                      text: connectionsState.errorMessage ??
                          "Failed to load connections",
                    ));
              } else if (connection == null) {
                return const EmptyState(text: "Connection not found");
              }

              // We have the connection data, display the chat interface

              // Check if otherUser exists
              if (connection.otherUser == null) {
                return const EmptyState(text: "User information not available");
              }

              // At this point, connection is guaranteed to be non-null
              final nonNullConnection = connection;

              return Column(
                children: [
                  const Gap(20),
                  ChatWindowsAppBar(
                    key: widget.key,
                    meltUserModel: nonNullConnection.otherUser!,
                    connectionModel: nonNullConnection,
                  ),
                  GameTile(
                    conversationsModel: nonNullConnection,
                  ),
                  MessageList(
                    nonNullConnection.connectionId,
                    onApproved: () {
                      ref.read(getMeltUserProvider.notifier).getMeltUsers();
                    },
                    onReply: (message) {
                      _onReplyCallback?.call(message);
                    },
                  ),
                  ChatBottomSheet(
                    meltUserModel: nonNullConnection.otherUser!,
                    connectionModel: nonNullConnection,
                    onGameClick: () => _handleGameSelection(nonNullConnection),
                    onReplyCallback: (callback) {
                      _onReplyCallback = callback;
                    },
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handleGameSelection(ConnectionModel connection) async {
    final gameModel = await Navigator.pushNamed(
      context,
      AppRoutes.gamePage,
    ) as GameModel?;

    if (gameModel != null) {
      final message = MessageModel(
        senderId: currentUserData!.id!,
        type: MessageType.text,
        timestamp: DateTime.now().toIso8601String(),
        isRead: false,
        message: gameModel.title,
      );

      await ref.read(gameConversationProvider.notifier).updateGameConversation(
            conversatioId: connection.connectionId,
            gameTitle: gameModel.title,
            message: message,
          );

      // Refresh connection to show game tile immediately
      ref
          .read(getConnectionProvider(connection.connectionId).notifier)
          .getConnection();
    }
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
