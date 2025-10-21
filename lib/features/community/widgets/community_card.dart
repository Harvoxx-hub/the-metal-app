import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/plain.button.dart';
import 'package:metal/features/community/data/domain/entries/community.model.dart';

class CommunityCard extends StatelessWidget {
  final CommunityModel community;
  final VoidCallback? onJoin;
  final VoidCallback? onLeave;
  final VoidCallback? onTap;

  const CommunityCard({
    super.key,
    required this.community,
    this.onJoin,
    this.onLeave,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and member count
            Row(
              children: [
                // Community icon/avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.metalPinkColour.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.group,
                    color: AppColors.metalPinkColour,
                    size: 24,
                  ),
                ),

                const Gap(12),

                // Community info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        community.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.metalBrownColourForText,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        '${community.memberCount} members',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.metalBrownColourForText
                              .withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                // Join/Leave button
                if (community.isJoined)
                  PlainButton(
                    buttonText: 'Leave',
                    onPressed: onLeave,
                    width: 70,
                    height: 32,
                    fontSize: 12,
                  )
                else
                  PlainButton(
                    buttonText: 'Join',
                    onPressed: onJoin,
                    width: 70,
                    height: 32,
                    fontSize: 12,
                  ),
              ],
            ),

            const Gap(12),

            // Description
            Text(
              community.description,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.metalBrownColourForText.withOpacity(0.8),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const Gap(12),

            // Tags
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: community.tags.take(3).map((tag) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.metalPinkColour.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.metalPinkColour,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),

            const Gap(8),

            // Creator info
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 14,
                  color: AppColors.metalBrownColourForText.withOpacity(0.5),
                ),
                const Gap(4),
                Text(
                  'Created by ${community.creatorName}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.metalBrownColourForText.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
