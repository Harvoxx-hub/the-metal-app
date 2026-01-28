import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/presentation/views/thought/widgets/thought_card.dart';
import 'package:metal/presentation/viewmodels/user/user_profile_viewmodel_providers.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/presentation/viewmodels/settings/blocked_users_viewmodel.dart';
 
import 'package:metal/presentation/widgets/profile/profile_header.dart';
import 'package:metal/presentation/widgets/settings/edit_field.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/state.handler/empty.state.dart';
import 'package:metal/widgets/state.handler/loading.state.dart';
import 'package:metal/widgets/text_views.dart';

/// My Profile View with 3 tabs: Thoughts, Personal
class MyProfileView extends ConsumerStatefulWidget {
  const MyProfileView({super.key});

  @override
  ConsumerState<MyProfileView> createState() => _MyProfileViewState();
}

class _MyProfileViewState extends ConsumerState<MyProfileView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Get profile view model for current user
    final userId = currentUser.id;
    final profileState = ref.watch(
      userProfileViewModelProvider(userId),
    );
    final profileViewModel = ref.read(
      userProfileViewModelProvider(userId).notifier,
    );

    return ProfileHeader(
      myProfile: true,
      eye: false,
      metalId: currentUser.metal ?? '',
      profileUrl: currentUser.profilePhoto,
      child: Padding(
        padding: const EdgeInsets.only(top: 110, left: 20, right: 20),
        child: Container(
          padding: const EdgeInsets.only(top: 122),
          decoration: const BoxDecoration(
            color: AppColors.metalWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(35),
              topRight: Radius.circular(35),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTabBar(),
              const Gap(8),
              SizedBox(
                height: MediaQuery.of(context).size.height - 500,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildThoughtsTab(profileState, profileViewModel),
             
                    _buildPersonalTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.metalPinkColour,
          borderRadius: BorderRadius.circular(25),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Thoughts'),
    
          Tab(text: 'Personal'),
        ],
      ),
    );
  }

  /// Thoughts Tab - Shows current user's thoughts
  Widget _buildThoughtsTab(profileState, profileViewModel) {
    if (profileState.isLoadingThoughts && profileState.thoughts.isEmpty) {
      return const LoadingState();
    }

    if (profileState.thoughts.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          await profileViewModel.refresh();
        },
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: 400,
            child: EmptyState(
              text: 'No Thoughts Available',
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await profileViewModel.refresh();
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            final metrics = notification.metrics;
            if (metrics.pixels >= metrics.maxScrollExtent - 200) {
              // Load more when near the bottom
              profileViewModel.loadMoreThoughts();
            }
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: profileState.thoughts.length +
              (profileState.hasMoreThoughts && profileState.isLoadingThoughts ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == profileState.thoughts.length) {
              // Load more indicator
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: CircularProgressIndicator.adaptive()),
              );
            }

            final thought = profileState.thoughts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ThoughtCard(
                thoughtModel: thought,
              ),
            );
          },
        ),
      ),
    );
  }

 

  /// Personal Tab - Shows list of personal settings and options
  Widget _buildPersonalTab() {
    final blockedUsersState = ref.watch(blockedUsersViewModelProvider);
    final blockedCount = blockedUsersState.blockedUsers.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(20),
          EditField(
            text: blockedCount.toString(),
            floatingLabel: 'Blocked Contacts',
            prefixIcon: TextView(
              text: 'View',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.blueAccent,
              underline: true,
              onTap: () {
                if (blockedCount > 0) {
                  Navigator.pushNamed(context, AppRoutes.blockedUser);
                }
              },
            ),
            onTap: () {
              if (blockedCount > 0) {
                Navigator.pushNamed(context, AppRoutes.blockedUser);
              }
            },
          ),
          const Gap(20),
          EditField(
            text: 'Settings',
            floatingLabel: '',
            prefixIcon: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.settingPage);
            },
          ),
          const Gap(20),
          EditField(
            text: 'Metal List',
            floatingLabel: '',
            prefixIcon: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.myMeltedMetals);
            },
          ),
        ],
      ),
    );
  }
}
