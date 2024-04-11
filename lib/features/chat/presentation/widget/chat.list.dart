import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/utils/screen.size.dart';
import 'package:metal/features/chat/domain/entries/conversations.model.dart';
import 'package:metal/features/chat/presentation/chat.window/chat.window.argument.dart';
import 'package:metal/features/chat/presentation/widget/profile.image.dart';
import 'package:metal/features/chat/provider/get.chatlist.notifier.dart';
import 'package:metal/features/home_page/domain/entries/melt.user.model.dart';
import 'package:metal/features/home_page/provider/get.melt.users.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/shimmer.loading.dart';
import 'package:metal/widgets/text_views.dart';

class ChatListWidget extends ConsumerStatefulWidget {
  const ChatListWidget({super.key});

  @override
  ConsumerState<ChatListWidget> createState() => _ChatListWidgetState();
}

class _ChatListWidgetState extends ConsumerState<ChatListWidget> {
  late Stream<List<ConversationsModel>> _conversationStream;
  late bool _isConversationtreamInitialized;
  @override
  void initState() {
    _isConversationtreamInitialized = false;

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _fetchMessages();
    });

    super.initState();
  }

  void _fetchMessages() async {
    try {
      _conversationStream = ref.read(chatListProvider).data ?? Stream.empty();
      setState(() {
        _isConversationtreamInitialized = true;
      });
    } catch (e) {
      print('Failed to fetch messages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final myMelt = ref.watch(getMeltUserProvider);

    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextView(
              text: "Messages",
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
            Gap(10),
            if (!_isConversationtreamInitialized)
              Center(child: CircularProgressIndicator())
            else
              SizedBox(
                height: getDeviceHeight(context) * 0.395,
                child: StreamBuilder<List<ConversationsModel>>(
                  stream: _conversationStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                     
                      return snapshot.data == []
                          ? Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: Column(
                                  children: [
                                    Gap(30),
                                    Assets.images.emptyChat.image(),
                                    Gap(20.h),
                                    TextView(
                                      text: "You have no messages yet",
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    Gap(10.h),
                                    TextView(
                                      text:
                                          "Tap on any of your metals to kickstart a conversation",
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w300,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Expanded(
                              child: ListView.builder(
                                itemCount:  snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  final message =  snapshot.data![index];
                                  // Find the data in myMelt.data where id matches message.id
                          
                                  var matchedData =
                                      myMelt.data!.firstWhere((element) {
                                    return message.participantIds.contains(element.id);
                                  });

                                  // Pass matchedData to chatListItem if it's not null
                                  return matchedData != null
                                      ? chatListItem(
                                          data: matchedData,
                                          conversationsModel: message,
                                        )
                                      : SizedBox();
                                },
                              ),
                            );
                    }
                  },
                ),
              )
          ],
        ));

    // : Padding(
    //     padding: const EdgeInsets.all(16.0),
    //     child: Center(
    //       child: Column(
    //         children: [
    //           Gap(30),
    //           Assets.images.emptyChat.image(),
    //           Gap(20.h),
    //           TextView(
    //             text: "You have no messages yet",
    //             fontSize: 16.sp,
    //             fontWeight: FontWeight.w500,
    //           ),
    //           Gap(10.h),
    //           TextView(
    //             text:
    //                 "Tap on any of your metals to kickstart a conversation",
    //             fontSize: 13.sp,
    //             fontWeight: FontWeight.w300,
    //             textAlign: TextAlign.center,
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
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
            ProfilePhoto(),
            Gap(16),
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
            Spacer(),
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
