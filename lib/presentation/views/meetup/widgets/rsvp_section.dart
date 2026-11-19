import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/domain/entities/meetup_dto.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

/// RSVP: summary (headline + pill) + segmented control (Going / Maybe / Decline).
class RsvpSection extends StatelessWidget {
  final MeetupDto meetup;
  final Function(String status) onRsvp; // 'accepted', 'rejected', or 'maybe'

  const RsvpSection({
    super.key,
    required this.meetup,
    required this.onRsvp,
  });

  @override
  Widget build(BuildContext context) {
    final isPast = meetup.isPast;
    final isFull = meetup.isFull || meetup.isClosed;
    final currentStatus = meetup.userRsvpStatus;
    final canChooseGoing = !isFull || currentStatus == 'accepted';

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCapacityBanner(isFull),
          if (!isPast) ...[
            const Gap(16),
            _buildResponseSummary(currentStatus, isFull),
            const Gap(16),
            TextView(
              text: 'Your response',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.metalBrownColourForText.withValues(alpha: 0.55),
            ),
            const Gap(8),
            _buildSegmentedRsvp(
              currentStatus: currentStatus,
              canChooseGoing: canChooseGoing,
              onRsvp: onRsvp,
            ),
          ] else ...[
            const Gap(16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 20, color: Colors.grey),
                  Gap(8),
                  TextView(
                    text: 'This event has passed',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCapacityBanner(bool isFull) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFull
            ? Colors.orange.withValues(alpha: 0.1)
            : Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFull
              ? Colors.orange.withValues(alpha: 0.3)
              : Colors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFull ? Icons.event_busy : Icons.event_available,
            size: 20,
            color: isFull ? Colors.orange : Colors.green,
          ),
          const Gap(8),
          TextView(
            text: isFull
                ? 'Event Full (${meetup.acceptedCount}/${meetup.maxParticipants})'
                : '${meetup.acceptedCount}/${meetup.maxParticipants} spots taken',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isFull ? Colors.orange : Colors.green,
          ),
        ],
      ),
    );
  }

  /// Option A: headline, supporting line, and status pill.
  Widget _buildResponseSummary(String? currentStatus, bool isFull) {
    if (currentStatus == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.metalTabBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.metalButtonStroke.withValues(alpha: 0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextView(
              text: 'Join this meetup?',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.metalBrownColourForText,
            ),
            const Gap(6),
            TextView(
              text: 'Pick Going, Maybe, or Decline below.',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.metalBrownColourForText.withValues(alpha: 0.75),
            ),
          ],
        ),
      );
    }

    final accent = _summaryAccent(currentStatus);
    final title = _summaryTitle(currentStatus);
    final subtitle = _summarySubtitle(currentStatus, isFull);
    final pillLabel = _pillLabel(currentStatus);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextView(
            text: title,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: accent.titleColor,
          ),
          const Gap(6),
          TextView(
            text: subtitle,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: accent.subtitleColor,
          ),
          const Gap(12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: accent.pillFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.pillBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_summaryIcon(currentStatus), size: 20, color: accent.pillIcon),
                const Gap(8),
                TextView(
                  text: pillLabel,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: accent.pillText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Option B: segmented row — only one segment is filled; colors match intent (green / orange / red).
  Widget _buildSegmentedRsvp({
    required String? currentStatus,
    required bool canChooseGoing,
    required Function(String status) onRsvp,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      // Scrollable column gives unbounded max height; stretch Row can collapse without this.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _RsvpSegment(
                label: 'Going',
                icon: Icons.check_circle_outline,
                selected: currentStatus == 'accepted',
                enabled: canChooseGoing,
                selectedFill: Colors.green.shade600,
                onTap: () {
                  if (currentStatus != 'accepted') onRsvp('accepted');
                },
              ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              indent: 0,
              endIndent: 0,
              color: Colors.grey.shade300,
            ),
            Expanded(
              child: _RsvpSegment(
                label: 'Maybe',
                icon: Icons.help_outline,
                selected: currentStatus == 'maybe',
                enabled: true,
                selectedFill: Colors.orange.shade600,
                onTap: () {
                  if (currentStatus != 'maybe') onRsvp('maybe');
                },
              ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              indent: 0,
              endIndent: 0,
              color: Colors.grey.shade300,
            ),
            Expanded(
              child: _RsvpSegment(
                label: 'Decline',
                icon: Icons.cancel_outlined,
                selected: currentStatus == 'rejected',
                enabled: true,
                selectedFill: Colors.red.shade600,
                onTap: () {
                  if (currentStatus != 'rejected') onRsvp('rejected');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _SummaryAccent _summaryAccent(String status) {
    switch (status) {
      case 'accepted':
        return _SummaryAccent(
          background: Colors.green.withValues(alpha: 0.06),
          border: Colors.green.withValues(alpha: 0.45),
          titleColor: AppColors.metalBrownColourForText,
          subtitleColor: AppColors.metalBrownColourForText.withValues(alpha: 0.75),
          pillFill: Colors.green.withValues(alpha: 0.12),
          pillBorder: Colors.green.withValues(alpha: 0.35),
          pillIcon: Colors.green.shade700,
          pillText: Colors.green.shade800,
        );
      case 'rejected':
        return _SummaryAccent(
          background: Colors.red.withValues(alpha: 0.06),
          border: Colors.red.withValues(alpha: 0.4),
          titleColor: AppColors.metalBrownColourForText,
          subtitleColor: AppColors.metalBrownColourForText.withValues(alpha: 0.75),
          pillFill: Colors.red.withValues(alpha: 0.12),
          pillBorder: Colors.red.withValues(alpha: 0.35),
          pillIcon: Colors.red.shade700,
          pillText: Colors.red.shade800,
        );
      case 'maybe':
        return _SummaryAccent(
          background: Colors.orange.withValues(alpha: 0.06),
          border: Colors.orange.withValues(alpha: 0.4),
          titleColor: AppColors.metalBrownColourForText,
          subtitleColor: AppColors.metalBrownColourForText.withValues(alpha: 0.75),
          pillFill: Colors.orange.withValues(alpha: 0.12),
          pillBorder: Colors.orange.withValues(alpha: 0.35),
          pillIcon: Colors.orange.shade700,
          pillText: Colors.orange.shade800,
        );
      default:
        return _SummaryAccent(
          background: AppColors.metalTabBg,
          border: AppColors.metalButtonStroke,
          titleColor: AppColors.metalBrownColourForText,
          subtitleColor: AppColors.metalBrownColourForText.withValues(alpha: 0.75),
          pillFill: AppColors.metalWhite,
          pillBorder: AppColors.metalButtonStroke,
          pillIcon: AppColors.metalBrownColourForText,
          pillText: AppColors.metalBrownColourForText,
        );
    }
  }

  String _summaryTitle(String status) {
    switch (status) {
      case 'accepted':
        return "You're going";
      case 'rejected':
        return 'You declined this meetup';
      case 'maybe':
        return 'You might go';
      default:
        return 'Your response';
    }
  }

  String _summarySubtitle(String status, bool isFull) {
    switch (status) {
      case 'accepted':
        return isFull
            ? "You're on the list. This event is at capacity."
            : "You're on the list. Others can see you're attending.";
      case 'rejected':
        return "You're not listed as attending. Change your mind anytime below.";
      case 'maybe':
        return "We'll show you as unsure until you pick Going or Decline.";
      default:
        return '';
    }
  }

  String _pillLabel(String status) {
    switch (status) {
      case 'accepted':
        return 'Going';
      case 'rejected':
        return 'Declined';
      case 'maybe':
        return 'Maybe';
      default:
        return '';
    }
  }

  IconData _summaryIcon(String status) {
    switch (status) {
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'maybe':
        return Icons.help;
      default:
        return Icons.radio_button_unchecked;
    }
  }
}

class _SummaryAccent {
  final Color background;
  final Color border;
  final Color titleColor;
  final Color subtitleColor;
  final Color pillFill;
  final Color pillBorder;
  final Color pillIcon;
  final Color pillText;

  _SummaryAccent({
    required this.background,
    required this.border,
    required this.titleColor,
    required this.subtitleColor,
    required this.pillFill,
    required this.pillBorder,
    required this.pillIcon,
    required this.pillText,
  });
}

class _RsvpSegment extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final Color selectedFill;
  final VoidCallback onTap;

  const _RsvpSegment({
    required this.label,
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.selectedFill,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected
        ? AppColors.metalWhite
        : AppColors.metalBrownColourForText.withValues(alpha: enabled ? 1.0 : 0.4);
    final bg = selected ? selectedFill : AppColors.metalWhite;

    return Material(
      color: bg,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: fg),
              const Gap(4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
