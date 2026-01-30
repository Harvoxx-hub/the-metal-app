import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:metal/core/config/map_config.dart';
import 'package:metal/domain/entities/meetup_dto.dart';
import 'package:metal/presentation/viewmodels/meetup/meetup_viewmodel.dart';
import 'package:metal/presentation/views/meetup/widgets/discover_linkup_event_card.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/shimmer/feed_shimmer_widget.dart';
import 'package:metal/widgets/state.handler/error.state.dart';
import 'package:metal/widgets/text_views.dart';

/// Discover LinkUps: map, Nearby LinkUps list, empty state.
/// Uses project design system. Shown in the Link Up tab.
class DiscoverLinkupsView extends ConsumerStatefulWidget {
  const DiscoverLinkupsView({super.key});

  @override
  ConsumerState<DiscoverLinkupsView> createState() => _DiscoverLinkupsViewState();
}

class _DiscoverLinkupsViewState extends ConsumerState<DiscoverLinkupsView> {
  static const double _paddingH = 16;
  static const double _sectionGap = 16;
  static const double _mapAspectRatio = 16 / 9;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(meetupFeedViewModelProvider.notifier).loadMeetups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(meetupFeedViewModelProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(meetupFeedViewModelProvider.notifier).refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: _paddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Gap(8),
            _buildMapSection(feedState.meetups),
            const Gap(_sectionGap),
            _buildEventsListHeader(),
            const Gap(12),
            _buildContent(feedState),
            const Gap(24),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection(List<MeetupDto> meetups) {
    return AspectRatio(
      aspectRatio: _mapAspectRatio,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: MapConfig.hasGoogleMapsKey
                ? _DiscoverMapContent(meetups: meetups)
                : _buildMapPlaceholder(),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Material(
              color: AppColors.metalBlack.withOpacity(0.5),
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: () {
                  // Expand map fullscreen - could push a fullscreen map route
                },
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: TextView(
                    text: 'EXPAND MAP',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.metalWhite,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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

  Widget _buildEventsListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextView(
          text: 'Nearby LinkUps',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.metalBrownColourForText,
        ),
        TextButton(
          onPressed: () {
            // VIEW ALL - could push full list or scroll
          },
          child: TextView(
            text: 'VIEW ALL',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.metalPinkColour,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(MeetupFeedState feedState) {
    if (feedState.isLoading && feedState.meetups.isEmpty) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, __) => const Gap(16),
        itemBuilder: (_, __) => SizedBox(
          height: 220,
          child: PostCardShimmer(),
        ),
      );
    }

    if (feedState.isError && feedState.meetups.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: ErrorState(
          text: feedState.errorMessage ?? 'Failed to load LinkUps',
          retry: () => ref.read(meetupFeedViewModelProvider.notifier).loadMeetups(),
        ),
      );
    }

    if (feedState.meetups.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: feedState.meetups.length + (feedState.hasMore ? 1 : 0),
      separatorBuilder: (_, __) => const Gap(16),
      itemBuilder: (context, index) {
        if (index == feedState.meetups.length) {
          ref.read(meetupFeedViewModelProvider.notifier).loadMoreMeetups();
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )),
          );
        }
        final meetup = feedState.meetups[index];
        return DiscoverLinkupEventCard(meetup: meetup);
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: AppColors.metalPinkColour.withOpacity(0.5),
          ),
          const Gap(20),
          TextView(
            text: 'No LinkUps nearby yet',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.metalBrownColourForText,
            textAlign: TextAlign.center,
          ),
          const Gap(8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextView(
              text: 'Be the first to create a LinkUp and invite people around you.',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.metalBrownColourForText.withOpacity(0.7),
              textAlign: TextAlign.center,
            ),
          ),
          const Gap(24),
          Material(
            color: AppColors.metalPinkColour,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, AppRoutes.createMeetup).then((_) {
                ref.read(meetupFeedViewModelProvider.notifier).refresh();
              }),
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: TextView(
                  text: 'CREATE LINKUP',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.metalWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders Google Map with LinkUp markers when API key is set.
class _DiscoverMapContent extends StatelessWidget {
  final List<MeetupDto> meetups;

  const _DiscoverMapContent({required this.meetups});

  static const LatLng _defaultCenter = LatLng(37.7749, -122.4194); // San Francisco
  static const double _defaultZoom = 11.0;

  @override
  Widget build(BuildContext context) {
    final withLocation = meetups.where((m) => m.placeLocation != null).toList();
    final initialPosition = withLocation.isNotEmpty
        ? CameraPosition(
            target: LatLng(
              withLocation.first.placeLocation!.latitude,
              withLocation.first.placeLocation!.longitude,
            ),
            zoom: _defaultZoom,
          )
        : const CameraPosition(target: _defaultCenter, zoom: _defaultZoom);

    final markerSet = <Marker>{};
    for (var i = 0; i < withLocation.length; i++) {
      final m = withLocation[i];
      final loc = m.placeLocation!;
      markerSet.add(
        Marker(
          markerId: MarkerId(m.id),
          position: LatLng(loc.latitude, loc.longitude),
          infoWindow: InfoWindow(title: m.eventName),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: initialPosition,
      markers: markerSet,
      mapType: MapType.normal,
      myLocationButtonEnabled: false,
      myLocationEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }
}
