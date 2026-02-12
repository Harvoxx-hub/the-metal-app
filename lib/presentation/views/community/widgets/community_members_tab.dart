import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/domain/entities/community_dto.dart';
import 'package:metal/presentation/viewmodels/community/community_detail_viewmodel_providers.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/state.handler/loading.state.dart';
import 'package:metal/widgets/state.handler/error.state.dart';
import 'package:metal/widgets/state.handler/empty.state.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/widgets/profile.photo.dart';

/// Community Members Tab - displays community members
class CommunityMembersTab extends ConsumerStatefulWidget {
  final String communityId;
  final int memberCount;

  const CommunityMembersTab({
    super.key,
    required this.communityId,
    required this.memberCount,
  });

  @override
  ConsumerState<CommunityMembersTab> createState() => _CommunityMembersTabState();
}

class _CommunityMembersTabState extends ConsumerState<CommunityMembersTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Load members when tab is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(communityDetailViewModelProvider(widget.communityId).notifier)
          .loadCommunityMembers(widget.communityId);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase().trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(
      communityDetailViewModelProvider(widget.communityId),
    );

    if (detailState.isLoadingMembers && detailState.members.isEmpty) {
      return const LoadingState();
    }

    if (detailState.isError && detailState.members.isEmpty) {
      return ErrorState(
        text: detailState.errorMessage ?? 'Failed to load members',
        retry: () {
          ref
              .read(communityDetailViewModelProvider(widget.communityId).notifier)
              .loadCommunityMembers(widget.communityId);
        },
      );
    }

    // Filter members based on search query
    final filteredMembers = _searchQuery.isEmpty
        ? detailState.members
        : detailState.members.where((member) {
            final username = member.userName.toLowerCase();
            return username.contains(_searchQuery);
          }).toList();

    if (filteredMembers.isEmpty) {
      return EmptyState(
        text: _searchQuery.isEmpty
            ? 'No members found'
            : 'No members match your search',
      );
    }

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search members...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        // Members list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(communityDetailViewModelProvider(widget.communityId).notifier)
                  .loadCommunityMembers(widget.communityId);
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredMembers.length,
              itemBuilder: (context, index) {
                final member = filteredMembers[index];
                return _buildMemberCard(context, member);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMemberCard(BuildContext context, CommunityMemberDto member) {
    final roleColor = _getRoleColor(member.role);
    final roleIcon = _getRoleIcon(member.role);

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.userProfile,
          arguments: member.userId,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.metalWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.metalGray.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Metal icon (not profile photo) based on member's metal
          ProfilePhoto(
            imgUrl: null,
            size: 50,
            meltId: member.userMetal ?? '',
          ),
          const Gap(12),
          // Member info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextView(
                        text: member.userName,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.metalBrownColourForText,
                      ),
                    ),
                    if (member.role != CommunityMemberRole.member) ...[
                      Icon(
                        roleIcon,
                        size: 16,
                        color: roleColor,
                      ),
                      const Gap(4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextView(
                          text: _getRoleLabel(member.role),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: roleColor,
                        ),
                      ),
                    ],
                  ],
                ),
                const Gap(4),
                TextView(
                  text: 'Joined ${_formatDate(member.joinedAt)}',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.metalBrownColourForText.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Color _getRoleColor(CommunityMemberRole role) {
    switch (role) {
      case CommunityMemberRole.creator:
        return AppColors.metalPinkColour;
      case CommunityMemberRole.admin:
        return Colors.blue;
      case CommunityMemberRole.member:
        return AppColors.metalBrownColourForText;
    }
  }

  IconData _getRoleIcon(CommunityMemberRole role) {
    switch (role) {
      case CommunityMemberRole.creator:
        return Icons.star;
      case CommunityMemberRole.admin:
        return Icons.shield;
      case CommunityMemberRole.member:
        return Icons.person;
    }
  }

  String _getRoleLabel(CommunityMemberRole role) {
    switch (role) {
      case CommunityMemberRole.creator:
        return 'Creator';
      case CommunityMemberRole.admin:
        return 'Admin';
      case CommunityMemberRole.member:
        return 'Member';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}
