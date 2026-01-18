import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/presentation/views/prompt/prompt_creation_view.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text_views.dart';

class PromptReminderDialog extends StatelessWidget {
  final int currentPromptCount;

  const PromptReminderDialog({
    super.key,
    this.currentPromptCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Gap(38),
        // Icon or image - using auto_awesome icon
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.auto_awesome,
            size: 64,
            color: Color(0xFFD2128B),
          ),
        ),
        const Gap(24),
        const TextView(
          text: 'Complete Your Profile with Prompts!',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          textAlign: TextAlign.center,
          color: Color(0xFF2C2C2C),
        ),
        const Gap(16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextView(
            text: currentPromptCount == 0
                ? 'Share your personality with 3 prompts! Let others know the real you and increase your chances of meaningful connections.'
                : 'You\'re ${3 - currentPromptCount} prompt${3 - currentPromptCount > 1 ? 's' : ''} away from completing your profile. Help others get to know you better!',
            fontSize: 16,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w400,
            color: Colors.grey[700],
          ),
        ),
        const Gap(24),
        // Benefits list
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              _buildBenefitItem('🎯', 'Stand out from the crowd'),
              const Gap(8),
              _buildBenefitItem('💬', 'Start meaningful conversations'),
              const Gap(8),
              _buildBenefitItem('✨', 'Show your authentic self'),
            ],
          ),
        ),
        const Gap(38),
        BaseButton(
          buttonText: 'Add Prompts Now',
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PromptCreationView(),
              ),
            );
          },
          enabled: true,
        ),
        const Gap(16),
        TextView(
          text: 'Maybe Later',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
          onTap: () => Navigator.pop(context),
        ),
        const Gap(21),
      ],
    );
  }

  Widget _buildBenefitItem(String emoji, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const Gap(8),
        Flexible(
          child: TextView(
            text: text,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
