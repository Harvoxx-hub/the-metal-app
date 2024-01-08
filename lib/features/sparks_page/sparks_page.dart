import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/sparks_page/widget/spark.card.dart';
import 'package:metal/features/sparks_page/widget/spark.card.item.dart';
import 'package:metal/features/sparks_page/widget/spark.history.item.dart';
import 'package:metal/widgets/text_views.dart';

import '../../res/colors/cr_colors.dart';
import '../../res/style/text_styles.dart';

class SparksPage extends StatelessWidget {
  const SparksPage({
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
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                margin: EdgeInsets.only(left: 10.w, right: 10.w),
                decoration: BoxDecoration(
                    color: AppColors.metalWhite,
                    borderRadius: BorderRadius.circular(13.sp)),
                child: Column(
                  children: [
                    const SparkCard(),
                    Gap(15),
                    Container(
                      decoration: ShapeDecoration(
                        color: AppColors.metalPinkColour.withOpacity(0.1),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                      ),
                      padding: EdgeInsets.all(13),
                      child: Row(
                        children: [
                          TextView(
                            text: "Transaction History",
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          Spacer(),
                          TextView(
                            text: "See all",
                            fontSize: 14.sp,
                            color: AppColors.metalPinkColour,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ),
                    Gap(9),
                    SparkHistoryItem(
                        type: SparkHistoryType.send,
                        User: "Seguncodes",
                        dateTime: DateTime.now(),
                        title: "Sent 2 Sparks"),
                    SparkHistoryItem(
                        type: SparkHistoryType.recived,
                        User: "Seguncodes",
                        dateTime: DateTime.now(),
                        title: "Sent 2 Sparks"),
                    SparkHistoryItem(
                        type: SparkHistoryType.recived,
                        User: "Seguncodes",
                        dateTime: DateTime.now(),
                        title: "Sent 2 Sparks"),
                    SparkHistoryItem(
                        type: SparkHistoryType.referred,
                        User: "Seguncodes",
                        dateTime: DateTime.now(),
                        title: "Sent 2 Sparks"),
                    SparkHistoryItem(
                        type: SparkHistoryType.referred,
                        User: "Seguncodes",
                        dateTime: DateTime.now(),
                        title: "Sent 2 Sparks"),
                    SparkHistoryItem(
                        type: SparkHistoryType.send,
                        User: "Seguncodes",
                        dateTime: DateTime.now(),
                        title: "Sent 2 Sparks"),
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
