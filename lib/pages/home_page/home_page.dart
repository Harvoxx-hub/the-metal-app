import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:metal/pages/home_page/widget/ads.card.dart';
import 'package:metal/pages/sparks_page/sparks_page.dart';
import 'package:metal/res/colors/cr_colors.dart';

import 'widget/metal.user.card.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
          Padding(
              padding: EdgeInsets.symmetric(vertical: 15.w),
              child: const Column(
                children: [
                  MetalUserCard(),
                  MetalUserCard(),
                  MetalUserCard(),
                  MetalUserCard(),
                  AdsCard(),
                  MetalUserCard(),
                  MetalUserCard(),
                ],
              )),
        ],
      ),
    );
  }
}
