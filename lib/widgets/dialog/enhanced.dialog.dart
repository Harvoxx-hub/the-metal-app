import 'package:flutter/material.dart';
import 'package:metal/widgets/text_views.dart';

class EnhancedDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final String primaryButtonText;
  final VoidCallback onPrimaryButtonPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryButtonPressed;

  const EnhancedDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.primaryButtonText,
    required this.onPrimaryButtonPressed,
    this.secondaryButtonText,
    this.onSecondaryButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextView(
            text: title,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 16),
          content,
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (secondaryButtonText != null) ...[
                TextButton(
                  onPressed: onSecondaryButtonPressed,
                  child: TextView(
                    text: secondaryButtonText!,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              ElevatedButton(
                onPressed: onPrimaryButtonPressed,
                child: TextView(
                  text: primaryButtonText,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
