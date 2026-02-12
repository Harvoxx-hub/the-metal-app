import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:metal/data/datasources/remote/media_remote_data_source.dart';
import 'package:metal/data/datasources/remote/media_remote_data_source_provider.dart';
import 'package:metal/domain/entities/community_dto.dart';
import 'package:metal/presentation/viewmodels/community/community_viewmodel_providers.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

/// Create Community Screen
class CreateCommunityScreen extends ConsumerStatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  ConsumerState<CreateCommunityScreen> createState() =>
      _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends ConsumerState<CreateCommunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isPublic = true;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  File? _selectedImage;
  String? _uploadedImageUrl;
  String? _selectedCategory;

  // Predefined community categories
  static const List<String> _categories = [
    'Technology',
    'Sports',
    'Art & Design',
    'Music',
    'Gaming',
    'Food & Cooking',
    'Travel',
    'Fitness & Health',
    'Education',
    'Business & Finance',
    'Science',
    'Entertainment',
    'Photography',
    'Writing',
    'Fashion',
    'Movies & TV',
    'Books',
    'Pets & Animals',
    'Cars & Vehicles',
    'DIY & Crafts',
    'Parenting',
    'Dating & Relationships',
    'Politics',
    'Religion',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _uploadedImageUrl =
              null; // Reset uploaded URL when new image is selected
        });
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(msg: 'Failed to pick image: $e');
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    final option = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (option != null) {
      await _pickImage(option);
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final mediaDataSource = ref.read(mediaRemoteDataSourceProvider);
      final publicUrl = await mediaDataSource.uploadMedia(
        file: _selectedImage!,
        mediaType: MediaType.image,
        purpose: MediaPurpose.community,
        contentType: 'image/jpeg',
      );

      if (mounted) {
        setState(() {
          _uploadedImageUrl = publicUrl;
          _isUploadingImage = false;
        });
        return publicUrl;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
        Fluttertoast.showToast(msg: 'Failed to upload image: $e');
      }
    }
    return null;
  }

  Future<void> _createCommunity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload image first if one is selected
      String? bannerImageUrl = _uploadedImageUrl;
      if (_selectedImage != null && bannerImageUrl == null) {
        bannerImageUrl = await _uploadImage();
        if (bannerImageUrl == null && _selectedImage != null) {
          // Upload failed, but user might want to continue without image
          if (mounted) {
            final shouldContinue = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Upload Failed'),
                content: const Text(
                  'Failed to upload image. Do you want to create the community without an image?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Continue'),
                  ),
                ],
              ),
            );
            if (shouldContinue != true) {
              setState(() {
                _isLoading = false;
              });
              return;
            }
          }
        }
      }

      final request = CreateCommunityDto(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        isPublic: _isPublic,
        type: CommunityType.general,
        bannerImage: bannerImageUrl,
      );

      final success = await ref
          .read(communityViewModelProvider.notifier)
          .createCommunity(request);

      if (mounted) {
        if (success) {
          Fluttertoast.showToast(msg: 'Community created successfully!');
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          final error = ref.read(communityViewModelProvider).errorMessage;
          Fluttertoast.showToast(
            msg: error ?? 'Failed to create community. Please try again.',
            toastLength: Toast.LENGTH_LONG,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(msg: 'Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.metalBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: const TextView(
          text: 'Create Community',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.metalBlack,
        ),
        centerTitle: true,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _createCommunity,
              child: const TextView(
                text: 'Create',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.metalPinkColour,
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EditFormField(
                controller: _nameController,
                label: 'Community Name',
                hint: 'Enter community name (3-50 characters)',
                keyboardType: TextInputType.text,
                autoValidate: false,
                radius: 12,
                fillColor: Colors.grey[50],
                isFilled: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Community name is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  if (value.trim().length > 50) {
                    return 'Name must not exceed 50 characters';
                  }
                  return null;
                },
              ),
              const Gap(16),
              EditFormField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Describe your community (10-500 characters)',
                keyboardType: TextInputType.multiline,
                autoValidate: false,
                radius: 12,
                fillColor: Colors.grey[50],
                isFilled: true,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  if (value.trim().length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  if (value.trim().length > 500) {
                    return 'Description must not exceed 500 characters';
                  }
                  return null;
                },
              ),
              const Gap(16),
              // Category Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextView(
                    text: 'Category (Optional)',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.metalBlack,
                  ),
                  const Gap(8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      hintText: 'Select a category',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.metalPinkColour,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: TextView(
                          text: category,
                          fontSize: 14,
                          color: AppColors.metalBlack,
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.metalPinkColour,
                    ),
                  ),
                ],
              ),
              const Gap(24),
              // Banner Image Upload Section
              const TextView(
                text: 'Banner Image (Optional)',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.metalBlack,
              ),
              const Gap(12),
              GestureDetector(
                onTap: _isUploadingImage ? null : _showImageSourceDialog,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: _isUploadingImage
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              Gap(12),
                              TextView(
                                text: 'Uploading image...',
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        )
                      : _selectedImage != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _selectedImage!,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _selectedImage = null;
                                          _uploadedImageUrl = null;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const Gap(8),
                                TextView(
                                  text: 'Tap to upload banner image',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                                const Gap(4),
                                TextView(
                                  text: 'Recommended: 1200x400px',
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ],
                            ),
                ),
              ),
              const Gap(24),
              Row(
                children: [
                  const Expanded(
                    child: TextView(
                      text: 'Community Visibility',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.metalBlack,
                    ),
                  ),
                  Switch(
                    value: _isPublic,
                    onChanged: (value) {
                      setState(() {
                        _isPublic = value;
                      });
                    },
                    activeColor: AppColors.metalPinkColour,
                  ),
                ],
              ),
              const Gap(8),
              TextView(
                text: _isPublic
                    ? 'Anyone can find and join this community'
                    : 'Only invited members can join this community',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
              const Gap(32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createCommunity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.metalPinkColour,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const TextView(
                          text: 'Create Community',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
