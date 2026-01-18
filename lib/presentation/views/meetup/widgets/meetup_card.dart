import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:metal/domain/entities/meetup_dto.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/text_views.dart';

/// Meetup Card Widget
/// Displays a meetup in the list view
class MeetupCard extends StatelessWidget {
  final MeetupDto meetup;

  const MeetupCard({
    super.key,
    required this.meetup,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.meetupDetails,
          arguments: meetup.id,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Event name and status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextView(
                        text: meetup.eventName,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.metalBlack,
                      ),
                      const Gap(4),
                      // Status badge
                      _buildStatusBadge(),
                    ],
                  ),
                ),
                // Distance
                if (meetup.distance != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.metalPinkColour.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextView(
                      text: '${meetup.distance!.toStringAsFixed(1)} km away',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.metalPinkColour,
                    ),
                  ),
              ],
            ),
            const Gap(12),
            // Date and time
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                const Gap(8),
                TextView(
                  text: _formatDateTime(),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade700,
                ),
              ],
            ),
            const Gap(8),
            // Capacity
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                const Gap(8),
                TextView(
                  text: '${meetup.acceptedCount}/${meetup.maxParticipants} accepted',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade700,
                ),
              ],
            ),
            if (meetup.description != null && meetup.description!.isNotEmpty) ...[
              const Gap(8),
              TextView(
                text: meetup.description!,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade600,
                maxLines: 2,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;

    if (meetup.isPast) {
      color = Colors.grey;
      text = 'Past Event';
    } else if (meetup.isClosed || meetup.isFull) {
      color = Colors.orange;
      text = 'Full';
    } else {
      color = Colors.green;
      text = 'Open';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextView(
        text: text,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  String _formatDateTime() {
    try {
      final dateTime = meetup.eventDateTime;
      final dateStr = DateFormat('MMM dd, yyyy').format(dateTime);
      final timeStr = meetup.time; // Already formatted as HH:MM
      return '$dateStr at $timeStr';
    } catch (e) {
      return '${meetup.date} at ${meetup.time}';
    }
  }
}
