import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/domain/entities/spark_dto.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

/// Transaction tile widget for displaying spark transactions
class SparkTransactionTile extends StatelessWidget {
  const SparkTransactionTile({
    super.key,
    required this.transaction,
    required this.currentUserId,
  });

  final SparkTransactionDto transaction;
  final String currentUserId;

  /// Determine if the current user is the sender
  bool get isSender => transaction.senderId == currentUserId;

  /// Determine if the current user is the receiver
  bool get isReceiver => transaction.recipientId == currentUserId;

  /// Helper to get the image path based on transaction type
  String _getImagePath() {
    switch (transaction.type) {
      case SparkTransactionType.sent:
        return isSender
            ? Assets.icons.sendSparks.path
            : Assets.icons.buySparks.path;
      case SparkTransactionType.received:
        return Assets.icons.buySparks.path;
      case SparkTransactionType.purchased:
        return Assets.icons.buySparks.path;
      case SparkTransactionType.earned:
        return Assets.icons.referred.path;
      case SparkTransactionType.spent:
        return Assets.icons.sendSparks.path;
    }
  }

  /// Helper to get the main text that explains the transaction
  String _getMainText() {
    switch (transaction.type) {
      case SparkTransactionType.sent:
        return isSender
            ? "You sent ${transaction.amount} sparks"
            : "You received ${transaction.amount} sparks";
      case SparkTransactionType.received:
        return "You received ${transaction.amount} sparks";
      case SparkTransactionType.purchased:
        return "You purchased ${transaction.amount} sparks";
      case SparkTransactionType.earned:
        return "You earned ${transaction.amount} sparks";
      case SparkTransactionType.spent:
        return "You spent ${transaction.amount} sparks";
    }
  }

  /// Helper to get the subtext providing additional details
  String _getSubText() {
    switch (transaction.type) {
      case SparkTransactionType.sent:
        return isSender
            ? "Sent to @${transaction.recipientName ?? 'User'}"
            : "Received from @${transaction.senderName ?? 'User'}";
      case SparkTransactionType.received:
        return "Received from @${transaction.senderName ?? 'User'}";
      case SparkTransactionType.purchased:
        return "In-app purchase";
      case SparkTransactionType.earned:
        return "Referral bonus or reward";
      case SparkTransactionType.spent:
        return "Feature unlock or boost";
    }
  }

  /// Get the appropriate color for the transaction type
  Color _getTransactionColor() {
    switch (transaction.type) {
      case SparkTransactionType.sent:
        return isSender ? Colors.orange : Colors.green;
      case SparkTransactionType.received:
        return Colors.green;
      case SparkTransactionType.purchased:
        return Colors.blue;
      case SparkTransactionType.earned:
        return Colors.purple;
      case SparkTransactionType.spent:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Show transaction details in a modal
        showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.metalWhite,
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
                colorFilter: ColorFilter.mode(
                  _getTransactionColor(),
                  BlendMode.srcIn,
                ),
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
                  text: formatTime(
                    isoDateString: transaction.timestamp.toIso8601String(),
                    locale: Localizations.localeOf(context).languageCode,
                  ),
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
          _detailRow("Type", transaction.type.name.toUpperCase()),
          _detailRow("Amount", "${transaction.amount} sparks"),
          _detailRow(
            "Date",
            formatTime(
              isoDateString: transaction.timestamp.toIso8601String(),
              locale: Localizations.localeOf(context).languageCode,
            ),
          ),
          if (transaction.type == SparkTransactionType.sent ||
              transaction.type == SparkTransactionType.received) ...[
            if (transaction.senderName != null)
              _detailRow("Sender", "@${transaction.senderName}"),
            if (transaction.recipientName != null)
              _detailRow("Receiver", "@${transaction.recipientName}"),
          ],
          if (transaction.message != null && transaction.message!.isNotEmpty) ...[
            _detailRow("Message", transaction.message!),
          ],
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const TextView(
                text: "Close",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.metalPinkColour,
              ),
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
          Flexible(
            child: TextView(
              text: value,
              fontWeight: FontWeight.w400,
              fontSize: 14,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
