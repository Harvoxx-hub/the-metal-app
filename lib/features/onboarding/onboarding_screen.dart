import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/core/utils/utils/screen.size.dart';

import '../../widgets/dash.progress.indicator.dart';
import '../../widgets/text_views.dart';

class OnboardingWidget extends StatefulWidget {
  final String imageUrl;
  final String headerText;
  final String descriptionText;
  final int index;
  final int currentPage;
  final VoidCallback next;
  const OnboardingWidget(
      {super.key,
      required this.imageUrl,
      required this.headerText,
      required this.index,
      required this.currentPage,
      required this.descriptionText,
      required this.next});

  @override
  State<OnboardingWidget> createState() => _OnboardingWidgetState();
}

class _OnboardingWidgetState extends State<OnboardingWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: getDeviceHeight(context),
      width: getDeviceWidth(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(128.h),
          Image.asset(
            widget.imageUrl,
            width: 172.w,
            height: 172.h,
          ),
          TextView(
            text: widget.headerText,
            fontSize: 36.sp,
            fontWeight: FontWeight.normal,
          ),
          Gap(20),
          TextView(
            text: widget.descriptionText,
            fontSize: 16.sp,
            fontFamily: 'Merri_weather',
            fontWeight: FontWeight.normal,
          ),
        ],
      ),
    );
  }
}
