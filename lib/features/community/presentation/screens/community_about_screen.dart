import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/features/community/data/domain/entries/community.model.dart';
import 'package:metal/features/community/provider/community_notifier.dart';
import 'package:metal/core/services/firebase.service.db.dart';
import 'package:metal/widgets/button/base_button.dart';

class CommunityAboutScreen extends ConsumerStatefulWidget {
  final CommunityModel community;

  const CommunityAboutScreen({
    super.key,
    required this.community,
  });

  @override
  ConsumerState<CommunityAboutScreen> createState() =>
      _CommunityAboutScreenState();
}

class _CommunityAboutScreenState extends ConsumerState<CommunityAboutScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _rulesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.community.name);
    _descriptionController =
        TextEditingController(text: widget.community.description);
    _rulesController =
        TextEditingController(text: widget.community.rules ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _rulesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Edit controls (creator only)
            _buildEditControls(context),
            const Gap(16),
            // About Section
            _buildSection(
              title: 'About',
              child: Text(
                widget.community.description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.metalBrownColourForText.withOpacity(0.8),
                  height: 1.4,
                ),
              ),
            ),

            const Gap(24),

            // Community Rules
            _buildSection(
              title: 'Community Rules',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRuleItem('Be respectful and kind to all members'),
                  _buildRuleItem('Stay on topic and relevant to the community'),
                  _buildRuleItem(
                      'No spam, self-promotion, or off-topic content'),
                  _buildRuleItem('Report inappropriate behavior or content'),
                  _buildRuleItem('Follow Metal\'s community guidelines'),
                ],
              ),
            ),

            const Gap(24),

            // Community Info
            _buildSection(
              title: 'Community Info',
              child: Column(
                children: [
                  _buildInfoRow(
                    icon: Icons.person,
                    label: 'Creator',
                    value: widget.community.creatorName,
                  ),
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: 'Created',
                    value: _formatDate(widget.community.createdAt),
                  ),
                  _buildInfoRow(
                    icon: Icons.group,
                    label: 'Members',
                    value: '${widget.community.memberCount} members',
                  ),
                  _buildInfoRow(
                    icon: Icons.public,
                    label: 'Type',
                    value: widget.community.isPublic ? 'Public' : 'Private',
                  ),
                ],
              ),
            ),

            const Gap(24),

            // Tags
            _buildSection(
              title: 'Topics',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.community.tags.map((tag) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.metalPinkColour.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.metalPinkColour.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.metalPinkColour,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const Gap(24),
          ],
        ),
      ),
    );
  }

  Widget _buildEditControls(BuildContext context) {
    // Only show if current user is the creator
    final state = ref.watch(communityNotifierProvider);
    final isLoading = state.isLoading;

    final isCreator = widget.community.creatorId ==
        FirebaseServiceDb.instance.userId; // uses singleton

    if (!isCreator) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.metalPinkColour.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.metalPinkColour.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Manage community',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.metalBrownColourForText,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: isLoading ? null : () => _openEditDialog(context),
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditDialog(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final viewInsets = MediaQuery.of(ctx).viewInsets;
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: viewInsets.bottom + 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Edit community',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.metalBrownColourForText,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const Gap(12),
              _buildTextField(
                controller: _nameController,
                label: 'Community name',
                maxLength: 64,
              ),
              const Gap(12),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 4,
                maxLength: 280,
              ),
              const Gap(12),
              _buildTextField(
                controller: _rulesController,
                label: 'Rules (optional)',
                maxLines: 4,
                maxLength: 500,
              ),
              const Gap(16),
              SizedBox(
                width: double.infinity,
                child: BaseButton(
                  buttonText: 'Save changes',
                  width: double.infinity,
                  onPressed: () async {
                    final trimmedName = _nameController.text.trim();
                    if (trimmedName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Name cannot be empty')),
                      );
                      return;
                    }
                    final updated = widget.community.copyWith(
                      name: trimmedName,
                      description: _descriptionController.text.trim(),
                      rules: _rulesController.text.trim().isEmpty
                          ? null
                          : _rulesController.text.trim(),
                    );
                    await ref
                        .read(communityNotifierProvider.notifier)
                        .updateCommunity(updated);
                    if (mounted) Navigator.of(ctx).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.metalBrownColourForText.withOpacity(0.7),
          ),
        ),
        const Gap(6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          decoration: InputDecoration(
            counterText: '',
            hintText: label,
            filled: true,
            fillColor: AppColors.metalPinkColour.withOpacity(0.04),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppColors.metalPinkColour.withOpacity(0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppColors.metalPinkColour.withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppColors.metalPinkColour,
                width: 1.2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.metalBrownColourForText,
          ),
        ),
        const Gap(12),
        child,
      ],
    );
  }

  Widget _buildRuleItem(String rule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 8, right: 12),
            decoration: BoxDecoration(
              color: AppColors.metalPinkColour,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: Text(
              rule,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.metalBrownColourForText.withOpacity(0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.metalBrownColourForText.withOpacity(0.6),
          ),
          const Gap(12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.metalBrownColourForText.withOpacity(0.6),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.metalBrownColourForText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
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
        children: [
          Icon(
            icon,
            size: 24,
            color: AppColors.metalPinkColour,
          ),
          const Gap(8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.metalBrownColourForText,
            ),
          ),
          const Gap(4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.metalBrownColourForText.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
    } catch (e) {
      return 'Recently';
    }
  }
}
