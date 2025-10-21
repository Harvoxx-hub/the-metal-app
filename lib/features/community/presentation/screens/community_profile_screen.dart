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
  final CommunityModel community;

  const CommunityProfileScreen({
    super.key,
    required this.community,
  });

  @override
  ConsumerState<CommunityProfileScreen> createState() =>
      _CommunityProfileScreenState();
}

class _CommunityProfileScreenState
    extends ConsumerState<CommunityProfileScreen> {
  late CommunityModel _community;

  @override
  void initState() {
    super.initState();
    _community = widget.community;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BaseScreen(
        appBarState: AppBarState.BackWithHeader,
        Header: _community.name,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Community Header
              _buildCommunityHeader(),

              const Gap(20),

              // Content Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: BaseTab(
                  tabs: [
                    BaseTabModel(
                      child: CommunityFeedScreen(community: _community),
                      title: 'Feed',
                    ),
                    BaseTabModel(
                      child: CommunityMembersScreen(community: _community),
                      title: 'Members',
                    ),
                    BaseTabModel(
                      child: CommunityAboutScreen(community: _community),
                      title: 'About',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _community.isJoined
          ? FloatingActionButton(
              onPressed: () {
                _navigateToThoughtComposer();
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

  void _navigateToThoughtComposer() async {
    // Navigate to the existing thought composer with community context
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.postThought,
      arguments: {
        'communityMetadata': {
          'communityId': _community.id,
          'communityName': _community.name,
          'categories': _community.tags,
          'communityImage': _community.bannerImage,
          'isPublic': _community.isPublic,
        }
      },
    );

    // Refresh community thoughts if a thought was posted
    if (result == true || result != null) {
      ref
          .read(communityThoughtsProvider(_community.id).notifier)
          .refreshCommunityThoughts(_community.id);
    }
  }

  Widget _buildCommunityHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: _community.bannerImage != null
            ? DecorationImage(
                image: NetworkImage(_community.bannerImage!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.darken,
                ),
              )
            : null,
        gradient: _community.bannerImage == null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.metalPinkColour,
                  AppColors.metalPinkColour.withOpacity(0.8),
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
            Gap(100),
            // Description
            Text(
              _community.description,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.metalWhite.withOpacity(0.9),
                height: 1.4,
              ),
            ),

            const Gap(16),

            // Tags
            Row(children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _community.tags.map((tag) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.metalWhite.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.metalWhite.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.metalWhite,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              Spacer(),
              if (_community.isJoined)
                PlainButton(
                  buttonText: 'Leave',
                  onPressed: () {
                    _showLeaveDialog();
                  },
                  width: 80,
                  height: 36,
                  fontSize: 12,
                )
              else
                PlainButton(
                  buttonText: 'Join',
                  onPressed: () {
                    _showJoinDialog();
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

  void _showJoinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Join ${_community.name}?',
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
            color: AppColors.metalBrownColourForText.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.metalBrownColourForText.withOpacity(0.6),
              ),
            ),
          ),
          PlainButton(
            buttonText: 'Join',
            onPressed: () async {
              Navigator.pop(context);
              await _joinCommunity();
            },
            width: 80,
            height: 40,
          ),
        ],
      ),
    );
  }

  void _showLeaveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Leave ${_community.name}?',
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
            color: AppColors.metalBrownColourForText.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.metalBrownColourForText.withOpacity(0.6),
              ),
            ),
          ),
          PlainButton(
            buttonText: 'Leave',
            onPressed: () async {
              Navigator.pop(context);
              await _leaveCommunity();
            },
            width: 80,
            height: 40,
            color: AppColors.metalRed,
          ),
        ],
      ),
    );
  }

  Future<void> _joinCommunity() async {
    try {
      final currentUserId = FirebaseServiceDb.instance.userId;
      if (currentUserId == null) {
        _showErrorSnackBar('Please log in to join communities');
        return;
      }

      final communityNotifier = ref.read(communityNotifierProvider.notifier);
      await communityNotifier.joinCommunity(_community.id);

      // Check if the operation was successful
      final state = ref.read(communityNotifierProvider);
      if (state.error != null) {
        _showErrorSnackBar(state.error!);
      } else {
        // Update local state
        setState(() {
          _community = _community.copyWith(
            isJoined: true,
            memberCount: _community.memberCount + 1,
          );
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to join community: ${e.toString()}');
    }
  }

  Future<void> _leaveCommunity() async {
    try {
      final currentUserId = FirebaseServiceDb.instance.userId;
      if (currentUserId == null) {
        _showErrorSnackBar('Please log in to leave communities');
        return;
      }

      final communityNotifier = ref.read(communityNotifierProvider.notifier);
      await communityNotifier.leaveCommunity(_community.id);

      // Check if the operation was successful
      final state = ref.read(communityNotifierProvider);
      if (state.error != null) {
        _showErrorSnackBar(state.error!);
      } else {
        // Update local state
        setState(() {
          _community = _community.copyWith(
            isJoined: false,
            memberCount: _community.memberCount - 1,
          );
        });
        _showSuccessSnackBar('Successfully left ${_community.name}');
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
