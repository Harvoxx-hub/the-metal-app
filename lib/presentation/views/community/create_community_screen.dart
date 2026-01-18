import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
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

class _CreateCommunityScreenState
    extends ConsumerState<CreateCommunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _isPublic = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _createCommunity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = CreateCommunityDto(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
        isPublic: _isPublic,
        type: CommunityType.general,
      );

      final success = await ref
          .read(communityViewModelProvider.notifier)
          .createCommunity(request);

      if (mounted) {
        if (success) {
          Fluttertoast.showToast(msg: 'Community created successfully!');
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          Fluttertoast.showToast(msg: 'Failed to create community');
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
              EditFormField(
                controller: _categoryController,
                label: 'Category (Optional)',
                hint: 'e.g., Technology, Sports, Art',
                keyboardType: TextInputType.text,
                autoValidate: false,
                radius: 12,
                fillColor: Colors.grey[50],
                isFilled: true,
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
