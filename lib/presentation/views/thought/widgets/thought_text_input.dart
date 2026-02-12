import 'package:flutter/material.dart';
import 'package:metal/res/colors/cr_colors.dart';

/// Text input section for thought creation
class ThoughtTextInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final int maxLength;
  final String? hintText;

  const ThoughtTextInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.maxLength = 1000,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        maxLength: maxLength,
        maxLines: null,
        minLines: 6,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.metalBlack,
          height: 1.5,
        ),
        decoration: InputDecoration(
          hintText: hintText ?? "What's on your mind?",
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          counterText: '', // Hide default counter, we'll show custom one
        ),
      ),
    );
  }
}



