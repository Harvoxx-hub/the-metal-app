import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/plain.button.dart';
import 'package:metal/widgets/tab/base.tab.dart';
import 'package:metal/features/community/data/domain/entries/community.model.dart';
import 'package:metal/features/community/presentation/screens/community_feed_screen.dart';
import 'package:metal/features/community/presentation/screens/community_members_screen.dart';
import 'package:metal/features/community/presentation/screens/community_about_screen.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/features/community/provider/community_thoughts_notifier.dart';
import 'package:metal/features/community/provider/community_notifier.dart';
import 'package:metal/core/services/firebase.service.db.dart';

class CommunityProfileScreen extends ConsumerStatefulWidget {
  final String communityId;

  const CommunityProfileScreen({
    super.key,
    required this.communityId,
  });

  @override
  ConsumerState<CommunityProfileScreen> createState() =>
      _CommunityProfileScreenState();
}

class _CommunityProfileScreenState
    extends ConsumerState<CommunityProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load the community using the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(communityNotifierProvider.notifier)
          .getCommunityById(widget.communityId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final communityState = ref.watch(communityNotifierProvider);
    final community = ref.watch(communityProvider(widget.communityId));

    if (communityState.isLoading) {
      return Scaffold(
        body: BaseScreen(
          appBarState: AppBarState.BackWithHeader,
          Header: 'Loading...',
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (communityState.error != null || community == null) {
      return Scaffold(
        body: BaseScreen(
          appBarState: AppBarState.BackWithHeader,
          Header: 'Error',
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey.shade500,
                ),
                const Gap(16),
                Text(
                  communityState.error ?? 'Community not found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(24),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(communityNotifierProvider.notifier)
                        .getCommunityById(widget.communityId);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: BaseScreen(
        appBarState: AppBarState.BackWithHeader,
        Header: community.name,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Community Header
              _buildCommunityHeader(community),

              const Gap(20),

              // Content Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: BaseTab(
                  tabs: [
                    BaseTabModel(
                      child: CommunityFeedScreen(community: community),
                      title: 'Feed',
                    ),
                    BaseTabModel(
                      child: CommunityMembersScreen(community: community),
                      title: 'Members',
                    ),
                    BaseTabModel(
                      child: CommunityAboutScreen(community: community),
                      title: 'About',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: community.isJoined
          ? FloatingActionButton(
              onPressed: () {
                _navigateToThoughtComposer(community);
              },
              backgroundColor: AppColors.metalPinkColour,
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  void _navigateToThoughtComposer(CommunityModel community) async {
    // Navigate to the existing thought composer with community context
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.postThought,
      arguments: {
        'communityMetadata': {
          'communityId': community.id,
          'communityName': community.name,
          'categories': community.tags,
          'communityImage': community.bannerImage,
          'isPublic': community.isPublic,
        }
      },
    );

    // Refresh community thoughts if a thought was posted
    if (result == true || result != null) {
      ref
          .read(communityThoughtsProvider(community.id).notifier)
          .refreshCommunityThoughts(community.id);
    }
  }

  Widget _buildCommunityHeader(CommunityModel community) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: community.bannerImage != null
            ? DecorationImage(
                image: NetworkImage(community.bannerImage!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.4),
                  BlendMode.darken,
                ),
              )
            : null,
        gradient: community.bannerImage == null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.metalPinkColour,
                  AppColors.metalPinkColour.withValues(alpha: 0.8),
                ],
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Community Icon and Name
            const Gap(100),
            // Description
            Text(
              community.description,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.metalWhite.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),

            const Gap(16),

            // Tags
            Row(children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: community.tags.map((tag) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.metalWhite.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.metalWhite.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.metalWhite,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              // Only show join/leave button if user is not the creator
              if (FirebaseServiceDb.instance.userId != community.creatorId)
                if (community.isJoined)
                  PlainButton(
                    buttonText: 'Leave',
                    onPressed: () {
                      _showLeaveDialog(community);
                    },
                    width: 80,
                    height: 36,
                    fontSize: 12,
                  )
                else
                  PlainButton(
                    buttonText: 'Join',
                    onPressed: () {
                      _showJoinDialog(community);
                    },
                    width: 80,
                    height: 36,
                    fontSize: 12,
                  ),
            ]),
          ],
        ),
      ),
    );
  }

  void _showJoinDialog(CommunityModel community) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Join ${community.name}?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.metalBrownColourForText,
          ),
        ),
        content: Text(
          'You\'ll be able to post, comment, and interact with other members.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.metalBrownColourForText.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.metalBrownColourForText.withValues(alpha: 0.6),
              ),
            ),
          ),
          PlainButton(
            buttonText: 'Join',
            onPressed: () async {
              Navigator.pop(context);
              await _joinCommunity(community);
            },
            width: 80,
            height: 40,
          ),
        ],
      ),
    );
  }

  void _showLeaveDialog(CommunityModel community) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Leave ${community.name}?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.metalBrownColourForText,
          ),
        ),
        content: Text(
          'You\'ll no longer be able to post or comment in this community.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.metalBrownColourForText.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.metalBrownColourForText.withValues(alpha: 0.6),
              ),
            ),
          ),
          PlainButton(
            buttonText: 'Leave',
            onPressed: () async {
              Navigator.pop(context);
              await _leaveCommunity(community);
            },
            width: 80,
            height: 40,
            color: AppColors.metalRed,
          ),
        ],
      ),
    );
  }

  Future<void> _joinCommunity(CommunityModel community) async {
    try {
      final currentUserId = FirebaseServiceDb.instance.userId;
      if (currentUserId == null) {
        _showErrorSnackBar('Please log in to join communities');
        return;
      }

      final communityNotifier = ref.read(communityNotifierProvider.notifier);
      await communityNotifier.joinCommunity(community.id);

      // Check if the operation was successful
      final state = ref.read(communityNotifierProvider);
      if (state.error != null) {
        _showErrorSnackBar(state.error!);
      } else {
        // Refresh the community data
        ref
            .read(communityNotifierProvider.notifier)
            .getCommunityById(community.id);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to join community: ${e.toString()}');
    }
  }

  Future<void> _leaveCommunity(CommunityModel community) async {
    try {
      final currentUserId = FirebaseServiceDb.instance.userId;
      if (currentUserId == null) {
        _showErrorSnackBar('Please log in to leave communities');
        return;
      }

      final communityNotifier = ref.read(communityNotifierProvider.notifier);
      await communityNotifier.leaveCommunity(community.id);

      // Check if the operation was successful
      final state = ref.read(communityNotifierProvider);
      if (state.error != null) {
        _showErrorSnackBar(state.error!);
      } else {
        // Refresh the community data
        ref
            .read(communityNotifierProvider.notifier)
            .getCommunityById(community.id);
        _showSuccessSnackBar('Successfully left ${community.name}');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to leave community: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.metalRed,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.metalPinkColour,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
