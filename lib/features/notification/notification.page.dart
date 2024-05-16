import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/text_views.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});
  static const name = 'notificationPage';
  static const route = name;
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        appBarState: AppBarState.BackWithHeader,
        Header: "Notifications",
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
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
                  Padding(
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

                        // MeltNotifcationItem(),
                        // MeltNotifcationItem(),
                        // MeltNotifcationItem(),
                        // MeltNotifcationItem(),
                        // MeltNotifcationItem(),
                        // MeltNotifcationItem(),
                        // MeltNotifcationItem(),
                        // MeltNotifcationItem(),
                        // MeltNotifcationItem(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
