import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:metal/features/chat/presentation/widget/profile.image.dart';
import 'package:metal/features/home_page/domain/entries/melt.user.model.dart';
import 'package:metal/features/home_page/provider/get.melt.users.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/shimmer.loading.dart';
import 'package:metal/widgets/text_views.dart';

class ChatListWidget extends ConsumerWidget {
  const ChatListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myMelt = ref.watch(getMeltUserProvider);

    return ShimmerLoading(
        isLoading: myMelt.isLoading,
        child: (myMelt.data ?? []).isNotEmpty
            ? Padding(
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
                      for (var data in myMelt.data!) chatListItem(data: data)
                    ]))
            : Padding(
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
              ));
  }
}

class chatListItem extends StatelessWidget {
  const chatListItem({
    super.key,
    required this.data,
  });

  final MeltUserModel data;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
            Navigator.pushNamed(
                                      context, AppRoutes.chatWindowsPage,
                                      arguments: data);
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
                  text: "Start Chating ",
                  fontWeight: FontWeight.w300,
                  fontSize: 13,
                ),
              ],
            ),
            Spacer(),
            TextView(
              text: "23 min",
              fontWeight: FontWeight.w300,
              fontSize: 13,
            ),
          ],
        ),
      ),
    );
  }
}
