import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';

import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/home_page/provider/swipe_users.notifier.dart';
import 'package:metal/features/home_page/widget/swipe_user_card.dart';
import 'package:metal/features/home_page/widget/swipe_card.dart';
import 'package:metal/features/home_page/widget/location_permission_screen.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/state.handler/error.state.dart';
import 'package:metal/widgets/text_views.dart';

class HomePage extends ConsumerStatefulWidget {
  HomePage({
    super.key,
  });

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _hasCheckedLocation = false;

  @override
  void initState() {
    super.initState();
    // Check location permission and load users
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocationAndLoadUsers();
    });
  }

  Future<void> _checkLocationAndLoadUsers() async {
    if (_hasCheckedLocation) return;
    _hasCheckedLocation = true;

    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Request permission first
      final requestedPermission = await Geolocator.requestPermission();
      if (requestedPermission == LocationPermission.denied ||
          requestedPermission == LocationPermission.deniedForever) {
        if (mounted) {
          _showLocationPermissionScreen(
              requestedPermission == LocationPermission.deniedForever);
        }
        return;
      }
    } else if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        _showLocationPermissionScreen(true);
      }
      return;
    }

    // Permission granted, load users
    ref.read(swipeUsersProvider.notifier).loadSwipeUsers();
  }

  Future<void> _checkLocationAndShowScreen() async {
    final permission = await Geolocator.checkPermission();
    final isPermanentlyDenied = permission == LocationPermission.deniedForever;
    if (mounted) {
      _showLocationPermissionScreen(isPermanentlyDenied);
    }
  }

  void _showLocationPermissionScreen(bool isPermanentlyDenied) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LocationPermissionScreen(
          isPermanentlyDenied: isPermanentlyDenied,
          onLocationGranted: () {
            // Reload users after permission is granted
            ref.read(swipeUsersProvider.notifier).refreshUsers();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final swipeUsersState = ref.watch(swipeUsersProvider);
    final swipeUsersNotifier = ref.read(swipeUsersProvider.notifier);

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _buildSwipeContent(swipeUsersState, swipeUsersNotifier),
        ),
      ],
    );
  }

  Widget _buildSwipeContent(
      SwipeUsersState state, SwipeUsersNotifier notifier) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }

    if (state.isError) {
      // Check if error is related to location
      final errorMessage = state.errorMessage ?? "";
      if (errorMessage.contains("Location data required") ||
          errorMessage.contains("location")) {
        // Show location permission screen instead of error
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _checkLocationAndShowScreen();
          }
        });
        return const Center(
          child: CircularProgressIndicator.adaptive(),
        );
      }

      return ErrorState(
        retry: () => notifier.refreshUsers(),
        text: errorMessage,
      );
    }

    if (state.isSuccess) {
      final users = state.data ?? [];
      if (users.isEmpty) {
        return _buildEmptyState();
      }
      return _buildSwipeStack(users, notifier);
    }

    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 53,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.00, -1.00),
          end: Alignment(0, 1),
          colors: [Color(0xFFDB217A), Color(0xFFF00E3E)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: TextView(
          text: "Discover People Around You",
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          TextView(
            text: "No more people to discover",
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 8),
          TextView(
            text: "Check back later for new people! or explore thoughts.",
            fontSize: 14,
            color: Colors.grey[500],
          ),
          const SizedBox(height: 32),
          // Navigation buttons

          Row(
            children: [
              Expanded(
                child: BaseButton(
                  buttonText: 'Explore Thoughts',
                  width: 200,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.dashboardPage,
                        arguments: {'tabIndex': AppRoutes.thoughtsTab});
                  },
                ),
              ),
              const Gap(16),
              Expanded(
                child: BaseButton(
                  buttonText: 'Change Preferences',
                  width: 200,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.editPreferences);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildSwipeStack(List<UserModel> users, SwipeUsersNotifier notifier) {
    return Stack(
      children: [
        // Background cards (stacked)
        ...users.asMap().entries.map((entry) {
          final user = entry.value;

          return Positioned.fill(
            child: Transform.scale(
              scale: 1.0,
              child: SwipeCard(
                onSwipeLeft: (offset) {
                  if (user.id != null) {
                    notifier.passUser(user.id!);
                  }
                },
                child: SwipeUserCard(
                  user: user,
                  onLike: () {
                    if (user.id != null) {
                      notifier.likeUser(user.id!);
                    }
                  },
                  onPass: () {
                    if (user.id != null) {
                      notifier.passUser(user.id!);
                    }
                  },
                  onSuperLike: () {
                    if (user.id != null) {
                      notifier.superLikeUser(user.id!);
                    }
                  },
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
