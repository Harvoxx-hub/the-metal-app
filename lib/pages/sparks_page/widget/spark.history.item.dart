import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/text_views.dart';

enum SparkHistoryType { send, recived, referred }

class SparkHistoryItem extends StatelessWidget {
  const SparkHistoryItem(
      {super.key,
      required this.type,
      required this.User,
      required this.dateTime,
      required this.title});
  final SparkHistoryType type;
  final String User;
  final String title;
  final DateTime dateTime;
  String getImagePath() {
    switch (type) {
      case SparkHistoryType.send:
        return Assets.icons.sendSparks.path;
      case SparkHistoryType.recived:
        return Assets.icons.buySparks.path;
      case SparkHistoryType.referred:
        return Assets.icons.referred.path;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          SvgPicture.asset(
            getImagePath(),
            height: 24,
            width: 24,
          ),
          Gap(15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextView(
                text: title,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              TextView(
                text: "From @$User",
                fontWeight: FontWeight.w300,
                fontSize: 13,
              )
            ],
          ),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextView(
                text: DateFormat('dd/MM/yyyy').format(dateTime),
                fontWeight: FontWeight.w300,
                fontSize: 13,
              ),
              TextView(
                text: DateFormat('h:mma').format(dateTime),
                fontWeight: FontWeight.w300,
                fontSize: 13,
              )
            ],
          ),
        ],
      ),
    );
  }
}
