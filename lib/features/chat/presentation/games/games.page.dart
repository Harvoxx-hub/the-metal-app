import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/features/chat/domain/entries/game.model.dart';
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
                    height: 220,
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
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: AppColors.metalWhite,
                          ),
                          TextView(
                            text: "GAME",
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.metalWhite,
                          ),
                          Gap(13),
                          TextView(
                            text:
                                "Break the conversation Ice using these starter games to discover yourselves better.",
                            fontSize: 14,
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
                    child: Wrap(
                      children: [
                        for (var element in gameData)
                          gameCard(
                            gameModel: element,

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
    required this.gameModel,
  
  });

  final GameModel gameModel;
 

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.gameRules,
            arguments: gameModel),
        child: Container(
          height: 162,
          width: 150,
          decoration: BoxDecoration(
              color: AppColors.metalPinkColour.withOpacity(0.07),
              borderRadius: BorderRadius.circular(20)),
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(gameModel.emojiPart),
              TextView(
                text: gameModel.title,
                textAlign: TextAlign.center,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
