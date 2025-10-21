import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/plain.button.dart';
import 'package:metal/features/community/data/domain/entries/community.model.dart';
import 'package:metal/features/community/provider/community_notifier.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';

class CreateCommunityScreen extends ConsumerStatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  ConsumerState<CreateCommunityScreen> createState() =>
      _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends ConsumerState<CreateCommunityScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _rulesController = TextEditingController();

  String _selectedCategory = 'Tech';
  String? _selectedImagePath;
  bool _isCreating = false;
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _categories = [
    'Tech',
    'Faith',
    'Afrobeat',
    'Career',
    'Sports',
    'Music',
    'Art',
    'Food',
    'Travel',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _rulesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to community state changes
    ref.listen<CommunityState>(communityNotifierProvider, (previous, next) {
      if (next.isCreating) {
        // Show loading indicator
        setState(() {
          _isCreating = true;
        });
      } else if (next.successMessage != null) {
        // Show success message and navigate back
        setState(() {
          _isCreating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.metalPinkColour,
          ),
        );

        Navigator.pop(context, true); // Return true to indicate success
      } else if (next.error != null) {
        // Show error message
        setState(() {
          _isCreating = false;
        });

        _showError(next.error!);
      }
    });

    return BaseScreen(
      appBarState: AppBarState.BackWithHeader,
      Header: 'Create Community',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Community Image Upload Section
            _buildImageUploadSection(),

            const Gap(24),

            // Community Name
            _buildInputField(
              controller: _nameController,
              label: 'Community Name',
              hint: 'Enter community name...',
              maxLines: 1,
            ),

            const Gap(20),

            // Description
            _buildInputField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Describe your community...',
              maxLines: 4,
            ),

            const Gap(20),

            // Category Selection
            _buildCategorySection(),

            const Gap(20),

            // Community Rules
            _buildInputField(
              controller: _rulesController,
              label: 'Community Rules (Optional)',
              hint: 'Set community guidelines...',
              maxLines: 3,
            ),

            const Gap(32),

            // Create Button
            _buildCreateButton(),

            const Gap(20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Community Image',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.metalBrownColourForText,
          ),
        ),
        const Gap(12),
        GestureDetector(
          onTap: _showImagePicker,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.metalTabBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.metalButtonStroke,
                width: 1,
              ),
            ),
            child: _selectedImagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(_selectedImagePath!),
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 48,
                        color:
                            AppColors.metalBrownColourForText.withOpacity(0.5),
                      ),
                      const Gap(12),
                      Text(
                        'Add Community Image',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.metalBrownColourForText
                              .withOpacity(0.7),
                        ),
                      ),
                      const Gap(4),
                      Text(
                        'Tap to select from gallery or camera',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.metalBrownColourForText
                              .withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required int maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.metalBrownColourForText,
          ),
        ),
        const Gap(12),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.metalButtonStroke),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.metalButtonStroke),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.metalPinkColour),
            ),
            filled: true,
            fillColor: AppColors.metalWhite,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.metalBrownColourForText,
          ),
        ),
        const Gap(12),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.metalButtonStroke),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.metalButtonStroke),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.metalPinkColour),
            ),
            filled: true,
            fillColor: AppColors.metalWhite,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: _categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: PlainButton(
        buttonText: _isCreating ? 'Creating...' : 'Create Community',
        onPressed: _isCreating ? null : _createCommunity,
        height: 52,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Community Image',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.metalBrownColourForText,
              ),
            ),
            const Gap(20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _selectImage('gallery');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.metalPinkColour.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.metalPinkColour.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.photo_library,
                            size: 40,
                            color: AppColors.metalPinkColour,
                          ),
                          const Gap(12),
                          Text(
                            'Gallery',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.metalPinkColour,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _selectImage('camera');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.metalPinkColour.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.metalPinkColour.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: AppColors.metalPinkColour,
                          ),
                          const Gap(12),
                          Text(
                            'Camera',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.metalPinkColour,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.metalBrownColourForText.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectImage(String source) async {
    try {
      XFile? image;

      if (source == 'gallery') {
        image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
      } else if (source == 'camera') {
        image = await _imagePicker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
      }

      if (image != null) {
        setState(() {
          _selectedImagePath = image!.path;
        });
      }
    } catch (e) {
      _showError('Failed to select image: ${e.toString()}');
    }
  }

  void _createCommunity() {
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter a community name');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showError('Please enter a community description');
      return;
    }

    // Get current user
    final userState = ref.read(userStateProvider);
    if (userState.data == null) {
      _showError('Please log in to create a community');
      return;
    }

    final currentUser = userState.data!;

    // Create community model (without banner image URL yet)
    final newCommunity = CommunityModel(
      id: '', // Will be generated by the repository
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      bannerImage: _selectedImagePath, // Will be set after upload
      creatorId: currentUser.id ?? 'unknown_user',
      creatorName: currentUser.fullname ?? currentUser.username ?? 'Unknown',
      memberCount: 1,
      isPublic: true,
      tags: [_selectedCategory],
      createdAt: DateTime.now().toIso8601String(),
      rules: _rulesController.text.trim().isNotEmpty
          ? _rulesController.text.trim()
          : null,
      isJoined: true, // Creator automatically joins
    );

    // Use the notifier to create the community with image upload
    ref
        .read(communityNotifierProvider.notifier)
        .createCommunity(newCommunity, imagePath: _selectedImagePath);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.metalRed,
      ),
    );
  }
}
