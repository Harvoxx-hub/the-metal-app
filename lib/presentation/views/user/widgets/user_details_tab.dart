import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/domain/entities/user_dto.dart';
import 'package:metal/presentation/viewmodels/profile/metal_properties_provider.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

/// User Details Tab - displays user information
class UserDetailsTab extends ConsumerWidget {
  final UserDto user;

  const UserDetailsTab({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // About section
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            _buildSection(
              title: 'About',
              child: TextView(
                text: user.bio!,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.metalBrownColourForText,
              ),
            ),
            const Gap(24),
          ],

          // Basic Info
          _buildSection(
            title: 'Basic Information',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user.gender != null) ...[
                  _buildInfoRow('Gender', user.gender!),
                  const Gap(12),
                ],
                if (user.dob != null && user.dob!.isNotEmpty) ...[
                  _buildInfoRow('Age', _calculateAgeFromString(user.dob!)),
                  const Gap(12),
                ],
                if (user.location?.address != null) ...[
                  _buildInfoRow('Location', user.location!.address!),
                  const Gap(12),
                ],
                if (user.metal != null) ...[
                  _buildMetalInfoRow(ref),
                  const Gap(12),
                ],
              ],
            ),
          ),

          // Preferences (if available)
          if (user.connectionOption != null && user.connectionOption!.isNotEmpty) ...[
            const Gap(24),
            _buildSection(
              title: 'Connection Preferences',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user.connectionOption!
                    .map((option) => Chip(
                          label: TextView(
                            text: option,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          backgroundColor: AppColors.metalPinkColour.withOpacity(0.1),
                          side: BorderSide(
                            color: AppColors.metalPinkColour.withOpacity(0.3),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],

          // Prompts (if available)
          if (user.prompts != null && user.prompts!.isNotEmpty) ...[
            const Gap(24),
            _buildSection(
              title: 'Prompts',
              child: Column(
                children: user.prompts!.map((prompt) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.metalButtonStroke,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextView(
                          text: prompt.questionText,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.metalBrownColourForText,
                        ),
                        const Gap(12),
                        TextView(
                          text: prompt.answer,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.metalBrownColourForText,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextView(
          text: title,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.metalBrownColourForText,
        ),
        const Gap(12),
        child,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: TextView(
            text: label,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.metalBrownColourForText.withOpacity(0.7),
          ),
        ),
        Expanded(
          child: TextView(
            text: value,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.metalBrownColourForText,
          ),
        ),
      ],
    );
  }

  Widget _buildMetalInfoRow(WidgetRef ref) {
    final metalProperties = ref.watch(metalPropertiesProvider);

    String metalName = user.metal!; // Fallback to ID if name not found

    if (!metalProperties.isLoading && metalProperties.data?.metals != null) {
      final metals = metalProperties.data!.metals!;
      if (metals.isNotEmpty && user.metal != null) {
        try {
          final metal = metals.firstWhere(
            (element) => element.id == user.metal,
          );
          metalName = metal.title;
        } catch (e) {
          // Metal not found, keep the ID as fallback
        }
      }
    }

    return _buildInfoRow('Metal', metalName);
  }

  String _calculateAgeFromString(String dobString) {
    try {
      final dob = DateTime.parse(dobString);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return '$age years old';
    } catch (e) {
      return 'Age not available';
    }
  }
}
