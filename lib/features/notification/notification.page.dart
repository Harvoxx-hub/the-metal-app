import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/features/notification/notification.item.dart';
import 'package:metal/features/notification/provider/notification.notifier.dart';
import 'package:metal/features/notification/widget/melt.notification.item.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/text_views.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});
  static const name = 'notificationPage';
  static const route = name;

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    final notificationData = ref.watch(notificationProvider);
    return BaseScreen(
        appBarState: AppBarState.BackWithHeader,
        Header: "Notifications",
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 53,
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
                  )),
            ),
            notificationData.isLoading
                ? Center(child: const CupertinoActivityIndicator())
                : notificationData.data?.isEmpty ?? true
                    ? Padding(
                        padding: const EdgeInsets.only(left: 24.0, right: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              Assets.gifs.empty.path,
                              height: 250,
                              width: 250,
                            ),
                            const Gap(46),
                            const TextView(
                              textAlign: TextAlign.center,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              text: "You have no notifications yet",
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: notificationData.data?.length ?? 0,
                        itemBuilder: (BuildContext context, int index) {
                          final notification = notificationData.data![index];
                          return NotificationItemFactory.create(notification);
                        },
                      )
          ],
        ));
  }
}
