import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/services/chat_assistant_analytics.dart';
import 'package:metal/core/services/firebase.remote.config.service.dart';
import 'package:metal/domain/entities/message_dto.dart';
import 'package:metal/presentation/viewmodels/chat/chat_assistant_viewmodel.dart';
import 'package:metal/presentation/viewmodels/chat/chat_viewmodel_providers.dart';
import 'package:metal/presentation/viewmodels/chat/chat_window_viewmodel.dart';
import 'package:metal/presentation/viewmodels/connection/connection_providers.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/presentation/views/chat/widgets/chat_app_bar.dart';
import 'package:metal/presentation/views/chat/widgets/chat_input.dart';
import 'package:metal/presentation/views/chat/widgets/chat_message_list.dart';
import 'package:metal/presentation/views/chat/widgets/chat_suggestion_bar.dart';
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
  final TextEditingController _chatTextController = TextEditingController();

  /// Avoid re-feeding the same transcript into the assistant on every rebuild.
  String? _lastChatAssistantMessageSignature;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Load messages when chat window opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatWindowViewModelProvider(widget.connectionId).notifier).loadMessages();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _chatTextController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // With reverse: true, older messages are towards maxScrollExtent
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      ref
          .read(chatWindowViewModelProvider(widget.connectionId).notifier)
          .loadMoreMessages();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // With reverse: true, the bottom (newest messages) is at offset 0
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState =
        ref.watch(chatWindowViewModelProvider(widget.connectionId));
    final connectionAsync =
        ref.watch(connectionDetailProvider(widget.connectionId));
    
    // Listen to chat state changes and refresh connection when messages are marked as read
    ref.listen<ChatWindowState>(
      chatWindowViewModelProvider(widget.connectionId),
      (previous, current) {
        // When messages are successfully loaded, invalidate connection to refresh unread count
        if (current.isSuccess && previous?.isSuccess != true) {
          // Invalidate connection detail to refresh unread count
          ref.invalidate(connectionDetailProvider(widget.connectionId));
          // BUG-020: Open chat at most recent message (scroll to bottom)
          if (current.messages.isNotEmpty) {
            _scrollToBottom();
          }
        }

        // AI assistant: only react when the message list actually changes (not every rebuild).
        final connection = ref
            .read(connectionDetailProvider(widget.connectionId))
            .valueOrNull;
        if (connection is ChatConnectionDto) {
          _syncChatAssistantIfEnabled(
            current,
            connection,
            ref.read(currentUserProvider)?.id,
          );
        }
      },
    );

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
                retry: () => ref
                    .invalidate(connectionDetailProvider(widget.connectionId)),
              ),
            ),
            data: (connection) {
              if (connection == null) {
                return const EmptyState(text: 'Connection not found');
              }

              return _buildChatContent(
                  chatState, connection as ChatConnectionDto);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildChatContent(
      ChatWindowState chatState, ChatConnectionDto connection) {
    final currentUser = ref.watch(currentUserProvider);
    final otherUser = connection.otherUser;

    if (otherUser == null) {
      return const EmptyState(text: 'User not found');
    }

    // BUG-011: Allow reply when there are already messages (don't show "Melt to reply" / block input)
    final pendingReceiverNoMessages = connection.meltStatus == 'pending' &&
        connection.isUserReceiver(currentUser?.id ?? '') &&
        chatState.messages.isEmpty;
    final canSend = !pendingReceiverNoMessages;

    final assistantEnabled = canSend &&
        FirebaseRemoteConfigService().isChatAssistantEnabled();

    if (assistantEnabled) {
      _syncChatAssistantIfEnabled(
        chatState,
        connection,
        currentUser?.id,
      );
    } else {
      _lastChatAssistantMessageSignature = null;
    }

    return Column(
      children: [
        const Gap(20),
        // App bar
        ChatAppBar(
          connection: connection,
          otherUser: otherUser,
        ),
        // Pending melt banner (only when no messages yet)
        if (pendingReceiverNoMessages) _buildPendingMeltBanner(connection),
        // Messages list
        Expanded(
          child: _buildMessagesList(chatState, currentUser?.id ?? ''),
        ),
        // AI suggestion bar (only when user can send and feature is enabled)
        if (assistantEnabled)
          ChatSuggestionBar(
            connectionId: widget.connectionId,
            onSuggestionTapped: (suggestion) {
              _chatTextController.text = suggestion;
              _chatTextController.selection = TextSelection.fromPosition(
                TextPosition(offset: suggestion.length),
              );
              ChatAssistantAnalytics.logSuggestionTapped(
                mode: ref
                    .read(chatAssistantProvider(widget.connectionId))
                    .mode
                    .apiValue,
                index: ref
                    .read(chatAssistantProvider(widget.connectionId))
                    .suggestions
                    .indexOf(suggestion),
              );
            },
          ),
        if (assistantEnabled) const Gap(4),
        // Input
        ChatInput(
          connectionId: widget.connectionId,
          canSend: canSend,
          connection: connection,
          onMessageSent: _scrollToBottom,
          textController: _chatTextController,
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
                  .read(
                      chatWindowViewModelProvider(widget.connectionId).notifier)
                  .deleteMessage(messageId);
            }
          },
          onUnmeltAction: (messageId, action) async {
            await _handleUnmeltAction(messageId, action);
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

  /// Handle unmelt action (approve/reject)
  Future<void> _handleUnmeltAction(String messageId, String action) async {
    final connectionId = widget.connectionId;

    try {
      final repository = ref.read(connectionRepositoryProvider);
      final result = await repository.processUnmeltAction(
        connectionId,
        messageId,
        action,
      );

      if (mounted) {
        if (result.isSuccess) {
          Fluttertoast.showToast(
            msg: action == 'approve'
                    ? 'Identities revealed! You can now see each other\'s photos.'
                    : 'Unmelt request declined.',
          );

          // Refresh messages to update the unmelt message status
          ref
              .read(chatWindowViewModelProvider(connectionId).notifier)
              .loadMessages();
        } else {
          Fluttertoast.showToast(
            msg: result.errorMessage ?? 'Failed to process unmelt action',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(msg: 'Error: $e');
      }
    }
  }

  static String _messageListSignature(List<MessageDto> messages) {
    if (messages.isEmpty) return '0:empty';
    return '${messages.length}:${messages.first.id}:${messages.last.id}';
  }

  /// Notifies the chat assistant only when the transcript identity changes.
  void _syncChatAssistantIfEnabled(
    ChatWindowState chatState,
    ChatConnectionDto connection,
    String? currentUserId,
  ) {
    final pendingReceiverNoMessages = connection.meltStatus == 'pending' &&
        connection.isUserReceiver(currentUserId ?? '') &&
        chatState.messages.isEmpty;
    final canSend = !pendingReceiverNoMessages;
    if (!canSend ||
        !FirebaseRemoteConfigService().isChatAssistantEnabled()) {
      return;
    }

    final sig = _messageListSignature(chatState.messages);
    if (_lastChatAssistantMessageSignature == sig) return;
    _lastChatAssistantMessageSignature = sig;

    ref.read(chatAssistantProvider(widget.connectionId).notifier).onMessagesChanged(
          chatState.messages,
          currentUserId,
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
      center.dx - size * 0.6,
      center.dy - size * 0.1,
      center.dx - size * 0.6,
      center.dy - size * 0.6,
      center.dx,
      center.dy - size * 0.3,
    );

    // Right curve
    path.cubicTo(
      center.dx + size * 0.6,
      center.dy - size * 0.6,
      center.dx + size * 0.6,
      center.dy - size * 0.1,
      center.dx,
      center.dy + size * 0.3,
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
