import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gap/gap.dart';
import 'package:metal/domain/entities/community_dto.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/text_views.dart';

class CommunityCard extends StatelessWidget {
  final CommunityDto community;
  final VoidCallback onJoin;
  final VoidCallback onLeave;

  const CommunityCard({
    super.key,
    required this.community,
    required this.onJoin,
    required this.onLeave,
  });

  void _navigateToCommunityDetails(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.communityDetails,
      arguments: community.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToCommunityDetails(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.metalWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.metalButtonStroke,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.metalBlack.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (community.bannerImage != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: community.bannerImage!,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  height: 140,
                  color: AppColors.metalGray,
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: AppColors.metalBrownColourForText,
                      size: 40,
                    ),
                  ),
                ),
                placeholder: (context, url) => Container(
                  height: 140,
                  color: AppColors.metalGray,
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.metalPinkColour,
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              height: 140,
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Center(
                child: Icon(
                  Icons.group,
                  size: 50,
                  color: AppColors.metalPinkColour,
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                Row(
                  children: [
                    Expanded(
                      child: TextView(
                        text: community.name,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.metalBrownColourForText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Gap(4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: community.isPublic
                            ? AppColors.metalPinkColour.withOpacity(0.1)
                            : AppColors.metalGray,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            community.isPublic ? Icons.public : Icons.lock,
                            size: 12,
                            color: community.isPublic
                                ? AppColors.metalPinkColour
                                : AppColors.metalBrownColourForText,
                          ),
                          const Gap(2),
                          TextView(
                            text: community.isPublic ? 'Public' : 'Private',
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: community.isPublic
                                ? AppColors.metalPinkColour
                                : AppColors.metalBrownColourForText,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(6),
                Expanded(
                  child: TextView(
                    text: community.description,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.metalBrownColourForText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
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
                      text: '${community.memberCount} ${community.memberCount == 1 ? 'member' : 'members'}',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.metalBrownColourForText,
                    ),
                    if (community.category != null) ...[
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.metalTabBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextView(
                          text: community.category!,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.metalBrownColourForText,
                        ),
                      ),
                    ],
                  ],
                ),
                const Gap(16),
                GestureDetector(
                  onTap: () {
                    // Handle button tap and prevent parent GestureDetector from firing
                    if (community.isJoined) {
                      onLeave();
                    } else {
                      onJoin();
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: BaseButton(
                    buttonText: community.isJoined ? 'Leave' : 'Join',
                    onPressed: () {
                      // This will be handled by the GestureDetector above
                    },
                    height: 44,
                    width: double.infinity,
                    radius: 12,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    enabled: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
