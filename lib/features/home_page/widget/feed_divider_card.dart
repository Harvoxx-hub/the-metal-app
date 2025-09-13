import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/text_views.dart';

/// Divider card that separates featured thoughts from suggested (unfeatured) thoughts
class FeedDividerCard extends StatelessWidget {
  final String message;
  final bool isButton;

  const FeedDividerCard({
    super.key,
    this.message =
        "🎯 You've reached the end of matched thoughts.\nHere are some suggested thoughts from the community.",
    this.isButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFDB217A),
            Color(0xFFF00E3E),
          ],
        ),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.explore_outlined,
            color: Colors.white,
            size: 32,
          ),
          const Gap(12),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              TextView(
                text: message,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                textAlign: TextAlign.center,
              ),
              if (isButton)
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.editPreferences);
                  },
                  child: TextView(
                    text: "Edit Preferences",
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                )
            ],
          )
        ],
      ),
    );
  }
}
