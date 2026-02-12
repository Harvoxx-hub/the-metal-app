import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:metal/core/config/map_config.dart';
import 'package:metal/domain/entities/meetup_dto.dart';
import 'package:metal/presentation/viewmodels/meetup/meetup_viewmodel.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/text_views.dart';

/// Full-screen expanded map showing user location and meetup markers.
/// - Map centers on user's current location first (with permission).
/// - Meetup markers: tap → navigate to meetup details.
/// - "Meetups near you" FAB opens a bottom sheet listing nearby meetups.
class ExpandedMeetupMapView extends ConsumerStatefulWidget {
  const ExpandedMeetupMapView({super.key});

  @override
  ConsumerState<ExpandedMeetupMapView> createState() =>
      _ExpandedMeetupMapViewState();
}

class _ExpandedMeetupMapViewState extends ConsumerState<ExpandedMeetupMapView> {
  static const LatLng _defaultCenter = LatLng(37.7749, -122.4194);
  static const double _defaultZoom = 11.0;
  static const String _myLocationMarkerId = '__my_location__';

  GoogleMapController? _mapController;
  LatLng? _userLocation;
  bool _locationLoaded = false;

  @override
  void initState() {
    super.initState();
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
      setState(() => _locationLoaded = true);
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
          _locationLoaded = true;
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_userLocation!, 12.0),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _locationLoaded = true);
    }
  }

  LatLng _initialPosition(List<MeetupDto> meetups) {
    if (_userLocation != null) return _userLocation!;
    final withLoc = meetups.where((m) => m.placeLocation != null).toList();
    if (withLoc.isNotEmpty) {
      final loc = withLoc.first.placeLocation!;
      return LatLng(loc.latitude, loc.longitude);
    }
    return _defaultCenter;
  }

  Set<Marker> _buildMarkers(List<MeetupDto> meetups) {
    final Set<Marker> markers = {};
    // My location marker: tap to see meetups near you
    if (_userLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId(_myLocationMarkerId),
          position: _userLocation!,
          infoWindow: const InfoWindow(title: 'You are here'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          onTap: () => _showMeetupsNearYou(meetups),
        ),
      );
    }
    for (final m in meetups) {
      if (m.placeLocation == null) continue;
      final loc = m.placeLocation!;
      markers.add(
        Marker(
          markerId: MarkerId(m.id),
          position: LatLng(loc.latitude, loc.longitude),
          infoWindow: InfoWindow(title: m.eventName),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
          onTap: () => _openMeetupDetails(m.id),
        ),
      );
    }
    return markers;
  }

  void _openMeetupDetails(String meetupId) {
    Navigator.pushNamed(context, AppRoutes.meetupDetails, arguments: meetupId);
  }

  void _showMeetupsNearYou(List<MeetupDto> meetups) {
    final sorted = List<MeetupDto>.from(meetups)
      ..sort((a, b) => (a.distance ?? double.infinity)
          .compareTo(b.distance ?? double.infinity));
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.25,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Gap(12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextView(
                text: 'Meetups near you',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.metalBrownColourForText,
              ),
            ),
            Expanded(
              child: sorted.isEmpty
                  ? Center(
                      child: TextView(
                        text: 'No meetups nearby',
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: sorted.length,
                      itemBuilder: (context, index) {
                        final m = sorted[index];
                        final dist = m.distance != null
                            ? '${m.distance!.toStringAsFixed(1)} km away'
                            : '';
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.metalPinkColour
                                .withValues(alpha: 0.2),
                            child: const Icon(
                              Icons.event,
                              color: AppColors.metalPinkColour,
                              size: 24,
                            ),
                          ),
                          title: TextView(
                            text: m.eventName,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.metalBrownColourForText,
                          ),
                          subtitle: dist.isNotEmpty
                              ? TextView(
                                  text: dist,
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                )
                              : null,
                          onTap: () {
                            Navigator.pop(context);
                            _openMeetupDetails(m.id);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(meetupFeedViewModelProvider);
    final meetups = feedState.meetups;

    if (!MapConfig.hasGoogleMapsKey) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Meetup map'),
          backgroundColor: AppColors.metalWhite,
          foregroundColor: AppColors.metalBrownColourForText,
        ),
        body: const Center(
          child: TextView(
            text: 'Map is not configured. Add a Google Maps API key.',
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      );
    }

    final initialPosition = CameraPosition(
      target: _initialPosition(meetups),
      zoom: _defaultZoom,
    );

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialPosition,
            markers: _buildMarkers(meetups),
            mapType: MapType.normal,
            myLocationEnabled: false,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              if (_userLocation != null) {
                controller.animateCamera(
                  CameraUpdate.newLatLngZoom(_userLocation!, 12.0),
                );
              }
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        elevation: 2,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Spacer(),
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        elevation: 2,
                        child: InkWell(
                          onTap: () => _showMeetupsNearYou(meetups),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 20,
                                  color: AppColors.metalPinkColour,
                                ),
                                const Gap(8),
                                TextView(
                                  text: 'Meetups near you',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.metalBrownColourForText,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (!_locationLoaded)
            Container(
              color: Colors.black26,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
