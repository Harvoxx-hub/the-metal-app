import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/domain/entities/message_dto.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/presentation/viewmodels/chat/chat_list_viewmodel.dart';
import 'package:metal/presentation/viewmodels/chat/chat_viewmodel_providers.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/state.handler/empty.state.dart';
import 'package:metal/widgets/state.handler/error.state.dart';
import 'package:metal/widgets/state.handler/loading.state.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

/// Chat List View - displays all chat connections
class ChatListView extends ConsumerStatefulWidget {
  const ChatListView({super.key});

  @override
  ConsumerState<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends ConsumerState<ChatListView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(chatListViewModelProvider.notifier).search(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const Gap(26),
        Expanded(child: _buildChatList()),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.00, -1.00),
          end: Alignment(0, 1),
          colors: [Color(0xFFDB217A), Color(0xFFF00E3E)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 24.0, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EditFormField(
              controller: _searchController,
              label: 'Search',
              keyboardType: TextInputType.text,
              autoValidate: false,
              prefixWidget: SvgPicture.asset(
                Assets.icons.chatsSearch.path,
                height: 24,
                width: 24,
              ),
              radius: 34,
            ),
            const Gap(10),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList() {
    final chatState = ref.watch(chatListViewModelProvider);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TextView(
            text: "Messages",
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          const Gap(10),
          Expanded(child: _buildListContent(chatState)),
        ],
      ),
    );
  }

  Widget _buildListContent(ChatListState chatState) {
    if (chatState.isLoading && chatState.connections.isEmpty) {
      return const LoadingState();
    }

    if (chatState.isError && chatState.connections.isEmpty) {
      return ErrorState(
        text: chatState.errorMessage ?? 'Failed to load chats',
        retry: () {
          ref.read(chatListViewModelProvider.notifier).refresh();
        },
      );
    }

    final connections = chatState.filteredConnections;

    if (connections.isEmpty) {
      if (chatState.searchQuery.isNotEmpty) {
        return _buildNoSearchResults(chatState.searchQuery);
      }
      return const EmptyState(
        text: 'No messages yet\nTap on any of your metals to start a conversation',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(chatListViewModelProvider.notifier).refresh(),
      child: ListView.builder(
        itemCount: connections.length,
        itemBuilder: (context, index) {
          return _ChatListItem(connection: connections[index]);
        },
      ),
    );
  }

  Widget _buildNoSearchResults(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const TextView(
            text: "No matches found",
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          const Gap(10),
          TextView(
            text: "No conversations match '$query'",
            fontSize: 13,
            fontWeight: FontWeight.w300,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Individual chat list item
class _ChatListItem extends ConsumerWidget {
  final ChatConnectionDto connection;

  const _ChatListItem({required this.connection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final otherUser = connection.otherUser;

    if (otherUser == null) {
      return const SizedBox.shrink();
    }

    final isUnread = currentUser?.id != connection.lastSenderId &&
        connection.unreadCount > 0;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.chatWindowView,
          arguments: connection.id,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ProfilePhoto(
              meltId: otherUser.metal ?? '',
              imgUrl: connection.isAnonymous ? null : otherUser.profilePhoto,
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextView(
                          text: otherUser.displayName,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // Pending melt indicator
                      if (connection.isMeltPending &&
                          connection.isUserReceiver(currentUser?.id ?? ''))
                        _buildMeltBadge(),
                    ],
                  ),
                  Text(
                    connection.lastMessage ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextView(
                  text: formatTime(isoDateString: connection.lastUpdatedAt?.toIso8601String()),
                  fontWeight: FontWeight.w300,
                  fontSize: 13,
                ),
                if (isUnread) _buildUnreadBadge(connection.unreadCount),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeltBadge() {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.metalPinkColour.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.metalPinkColour,
          width: 1,
        ),
      ),
      child: const TextView(
        text: "Melt to reply",
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.metalPinkColour,
      ),
    );
  }

  Widget _buildUnreadBadge(int count) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
