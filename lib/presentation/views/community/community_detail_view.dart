import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:metal/domain/entities/thought_dto.dart';
import 'package:metal/presentation/viewmodels/community/community_detail_viewmodel_providers.dart';
import 'package:metal/presentation/viewmodels/user/user_state_provider.dart';
import 'package:metal/presentation/views/community/widgets/community_posts_tab.dart';
import 'package:metal/presentation/views/community/widgets/community_members_tab.dart';
import 'package:metal/presentation/views/community/widgets/community_about_tab.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/state.handler/error.state.dart';
import 'package:metal/widgets/state.handler/loading.state.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/route/routes.dart';

/// Community Detail View - Facebook-group-style community page
class CommunityDetailView extends ConsumerStatefulWidget {
  final String communityId;

  const CommunityDetailView({
    super.key,
    required this.communityId,
  });

  @override
  ConsumerState<CommunityDetailView> createState() =>
      _CommunityDetailViewState();
}

class _CommunityDetailViewState extends ConsumerState<CommunityDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _postsScrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _postsScrollController = ScrollController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _postsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(
      communityDetailViewModelProvider(widget.communityId),
    );

    return Scaffold(
      body: detailState.isLoading && detailState.community == null
          ? const LoadingState()
          : detailState.isError && detailState.community == null
              ? ErrorState(
                  text: detailState.errorMessage ?? 'Failed to load community',
                  retry: () {
                    ref
                        .read(
                          communityDetailViewModelProvider(widget.communityId)
                              .notifier,
                        )
                        .loadCommunityDetails(widget.communityId);
                  },
                )
              : detailState.community == null
                  ? const Center(child: TextView(text: 'Community not found'))
                  : NestedScrollView(
                      headerSliverBuilder: (context, innerBoxIsScrolled) {
                        return [
                          _buildAppBar(context, detailState.community!),
                        ];
                      },
                      body: Column(
                        children: [
                          _buildTabBar(),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                CommunityPostsTab(
                                  communityId: widget.communityId,
                                  scrollController: _postsScrollController,
                                ),
                                CommunityMembersTab(
                                  communityId: widget.communityId,
                                  memberCount: detailState.community!.memberCount,
                                ),
                                CommunityAboutTab(
                                  community: detailState.community!,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
      floatingActionButton: detailState.community?.isJoined == true
          ? FloatingActionButton(
              onPressed: () =>
                  _navigateToCreateThought(context, detailState.community!),
              backgroundColor: AppColors.metalPinkColour,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  void _navigateToCreateThought(BuildContext context, community) async {
    final communityMetadata = {
      'communityId': widget.communityId,
      'communityName': community.name,
      'communityImage': community.bannerImage,
      'isPublic': community.isPublic,
      'categories': community.tags,
    };

    final result = await Navigator.pushNamed(
      context,
      AppRoutes.postThought,
      arguments: communityMetadata,
    );

    if (!mounted) return;

    final viewModel = ref.read(
      communityDetailViewModelProvider(widget.communityId).notifier,
    );
    if (result != null && result is ThoughtDto) {
      // Add the new post first so it appears at the top immediately (no waiting for refresh)
      viewModel.addPost(result);

      // Ensure we're on the Posts tab
      if (_tabController.index != 0) {
        _tabController.animateTo(0);
      }

      // Scroll to top so the new post is visible; retry for a few frames in case the list isn't built yet
      _scrollPostsToTop(retries: 8);
    }
  }

  void _scrollPostsToTop({int retries = 8}) {
    if (retries <= 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_postsScrollController.hasClients) {
        _postsScrollController.jumpTo(0);
      } else {
        _scrollPostsToTop(retries: retries - 1);
      }
    });
  }

  Widget _buildAppBar(BuildContext context, community) {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Column(
          children: [
            // Banner image
            if (community.bannerImage != null)
              CachedNetworkImage(
                imageUrl: community.bannerImage!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  height: 200,
                  color: AppColors.metalGray,
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: AppColors.metalBrownColourForText,
                      size: 40,
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.metalPinkColour.withOpacity(0.3),
                      AppColors.metalPinkColour.withOpacity(0.1),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.group,
                    size: 60,
                    color: AppColors.metalPinkColour,
                  ),
                ),
              ),
            // Community info section
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.metalWhite,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextView(
                    text: community.name,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.metalBrownColourForText,
                  ),
                  const Gap(8),
                  TextView(
                    text: community.description,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.metalBrownColourForText,
                    maxLines: 2,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                  const Gap(12),
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 16,
                        color: AppColors.metalPinkColour,
                      ),
                      const Gap(6),
                      TextView(
                        text:
                            '${community.memberCount} ${community.memberCount == 1 ? 'member' : 'members'}',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.metalBrownColourForText,
                      ),
                      const Spacer(),
                      // Hide Leave/Join for creator — creator cannot leave
                      if (ref.watch(currentUserProvider)?.id != community.creatorId)
                        BaseButton(
                          buttonText: community.isJoined ? 'Leave' : 'Join',
                          onPressed: () async {
                            final viewModel = ref.read(
                              communityDetailViewModelProvider(widget.communityId)
                                  .notifier,
                            );
                            if (community.isJoined) {
                              final result = await viewModel
                                  .leaveCommunity(widget.communityId);
                              // Check if community was deleted (admin left)
                              if (result != null && result['deleted'] == true) {
                                if (mounted) {
                                  // Show success message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Community and all posts have been deleted',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  // Navigate back
                                  Navigator.pop(context);
                                }
                              }
                            } else {
                              viewModel.joinCommunity(widget.communityId);
                            }
                          },
                          height: 36,
                          width: 100,
                          radius: 8,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          enabled: !ref
                                  .watch(
                                    communityDetailViewModelProvider(
                                        widget.communityId),
                                  )
                                  .isJoining &&
                              !ref
                                  .watch(
                                    communityDetailViewModelProvider(
                                        widget.communityId),
                                  )
                                  .isLeaving,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.metalWhite,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.metalPinkColour,
        labelColor: AppColors.metalPinkColour,
        unselectedLabelColor: AppColors.metalBrownColourForText,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(text: 'Posts'),
          Tab(text: 'Members'),
          Tab(text: 'About'),
        ],
      ),
    );
  }
}
