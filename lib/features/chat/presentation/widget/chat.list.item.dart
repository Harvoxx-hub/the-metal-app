import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
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
    final currentUser = ref.watch(authProvider).data;
    final metalId = conversationsModel.users.firstWhere(
      (user) => user != currentUser!.id,
      orElse: () => "",
    );
    final getUser = ref.watch(getUserProvider(metalId));

    return !getUser.isLoading
        ? GestureDetector(
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
                        const SizedBox(width: 16),
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
                      ],
                    ),
                  ),
          )
        : const Center(child: CircularProgressIndicator.adaptive());
  }
}
