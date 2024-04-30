import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/dashboard.dart/widget/complete.profile.dialog.dart';
import 'package:metal/features/home_page/domain/entries/all.user.model.dart';
import 'package:metal/features/home_page/provider/get.all.users.notifier.dart';
import 'package:metal/features/home_page/provider/like.user.notifier.dart';
import 'package:metal/features/home_page/provider/melt.user.notifier.dart';

import 'package:metal/gen/assets.gen.dart';

import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/res/style/text_styles.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/text_views.dart';

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
    _controller = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _userState = ref.watch(authProvider).data;
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
                text: '@${widget.user.username}_${widget.user.metal!.title}',
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
          _buildSubItem(
              'Age range', getAgeRange(int.parse(widget.user.age_range!))),
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
                  _userState!.completed_profile!
                      ? {
                          !widget.user.pushedMe
                              ?  _meltUser()
                              : Navigator.pushNamed(
                                  context,
                                  AppRoutes.meltMetal,
                                  arguments: widget.user,
                                )
                        }
                      : showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomDialog(
                              content: ComplecteProfileDialog(),
                            );
                          },
                        );
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
                    _userState!.completed_profile!
                        ? {
                            _controller.play(),
                            setState(() {
                              liked = true;
                            }),
                            ref
                                .read(likeUserProvider.notifier)
                                .LikeUser(widget.user.id!),
                          }
                        : showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomDialog(
                                content: ComplecteProfileDialog(),
                              );
                            },
                          );
                  },
                  child: Image.asset(Assets.images.like.path),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _userState!.completed_profile!
                      ? Navigator.pushNamed(context, AppRoutes.pushMetal,
                          arguments: widget.user)
                      : showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomDialog(
                              content: ComplecteProfileDialog(),
                            );
                          },
                        );
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

  String getAgeRange(int age) {
    if (age >= 18 && age <= 23) {
      return "18 - 23";
    } else if (age >= 24 && age <= 29) {
      return "24 - 29";
    } else if (age >= 30 && age <= 35) {
      return "30 - 35";
    } else if (age >= 36 && age <= 41) {
      return "36 - 41";
    } else if (age >= 42 && age <= 47) {
      return "42 - 47";
    } else if (age >= 48 && age <= 53) {
      return "48 - 53";
    } else if (age >= 54 && age <= 59) {
      return "54 - 59";
    } else if (age >= 60 && age <= 65) {
      return "60 - 65";
    } else if (age >= 66 && age <= 71) {
      return "66 - 71";
    } else if (age >= 72 && age <= 77) {
      return "72 - 77";
    } else if (age >= 78 && age <= 83) {
      return "78 - 83";
    } else if (age >= 85 && age <= 90) {
      return "85 - 90";
    } else if (age >= 91 && age <= 100) {
      return "91 - 100";
    } else {
      return "Age is not within any specified range";
    }
  }

  void _meltUser() {
    ref.watch(meltUserProvider(widget.user.id!));
  }
}
