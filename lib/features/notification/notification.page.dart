import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/features/notification/widget/melt.notification.item.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});
  static const name = 'notificationPage';
  static const route = '$name';
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        appBarState: AppBarState.BackWithHeader,
        Header: "Notifications",
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 53.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment(0.00, -1.00),
                          end: Alignment(0, 1),
                          colors: [Color(0xFFDB217A), Color(0xFFF00E3E)],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(35.sp),
                          bottomRight: Radius.circular(35.sp),
                        )),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 24.0, right: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MeltNotifcationItem(),
                        MeltNotifcationItem(),
                        MeltNotifcationItem(),
                        MeltNotifcationItem(),
                        MeltNotifcationItem(),
                        MeltNotifcationItem(),
                        MeltNotifcationItem(),
                        MeltNotifcationItem(),
                        MeltNotifcationItem(),
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
