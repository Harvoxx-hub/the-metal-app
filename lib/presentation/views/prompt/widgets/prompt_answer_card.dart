import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/domain/entities/prompt_dto.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

/// Prompt Answer Card
/// Displays a question with an answer input field
/// Allows deletion of prompts
class PromptAnswerCard extends StatefulWidget {
  final UserPromptDto prompt;
  final Function(String) onAnswerChanged;
  final VoidCallback onDelete;
  final bool isReadOnly;

  const PromptAnswerCard({
    super.key,
    required this.prompt,
    required this.onAnswerChanged,
    required this.onDelete,
    this.isReadOnly = false,
  });

  @override
  State<PromptAnswerCard> createState() => _PromptAnswerCardState();
}

class _PromptAnswerCardState extends State<PromptAnswerCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.prompt.answer);
  }

  @override
  void didUpdateWidget(PromptAnswerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.prompt.answer != widget.prompt.answer) {
      _controller.text = widget.prompt.answer;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.metalButtonStroke,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text
          Row(
            children: [
              Expanded(
                child: TextView(
                  text: widget.prompt.questionText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.metalBrownColourForText,
                ),
              ),
              if (!widget.isReadOnly)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  color: Colors.grey,
                  onPressed: widget.onDelete,
                ),
            ],
          ),
          const Gap(12),
          // Answer input or display
          TextView(
            text: widget.prompt.answer,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.metalBrownColourForText,
          )
        ],
      ),
    );
  }
}
