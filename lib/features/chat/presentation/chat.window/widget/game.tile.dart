import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/features/chat/domain/entries/game.model.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

class GameTile extends StatelessWidget {
  const GameTile({super.key, required this.game});
  final GameModel game;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Gap(10),
        Container(
          padding: EdgeInsets.only(left: 18, right: 18),
          height: 66,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  Assets.images.gameFrame.path,
                ),
                fit: BoxFit.fitWidth),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(game!.emojiPart),
              Gap(20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextView(text: "Active Game:"),
                  TextView(
                    text: game!.title,
                    fontWeight: FontWeight.bold,
                  )
                ],
              ),
              Spacer(),
              Container(
                height: 39,
                width: 95,
                decoration: BoxDecoration(
                    color: AppColors.metalPinkColour,
                    borderRadius: BorderRadius.circular(15)),
                child: Center(
                  child: TextView(
                    text: "END GAME",
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
