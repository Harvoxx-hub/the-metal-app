import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text_views.dart';

enum gameType { nameAThing, truthAndDare, neverHaveIEver, twoTruthAndALie }

class GameRules extends StatelessWidget {
  GameRules({super.key, required this.games});
  final String games;
  static const name = 'gameRules';
  static const route = '$name';

  String twoTruthAndALineTitle = "Two Truths and A lie";
  String twoTruthAndALineSubTitle =
      "Two Truths and a Lie is a fun and easy icebreaker game that's perfect for getting to know a new person. The objective of the game is to correctly identify which statement is the false one.";
  String twoTruthAndALineExpain =
      "Explain the Rules: Each player will share three statements about themselves, two of which are true and one is false. The other player must try to guess which statement is false. Select a player to go first: Discuss and agree on the player to go first. The first person to play will write three statements about themselves, and the other player will guess which statement is the lie. Respond: After the first player has written their statements, the other player must guess which statement they think is false. The first player will reveal which statement was the lie. The game then moves on to the other player, who will make their own three statements, and so on. The game continues by rotating turns Score: Record the scores in your chat to track the winner. Update the scores as you complete new rounds. You can keep score by awarding points to players who correctly guess the lie.";

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
                              text: "Two Truths and A lie",
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            Gap(13.h),
                            TextView(
                              text: twoTruthAndALineSubTitle,
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
                          text: twoTruthAndALineExpain,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                        ),
                        Gap(27.h),
                        BaseButton(
                            buttonText: "Start Game",
                            onPressed: () {
                              context.pop();
                              context.pop();
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
