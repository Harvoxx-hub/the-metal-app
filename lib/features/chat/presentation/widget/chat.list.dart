import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
 
 
import 'package:metal/features/chat/presentation/chat.page.dart';
import 'package:metal/features/chat/presentation/widget/chat.list.item.dart';
import 'package:metal/features/home_page/domain/entries/connection.model.dart';
import 'package:metal/features/home_page/provider/get.melt.users.notifier.dart';
 
import 'package:metal/widgets/text_views.dart';
 

class ChatListWidget extends ConsumerStatefulWidget {
  const ChatListWidget({super.key});

  @override
  ConsumerState<ChatListWidget> createState() => _ChatListWidgetState();
}

class _ChatListWidgetState extends ConsumerState<ChatListWidget> {
  @override
  Widget build(BuildContext context) {
    final myMelt = ref.watch(getMeltUserProvider).data ?? [];
    final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

    // Filter the list based on username
    final filteredList = myMelt.where((connection) {
      return connection.otherUser!.username!.toLowerCase().contains(searchQuery);
    }).toList();

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
          filteredList.isEmpty
              ? _buildEmptyChatMessage()
              : _buildChatListContent(filteredList),
        ],
      ),
    );
  }

  Widget _buildChatListContent(List<ConnectionModel> filteredList) {
    return Expanded(
      child: ListView.builder(
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          return ChatListItem(
            conversationsModel: filteredList[index],
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
}
