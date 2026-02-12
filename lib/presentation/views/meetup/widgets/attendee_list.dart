import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/domain/entities/meetup_dto.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

/// Attendee List Widget
/// Shows list of attendees with filtering options
class AttendeeList extends ConsumerStatefulWidget {
  final List<MeetupRsvpDto> attendees;
  final bool isLoading;
  final String currentStatus; // 'all', 'accepted', 'maybe'
  final Function(String status) onStatusChanged;
  final bool filterByPreferences;
  final Function() onToggleFilter;

  const AttendeeList({
    super.key,
    required this.attendees,
    required this.isLoading,
    required this.currentStatus,
    required this.onStatusChanged,
    required this.filterByPreferences,
    required this.onToggleFilter,
  });

  @override
  ConsumerState<AttendeeList> createState() => _AttendeeListState();
}

class _AttendeeListState extends ConsumerState<AttendeeList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with filters
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TextView(
                text: 'Attendees',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.metalBlack,
              ),
              // Filter by preferences toggle
              IconButton(
                icon: Icon(
                  widget.filterByPreferences
                      ? Icons.filter_list
                      : Icons.filter_list_outlined,
                      color: widget.filterByPreferences
                          ? AppColors.metalPinkColour
                          : AppColors.metalBrownColourForText,
                ),
                onPressed: widget.onToggleFilter,
                tooltip: 'Filter by preferences',
              ),
            ],
          ),
          const Gap(12),
          
          // Status tabs
          Container(
            decoration: BoxDecoration(
              color: AppColors.metalGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildStatusTab('all', 'All'),
                _buildStatusTab('accepted', 'Accepted'),
                _buildStatusTab('maybe', 'Maybe'),
              ],
            ),
          ),
          
          const Gap(16),
          
          // Attendees list
          if (widget.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (widget.attendees.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: TextView(
                    text: widget.currentStatus == 'accepted'
                        ? 'No accepted attendees yet'
                        : widget.currentStatus == 'maybe'
                            ? 'No maybe responses yet'
                            : 'No attendees yet',
                    fontSize: 14,
                    color: AppColors.metalBrownColourForText,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.attendees.length,
              itemBuilder: (context, index) {
                final attendee = widget.attendees[index];
                return _buildAttendeeItem(attendee);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatusTab(String status, String label) {
    final isActive = widget.currentStatus == status;
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onStatusChanged(status),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.metalPinkColour : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: TextView(
              text: label,
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? Colors.white : AppColors.metalBrownColourForText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttendeeItem(MeetupRsvpDto attendee) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundImage: attendee.userPhoto != null
                ? NetworkImage(attendee.userPhoto!)
                : null,
            child: attendee.userPhoto == null
                ? Text(
                    (attendee.username ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(fontSize: 18),
                  )
                : null,
          ),
          const Gap(12),
          
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextView(
                  text: '@${attendee.username ?? 'Unknown'}',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.metalBlack,
                ),
                const Gap(4),
                    TextView(
                      text: 'Responded ${_formatResponseTime(attendee.respondedAt)}',
                      fontSize: 12,
                      color: AppColors.metalBrownColourForText,
                    ),
              ],
            ),
          ),
          
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(attendee.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getStatusColor(attendee.status).withOpacity(0.3),
              ),
            ),
            child: TextView(
              text: attendee.status.toUpperCase(),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(attendee.status),
            ),
          ),
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

  String _formatResponseTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'just now';
    }
  }

}

