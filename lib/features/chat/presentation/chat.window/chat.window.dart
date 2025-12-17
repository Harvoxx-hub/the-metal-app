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
import 'package:metal/features/thought/provider/get.user.notifier.dart';

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

    // Get connection from existing data first
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

    // If connection not found in list, fetch it directly
    final directConnectionState = connection == null
        ? ref.watch(getConnectionProvider(widget.connectionId))
        : null;

    // Use direct connection if available, otherwise use connection from list
    final finalConnection = connection ?? 
        (directConnectionState?.isSuccess == true 
            ? directConnectionState!.data 
            : null);

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
              // Show loading if fetching connection directly
              if (connection == null && directConnectionState != null) {
                if (directConnectionState.isLoading) {
                  return const LoadingState();
                } else if (directConnectionState.isError) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ErrorState(
                      retry: () {
                        ref.read(getConnectionProvider(widget.connectionId).notifier).getConnection();
                      },
                      text: directConnectionState.errorMessage ??
                          "Failed to load connection",
                    ),
                  );
                }
              }

              // Show loading if connections list is loading and we don't have direct connection
              if (connectionsState.isLoading && finalConnection == null) {
                return const LoadingState();
              } else if (connectionsState.isError && finalConnection == null) {
                return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ErrorState(
                      retry: () {
                        ref.read(getMeltUserProvider.notifier).getMeltUsers();
                      },
                      text: connectionsState.errorMessage ??
                          "Failed to load connections",
                    ));
              } else if (finalConnection == null) {
                return const EmptyState(text: "Connection not found");
              }

              // We have the connection data, display the chat interface
              // At this point, finalConnection is guaranteed to be non-null

              // Check if otherUser exists
              if (finalConnection.otherUser == null) {
                // If otherUser is missing, fetch it directly
                // This can happen for newly created connections
                final currentUserId = currentUserData?.id;
                if (currentUserId != null) {
                  final otherUserId = finalConnection.users
                      .firstWhere((id) => id != currentUserId, orElse: () => '');
                  
                  if (otherUserId.isNotEmpty) {
                    // Fetch user data
                    final userState = ref.watch(getUserProvider(otherUserId));
                    if (userState.isLoading) {
                      return const LoadingState();
                    } else if (userState.isSuccess && userState.data != null) {
                      // User data fetched, update connection and continue
                      final updatedConnection = finalConnection.copyWith(
                        otherUser: userState.data,
                      );
                      // Use updated connection
                      final nonNullConnection = updatedConnection;
                      
                      return Column(
                        children: [
                          const Gap(20),
                          ChatWindowsAppBar(
                            key: widget.key,
                            meltUserModel: nonNullConnection.otherUser!,
                            connectionModel: nonNullConnection,
                          ),
                          if (nonNullConnection.isMeltPending &&
                              nonNullConnection.isUserReceiver(currentUserData!.id!))
                            _buildPendingMeltBanner(nonNullConnection),
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
                    }
                  }
                }
                
                // If we can't fetch user, show loading and trigger refresh
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(getMeltUserProvider.notifier).getMeltUsers();
                });
                return const LoadingState();
              }

              // At this point, connection is guaranteed to be non-null with otherUser
              final nonNullConnection = finalConnection;

              return Column(
                children: [
                  const Gap(20),
                  ChatWindowsAppBar(
                    key: widget.key,
                    meltUserModel: nonNullConnection.otherUser!,
                    connectionModel: nonNullConnection,
                  ),
                  // Show banner if melt is pending and current user is receiver
                  if (nonNullConnection.isMeltPending &&
                      nonNullConnection.isUserReceiver(currentUserData!.id!))
                    _buildPendingMeltBanner(nonNullConnection),
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

  Widget _buildPendingMeltBanner(ConnectionModel connection) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.metalPinkColour.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.metalPinkColour.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.metalPinkColour,
            size: 20,
          ),
          const Gap(12),
          Expanded(
            child: TextView(
              text: "You haven't melted with ${connection.otherUser?.username ?? 'this user'} yet. Melt to reply.",
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.metalPinkColour,
            ),
          ),
        ],
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
