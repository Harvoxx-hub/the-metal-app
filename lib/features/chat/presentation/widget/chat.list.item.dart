import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/chat/presentation/widget/chat.shimmer.widget.dart';
import 'package:metal/features/home_page/domain/entries/connection.model.dart';
import 'package:metal/features/home_page/provider/get.user.notifier.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';

class ChatListItem extends ConsumerWidget {
  const ChatListItem({
    Key? key,
    required this.conversationsModel,
  }) : super(key: key);

  final ConnectionModel conversationsModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.chatWindowsPage,
            arguments: conversationsModel.otherUser!.id);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ProfilePhoto(
              meltId: conversationsModel.otherUser?.metal ?? '',
              imgUrl: conversationsModel.isAnonymous
                  ? null
                  : conversationsModel.otherUser?.profilePhoto ?? '',
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextView(
                    text: conversationsModel.otherUser?.username ?? "Unknown",
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
              text: formatTime(isoDateString: conversationsModel.lastUpdatedAt),
              fontWeight: FontWeight.w300,
              fontSize: 13,
            ),
          ],
        ),
      ),
    );
  }
}
