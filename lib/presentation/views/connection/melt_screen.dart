import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/presentation/viewmodels/user/user_profile_viewmodel_providers.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';

/// Melt Screen
/// Shown when two users mutually melt with each other
/// Displays a celebration screen indicating they can now communicate
class MeltScreen extends ConsumerStatefulWidget {
  final String userId;
  final String? connectionId;

  const MeltScreen({
    super.key,
    required this.userId,
    this.connectionId,
  });

  static const routeName = '/meltMetal';

  @override
  ConsumerState<MeltScreen> createState() => _MeltScreenState();
}

class _MeltScreenState extends ConsumerState<MeltScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileViewModelProvider(widget.userId));
    final otherUser = profileState.user;
    final currentUser = ref.watch(currentUserProvider);

    return BaseScreen(
      Header: 'Metals Melt',
      appBarState: AppBarState.HambugerWithHeader,
      body: Stack(
        children: [
          // Light pink heart icon in top left corner
          Positioned(
            top: 20,
            left: 20,
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                Assets.images.heartLocks1.path,
                height: 40,
                width: 40,
              ),
            ),
          ),
          // Main content
          Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Gap(40),
                  // "It's a melt" text with party popper
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const TextView(
                          text: "It's a melt",
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        const Gap(8),
                        Image.asset(
                          Assets.images.partpoppercelebrationemoji.path,
                          height: 32,
                          width: 32,
                        ),
                      ],
                    ),
                  ),
                  const Gap(16),
                  // "You and @username just melted" text
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: TextView(
                      text: otherUser != null
                          ? "You and @${otherUser.username ?? otherUser.fullname ?? 'User'} just melted"
                          : "You just melted",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Gap(40),
                  // Two circular profile photos side by side
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 420;
                          final circleSize = isNarrow ? 96.0 : 120.0;
                          final heartSize = isNarrow ? 36.0 : 40.0;
                          final heartGap =
                              (constraints.maxWidth * 0.10).clamp(16.0, 80.0);

                          final youLabel =
                              "You: @${currentUser?.username ?? currentUser?.fullname ?? 'User'}";
                          final otherLabel =
                              "@${otherUser?.username ?? otherUser?.fullname ?? 'User'}";

                          if (isNarrow) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildUserCircle(
                                  user: currentUser,
                                  label: youLabel,
                                  isCurrentUser: true,
                                  size: circleSize,
                                ),
                                const Gap(16),
                                Image.asset(
                                  Assets.images.meltSpark.path,
                                  height: heartSize,
                                  width: heartSize,
                                ),
                                const Gap(16),
                                _buildUserCircle(
                                  user: otherUser,
                                  label: otherLabel,
                                  isCurrentUser: false,
                                  size: circleSize,
                                ),
                              ],
                            );
                          }

                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildUserCircle(
                                    user: currentUser,
                                    label: youLabel,
                                    isCurrentUser: true,
                                    size: circleSize,
                                  ),
                                  SizedBox(width: heartGap),
                                  _buildUserCircle(
                                    user: otherUser,
                                    label: otherLabel,
                                    isCurrentUser: false,
                                    size: circleSize,
                                  ),
                                ],
                              ),
                              Positioned(
                                top: (circleSize / 2) - (heartSize / 2),
                                child: Image.asset(
                                  Assets.images.meltSpark.path,
                                  height: heartSize,
                                  width: heartSize,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomWidget: _buildBottomNavBar(),
    );
  }

  Widget _buildUserCircle({
    required dynamic user,
    required String label,
    required bool isCurrentUser,
    double size = 120,
  }) {
    final metalId = user?.metal ?? 'default';
    // Show profile photo only if connected and not anonymous, otherwise show metal image
    final profileUrl = (user?.isConnected == true && user?.isAnonymous == false)
        ? user?.profilePhoto
        : null;

    return Column(
      children: [
        DottedBorder(
          borderType: BorderType.Circle,
          radius: const Radius.circular(100),
          padding: EdgeInsets.zero,
          strokeWidth: 2,
          dashPattern: const [5, 5],
          color: AppColors.metalPinkColour.withOpacity(0.3),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isCurrentUser
                    ? [
                        AppColors.metalPinkColour.withOpacity(0.3),
                        const Color(0xFF9B8787).withOpacity(0.2),
                      ]
                    : [
                        const Color(0xFF00D4AA).withOpacity(0.3),
                        AppColors.metalPinkColour.withOpacity(0.2),
                      ],
              ),
            ),
            child: ClipOval(
              child: ProfilePhoto(
                size: size,
                verfly: false,
                imgUrl: profileUrl,
                meltId: metalId,
              ),
            ),
          ),
        ),
        const Gap(12),
        // Label with pink background
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.metalPinkColour.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextView(
            text: label,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.metalPinkColour,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Assets.images.inactiveMessage.path,
                activeIcon: Assets.images.activeMessage.path,
                label: "Chat",
                index: 0,
                onTap: () => _navigateToChat(),
              ),
              _buildNavItem(
                icon: Assets.images.inactiveSpark.path,
                activeIcon: Assets.images.activeSpark.path,
                label: "Spark",
                index: 1,
                onTap: () => _navigateToSpark(),
              ),
              _buildNavItem(
                icon: Assets.images.inactiveUser.path,
                activeIcon: Assets.images.activeUser.path,
                label: "Profile",
                index: 2,
                onTap: () => _navigateToProfile(),
              ),
              _buildNavItem(
                icon: Assets.images.inactiveHome.path,
                activeIcon: Assets.images.activeHome.path,
                label: "Dashboard",
                index: 3,
                onTap: () => _navigateToDashboard(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String icon,
    required String activeIcon,
    required String label,
    required int index,
    required VoidCallback onTap,
  }) {
    final isActive = _currentNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentNavIndex = index);
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isActive
                    ? _getNavGradientColors(index)
                    : [
                        Colors.grey.withOpacity(0.1),
                        Colors.grey.withOpacity(0.1),
                      ],
              ),
            ),
            child: Center(
              child: Image.asset(
                isActive ? activeIcon : icon,
                width: 24,
                height: 24,
              ),
            ),
          ),
          const Gap(4),
          TextView(
            text: label,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? AppColors.metalPinkColour : Colors.grey,
          ),
        ],
      ),
    );
  }

  List<Color> _getNavGradientColors(int index) {
    switch (index) {
      case 0: // Chat
        return [
          const Color(0xFF4A90E2).withOpacity(0.3),
          const Color(0xFF7B68EE).withOpacity(0.3),
        ];
      case 1: // Spark
        return [
          const Color(0xFF9B59B6).withOpacity(0.3),
          AppColors.metalPinkColour.withOpacity(0.3),
        ];
      case 2: // Profile
        return [
          AppColors.metalPinkColour.withOpacity(0.3),
          const Color(0xFFE74C3C).withOpacity(0.3),
        ];
      case 3: // Dashboard
        return [
          const Color(0xFF00D4AA).withOpacity(0.3),
          const Color(0xFF1ABC9C).withOpacity(0.3),
        ];
      default:
        return [Colors.grey.withOpacity(0.1), Colors.grey.withOpacity(0.1)];
    }
  }

  void _navigateToChat() {
    String? connectionId = widget.connectionId;

    if (connectionId == null || connectionId.isEmpty) {
      final profileState =
          ref.read(userProfileViewModelProvider(widget.userId));
      final user = profileState.user;
      connectionId = user?.connectionId;
    }

    if (connectionId != null && connectionId.isNotEmpty) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.chatWindowView,
        (route) => route.settings.name == AppRoutes.dashboardPage,
        arguments: connectionId,
      );
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.dashboardPage,
        (route) => false,
      );
    }
  }

  void _navigateToSpark() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.dashboardPage,
      (route) => false,
    );
    // Navigate to spark tab (index 2 in dashboard)
    Future.delayed(const Duration(milliseconds: 100), () {
      Navigator.pushNamed(
        context,
        AppRoutes.dashboardPage,
        arguments: 2,
      );
    });
  }

  void _navigateToProfile() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.dashboardPage,
      (route) => false,
    );
    // Navigate to profile tab (index 4 in dashboard)
    Future.delayed(const Duration(milliseconds: 100), () {
      Navigator.pushNamed(
        context,
        AppRoutes.dashboardPage,
        arguments: 4,
      );
    });
  }

  void _navigateToDashboard() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.dashboardPage,
      (route) => false,
    );
  }
}
