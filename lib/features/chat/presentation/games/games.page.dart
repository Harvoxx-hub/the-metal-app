import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/features/chat/presentation/games/games.rule.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/text_views.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});
  static const name = 'gamePage';
  static const route = '$name';
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        appBarState: AppBarState.BackWithHeader,
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
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
                      padding: const EdgeInsets.only(left: 43.0, right: 43),
                      child: Column(
                        children: [
                          Image.asset(Assets
                              .images.chatStarStruckExcitedHappyEmoji1.path),
                          Image.asset(Assets.images.chatVideoGameEmoji1.path),
                          TextView(
                            text: "Let’s Play",
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.metalWhite,
                          ),
                          TextView(
                            text: "GAME",
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.metalWhite,
                          ),
                          Gap(13.h),
                          TextView(
                            text:
                                "Break the conversation Ice using these starter games to discover yourselves better.",
                            fontSize: 16.sp,
                            textAlign: TextAlign.center,
                            fontWeight: FontWeight.w400,
                            color: AppColors.metalWhite,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap(31.h),
                  TextView(
                    text: "Please choose one game at a time",
                    fontSize: 15.sp,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                  ),
                  Gap(27.h),
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            gameCard(
                                title: "Two Truths and A lie",
                                game: gameType.twoTruthAndALie,
                                path: Assets.images.chatSmilingFaceEmoji1.path),
                            gameCard(
                                title: "Never Have I Ever",
                                game: gameType.neverHaveIEver,
                                path:
                                    Assets.images.chatAstonishedFaceEmoji1.path)
                          ],
                        ),
                        Gap(17.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            gameCard(
                                title: "Name a Thing",
                                game: gameType.nameAThing,
                                path: Assets
                                    .images.chatEmojiWomanRaisingHand1.path),
                            gameCard(
                                title: "Truth and Dare",
                                game: gameType.truthAndDare,
                                path: Assets
                                    .images.chatPersonSayingMoreEmoji1.path)
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ));
  }
}

class gameCard extends StatelessWidget {
  const gameCard({
    super.key,
    required this.title,
    required this.path,
    required this.game,
  });

  final String title;
  final String path;
  final gameType game;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>  Navigator.pushNamed(context,  AppRoutes.gameRules, arguments: game.name ),
      
 
      child: Container(
        height: 162,
        width: 150.w,
        decoration: BoxDecoration(
            color: AppColors.metalPinkColour.withOpacity(0.07),
            borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(path),
            TextView(
              text: title,
              textAlign: TextAlign.center,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
      ),
    );
  }
}
