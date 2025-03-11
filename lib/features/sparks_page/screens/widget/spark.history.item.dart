import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/features/sparks_page/domain/entries/spark.model.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/text_views.dart';

enum SparkHistoryType { Purchase, Sent, Received, Referred }

class SparkHistoryItem extends StatelessWidget {
  const SparkHistoryItem({
    super.key,
    required this.sparkModel,
    required this.userID,
  });

  final SparkModel sparkModel;
  final String userID;

  /// Determine if the user is the sender or receiver
  bool get isSender => sparkModel.userId == userID;
  bool get isReceiver => sparkModel.receiverId == userID;

  /// Helper to get the image path based on Spark type
  String _getImagePath() {
    if (isSender) return Assets.icons.sendSparks.path;
    if (isReceiver) return Assets.icons.referred.path;
    
    switch (sparkModel.type) {
      case 'Purchase':
        return Assets.icons.buySparks.path;
      case 'Referred':
        return Assets.icons.referred.path;
      default:
        return Assets.icons.iconlyLightProfile.path;
    }
  }

  /// Helper to get the main text that explains the spark activity
  String _getMainText() {
    if (isSender) return "You sent ${sparkModel.sparks} sparks";
    if (isReceiver) return "You received ${sparkModel.sparks} sparks";

    switch (sparkModel.type) {
      case 'Purchase':
        return "You purchased ${sparkModel.sparks} sparks";
      case 'Referred':
        return "Referred new users";
      default:
        return "Unknown spark activity";
    }
  }

  /// Helper to get the subtext providing additional details about the spark activity
  String _getSubText() {
    if (isSender) return "Sent to @${sparkModel.receiverName}";
    if (isReceiver) return "Received from @${sparkModel.senderName}";

    switch (sparkModel.type) {
      case 'Purchase':
        return "Purchased from @Metal"; 
      case 'Referred':
        return "Earned ${sparkModel.sparks} sparks for referrals";
      default:
        return "No additional details available";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          SvgPicture.asset(
            _getImagePath(),
            height: 24,
            width: 24,
          ),
          const Gap(15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextView(
                text: _getMainText(),
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              TextView(
                text: _getSubText(),
                fontWeight: FontWeight.w300,
                fontSize: 13,
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end, // Align time to the right
            children: [
              TextView(
                text: formatTime(isoDateString: sparkModel.timestamp),
                fontWeight: FontWeight.w300,
                fontSize: 13,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
