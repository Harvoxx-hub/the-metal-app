import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/features/chat/domain/entries/conversations.model.dart';
import 'package:metal/features/chat/domain/entries/game.model.dart';
import 'package:metal/features/chat/provider/game.conversation.notifier.dart';
import 'package:metal/features/home_page/domain/entries/connection.model.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

class GameTile extends ConsumerWidget {
  GameTile({
    super.key,
    required this.conversationsModel,
  });

  final ConnectionModel conversationsModel;
  GameModel? game;

  void setGame() {
    for (var a in gameData) {
      if (a.title == conversationsModel.game) {
        game = a;
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    setGame();
    if (game == null) {
      return const SizedBox();
    }

    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          height: 66,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(Assets.images.gameFrame.path),
              fit: BoxFit.fitWidth,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(game!.emojiPart),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const TextView(text: "Active Game:"),
                  TextView(
                    text: game!.title,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  ref
                      .read(gameConversationProvider.notifier)
                      .updateGameConversation(
                          conversatioId: conversationsModel.connectionId,
                          gameTitle: ""
                          //
                          // "",
                          );
                },
                child: Container(
                  height: 39,
                  width: 95,
                  decoration: BoxDecoration(
                    color: AppColors.metalPinkColour,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(
                    child: TextView(
                      text: "END GAME",
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
