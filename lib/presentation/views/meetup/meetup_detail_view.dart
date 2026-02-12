import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:metal/core/config/map_config.dart';
import 'package:metal/core/services/deep_link_service.dart';
import 'package:metal/data/repositories/place/place_repository_providers.dart';
import 'package:metal/domain/entities/meetup_dto.dart';
import 'package:metal/presentation/viewmodels/meetup/meetup_detail_viewmodel.dart';
import 'package:metal/presentation/views/meetup/edit_meetup_screen.dart';
import 'package:metal/presentation/views/meetup/widgets/rsvp_section.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/widgets/state.handler/empty.state.dart';
import 'package:metal/widgets/state.handler/error.state.dart';
import 'package:url_launcher/url_launcher.dart';

/// Meetup Detail (Live Event Dashboard)
/// Header, LIVE DASHBOARD badge, stats cards, capacity, map, tabbed attendees, Re-Broadcast.
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
  /// Resolved lat/lng when meetup has placeName but no placeLocation (geocode fallback).
  LatLng? _resolvedMapLocation;
  String? _geocodeRequestedForMeetupId;

  Future<void> _maybeGeocodePlaceName(MeetupDto meetup) async {
    if (meetup.placeLocation != null ||
        meetup.placeName.isEmpty ||
        _geocodeRequestedForMeetupId == meetup.id) return;
    _geocodeRequestedForMeetupId = meetup.id;
    final repo = ref.read(placeRepositoryProvider);
    final result = await repo.geocodeAddress(meetup.placeName);
    if (!mounted) return;
    if (result != null &&
        result.latitude.isFinite &&
        result.longitude.isFinite &&
        result.latitude >= -90 &&
        result.latitude <= 90 &&
        result.longitude >= -180 &&
        result.longitude <= 180) {
      setState(() {
        _resolvedMapLocation = LatLng(result.latitude, result.longitude);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(meetupDetailViewModelProvider(widget.meetupId).notifier)
          .loadMeetup(widget.meetupId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(meetupDetailViewModelProvider(widget.meetupId));
    final viewModel =
        ref.read(meetupDetailViewModelProvider(widget.meetupId).notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(state, viewModel),
      body: _buildBody(state, viewModel),
    );
  }

  PreferredSizeWidget _buildAppBar(
      MeetupDetailState state, MeetupDetailViewModel viewModel) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.metalWhite,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back,
            color: AppColors.metalBrownColourForText),
        onPressed: () => Navigator.pop(context),
      ),
      title: null,
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined,
              color: AppColors.metalBrownColourForText),
          onPressed: () => _handleShare(state.meetup),
        ),
      ],
    );
  }

  static const double _paddingH = 16;
  static const double _sectionGap = 20;

  Widget _buildBody(MeetupDetailState state, MeetupDetailViewModel viewModel) {
    if (widget.meetupId.isEmpty) {
      return const EmptyState(text: 'Invalid link');
    }
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (state.isError) {
      return ErrorState(
        text: state.errorMessage ?? 'Failed to load meetup',
        retry: () => viewModel.refresh(widget.meetupId),
      );
    }
    if (state.meetup == null) {
      return const EmptyState(text: 'Meetup not found');
    }

    final meetup = state.meetup!;

    return RefreshIndicator(
      onRefresh: () => viewModel.refresh(widget.meetupId),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: _paddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Gap(8),
            _buildPageHeader(meetup, viewModel),
            const Gap(10),
            _buildStatusBadge(meetup, viewModel.isCreator),
            if (meetup.description != null && meetup.description!.trim().isNotEmpty) ...[
              const Gap(_sectionGap),
              _buildDescriptionSection(meetup),
            ],
            const Gap(_sectionGap),
            _buildLocationSection(meetup),
            const Gap(_sectionGap),
            _buildPeopleAttendingSection(state, viewModel),
            const Gap(_sectionGap),
            if (viewModel.isCreator) ...[
              _buildStatsCards(meetup),
              const Gap(_sectionGap),
              _buildCapacitySection(meetup),
              const Gap(_sectionGap),
              _buildAttendeesSection(state, viewModel),
              const Gap(_sectionGap),
              _buildRebroadcastButton(meetup, viewModel),
            ] else ...[
              _buildGoingSummary(meetup),
              const Gap(_sectionGap),
              RsvpSection(
                meetup: meetup,
                onRsvp: (status) => _handleRsvp(viewModel, status),
              ),
            ],
            const Gap(32),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader(MeetupDto meetup, MeetupDetailViewModel viewModel) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextView(
            text: meetup.eventName,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.metalBrownColourForText,
          ),
        ),
        if (viewModel.isCreator)
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: AppColors.metalBrownColourForText),
            onPressed: () => _showSettingsMenu(meetup, viewModel),
          ),
      ],
    );
  }

  void _showSettingsMenu(MeetupDto meetup, MeetupDetailViewModel viewModel) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Meetup'),
              onTap: () {
                Navigator.pop(ctx);
                _handleEdit(meetup);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _handleDelete(viewModel);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Creator sees LIVE DASHBOARD; others see Open / Full / Past.
  Widget _buildStatusBadge(MeetupDto meetup, bool isCreator) {
    if (isCreator) {
      final isLive = !meetup.isPast && meetup.isOpen;
      return Row(
        children: [
          if (isLive) ...[
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.metalPinkColour,
                shape: BoxShape.circle,
              ),
            ),
            const Gap(8),
          ],
          TextView(
            text: isLive
                ? 'LIVE DASHBOARD'
                : (meetup.isPast ? 'PAST EVENT' : 'EVENT FULL'),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.metalBrownColourForText.withOpacity(0.8),
          ),
        ],
      );
    }
    final isFull = meetup.isFull;
    String label = meetup.isPast ? 'Past event' : (isFull ? 'Full' : 'Open');
    return TextView(
      text: label,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.metalBrownColourForText.withOpacity(0.8),
    );
  }

  Widget _buildDescriptionSection(MeetupDto meetup) {
    final desc = meetup.description?.trim() ?? '';
    if (desc.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextView(
          text: 'Description',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.metalBrownColourForText,
        ),
        const Gap(8),
        TextView(
          text: desc,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.metalBrownColourForText.withOpacity(0.85),
        ),
      ],
    );
  }

  /// People that are attending: list with Metal icon, name, when they got interest, tap to profile.
  Widget _buildPeopleAttendingSection(
      MeetupDetailState state, MeetupDetailViewModel viewModel) {
    final meetup = state.meetup!;
    final accepted = state.acceptedAttendees;
    final count = accepted.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextView(
          text: 'People that are attending',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.metalBrownColourForText,
        ),
        if (count > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TextView(
              text: 'People that are going for the ${meetup.eventName}',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.metalBrownColourForText.withOpacity(0.6),
            ),
          ),
        const Gap(12),
        if (state.isLoadingAttendees && state.attendeeStatus == 'accepted')
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (accepted.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: TextView(
              text: 'No one has confirmed yet',
              fontSize: 14,
              color: AppColors.metalBrownColourForText.withOpacity(0.7),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: accepted.length,
            separatorBuilder: (_, __) => const Gap(12),
            itemBuilder: (_, index) => _buildAttendingPersonItem(accepted[index]),
          ),
      ],
    );
  }

  Widget _buildAttendingPersonItem(MeetupRsvpDto attendee) {
    final displayName =
        attendee.username != null && attendee.username!.isNotEmpty
            ? attendee.username!
            : 'User';
    final whenInterested = DateFormat('MMM d, y • HH:mm').format(attendee.respondedAt);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.userProfile,
            arguments: attendee.userId,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: AppColors.metalWhite,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.metalBlack.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: attendee.userPhoto != null
                    ? NetworkImage(attendee.userPhoto!)
                    : null,
                backgroundColor: AppColors.metalTabBg,
                child: attendee.userPhoto == null
                    ? TextView(
                        text: displayName.length >= 2
                            ? '${displayName[0].toUpperCase()}${displayName[1].toUpperCase()}'
                            : displayName.isNotEmpty
                                ? displayName[0].toUpperCase()
                                : 'U',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.metalBrownColourForText,
                      )
                    : null,
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextView(
                      text: displayName,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.metalBrownColourForText,
                    ),
                    const Gap(2),
                    TextView(
                      text: 'Interested $whenInterested',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.metalBrownColourForText.withOpacity(0.6),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.metalBrownColourForText.withOpacity(0.5),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// For non-creators: simple "X people going" summary.
  Widget _buildGoingSummary(MeetupDto meetup) {
    final going = meetup.acceptedCount;
    final max = meetup.maxParticipants;
    return Row(
      children: [
        Icon(Icons.people_outline,
            size: 18,
            color: AppColors.metalBrownColourForText.withOpacity(0.7)),
        const Gap(8),
        TextView(
          text:
              '$going ${going == 1 ? 'person' : 'people'} going${max > 0 ? ' · $max spots' : ''}',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.metalBrownColourForText.withOpacity(0.8),
        ),
      ],
    );
  }

  Widget _buildStatsCards(MeetupDto meetup) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'CONFIRMED',
            '${meetup.acceptedCount}/${meetup.maxParticipants}',
          ),
        ),
        const Gap(8),
        Expanded(
          child: _buildStatCard('PENDING', '${meetup.maybeCount}'),
        ),
        const Gap(8),
        Expanded(
          child: _buildStatCard('REJECTED', '${meetup.rejectedCount}'),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.metalWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.metalButtonStroke),
      ),
      child: Column(
        children: [
          TextView(
            text: label,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.metalBrownColourForText.withOpacity(0.7),
          ),
          const Gap(6),
          TextView(
            text: value,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.metalBrownColourForText,
          ),
        ],
      ),
    );
  }

  Widget _buildCapacitySection(MeetupDto meetup) {
    final pct = meetup.maxParticipants > 0
        ? (meetup.acceptedCount / meetup.maxParticipants * 100).round()
        : 0;
    final remaining = (meetup.maxParticipants - meetup.acceptedCount)
        .clamp(0, meetup.maxParticipants);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextView(
              text: 'Capacity Reached',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.metalBrownColourForText,
            ),
            TextView(
              text: '$pct%',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.metalPinkColour,
            ),
          ],
        ),
        const Gap(10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: meetup.maxParticipants > 0
                ? meetup.acceptedCount / meetup.maxParticipants
                : 0,
            minHeight: 10,
            backgroundColor: AppColors.metalTabBg,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.metalPinkColour),
          ),
        ),
        const Gap(8),
        TextView(
          text:
              '$remaining spot${remaining == 1 ? '' : 's'} remaining for a full house',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.metalBrownColourForText.withOpacity(0.7),
        ),
      ],
    );
  }

  /// Effective map position: from meetup.placeLocation or from geocoded placeName.
  LatLng? _mapPosition(MeetupDto meetup) {
    if (meetup.placeLocation != null) {
      final lat = meetup.placeLocation!.latitude;
      final lng = meetup.placeLocation!.longitude;
      if (lat.isFinite &&
          lng.isFinite &&
          lat >= -90 &&
          lat <= 90 &&
          lng >= -180 &&
          lng <= 180) {
        return LatLng(lat, lng);
      }
    }
    return _resolvedMapLocation;
  }

  Widget _buildLocationSection(MeetupDto meetup) {
    final position = _mapPosition(meetup);
    if (meetup.placeLocation == null &&
        meetup.placeName.isNotEmpty &&
        _geocodeRequestedForMeetupId != meetup.id) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _maybeGeocodePlaceName(meetup));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: position != null && MapConfig.hasGoogleMapsKey
                    ? GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: position,
                          zoom: 14,
                        ),
                        markers: {
                          Marker(
                            markerId: MarkerId(meetup.id),
                            position: position,
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueRose),
                          ),
                        },
                        zoomControlsEnabled: false,
                        myLocationButtonEnabled: false,
                      )
                    : _buildMapPlaceholder(),
              ),
              Positioned(
                left: 12,
                bottom: 12,
                right: 56,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.metalWhite.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.metalButtonStroke.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextView(
                        text: 'LOCATION',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color:
                            AppColors.metalBrownColourForText.withOpacity(0.7),
                      ),
                      const Gap(2),
                      TextView(
                        text: meetup.placeName.isNotEmpty
                            ? meetup.placeName
                            : 'No address',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.metalBrownColourForText,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 12,
                bottom: 12,
                child: Material(
                  color: AppColors.metalPinkColour,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: () => _openPlaceInMaps(meetup),
                    borderRadius: BorderRadius.circular(24),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.directions,
                          color: AppColors.metalWhite, size: 24),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openPlaceInMaps(MeetupDto meetup) async {
    try {
      Uri uri;
      if (meetup.placeLocation != null) {
        final lat = meetup.placeLocation!.latitude;
        final lng = meetup.placeLocation!.longitude;
        uri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
        );
      } else {
        final query = Uri.encodeComponent(
            meetup.placeName.isNotEmpty ? meetup.placeName : '');
        uri =
            Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
      }
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Fluttertoast.showToast(msg: 'Could not open maps');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Could not open maps');
    }
  }

  Widget _buildMapPlaceholder() {
    return Container(
      color: AppColors.metalTabBg,
      child: Center(
        child: Icon(
          Icons.map_outlined,
          size: 48,
          color: AppColors.metalButtonStroke.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildAttendeesSection(
      MeetupDetailState state, MeetupDetailViewModel viewModel) {
    final tabs = ['accepted', 'maybe', 'waitlist'];
    final labels = ['Confirmed', 'Pending', 'Waitlist'];
    final currentIndex = tabs.indexOf(state.attendeeStatus);
    final effectiveIndex = currentIndex >= 0 ? currentIndex : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(3, (i) {
            final isSelected = effectiveIndex == i;
            final count = i == 0
                ? state.meetup?.acceptedCount ?? 0
                : i == 1
                    ? state.meetup?.maybeCount ?? 0
                    : 0;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  viewModel.setAttendeeStatus(tabs[i]);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected
                            ? AppColors.metalPinkColour
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextView(
                        text: labels[i],
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.metalBrownColourForText
                            : AppColors.metalBrownColourForText
                                .withOpacity(0.6),
                      ),
                      if (i == 1 && count > 0) ...[
                        const Gap(6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.metalPinkColour,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextView(
                            text: '$count',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.metalWhite,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
        const Gap(16),
        if (state.isLoadingAttendees)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
                child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )),
          )
        else if (state.attendeeStatus == 'waitlist')
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: TextView(
                text: 'No one on waitlist',
                fontSize: 14,
                color: AppColors.metalBrownColourForText.withOpacity(0.7),
              ),
            ),
          )
        else if (state.attendees.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: TextView(
                text: state.attendeeStatus == 'accepted'
                    ? 'No confirmed attendees yet'
                    : 'No pending responses yet',
                fontSize: 14,
                color: AppColors.metalBrownColourForText.withOpacity(0.7),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.attendees.length,
            separatorBuilder: (_, __) => const Gap(12),
            itemBuilder: (_, index) {
              final a = state.attendees[index];
              return _buildAttendeeItem(a);
            },
          ),
      ],
    );
  }

  Widget _buildAttendeeItem(MeetupRsvpDto attendee) {
    final displayName =
        attendee.username != null && attendee.username!.isNotEmpty
            ? attendee.username!
            : 'User';
    final initials = displayName.length >= 2
        ? '${displayName[0].toUpperCase()}${displayName[1].toUpperCase()}'
        : displayName.isNotEmpty
            ? displayName[0].toUpperCase()
            : 'U';
    final statusLabel = attendee.status == 'accepted'
        ? 'GOING'
        : attendee.status == 'maybe'
            ? 'MAYBE'
            : 'NOT GOING';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.metalWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.metalBlack.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: attendee.userPhoto != null
                ? NetworkImage(attendee.userPhoto!)
                : null,
            backgroundColor: AppColors.metalTabBg,
            child: attendee.userPhoto == null
                ? TextView(
                    text: initials,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.metalBrownColourForText,
                  )
                : null,
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextView(
                  text: displayName,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.metalBrownColourForText,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextView(
                text: 'STATUS',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.metalBrownColourForText.withOpacity(0.6),
              ),
              const Gap(2),
              TextView(
                text: statusLabel,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: attendee.status == 'accepted'
                    ? AppColors.metalPinkColour
                    : AppColors.metalBrownColourForText.withOpacity(0.8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRebroadcastButton(
      MeetupDto meetup, MeetupDetailViewModel viewModel) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Material(
            color: AppColors.metalPinkColour,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: () async {
                final success =
                    await viewModel.broadcastMeetup(widget.meetupId);
                if (mounted) {
                  if (success) {
                    Fluttertoast.showToast(
                        msg: 'Meetup re-broadcast successfully');
                  } else {
                    Fluttertoast.showToast(
                        msg: 'Re-broadcast failed. Try again later.');
                  }
                }
              },
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cell_tower,
                        color: AppColors.metalWhite, size: 22),
                    const Gap(10),
                    TextView(
                      text: 'Re-Broadcast Meetup',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.metalWhite,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Gap(10),
        Center(
          child: TextView(
            text: 'Reach 50+ users active within ${meetup.broadcastRadius} km',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.metalBrownColourForText.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Future<void> _handleRsvp(
      MeetupDetailViewModel viewModel, String status) async {
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

  Future<void> _handleDelete(MeetupDetailViewModel viewModel) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meetup'),
        content: const Text(
            'Are you sure you want to delete this meetup? This action cannot be undone.'),
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
    final text =
        'Join me for ${meetup.eventName} on ${DateFormat('MMM dd, yyyy').format(meetup.eventDateTime)} at ${meetup.time}! $url';

    await Share.share(text);
  }

  Future<void> _handleEdit(MeetupDto meetup) async {
    final viewModel =
        ref.read(meetupDetailViewModelProvider(widget.meetupId).notifier);
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMeetupScreen(
          meetupId: widget.meetupId,
          meetup: meetup,
        ),
      ),
    );

    // Refresh meetup if it was updated
    if (result == true && mounted) {
      await viewModel.refresh(widget.meetupId);
    }
  }
}
