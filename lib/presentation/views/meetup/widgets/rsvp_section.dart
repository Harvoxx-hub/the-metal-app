import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/domain/entities/meetup_dto.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

/// RSVP Section Widget
/// Shows RSVP buttons (Accept/Reject/Maybe) and capacity indicator
class RsvpSection extends StatelessWidget {
  final MeetupDto meetup;
  final Function(String status) onRsvp; // Callback with 'accepted', 'rejected', or 'maybe'

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

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Capacity Indicator
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isFull
                  ? Colors.orange.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isFull
                    ? Colors.orange.withOpacity(0.3)
                    : Colors.green.withOpacity(0.3),
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
          ),
          
          if (!isPast) ...[
            const Gap(16),
            // Current RSVP Status
            if (currentStatus != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(currentStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getStatusIcon(currentStatus),
                      size: 20,
                      color: _getStatusColor(currentStatus),
                    ),
                    const Gap(8),
                    TextView(
                      text: 'You ${_getStatusText(currentStatus)}',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(currentStatus),
                    ),
                  ],
                ),
              ),
            
            const Gap(16),
            // RSVP Buttons
            Row(
              children: [
                // Accept Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isFull && currentStatus != 'accepted'
                        ? null
                        : () {
                            if (currentStatus != 'accepted') {
                              onRsvp('accepted');
                            }
                          },
                    icon: Icon(
                      currentStatus == 'accepted'
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      size: 20,
                    ),
                    label: Text(currentStatus == 'accepted' ? 'Accepted' : 'Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentStatus == 'accepted'
                          ? Colors.green
                          : AppColors.metalPinkColour,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                  ),
                ),
                const Gap(12),
                
                // Maybe Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (currentStatus != 'maybe') {
                        onRsvp('maybe');
                      }
                    },
                    icon: Icon(
                      currentStatus == 'maybe'
                          ? Icons.help
                          : Icons.help_outline,
                      size: 20,
                    ),
                    label: Text(currentStatus == 'maybe' ? 'Maybe' : 'Maybe'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: currentStatus == 'maybe'
                          ? Colors.orange
                          : AppColors.metalBlack,
                      side: BorderSide(
                        color: currentStatus == 'maybe'
                            ? Colors.orange
                            : Colors.grey.shade300,
                        width: currentStatus == 'maybe' ? 2 : 1,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const Gap(12),
                
                // Reject Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (currentStatus != 'rejected') {
                        onRsvp('rejected');
                      }
                    },
                    icon: Icon(
                      currentStatus == 'rejected'
                          ? Icons.cancel
                          : Icons.cancel_outlined,
                      size: 20,
                    ),
                    label: Text(currentStatus == 'rejected' ? 'Rejected' : 'Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: currentStatus == 'rejected'
                          ? Colors.red
                          : AppColors.metalBlack,
                      side: BorderSide(
                        color: currentStatus == 'rejected'
                            ? Colors.red
                            : Colors.grey.shade300,
                        width: currentStatus == 'rejected' ? 2 : 1,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const Gap(16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'maybe':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
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

  String _getStatusText(String status) {
    switch (status) {
      case 'accepted':
        return 'accepted';
      case 'rejected':
        return 'rejected';
      case 'maybe':
        return 'marked as maybe';
      default:
        return '';
    }
  }
}
