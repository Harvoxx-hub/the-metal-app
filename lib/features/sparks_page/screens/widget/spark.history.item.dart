import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/features/sparks_page/domain/entries/spark.model.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/text_views.dart';

enum SparkHistoryType { Purchase, Sent, Received, Referred, ReferralBonus }

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
    if (sparkModel.type == 'Sent' && isSender)
      return Assets.icons.sendSparks.path;
    if (sparkModel.type == 'Sent' && isReceiver)
      return Assets.icons.buySparks.path;

    switch (sparkModel.type) {
      case 'Purchase':
        return Assets.icons.buySparks.path;
      case 'Referred':
        return Assets.icons.referred.path;
      case 'ReferralBonus':
        return Assets.icons.referred.path;
      default:
        return Assets.icons.iconlyLightProfile.path;
    }
  }

  /// Helper to get the main text that explains the spark activity
  String _getMainText() {
    if (sparkModel.type == 'Sent' && isSender)
      return "You sent ${sparkModel.sparks} sparks";
    if (sparkModel.type == 'Sent' && isReceiver)
      return "You received ${sparkModel.sparks} sparks";

    switch (sparkModel.type) {
      case 'Purchase':
        return "You purchased ${sparkModel.sparks} sparks";
      case 'Referred':
        return "Referral bonus received";
      case 'ReferralBonus':
        return "Referral signup bonus";
      default:
        return "Spark transaction: ${sparkModel.sparks} sparks";
    }
  }

  /// Helper to get the subtext providing additional details about the spark activity
  String _getSubText() {
    if (sparkModel.type == 'Sent' && isSender)
      return "Sent to @${sparkModel.receiverName ?? 'User'}";
    if (sparkModel.type == 'Sent' && isReceiver)
      return "Received from @${sparkModel.senderName ?? 'User'}";

    switch (sparkModel.type) {
      case 'Purchase':
        return "Purchased for \$${sparkModel.amount ?? '0.00'}";
      case 'Referred':
        return "User @${sparkModel.referredName ?? 'Unknown'} used your code";
      case 'ReferralBonus':
        return "You used @${sparkModel.referrerName ?? 'Unknown'}'s code";
      default:
        return formatTime(isoDateString: sparkModel.timestamp);
    }
  }

  // Get the appropriate color for the transaction type
  Color _getTransactionColor() {
    if (sparkModel.type == 'Sent' && isSender) return Colors.orange;
    if (sparkModel.type == 'Sent' && isReceiver) return Colors.green;

    switch (sparkModel.type) {
      case 'Purchase':
        return Colors.blue;
      case 'Referred':
        return Colors.purple;
      case 'ReferralBonus':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Show transaction details in a modal
        showModalBottomSheet(
          context: context,
          builder: (context) => _buildTransactionDetails(context),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getTransactionColor().withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                _getImagePath(),
                height: 24,
                width: 24,
                color: _getTransactionColor(),
              ),
            ),
            const Gap(15),
            Expanded(
              child: Column(
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
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
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
      ),
    );
  }

  Widget _buildTransactionDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TextView(
            text: "Transaction Details",
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          const Divider(),
          _detailRow("Type", sparkModel.type ?? "Unknown"),
          _detailRow("Amount", "${sparkModel.sparks} sparks"),
          _detailRow("Date", formatTime(isoDateString: sparkModel.timestamp)),
          if (sparkModel.type == 'Sent') ...[
            _detailRow("Sender", "@${sparkModel.senderName ?? 'Unknown'}"),
            _detailRow("Receiver", "@${sparkModel.receiverName ?? 'Unknown'}"),
          ],
          if (sparkModel.type == 'Purchase') ...[
            _detailRow("Cost", "\$${sparkModel.amount ?? '0.00'}"),
          ],
          if (sparkModel.type == 'Referred' ||
              sparkModel.type == 'ReferralBonus') ...[
            _detailRow("Referral Code", "Used for this transaction"),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextView(
            text: label,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          TextView(
            text: value,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ],
      ),
    );
  }
}
