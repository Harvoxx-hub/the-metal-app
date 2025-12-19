import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/core/services/startup_service.dart';
import 'package:metal/core/utils/strings/app_strings.dart';
import 'package:metal/presentation/views/chat/chat_list_view.dart';
import 'package:metal/features/profile/presentation/profile.page.dart';
import 'package:metal/presentation/views/spark/spark_view.dart';
import 'package:metal/presentation/views/thought/thought_screen.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/presentation/viewmodels/profile/metal_properties_provider.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/presentation/views/home/home_view.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/nav/badged_nav_icon.dart';

/// Dashboard View
/// Main navigation hub hosting bottom navigation and page switching
/// Keep this clean - initialization logic is in StartupService
class DashboardView extends ConsumerStatefulWidget {
  final int? initialPageIndex;

  const DashboardView({
    super.key,
    this.initialPageIndex,
  });

  static const name = 'dashboard';
  static const route = '/$name';

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  late int _currentIndex;
  bool _startupComplete = false;

  /// Pages displayed in bottom navigation
  final List<Widget> _pages = [
    const HomeView(),
    const ThoughtScreen(), // Updated to use new API-based thoughts with 3 tabs
    const SparkView(), // Updated to use new API-based sparks
    const ChatListView(), // Updated to use new API-based chat
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialPageIndex ?? 0;

    // Run startup tasks after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runStartupTasks();
    });
  }

  /// Run startup initialization tasks
  Future<void> _runStartupTasks() async {
    if (_startupComplete || !mounted) return;
    _startupComplete = true;

    final userData = ref.read(userStateProvider).user;
    if (userData != null && mounted) {
      await ref
          .read(startupServiceProvider)
          .runStartupTasks(context, ref, userData);
    }
  }

  /// Handle bottom nav tap
  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userStateProvider);

    // Watch providers that need to stay active
    ref.watch(metalPropertiesProvider);

    return BaseScreen(
      appBarState: AppBarState.Dashboard,
      body: userState.status == AuthStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : _pages[_currentIndex],
      floatingActionButton: _buildFAB(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  /// Build FAB for thought screen
  Widget? _buildFAB() {
    if (_currentIndex != 1) return null;

    return FloatingActionButton(
      backgroundColor: const Color(0xFFD2128B),
      onPressed: () => Navigator.pushNamed(context, AppRoutes.postThought),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  /// Build bottom navigation bar
  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedFontSize: 0,
      unselectedFontSize: 0,
      onTap: _onNavTap,
      items: [
        _buildNavItem(
          icon: Assets.images.inactiveHome.path,
          activeIcon: Assets.images.activeHome.path,
          label: AppStrings.home,
        ),
        _buildNavItem(
          iconWidget: Assets.icons.tought.svg(
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          ),
          activeIconWidget: Assets.icons.tought.svg(
            colorFilter: const ColorFilter.mode(
                AppColors.metalPinkColour, BlendMode.srcIn),
          ),
          label: AppStrings.tought,
        ),
        _buildNavItem(
          icon: Assets.images.inactiveSpark.path,
          activeIcon: Assets.images.activeSpark.path,
          label: AppStrings.sparks,
        ),
        _buildChatNavItem(),
        _buildNavItem(
          icon: Assets.images.inactiveUser.path,
          activeIcon: Assets.images.activeUser.path,
          label: AppStrings.profile,
        ),
      ],
    );
  }

  /// Build standard nav item
  BottomNavigationBarItem _buildNavItem({
    String? icon,
    String? activeIcon,
    Widget? iconWidget,
    Widget? activeIconWidget,
    required String label,
  }) {
    return BottomNavigationBarItem(
      icon: iconWidget ?? Image.asset(icon!),
      activeIcon: activeIconWidget ?? Image.asset(activeIcon!),
      label: label,
    );
  }

  /// Build chat nav item with badge
  BottomNavigationBarItem _buildChatNavItem() {
    return BottomNavigationBarItem(
      icon: ChatNavIcon(icon: Image.asset(Assets.images.inactiveMessage.path)),
      activeIcon:
          ChatNavIcon(icon: Image.asset(Assets.images.activeMessage.path)),
      label: AppStrings.chat,
    );
  }
}
