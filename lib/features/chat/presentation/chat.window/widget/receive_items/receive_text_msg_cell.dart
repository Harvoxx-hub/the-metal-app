import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:zego_zim/zego_zim.dart';

import '../bubble/text_bubble.dart';

class ReceiveTextMsgCell extends StatefulWidget {
  ZIMTextMessage message;

  ReceiveTextMsgCell({required this.message});

  @override
  State<StatefulWidget> createState() => _MyCellState();
}

class _MyCellState extends State<ReceiveTextMsgCell> {
  @override
  Widget build(BuildContext context) {
   return  Column(
      children: [
        Column(
          crossAxisAlignment:
       CrossAxisAlignment.start,
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
                    bottomLeft:  const Radius.circular(0),
                    bottomRight:  
                         const Radius.circular(15)),
                color:  AppColors.metalPinkColour.withOpacity(0.07),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextView(
                    text:   widget.message.message,
                    fontFamily: 'Raleway',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.metalBlack,
                  ),
                ],
              ),
            ),
            Align(
              alignment:  Alignment.centerLeft,
              child: TextView(
                text: DateFormat('h:mma').format(
                        DateTime.fromMicrosecondsSinceEpoch(
                            widget.message!.timestamp * 1000)),
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
 