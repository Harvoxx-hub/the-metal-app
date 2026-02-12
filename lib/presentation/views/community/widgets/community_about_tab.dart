import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/domain/entities/community_dto.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

/// Community About Tab - displays community information
class CommunityAboutTab extends StatelessWidget {
  final CommunityDto community;

  const CommunityAboutTab({
    super.key,
    required this.community,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          _buildSection(
            title: 'Description',
            child: TextView(
              text: community.description,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.metalBrownColourForText,
            ),
          ),
          const Gap(24),

          // Category
          if (community.category != null) ...[
            _buildSection(
              title: 'Category',
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.metalTabBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextView(
                  text: community.category!,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.metalBrownColourForText,
                ),
              ),
            ),
            const Gap(24),
          ],

          // Type
          _buildSection(
            title: 'Type',
            child: Row(
              children: [
                Icon(
                  community.isPublic ? Icons.public : Icons.lock,
                  size: 16,
                  color: community.isPublic
                      ? AppColors.metalPinkColour
                      : AppColors.metalBrownColourForText,
                ),
                const Gap(8),
                TextView(
                  text: community.isPublic
                      ? 'Public Community'
                      : 'Private Community',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.metalBrownColourForText,
                ),
              ],
            ),
          ),
          const Gap(24),

          // Tags
          if (community.tags.isNotEmpty) ...[
            _buildSection(
              title: 'Tags',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: community.tags.map((tag) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.metalPinkColour.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.metalPinkColour.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: TextView(
                      text: tag,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.metalPinkColour,
                    ),
                  );
                }).toList(),
              ),
            ),
            const Gap(24),
          ],

          // Rules
          if (community.rules != null && community.rules!.isNotEmpty) ...[
            _buildSection(
              title: 'Community Rules',
              child: TextView(
                text: community.rules!,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.metalBrownColourForText,
              ),
            ),
            const Gap(24),
          ],

          // Created info
          _buildSection(
            title: 'Created',
            child: TextView(
              text: 'Created ${_formatDate(community.createdAt)}',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.metalBrownColourForText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextView(
          text: title,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.metalBrownColourForText,
        ),
        const Gap(8),
        child,
      ],
    );
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
