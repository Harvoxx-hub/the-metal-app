import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/features/settings/provider/block.user.notifier.dart';

void showBlockedUserActions(
    BuildContext context, String username, String userId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConsumerActionButton(
                onTap: (ref) async {
                  ref.read(blockUserProvider.notifier).unBlockUser(userId);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                text: 'Unblock @$username',
              ),
              const SizedBox(height: 12),
              ConsumerActionButton(
                onTap: (ref) {
                  // Implement de-melt logic here
                  Navigator.pop(context);
                },
                text: 'De-melt @$username',
              ),
            ],
          ),
        ),
      );
    },
  );
}

class ConsumerActionButton extends ConsumerWidget {
  final Function(WidgetRef ref) onTap;
  final String text;

  const ConsumerActionButton({
    super.key,
    required this.onTap,
    required this.text,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => onTap(ref),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
