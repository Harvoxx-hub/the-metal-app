import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/features/chat/domain/entries/game.model.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text_views.dart';

enum gameType { nameAThing, truthAndDare, neverHaveIEver, twoTruthAndALie }

class GameRules extends StatelessWidget {
  GameRules({super.key, required this.games});
  final GameModel games;
  static const name = 'gameRules';
  static const route = '$name';

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        appBarState: AppBarState.BackWithHeader,
        body: SingleChildScrollView(
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
                    child: Padding(
                      padding: const EdgeInsets.only(left: 9.0, right: 9),
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: 31,
                          right: 31,
                          top: 13,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          image: DecorationImage(
                              image:
                                  AssetImage(Assets.images.chatFrame3049.path)),
                        ),
                        child: Column(
                          children: [
                            Image.asset(
                                Assets.images.chatSmilingFaceEmoji1.path),
                            TextView(
                              text: games.title,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            Gap(13.h),
                            TextView(
                              text: games.about,
                              fontSize: 14.sp,
                              textAlign: TextAlign.center,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Gap(43.h),
                  Padding(
                    padding: const EdgeInsets.only(left: 23.0, right: 23.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextView(
                          text: "Here's how to play:",
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        Gap(15),
                        TextView(
                          text: games.rule,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                        ),
                        Gap(27.h),
                        BaseButton(
                            buttonText: "Start Game",
                            onPressed: () {
                              Navigator.pop(context, games);
                              Navigator.pop(context, games);
                            })
                      ],
                    ),
                  ),

                  // Padding(
                  //   padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                  //   child: Column(
                  //     children: [
                  //       Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           gameCard(
                  //               title: "Two Truths and A lie",
                  //               game: gameType.twoTruthAndALie,
                  //               path: Assets.images.chatSmilingFaceEmoji1.path),
                  //           gameCard(
                  //               title: "Never Have I Ever",
                  //               game: gameType.neverHaveIEver,
                  //               path:
                  //                   Assets.images.chatAstonishedFaceEmoji1.path)
                  //         ],
                  //       ),
                  //       Gap(17.h),
                  //       Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           gameCard(
                  //               title: "Name a Thing",
                  //               game: gameType.nameAThing,
                  //               path: Assets
                  //                   .images.chatEmojiWomanRaisingHand1.path),
                  //           gameCard(
                  //               title: "Truth and Dare",
                  //               game: gameType.truthAndDare,
                  //               path: Assets
                  //                   .images.chatPersonSayingMoreEmoji1.path)
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // )
                ],
              ),
            ],
          ),
        ));
  }
}
