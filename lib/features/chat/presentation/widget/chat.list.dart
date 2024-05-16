import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/utils/screen.size.dart';

import 'package:metal/features/chat/domain/entries/conversations.model.dart';
import 'package:metal/features/chat/presentation/chat.window/chat.window.argument.dart';
import 'package:metal/features/chat/provider/get.chatlist.notifier.dart';
import 'package:metal/features/home_page/domain/entries/melt.user.model.dart';
import 'package:metal/features/home_page/provider/get.melt.users.notifier.dart';
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
    final myMelt = ref.watch(getMeltUserProvider);
    final chatList = ref.watch(chatListProvider);

    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const TextView(
            text: "Messages",
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          const Gap(10),
          SizedBox(
              height: getDeviceHeight(context) * 0.395,
              child: chatList.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : chatList.isError
                      ? Center(
                          child:
                              Text('Error: ${chatList.errorData.toString()}'))
                      : chatList.data == []
                          ? Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: Column(
                                  children: [
                                    const Gap(30),
                                    Assets.images.emptyChat.image(),
                                    const Gap(20),
                                    const TextView(
                                      text: "You have no messages yet",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    const Gap(10),
                                    const TextView(
                                      text:
                                          "Tap on any of your metals to kickstart a conversation",
                                      fontSize: 13,
                                      fontWeight: FontWeight.w300,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : myMelt.data!.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        const Gap(30),
                                        Assets.images.emptyChat.image(),
                                        const Gap(20),
                                        const TextView(
                                          text: "You have no messages yet",
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        const Gap(10),
                                        const TextView(
                                          text:
                                              "Tap on any of your metals to kickstart a conversation",
                                          fontSize: 13,
                                          fontWeight: FontWeight.w300,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: chatList.data?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    final message = chatList.data![index];

                                    var matchedData =
                                        myMelt.data!.firstWhere((element) {
                                      return message.participantIds
                                          .contains(element.id);
                                    });

                                    return matchedData != null
                                        ? chatListItem(
                                            data: matchedData,
                                            conversationsModel: message,
                                          )
                                        : const SizedBox();
                                  },
                                ))
        ]));
  }
}

class chatListItem extends StatelessWidget {
  const chatListItem({
    super.key,
    required this.data,
    required this.conversationsModel,
  });

  final MeltUserModel data;
  final ConversationsModel conversationsModel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.chatWindowsPage,
            arguments: ChatWindowArgument(
                user: data, conversationId: conversationsModel.documentId));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            const ProfilePhoto(),
            const Gap(16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextView(
                  text: data.name!,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                TextView(
                  text: conversationsModel.lastMessage,
                  fontWeight: FontWeight.w300,
                  fontSize: 13,
                ),
              ],
            ),
            const Spacer(),
            TextView(
              text: formatChatTime(conversationsModel.lastUpdatedAt),
              fontWeight: FontWeight.w300,
              fontSize: 13,
            ),
          ],
        ),
      ),
    );
  }
}
