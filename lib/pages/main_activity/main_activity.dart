import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/pages/sparks_page/sparks_page.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/res/style/text_styles.dart';

import '../home_page/home_page.dart';

class MainActivityPage extends StatefulWidget {
  const MainActivityPage({super.key});

  static const name = 'main-activity';
  static const route = '/$name';

  @override
  State<MainActivityPage> createState() => _MainActivityPageState();
}

class _MainActivityPageState extends State<MainActivityPage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bottomNavPages = [
      HomePage(),
      SparksPage(),
      Container(),
      Container(),
    ];
    return Scaffold(
      backgroundColor: AppColors.metalPinkColour,
      body: Column(
        children: [
          Gap(top),
          const CustomAppBar(),
          Expanded(
              child: Container(
            color: AppColors.metalWhite,
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      height: 220.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: AppColors.metalPinkColour,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(35.sp),
                            bottomRight: Radius.circular(35.sp),
                          )),
                    ),

                    // This container is for the background image decoration
                    Container()
                  ],
                ),
                bottomNavPages[currentIndex]
              ],
            ),
          )),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.abc), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.abc), label: 'Sparks'),
          BottomNavigationBarItem(icon: Icon(Icons.abc), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.abc), label: 'Profile'),
        ],
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 80.h,
      padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 10.h),
      decoration: BoxDecoration(
          color: AppColors.metalPinkColour,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(35.sp),
            bottomRight: Radius.circular(35.sp),
          )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 45.w,
            width: 45.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.metalWhite,
            ),
            child: Icon(Icons.menu),
          ),
          Container(
            alignment: Alignment.center,
            height: 45.w,
            width: 45.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.metalWhite,
            ),
            child: SvgPicture.asset(Assets.icons.notification.path),
          ),
        ],
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size(double.infinity, 80);
}
