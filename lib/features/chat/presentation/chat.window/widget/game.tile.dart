import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/features/chat/domain/entries/game.model.dart';
import 'package:metal/features/chat/provider/game.conversation.notifier.dart';
import 'package:metal/features/thought/data/domain/entries/connection.model.dart';
import 'package:metal/features/thought/provider/get.connection.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

class GameTile extends ConsumerWidget {
  GameTile({
    super.key,
    required this.conversationsModel,
  });

  final ConnectionModel conversationsModel;

  GameModel? _getGame() {
    for (var game in gameData) {
      if (game.title == conversationsModel.game) {
        return game;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = _getGame();
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
              Image.asset(game.emojiPart),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const TextView(text: "Active Game:"),
                  TextView(
                    text: game.title,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  await ref
                      .read(gameConversationProvider.notifier)
                      .updateGameConversation(
                          conversatioId: conversationsModel.connectionId,
                          gameTitle: "");

                  // Refresh connection to hide game tile immediately
                  ref
                      .read(
                          getConnectionProvider(conversationsModel.connectionId)
                              .notifier)
                      .getConnection();
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
