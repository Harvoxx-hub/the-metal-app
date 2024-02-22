import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:metal/features/sparks_page/domain/entries/spark.model.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/text_views.dart';

enum SparkHistoryType { Purchase, Sent, Referred }

class SparkHistoryItem extends StatelessWidget {
  SparkHistoryItem({
    super.key,
    required this.sparkModel,
  });
  final SparkModel sparkModel;

  // String getImagePath() {
  //   switch (sparkModel.type) {
  //     case SparkHistoryType.send.name:
  //       return Assets.icons.sendSparks.path;
  //     case SparkHistoryType.recived:
  //       return Assets.icons.buySparks.path;
  //     case SparkHistoryType.referred:
  //       return Assets.icons.referred.path;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          SvgPicture.asset(
            sparkModel.type == SparkHistoryType.Sent.name
                ? Assets.icons.sendSparks.path
                : sparkModel.type == SparkHistoryType.Purchase.name
                    ? Assets.icons.buySparks.path
                    : Assets.icons.referred.path,
            height: 24,
            width: 24,
          ),
          Gap(15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextView(
                text: sparkModel.type == SparkHistoryType.Sent.name
                    ? "Sent ${sparkModel.numberOfSparks} sparks"
                    : sparkModel.type == SparkHistoryType.Purchase.name
                        ? "Received ${sparkModel.numberOfSparks} sparks "
                        : "Referred ${sparkModel.numberOfSparks} people",
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              TextView(
                text: sparkModel.type == SparkHistoryType.Sent.name
                    ? "To @${sparkModel.receiver}"
                    : sparkModel.type == SparkHistoryType.Purchase.name
                        ? "From @metal"
                        : "Earned ${sparkModel.numberOfSparks} sparks",
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
                text: sparkModel.date!,
                fontWeight: FontWeight.w300,
                fontSize: 13,
              ),
              TextView(
                text: sparkModel.time!,
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
