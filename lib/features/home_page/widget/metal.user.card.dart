import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/features/home_page/domain/entries/all.user.model.dart';
import 'package:metal/features/home_page/provider/like.user.notifier.dart';
import 'package:metal/features/home_page/provider/melt.user.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/home_page/melt.metal.dart';
import 'package:metal/features/home_page/push.metal.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/res/style/text_styles.dart';
import 'package:metal/widgets/text_views.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class MetalUserCard extends ConsumerStatefulWidget {
  const MetalUserCard({
    super.key,
    required this.user,
  });
  final ALLUserModel user;

  @override
  ConsumerState<MetalUserCard> createState() => _MetalUserCardState();
}

class _MetalUserCardState extends ConsumerState<MetalUserCard> {
  late ConfettiController _controller;
  bool? liked;
  @override
  void initState() {
    super.initState();
    liked = widget.user.liked;
    _controller = ConfettiController(duration: const Duration(seconds: 10));
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 27.h),
      margin: EdgeInsets.only(bottom: 40.h, left: 20.w, right: 20.w),
      // height: 100.h,
      decoration: BoxDecoration(
          color: AppColors.metalWhite,
          borderRadius: BorderRadius.circular(13.sp),
          boxShadow: [
            BoxShadow(
              blurRadius: 3,
              color: Colors.grey.withOpacity(0.5),
            )
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(30),
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 140.w,
              width: 140.w,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.metalBlack.withOpacity(0.1)),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(70.w),
                  child: Image.network(
                    widget.user.metal!.img!,
                    fit: BoxFit.cover,
                  )),
            ),
          ),
          const Gap(20),
          Row(
            children: [
              TextView(
                text: '@${widget.user.username}',
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
              Gap(10.w),
              widget.user.verfied
                  ? SvgPicture.asset(
                      Assets.icons.checkVerified.path,
                      height: 24,
                      width: 24,
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          Gap(6.h),
          _buildSubItem('Gender', widget.user.gender!),
          _buildSubItem('Age range', widget.user.age_range ?? ""),
          Gap(12.h),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 7.w,
              vertical: 4.w,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.sp),
                color: AppColors.metalPinkColour60.withOpacity(0.2)),
            child: Text(
              'Ready to Melt with  ${widget.user.connection_option!.join(', ')}',
              style: TextStyles.text(weight: FontWeight.w500),
            ),
          ),
          Gap(15.h),
          Text(
            'Interests: ${widget.user.passion!.join(', ')}',
            style: TextStyles.text(fontStyle: FontStyle.italic),
          ),
          Gap(15.h),
          Padding(
            padding: EdgeInsets.only(right: 15.w),
            child: const Divider(thickness: 1.5),
          ),
          Gap(8.h),
          Text(
            widget.user.description!,
            style: TextStyles.text(),
          ),
          Gap(20.h),
          liked!
              ? Center(
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: ShapeDecoration(
                      color: Color(0xFF07840A).withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3)),
                    ),
                    child: TextView(
                      text: "you liked @${widget.user.username} profile",
                    ),
                  ),
                )
              : SizedBox(),
          Gap(20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  context.pushNamed(MeltMetal.name, extra: widget.user);
                },
                child: Image.asset(Assets.images.melt.path),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ConfettiWidget(
                  confettiController: _controller,
                  blastDirection: -pi / 2,
                  emissionFrequency: 0.01,
                  numberOfParticles: 20,
                  maxBlastForce: 60,
                  minBlastForce: 20,
                  gravity: 0.3,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () {
                    _controller.play();
                    setState(() {
                      liked = true;
                    });
                    ref
                        .read(likeUserProvider.notifier)
                        .LikeUser(widget.user.id!);
                  },
                  child: Image.asset(Assets.images.like.path),
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.pushNamed(PushMetal.name, extra: widget.user);
                },
                child: Image.asset(Assets.images.pushMetalscreen.path),
              )
            ],
          )
        ],
      ),
    );
  }

  Text _buildSubItem(String key, String value) {
    return Text.rich(TextSpan(
        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w300),
        text: '$key: ',
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          )
        ]));
  }
}
