import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:metal/presentation/viewmodels/community/community_detail_viewmodel_providers.dart';
import 'package:metal/presentation/views/community/widgets/community_posts_tab.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
                                  initialPosts: detailState.posts,
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

    // Refresh community details if thought was posted successfully
    if (result == true && mounted) {
      final viewModel = ref.read(
        communityDetailViewModelProvider(widget.communityId).notifier,
      );
      // Force a full refresh to get the latest posts
      await viewModel.refreshAll(widget.communityId);
      
      // Ensure we're on the Posts tab to see the new post
      if (_tabController.index != 0) {
        _tabController.animateTo(0);
      }
    }
  }

  Widget _buildAppBar(BuildContext context, community) {
    return SliverAppBar(
      expandedHeight: 280,
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
                      BaseButton(
                        buttonText: community.isJoined ? 'Leave' : 'Join',
                        onPressed: () {
                          final viewModel = ref.read(
                            communityDetailViewModelProvider(widget.communityId)
                                .notifier,
                          );
                          if (community.isJoined) {
                            viewModel.leaveCommunity(widget.communityId);
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
          Tab(text: 'About'),
        ],
      ),
    );
  }
}
