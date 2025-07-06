import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';

 

import 'package:metal/features/home_page/domain/entries/connection.model.dart';

import 'package:metal/features/home_page/provider/get.melt.users.notifier.dart';
import 'package:metal/features/home_page/provider/get.user.notifier.dart';
import 'package:metal/features/settings/provider/get.blocked.user.notifier.dart';
 
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/features/chat/presentation/chat.page.dart'; // Import for searchQueryProvider

class ChatListWidget extends ConsumerStatefulWidget {
  const ChatListWidget({super.key});

  @override
  ConsumerState<ChatListWidget> createState() => _ChatListWidgetState();
}

class _ChatListWidgetState extends ConsumerState<ChatListWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final myMelt = ref.watch(getMeltUserProvider).data;
    final searchQuery =
        ref.watch(searchQueryProvider).toLowerCase(); // Get the search query

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
          _buildChatListContent(myMelt, searchQuery),
        ],
      ),
    );
  }

  Widget _buildChatListContent(
      List<ConnectionModel>? myMelt, String searchQuery) {
    // Filter the chat list based on search query if there's a search term
    List<ConnectionModel>? filteredList = myMelt;

    if (searchQuery.isNotEmpty && myMelt != null) {
      filteredList = [];

      // For each connection, check if it matches the search query
      for (var connection in myMelt) {
        // Get the other user's details to match against the query
        final currentUser = ref.read(userStateProvider).data;
        final metalId = connection.users.firstWhere(
          (user) => user != currentUser!.id,
          orElse: () => "",
        );

        // Get user data to check username
        final userData = ref.read(getUserProvider(metalId)).data;

        // Check if username or last message contains the search query
        if ((userData?.username?.toLowerCase().contains(searchQuery) ??
                false) ||
            (connection.lastMessage?.toLowerCase().contains(searchQuery) ??
                false)) {
          filteredList.add(connection);
        }
      }
    }

    // If there are no matches, show empty state
    if (filteredList == null || filteredList.isEmpty) {
      if (searchQuery.isNotEmpty) {
        return _buildNoSearchResultsMessage();
      }
      return _buildEmptyChatMessage();
    }

    return Expanded(
      flex: 1,
      child: ListView.builder(
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          return chatListItem(
            conversationsModel: filteredList![index],
          );
        },
      ),
    );
  }

  Widget _buildEmptyChatMessage() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Gap(10),
            Gap(20),
            TextView(
              text: "You have no messages yet",
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            Gap(10),
            TextView(
              text: "Tap on any of your metals to kickstart a conversation",
              fontSize: 13,
              fontWeight: FontWeight.w300,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResultsMessage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Gap(20),
            const TextView(
              text: "No matches found",
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            const Gap(10),
            TextView(
              text:
                  "No conversations match '${ref.watch(searchQueryProvider)}'",
              fontSize: 13,
              fontWeight: FontWeight.w300,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class chatListItem extends ConsumerWidget {
  const chatListItem({
    Key? key,
    required this.conversationsModel,
  }) : super(key: key);

  final ConnectionModel conversationsModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //handle blocked user
    final blockedUsers = ref.watch(getBlockUserProvider).data ?? [];
    final isBlocked = blockedUsers.any(
        (blockedUser) => blockedUser['id'] == conversationsModel.otherUser?.id);

    if (isBlocked) {
      return const SizedBox.shrink();
    }

    final currentUser = ref.watch(userStateProvider).data;
    final metalId = conversationsModel.users.firstWhere(
      (user) => user != currentUser!.id,
      orElse: () =>
          "", // Handle cases where all user IDs match the current user
    );
    final getUser = ref.watch(getUserProvider(metalId));

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.chatWindowsPage,
            arguments: getUser.data?.id);
      },
      child: getUser.isLoading
          ? const Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  ProfilePhoto(
                    meltId: getUser.data?.metal ?? '',
                    imgUrl: conversationsModel.isAnonymous
                        ? null
                        : getUser.data?.profilePhoto ?? '',
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextView(
                          text: getUser.data?.username ?? "Unknown",
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        TextView(
                          text: conversationsModel.lastMessage ?? "",
                          fontWeight: FontWeight.w300,
                          fontSize: 13,
                        ),
                      ],
                    ),
                  ),
                  TextView(
                    text: formatTime(
                        isoDateString: conversationsModel.lastUpdatedAt),
                    fontWeight: FontWeight.w300,
                    fontSize: 13,
                  ),
                  //add a badge if the message is unread
                  if (currentUser!.id != conversationsModel.lastSenderId &&
                      conversationsModel.unreadCount > 0)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        conversationsModel.unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
