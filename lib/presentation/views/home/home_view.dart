import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:metal/domain/entities/discovery_user_dto.dart';
import 'package:metal/presentation/viewmodels/home/home_viewmodel.dart';
import 'package:metal/presentation/views/home/widgets/discovery_user_card.dart';
import 'package:metal/presentation/views/home/widgets/location_permission_screen.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/state.handler/error.state.dart';
import 'package:metal/widgets/text_views.dart';

/// Home View - Discovery/Swipe Interface
/// Uses the new Clean Architecture with backend API
class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  bool _hasCheckedLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocationAndLoadUsers();
    });
  }

  Future<void> _checkLocationAndLoadUsers() async {
    if (_hasCheckedLocation) return;
    _hasCheckedLocation = true;

    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
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
    ref.read(homeViewModelProvider.notifier).loadUsers();
  }

  void _showLocationPermissionScreen(bool isPermanentlyDenied) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LocationPermissionScreen(
          isPermanentlyDenied: isPermanentlyDenied,
          onLocationGranted: () {
            ref.read(homeViewModelProvider.notifier).refresh();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);

    // Listen for match results
    ref.listen<SwipeResultDto?>(lastSwipeResultProvider, (previous, next) {
      if (next != null && next.isMatch) {
        _showMatchDialog(next);
      }
    });

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _buildContent(homeState),
        ),
      ],
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

  Widget _buildContent(HomeState state) {
    if (state.isLoading && (state.data == null || state.data!.isEmpty)) {
      return const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }

    if (state.isError && (state.data == null || state.data!.isEmpty)) {
      final errorMessage = state.errorMessage ?? "";
      
      // Check if error is related to location
      if (errorMessage.contains("Location data required") ||
          errorMessage.toLowerCase().contains("location")) {
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
        retry: () => ref.read(homeViewModelProvider.notifier).refresh(),
        text: errorMessage,
      );
    }

    final users = state.data ?? [];
    if (users.isEmpty) {
      return _buildEmptyState();
    }

    return _buildSwipeStack(users);
  }

  Future<void> _checkLocationAndShowScreen() async {
    final permission = await Geolocator.checkPermission();
    final isPermanentlyDenied = permission == LocationPermission.deniedForever;
    if (mounted) {
      _showLocationPermissionScreen(isPermanentlyDenied);
    }
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
      ),
    );
  }

  Widget _buildSwipeStack(List<DiscoveryUserDto> users) {
    final notifier = ref.read(homeViewModelProvider.notifier);

    return Stack(
      children: users.asMap().entries.map((entry) {
        final user = entry.value;

        return Positioned.fill(
          child: Transform.scale(
            scale: 1.0,
            child: DiscoveryUserCard(
              user: user,
              onLike: () => notifier.likeUser(user.id),
              onPass: () => notifier.passUser(user.id),
              onSuperLike: () => notifier.superLikeUser(user.id),
              onMessage: () => _handleDirectMessage(user),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _handleDirectMessage(DiscoveryUserDto user) {
    // Navigate to user profile for now
    // Direct messaging can be implemented later
    Navigator.pushNamed(
      context,
      AppRoutes.myMeltedUser,
      arguments: {"metalId": user.id},
    );
  }

  void _showMatchDialog(SwipeResultDto result) {
    // Clear the result first
    ref.read(homeViewModelProvider.notifier).clearLastSwipeResult();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("It's a Match! 🎉"),
        content: const Text(
          "You and this person liked each other! Start a conversation now.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Later"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (result.connectionId != null) {
                Navigator.pushNamed(
                  context,
                  AppRoutes.chatWindowsPage,
                  arguments: result.connectionId,
                );
              }
            },
            child: const Text("Say Hi!"),
          ),
        ],
      ),
    );
  }
}

