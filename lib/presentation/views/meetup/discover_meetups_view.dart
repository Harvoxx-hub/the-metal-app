import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:metal/core/config/map_config.dart';
import 'package:metal/domain/entities/meetup_dto.dart';
import 'package:metal/presentation/viewmodels/meetup/meetup_viewmodel.dart';
import 'package:metal/presentation/views/meetup/expanded_meetup_map_view.dart';
import 'package:metal/presentation/views/meetup/widgets/discover_meetup_event_card.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/shimmer/feed_shimmer_widget.dart';
import 'package:metal/widgets/state.handler/error.state.dart';
import 'package:metal/widgets/text_views.dart';

/// Discover Meetups: map, Nearby Meetups list, empty state.
/// Uses project design system. Shown in the Meetup tab.
class DiscoverMeetupsView extends ConsumerStatefulWidget {
  const DiscoverMeetupsView({super.key});

  @override
  ConsumerState<DiscoverMeetupsView> createState() =>
      _DiscoverMeetupsViewState();
}

class _DiscoverMeetupsViewState extends ConsumerState<DiscoverMeetupsView> {
  static const double _paddingH = 16;
  static const double _sectionGap = 16;
  static const double _mapAspectRatio = 16 / 9;

  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(meetupFeedViewModelProvider.notifier).loadMeetups();
    });
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
    if (!mounted) return;
    final nowPerm = await Geolocator.checkPermission();
    if (nowPerm != LocationPermission.whileInUse &&
        nowPerm != LocationPermission.always) {
      return;
    }
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );
      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (_) {
      // Keep _userLocation null; map will use fallback center
    }
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
                ? _DiscoverMapContent(
                    meetups: meetups,
                    userLocation: _userLocation,
                  )
                : _buildMapPlaceholder(),
          ),
          if (MapConfig.hasGoogleMapsKey && _userLocation != null)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: _BreathingLocationCircle(),
                ),
              ),
            ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Material(
              color: AppColors.metalBlack.withOpacity(0.5),
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: () {
                  if (MapConfig.hasGoogleMapsKey) {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const ExpandedMeetupMapView(),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          text: 'Nearby Meetups',
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
          text: feedState.errorMessage ?? 'Failed to load Meetups',
          retry: () =>
              ref.read(meetupFeedViewModelProvider.notifier).loadMeetups(),
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
            child: Center(
                child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )),
          );
        }
        final meetup = feedState.meetups[index];
        return DiscoverMeetupEventCard(meetup: meetup);
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
            text: 'No Meetups nearby yet',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.metalBrownColourForText,
            textAlign: TextAlign.center,
          ),
          const Gap(8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextView(
              text:
                  'Be the first to create a Meetup and invite people around you.',
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
              onTap: () => Navigator.pushNamed(context, AppRoutes.createMeetup)
                  .then((_) {
                ref.read(meetupFeedViewModelProvider.notifier).refresh();
              }),
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: TextView(
                  text: 'CREATE MEETUP',
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

/// Renders Google Map with Meetup markers when API key is set.
/// Centers on user's current location when available; otherwise first meetup or default.
class _DiscoverMapContent extends StatelessWidget {
  final List<MeetupDto> meetups;
  final LatLng? userLocation;

  const _DiscoverMapContent({
    required this.meetups,
    this.userLocation,
  });

  static const LatLng _defaultCenter =
      LatLng(37.7749, -122.4194); // San Francisco fallback
  static const double _defaultZoom = 11.0;

  LatLng _initialCenter() {
    if (userLocation != null) return userLocation!;
    final withLocation = meetups.where((m) => m.placeLocation != null).toList();
    if (withLocation.isNotEmpty) {
      final loc = withLocation.first.placeLocation!;
      return LatLng(loc.latitude, loc.longitude);
    }
    return _defaultCenter;
  }

  @override
  Widget build(BuildContext context) {
    final withLocation = meetups.where((m) => m.placeLocation != null).toList();
    final initialPosition = CameraPosition(
      target: _initialCenter(),
      zoom: _defaultZoom,
    );

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
      key: ValueKey('${userLocation?.latitude}_${userLocation?.longitude}'),
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

/// Round circle with a breathing (pulsing) animation for current location.
class _BreathingLocationCircle extends StatefulWidget {
  @override
  State<_BreathingLocationCircle> createState() =>
      _BreathingLocationCircleState();
}

class _BreathingLocationCircleState extends State<_BreathingLocationCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.4, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.metalPinkColour.withOpacity(0.25),
                    border: Border.all(
                      color: AppColors.metalPinkColour.withOpacity(0.6),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.metalPinkColour,
                border: Border.all(
                  color: AppColors.metalWhite,
                  width: 2.5,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
