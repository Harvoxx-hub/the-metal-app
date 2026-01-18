import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:metal/domain/entities/meetup_dto.dart';
import 'package:metal/presentation/viewmodels/meetup/meetup_detail_viewmodel.dart';
import 'package:metal/presentation/views/meetup/widgets/rsvp_section.dart';
import 'package:metal/presentation/views/meetup/widgets/attendee_list.dart';
import 'package:metal/core/services/deep_link_service.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/widgets/state.handler/empty.state.dart';
import 'package:metal/widgets/state.handler/error.state.dart';
import 'package:url_launcher/url_launcher.dart';

/// Meetup Detail View
/// Displays a single meetup with full details, RSVP options, and attendees
class MeetupDetailView extends ConsumerStatefulWidget {
  final String meetupId;

  const MeetupDetailView({
    super.key,
    required this.meetupId,
  });

  @override
  ConsumerState<MeetupDetailView> createState() => _MeetupDetailViewState();
}

class _MeetupDetailViewState extends ConsumerState<MeetupDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(meetupDetailViewModelProvider(widget.meetupId).notifier).loadMeetup(widget.meetupId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(meetupDetailViewModelProvider(widget.meetupId));
    final viewModel = ref.read(meetupDetailViewModelProvider(widget.meetupId).notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(state, viewModel),
      body: _buildBody(state, viewModel),
    );
  }

  PreferredSizeWidget _buildAppBar(MeetupDetailState state, MeetupDetailViewModel viewModel) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.metalBlack),
        onPressed: () => Navigator.pop(context),
      ),
      title: const TextView(
        text: 'Meetup',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.metalBlack,
      ),
      centerTitle: true,
      actions: [
        // Share button
        IconButton(
          icon: const Icon(Icons.share, color: AppColors.metalBlack),
          onPressed: () => _handleShare(state.meetup),
        ),
        // Edit/Delete if creator
        if (viewModel.isCreator && state.meetup != null)
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: AppColors.metalBlack),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    Gap(8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    Gap(8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'delete') {
                _handleDelete(viewModel);
              } else if (value == 'edit') {
                // TODO: Navigate to edit screen
                Fluttertoast.showToast(msg: 'Edit feature coming soon');
              }
            },
          ),
      ],
    );
  }

  Widget _buildBody(MeetupDetailState state, MeetupDetailViewModel viewModel) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }

    if (state.isError) {
      return ErrorState(
        text: state.errorMessage ?? 'Failed to load meetup',
        retry: () => viewModel.refresh(widget.meetupId),
      );
    }

    if (state.meetup == null) {
      return const EmptyState(
        text: 'Meetup not found',
      );
    }

    final meetup = state.meetup!;

    return RefreshIndicator(
      onRefresh: () async {
        await viewModel.refresh(widget.meetupId);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeaderSection(meetup),
            const Divider(height: 1),
            
            // Event Details
            _buildEventDetails(meetup),
            const Divider(height: 1),
            
            // Place Section
            _buildPlaceSection(meetup),
            
            // Description Section
            if (meetup.description != null && meetup.description!.isNotEmpty) ...[
              const Divider(height: 1),
              _buildDescriptionSection(meetup),
            ],
            
            // RSVP Section
            const Divider(height: 1),
            RsvpSection(
              meetup: meetup,
              onRsvp: (status) => _handleRsvp(viewModel, status),
            ),
            
            // Attendees Section
            const Divider(height: 1),
            AttendeeList(
              attendees: state.attendees,
              isLoading: state.isLoadingAttendees,
              currentStatus: state.attendeeStatus,
              onStatusChanged: (status) => viewModel.setAttendeeStatus(status),
              filterByPreferences: state.filterByPreferences,
              onToggleFilter: () => viewModel.toggleFilterByPreferences(),
              meetupId: widget.meetupId,
              onInviteUsers: (usernames) => _handleInviteUsers(viewModel, usernames),
              isCreator: viewModel.isCreator,
            ),
            
            const Gap(32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(MeetupDto meetup) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Name
          TextView(
            text: meetup.eventName,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.metalBlack,
          ),
          const Gap(8),
          
          // Status Badge
          Row(
            children: [
              _buildStatusBadge(meetup),
              if (meetup.distance != null) ...[
                const Gap(12),
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
            ],
          ),
          
          const Gap(16),
          
          // Creator Info
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: meetup.creatorPhoto != null
                    ? NetworkImage(meetup.creatorPhoto!)
                    : null,
                child: meetup.creatorPhoto == null
                    ? Text(
                        (meetup.creatorUsername ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(fontSize: 16),
                      )
                    : null,
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextView(
                      text: 'Created by ${meetup.creatorUsername ?? 'Someone'}',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.metalBlack,
                    ),
                    TextView(
                      text: '${DateFormat('MMM dd, yyyy').format(meetup.createdAt)} at ${DateFormat('hh:mm a').format(meetup.createdAt)}',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(MeetupDto meetup) {
    Color color;
    String text;

    if (meetup.isPast) {
      color = Colors.grey;
      text = 'Past Event';
    } else if (meetup.isClosed || meetup.isFull) {
      color = Colors.orange;
      text = 'Event Full';
    } else {
      color = Colors.green;
      text = 'Open';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: TextView(
        text: text,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  Widget _buildEventDetails(MeetupDto meetup) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Date and Time
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextView(
                      text: 'Date & Time',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    const Gap(4),
                    TextView(
                      text: _formatDateTime(meetup),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.metalBlack,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(16),
          
          // Capacity
          Row(
            children: [
              const Icon(Icons.people, size: 20, color: Colors.grey),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextView(
                      text: 'Capacity',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    const Gap(4),
                    TextView(
                      text: '${meetup.acceptedCount} / ${meetup.maxParticipants} accepted',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.metalBlack,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceSection(MeetupDto meetup) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, size: 20, color: Colors.grey),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextView(
                      text: 'Location',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    const Gap(4),
                    GestureDetector(
                      onTap: () => _openPlaceUrl(meetup.placeUrl),
                    child: Text(
                      'View on Map',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.metalPinkColour,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(MeetupDto meetup) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextView(
            text: 'Description',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.metalBlack,
          ),
          const Gap(8),
          TextView(
            text: meetup.description!,
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ],
      ),
    );
  }

  String _formatDateTime(MeetupDto meetup) {
    try {
      final dateStr = DateFormat('MMM dd, yyyy').format(meetup.eventDateTime);
      final timeStr = meetup.time; // Already formatted as HH:MM
      final timeOfDay = TimeOfDay(
        hour: int.parse(timeStr.split(':')[0]),
        minute: int.parse(timeStr.split(':')[1]),
      );
      return '$dateStr at ${timeOfDay.format(context)}';
    } catch (e) {
      return '${meetup.date} at ${meetup.time}';
    }
  }

  Future<void> _openPlaceUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Fluttertoast.showToast(msg: 'Could not open location URL');
    }
  }

  Future<void> _handleRsvp(MeetupDetailViewModel viewModel, String status) async {
    final success = await viewModel.rsvpMeetup(widget.meetupId, status);
    if (mounted) {
      if (success) {
        Fluttertoast.showToast(
          msg: status == 'accepted'
              ? 'You accepted the meetup!'
              : status == 'rejected'
                  ? 'You rejected the meetup'
                  : 'You marked as maybe',
        );
      } else {
        Fluttertoast.showToast(msg: 'Failed to update RSVP');
      }
    }
  }

  Future<void> _handleInviteUsers(MeetupDetailViewModel viewModel, List<String> usernames) async {
    final success = await viewModel.inviteUsers(widget.meetupId, usernames);
    if (mounted) {
      if (success) {
        Fluttertoast.showToast(msg: 'Users invited successfully!');
      } else {
        Fluttertoast.showToast(msg: 'Failed to invite users');
      }
    }
  }

  Future<void> _handleDelete(MeetupDetailViewModel viewModel) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meetup'),
        content: const Text('Are you sure you want to delete this meetup? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await viewModel.deleteMeetup(widget.meetupId);
      if (mounted) {
        if (success) {
          Fluttertoast.showToast(msg: 'Meetup deleted successfully');
          Navigator.pop(context);
        } else {
          Fluttertoast.showToast(msg: 'Failed to delete meetup');
        }
      }
    }
  }

  Future<void> _handleShare(MeetupDto? meetup) async {
    if (meetup == null) return;

    final url = DeepLinkService.generateMeetupUrl(meetup.id);
    final text = 'Join me for ${meetup.eventName} on ${DateFormat('MMM dd, yyyy').format(meetup.eventDateTime)} at ${meetup.time}! $url';

    await Share.share(text);
  }
}
