import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/utils/input/validators/validators.dart';
import 'package:metal/core/utils/metal.helper.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';

import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/presentation/views/dashboard/widgets/complete.profile.dialog.dart';
 
import 'package:metal/features/home_page/widget/swipe_card.dart';
import 'package:metal/features/settings/provider/block.user.notifier.dart';
import 'package:metal/features/thought/provider/get.melt.users.notifier.dart';

import 'package:metal/gen/assets.gen.dart';

import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/res/style/text_styles.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

class MetalUserCard extends ConsumerStatefulWidget {
  const MetalUserCard({
    super.key,
    required this.user,
  });
  final UserModel user;

  @override
  ConsumerState<MetalUserCard> createState() => _MetalUserCardState();
}

class _MetalUserCardState extends ConsumerState<MetalUserCard> {
  
  // final GlobalKey<SwipeCardState> _swipeCardKey = GlobalKey();
  bool? liked;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authProvider).data;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      margin: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
      decoration: BoxDecoration(
          color: AppColors.metalWhite,
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              blurRadius: 3,
              color: Colors.grey.withOpacity(0.5),
            )
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Spacer(),
              IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      backgroundColor: Colors.white,
                      context: context,
                      builder: (BuildContext context) {
                        return SafeArea(
                          child: Wrap(
                            children: <Widget>[
                              ListTile(
                                title: const Text('Block Metal'),
                                onTap: () {
                                  // showDialog(
                                  //   context: context,
                                  //   builder: (BuildContext context) {
                                  //     return CustomDialog(
                                  //         content: _blockDialog(
                                  //             context, widget.user, ref));
                                  //   },
                                  // );
                                },
                              ),
                              ListTile(
                                  title: const Text('Block and Report'),
                                  onTap: () {

                                  } 
                                  // showDialog(
                                  //       context: context,
                                  //       builder: (BuildContext context) {
                                  //         return CustomDialog(
                                  //             content: _blockAndReportDialog(
                                  //                 context, widget.user, ref));
                                  //       },
                                  //     )
                                      ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.more_vert))
            ],
          ),
          const Gap(10),
          Align(
            alignment: Alignment.center,
            child:  ProfilePhoto(
                  verfly: false,
                  size: 140,
                  meltId: userState?.metal ?? "",
                ),
          ),
          const Gap(20),
          Row(
            children: [
              TextView(
                text: '@${widget.user.username}_${widget.user.metal!}',
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              const Gap(10),
              widget.user.isVerified ?? false
                  ? SvgPicture.asset(
                      Assets.icons.checkVerified.path,
                      height: 24,
                      width: 24,
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          const Gap(6),
          _buildSubItem('Gender', widget.user.gender!),
          _buildSubItem(
              'Age range', MetalHelper.getAgeRange(widget.user.dob!)),
          const Gap(12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 7,
              vertical: 4,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: AppColors.metalPinkColour60.withOpacity(0.2)),
            child: Text(
              'Ready to Melt with  ${widget.user.connectionOption!.join(', ')}',
              style: TextStyles.text(weight: FontWeight.w500),
            ),
          ),
          const Gap(15),
          Text(
            'Interests: ${widget.user.passion!.join(', ')}',
            style: TextStyles.text(fontStyle: FontStyle.italic),
          ),
          const Gap(15),
          const Padding(
            padding: EdgeInsets.only(right: 15),
            child: Divider(thickness: 1.5),
          ),
          const Gap(8),
          Text(
            widget.user.bio!,
            style: TextStyles.text(),
          ),
          const Gap(20),
          liked!
              ? Center(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: ShapeDecoration(
                      color: const Color(0xFF07840A).withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3)),
                    ),
                    child: TextView(
                      text: "you liked @${widget.user.username} profile",
                    ),
                  ),
                )
              : const SizedBox(),
          const Gap(20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  _meltUser();
                },
                child: Image.asset(Assets.images.melt.path),
              ),
              // Fixed: Import confetti_widget package and define _controller in your state class.
              // Make sure to add: import 'package:confetti/confetti.dart';
              // In your _MetalUserCardState, add: late ConfettiController _controller;
              // And initialize it in initState and dispose it in dispose.
              
              Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () {
                    
                  },
                  child: Image.asset(Assets.images.like.path),
                ),
              ),
              GestureDetector(
                onTap: () {
                
                   Navigator.pushNamed(context, AppRoutes.pushMetal,
                          arguments: widget.user);
                     
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
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
        text: '$key: ',
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          )
        ]));
  }



  void _meltUser() {
    
  }

 }
