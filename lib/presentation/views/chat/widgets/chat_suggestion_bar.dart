import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/services/chat_assistant_analytics.dart';
import 'package:metal/presentation/viewmodels/chat/chat_assistant_viewmodel.dart';
import 'package:metal/presentation/viewmodels/chat/chat_viewmodel_providers.dart';
import 'package:metal/res/colors/cr_colors.dart';

/// Horizontally scrollable suggestion chips + tone selector.
/// Sits between the message list and [ChatInput].
class ChatSuggestionBar extends ConsumerWidget {
  final String connectionId;
  final ValueChanged<String> onSuggestionTapped;
  final VoidCallback? onFallbackUsed;
  final VoidCallback? onSuggestionsShown;

  const ChatSuggestionBar({
    super.key,
    required this.connectionId,
    required this.onSuggestionTapped,
    this.onFallbackUsed,
    this.onSuggestionsShown,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assistantState = ref.watch(chatAssistantProvider(connectionId));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tone selector row
        _ToneSelector(connectionId: connectionId),
        const Gap(4),
        // Suggestion chips or shimmer
        if (assistantState.isLoading && assistantState.suggestions.isEmpty)
          _ShimmerRow()
        else if (assistantState.suggestions.isNotEmpty)
          _SuggestionChips(
            suggestions: assistantState.suggestions,
            onTap: onSuggestionTapped,
          ),
      ],
    );
  }
}

// ── Tone selector ────────────────────────────────────────────────────────────

class _ToneSelector extends ConsumerWidget {
  final String connectionId;
  const _ToneSelector({required this.connectionId});

  static const _tones = [
    (AssistantTone.casual, '😎', 'Casual'),
    (AssistantTone.funny, '😂', 'Funny'),
    (AssistantTone.deep, '💭', 'Deep'),
    (AssistantTone.flirty, '😉', 'Flirty'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTone =
        ref.watch(chatAssistantProvider(connectionId).select((s) => s.tone));

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _tones.length,
        separatorBuilder: (_, __) => const Gap(6),
        itemBuilder: (context, index) {
          final (tone, emoji, label) = _tones[index];
          return _ToneChip(
            emoji: emoji,
            label: label,
            isSelected: currentTone == tone,
            onTap: () {
              ref
                  .read(chatAssistantProvider(connectionId).notifier)
                  .setTone(tone);
              ChatAssistantAnalytics.logToneSelected(tone: tone.apiValue);
            },
          );
        },
      ),
    );
  }
}

class _ToneChip extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToneChip({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.metalPinkColour.withValues(alpha: 0.12)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.metalPinkColour
                : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const Gap(4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppColors.metalPinkColour
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Suggestion chips ─────────────────────────────────────────────────────────

class _SuggestionChips extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onTap;

  const _SuggestionChips({
    required this.suggestions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const Gap(8),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => onTap(suggestions[index]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                suggestions[index],
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Shimmer loading ──────────────────────────────────────────────────────────

class _ShimmerRow extends StatefulWidget {
  @override
  State<_ShimmerRow> createState() => _ShimmerRowState();
}

class _ShimmerRowState extends State<_ShimmerRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            separatorBuilder: (_, __) => const Gap(8),
            itemBuilder: (context, index) {
              final width = [110.0, 140.0, 100.0, 130.0][index];
              return Container(
                width: width,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment(-1.0 + _controller.value * 3, 0),
                    end: Alignment(_controller.value * 3, 0),
                    colors: [
                      Colors.grey.shade200,
                      Colors.grey.shade100,
                      Colors.grey.shade200,
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
