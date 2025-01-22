import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/utils/date.formart.dart';

import 'package:metal/features/authentication/provider/auth.notifier.dart';

import 'package:metal/features/home_page/domain/entries/connection.model.dart';

import 'package:metal/features/home_page/provider/get.melt.users.notifier.dart';
import 'package:metal/features/home_page/provider/get.user.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';

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
          _buildChatListContent(myMelt),
        ],
      ),
    );
  }

  Widget _buildChatListContent(List<ConnectionModel>? myMelt) {
    return Expanded(
      flex: 1,
      child: ListView.builder(
        itemCount: myMelt!.length,
        itemBuilder: (context, index) {
          return chatListItem(
            conversationsModel: myMelt[index],
          );
        },
      ),
    );
  }

  Widget _buildEmptyChatMessage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          children: [
            const Gap(10),
            Assets.images.emptyChat.image(height: 121),
            const Gap(20),
            const TextView(
              text: "You have no messages yet",
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            const Gap(10),
            const TextView(
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

class chatListItem extends ConsumerWidget {
  const chatListItem({
    Key? key,
    required this.conversationsModel,
  }) : super(key: key);

  final ConnectionModel conversationsModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider).data;
    final metalId = conversationsModel.users.firstWhere(
      (user) => user != currentUser!.id,
      orElse: () =>
          "", // Handle cases where all user IDs match the current user
    );
    final getUser = ref.watch(getUserProvider(metalId));
 
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.chatWindowsPage,
            arguments: getUser.data!.id);
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
                      meltId: getUser.data!.metal!,
                      imgUrl: conversationsModel.isAnonymous
                          ? null
                          : getUser.data!.profilePhoto ?? null),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextView(
                          text: getUser.data!.username ?? "Unknown",
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
                ],
              ),
            ),
    );
  }
}
