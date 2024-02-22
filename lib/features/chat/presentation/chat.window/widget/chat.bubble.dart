import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:metal/features/chat/presentation/chat.window/widget/bubble/text_bubble.dart';

import 'package:metal/res/colors/cr_colors.dart';

import 'package:metal/widgets/text_views.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

class ChatBubble extends ConsumerWidget {
  const ChatBubble(
      {required this.message,
      required this.time,
      super.key,
      this.isme = false});
  final bool isme;
  final String message;
  final DateTime time;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Column(
          crossAxisAlignment:
              isme ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(
                top: 6,
                right: 6,
                left: 6,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(15),
                    topRight: const Radius.circular(15),
                    bottomLeft: isme
                        ? const Radius.circular(15)
                        : const Radius.circular(0),
                    bottomRight: isme
                        ? const Radius.circular(0)
                        : const Radius.circular(15)),
                color: isme
                    ? AppColors.metalBlack.withOpacity(0.07)
                    : AppColors.metalPinkColour.withOpacity(0.07),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextView(
                    text: message,
                    fontFamily: 'Raleway',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.metalBlack,
                  ),
                ],
              ),
            ),
            Align(
              alignment: isme ? Alignment.centerRight : Alignment.centerLeft,
              child: TextView(
                text: DateFormat('h:mma').format(time),
                fontFamily: 'Raleway',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.metalBrownColourForText.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

