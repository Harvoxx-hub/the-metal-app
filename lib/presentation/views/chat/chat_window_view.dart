import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/domain/entities/message_dto.dart';
import 'package:metal/presentation/viewmodels/chat/chat_viewmodel_providers.dart';
import 'package:metal/presentation/viewmodels/chat/chat_window_viewmodel.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/presentation/views/chat/widgets/chat_app_bar.dart';
import 'package:metal/presentation/views/chat/widgets/chat_input.dart';
import 'package:metal/presentation/views/chat/widgets/chat_message_list.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/state.handler/empty.state.dart';
import 'package:metal/widgets/state.handler/error.state.dart';
import 'package:metal/widgets/state.handler/loading.state.dart';
import 'package:metal/widgets/text_views.dart';

/// Chat Window View - displays messages and input for a single conversation
class ChatWindowView extends ConsumerStatefulWidget {
  final String connectionId;

  const ChatWindowView({super.key, required this.connectionId});

  @override
  ConsumerState<ChatWindowView> createState() => _ChatWindowViewState();
}

class _ChatWindowViewState extends ConsumerState<ChatWindowView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Load more messages when scrolling to top
    if (_scrollController.position.pixels <=
        _scrollController.position.minScrollExtent + 100) {
      ref
          .read(chatWindowViewModelProvider(widget.connectionId).notifier)
          .loadMoreMessages();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatWindowViewModelProvider(widget.connectionId));
    final connectionAsync = ref.watch(connectionDetailProvider(widget.connectionId));

    return BaseScreen(
      appBarEnabled: false,
      body: Container(
        padding: const EdgeInsets.only(top: 50),
        color: AppColors.metalPinkColour,
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(13),
              topRight: Radius.circular(13),
            ),
            color: AppColors.metalWhite,
          ),
          child: connectionAsync.when(
            loading: () => const LoadingState(),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(20.0),
              child: ErrorState(
                text: error.toString(),
                retry: () => ref.invalidate(connectionDetailProvider(widget.connectionId)),
              ),
            ),
            data: (connection) {
              if (connection == null) {
                return const EmptyState(text: 'Connection not found');
              }

              return _buildChatContent(chatState, connection as ChatConnectionDto);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildChatContent(ChatWindowState chatState, ChatConnectionDto connection) {
    final currentUser = ref.watch(currentUserProvider);
    final otherUser = connection.otherUser;

    if (otherUser == null) {
      return const EmptyState(text: 'User not found');
    }

    final isPendingReceiver = connection.isMeltPending &&
        connection.isUserReceiver(currentUser?.id ?? '');

    return Column(
      children: [
        const Gap(20),
        // App bar
        ChatAppBar(
          connection: connection,
          otherUser: otherUser,
        ),
        // Pending melt banner
        if (isPendingReceiver) _buildPendingMeltBanner(connection),
        // Messages list
        Expanded(
          child: _buildMessagesList(chatState, currentUser?.id ?? ''),
        ),
        // Input (no gap/padding between messages and input)
        ChatInput(
          connectionId: widget.connectionId,
          canSend: !isPendingReceiver,
          connection: connection,
          onMessageSent: _scrollToBottom,
        ),
      ],
    );
  }

  Widget _buildMessagesList(ChatWindowState chatState, String currentUserId) {
    if (chatState.isLoading && chatState.messages.isEmpty) {
      return const LoadingState();
    }

    if (chatState.isError && chatState.messages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: ErrorState(
          text: chatState.errorMessage ?? 'Failed to load messages',
          retry: () {
            ref
                .read(chatWindowViewModelProvider(widget.connectionId).notifier)
                .refresh();
          },
        ),
      );
    }

    if (chatState.messages.isEmpty) {
      return const Center(
        child: TextView(
          text: 'No messages yet\nSay hello!',
          fontSize: 14,
          textAlign: TextAlign.center,
          color: Colors.grey,
        ),
      );
    }

    return Stack(
      children: [
        // Decorative hearts background
        Positioned.fill(
          child: _buildHeartsBackground(),
        ),
        // Messages
        ChatMessageList(
          messages: chatState.messages,
          currentUserId: currentUserId,
          scrollController: _scrollController,
          isLoadingMore: chatState.isLoading,
          onReply: (message) {
            ref
                .read(chatWindowViewModelProvider(widget.connectionId).notifier)
                .setReplyingTo(message);
          },
          onDelete: (messageId) async {
            final confirm = await _showDeleteConfirmation();
            if (confirm == true) {
              await ref
                  .read(chatWindowViewModelProvider(widget.connectionId).notifier)
                  .deleteMessage(messageId);
            }
          },
        ),
      ],
    );
  }

  Widget _buildHeartsBackground() {
    return CustomPaint(
      painter: _HeartsPainter(),
      child: Container(),
    );
  }

  Widget _buildPendingMeltBanner(ChatConnectionDto connection) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.metalPinkColour.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.metalPinkColour.withValues(alpha: 0.3),
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
              text:
                  "You haven't melted with ${connection.otherUser?.displayName ?? 'this user'} yet. Melt to reply.",
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.metalPinkColour,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for decorative hearts background
class _HeartsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.metalPinkColour.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    // Draw hearts at various positions
    final heartPositions = [
      Offset(size.width * 0.1, size.height * 0.15),
      Offset(size.width * 0.85, size.height * 0.25),
      Offset(size.width * 0.15, size.height * 0.45),
      Offset(size.width * 0.9, size.height * 0.65),
      Offset(size.width * 0.2, size.height * 0.80),
      Offset(size.width * 0.75, size.height * 0.90),
    ];

    for (final position in heartPositions) {
      _drawHeart(canvas, paint, position, 20);
    }
  }

  void _drawHeart(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();

    // Start from bottom point
    path.moveTo(center.dx, center.dy + size * 0.3);

    // Left curve
    path.cubicTo(
      center.dx - size * 0.6, center.dy - size * 0.1,
      center.dx - size * 0.6, center.dy - size * 0.6,
      center.dx, center.dy - size * 0.3,
    );

    // Right curve
    path.cubicTo(
      center.dx + size * 0.6, center.dy - size * 0.6,
      center.dx + size * 0.6, center.dy - size * 0.1,
      center.dx, center.dy + size * 0.3,
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
