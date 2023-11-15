import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/pages/profile/tab.screen/discovery.tab.dart';
import 'package:metal/pages/profile/tab.screen/metal.plan.tab.dart';
import 'package:metal/pages/profile/tab.screen/personal.tab.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/tab/base.tab.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 220.h,
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
                child: const Padding(
                  padding: EdgeInsets.only(left: 24.0, right: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 110, left: 20, right: 20),
            child: Container(
              padding: EdgeInsets.only(
                top: 122,
              ),
              decoration: const BoxDecoration(
                  color: AppColors.metalWhite,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35))),
              child: Column(
                children: [
                  BaseTab(
                    tabs: [
                      BaseTabModel(child: PersonalTab(), title: "Personal"),
                      BaseTabModel(child: MetalPlanTab(), title: "Metal Plan"),
                      BaseTabModel(child: DiscoveryTab(), title: "Discovery")
                    ],
                  )
                ],
              ),
            ),
          ),
          Positioned(
              top: 19,
              left: 0,
              right: 0,
              child: Image.asset(
                Assets.images.profileImage1.path,
                height: 175,
                width: 175,
              )),
        ],
      ),
    );
  }
}
