import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/features/community/data/domain/entries/community.model.dart';
import 'package:metal/features/community/provider/community_members_notifier.dart';
import 'package:metal/widgets/profile.photo.dart';

class CommunityMembersScreen extends ConsumerStatefulWidget {
  final CommunityModel community;

  const CommunityMembersScreen({
    super.key,
    required this.community,
  });

  @override
  ConsumerState<CommunityMembersScreen> createState() =>
      _CommunityMembersScreenState();
}

class _CommunityMembersScreenState
    extends ConsumerState<CommunityMembersScreen> {
  @override
  void initState() {
    super.initState();
    // Load community members when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(communityMembersNotifierProvider.notifier)
          .getCommunityMembers(widget.community.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final membersState =
        ref.watch(communityMembersProvider(widget.community.id));

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Members Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Members',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.metalBrownColourForText,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${membersState.members.length} members',
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            AppColors.metalBrownColourForText.withOpacity(0.6),
                      ),
                    ),
                    const Gap(8),
                    IconButton(
                      onPressed: () {
                        ref
                            .read(communityMembersNotifierProvider.notifier)
                            .getCommunityMembers(widget.community.id);
                      },
                      icon: Icon(
                        Icons.refresh,
                        size: 20,
                        color:
                            AppColors.metalBrownColourForText.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Gap(16),

            // Loading State
            if (membersState.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              )
            // Error State
            else if (membersState.error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.metalRed,
                      ),
                      const Gap(16),
                      Text(
                        'Failed to load members',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.metalBrownColourForText,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        membersState.error!,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.metalBrownColourForText
                              .withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(16),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(communityMembersNotifierProvider.notifier)
                              .getCommunityMembers(widget.community.id);
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            // Empty State
            else if (membersState.members.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 48,
                        color:
                            AppColors.metalBrownColourForText.withOpacity(0.4),
                      ),
                      const Gap(16),
                      Text(
                        'No members yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.metalBrownColourForText,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        'Be the first to join this community!',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.metalBrownColourForText
                              .withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            // Members Grid
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: membersState.members.length,
                itemBuilder: (context, index) {
                  final memberData = membersState.members[index];
                  return _buildMemberCard(memberData);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> memberData) {
    final userName = memberData['userName'] ?? 'Unknown User';
    final userPhoto = memberData['userPhoto'];
    final metalId = memberData['metal'] ?? '';
    final role = memberData['role'] ?? 'member';
    final joinedAt = memberData['joinedAt'] ?? '';

    return GestureDetector(
      onTap: () {
        _showMemberProfile(memberData);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.metalWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.metalBlack.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Member Avatar
            Stack(
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: ProfilePhoto(
                    size: 60,
                    meltId: metalId,
                    imgUrl: userPhoto,
                    verfly: false,
                  ),
                ),

                // Role Badge
                if (role != 'member')
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: role == 'creator'
                            ? AppColors.metalPinkColour
                            : AppColors.metalBrownColourForText,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.metalWhite,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        role == 'creator'
                            ? Icons.star
                            : Icons.admin_panel_settings,
                        color: AppColors.metalWhite,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),

            const Gap(8),

            // Member Name
            Text(
              userName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.metalBrownColourForText,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const Gap(4),

            // Role
            Text(
              role.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                color: role == 'creator'
                    ? AppColors.metalPinkColour
                    : role == 'admin'
                        ? AppColors.metalBrownColourForText.withOpacity(0.7)
                        : AppColors.metalBrownColourForText.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
            ),

            const Gap(4),

            // Join Date
            Text(
              _formatJoinDate(joinedAt),
              style: TextStyle(
                fontSize: 10,
                color: AppColors.metalBrownColourForText.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatJoinDate(String joinedAt) {
    try {
      final dateTime = DateTime.parse(joinedAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()}mo ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  void _showMemberProfile(Map<String, dynamic> memberData) {
    final userName = memberData['userName'] ?? 'Unknown User';
    final userPhoto = memberData['userPhoto'];
    final metalId = memberData['metal'] ?? '';
    final role = memberData['role'] ?? 'member';
    final joinedAt = memberData['joinedAt'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          userName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.metalBrownColourForText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: ProfilePhoto(
                size: 80,
                meltId: metalId,
                imgUrl: userPhoto,
                verfly: false,
              ),
            ),
            const Gap(16),
            Text(
              'Role: ${role.toUpperCase()}',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.metalBrownColourForText.withOpacity(0.7),
              ),
            ),
            const Gap(8),
            Text(
              'Joined: ${_formatJoinDate(joinedAt)}',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.metalBrownColourForText.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: AppColors.metalBrownColourForText.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
