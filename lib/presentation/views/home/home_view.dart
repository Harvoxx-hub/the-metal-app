import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/domain/entities/discovery_user_dto.dart';
import 'package:metal/presentation/viewmodels/home/home_viewmodel.dart';
import 'package:metal/presentation/views/home/widgets/discovery_user_card.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/state.handler/error.state.dart';
import 'package:metal/widgets/text_views.dart';

/// Home View — pure UI.
///
/// Watches [homeViewModelProvider] and renders:
///   • Loading spinner
///   • Discovery cards
///   • Location permission screen (when API says location is missing)
///   • Error / empty states
class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView>
    with WidgetsBindingObserver {
  bool _locationScreenPushed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(homeViewModelProvider.notifier).retryIfNeeded();
    }
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
        Expanded(child: _buildContent(homeState)),
      ],
    );
  }

  // ── Content switcher ──────────────────────────────────────────

  Widget _buildContent(HomeState state) {
    // API said location is needed → navigate to central Enable Location screen once
    if (state.locationStatus == LocationStatus.denied ||
        state.locationStatus == LocationStatus.permanentlyDenied) {
      _navigateToEnableLocationOnce();
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    // Loading
    if (state.isLoading && (state.data == null || state.data!.isEmpty)) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    // Error (non-location)
    if (state.isError && (state.data == null || state.data!.isEmpty)) {
      return ErrorState(
        retry: () => ref.read(homeViewModelProvider.notifier).refresh(),
        text: state.errorMessage ?? '',
      );
    }

    // No users
    final users = state.data ?? [];
    if (users.isEmpty) return _buildEmptyState();

    return _buildSwipeStack(users);
  }

  // ── Navigation helpers ────────────────────────────────────────

  void _navigateToEnableLocationOnce() {
    if (_locationScreenPushed) return;
    _locationScreenPushed = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context)
          .pushNamed(AppRoutes.locationEnablePage)
          .then((_) {
        _locationScreenPushed = false;
        ref.read(homeViewModelProvider.notifier).retryIfNeeded();
      });
    });
  }

  void _showMatchDialog(SwipeResultDto result) {
    ref.read(homeViewModelProvider.notifier).clearLastSwipeResult();
    Navigator.pushNamed(context, AppRoutes.meltMetal, arguments: {
      'userId': result.targetUserId,
      'connectionId': result.connectionId,
    });
  }

  // ── Static UI ─────────────────────────────────────────────────

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
            Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
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
      children: [
        // Reverse so first user is on top (last in stack = drawn on top).
        for (var i = users.length - 1; i >= 0; i--) ...[
          Positioned.fill(
            child: Transform.scale(
              scale: 1.0,
              child: DiscoveryUserCard(
                user: users[i],
                onLike: () => notifier.likeUser(users[i].id),
                onPass: () => notifier.passUser(users[i].id),
                onDirectMessageSent: (userId) => notifier.removeUser(userId),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
