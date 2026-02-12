import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/utils/image_picker_util.dart';
// AppbarBackground widget removed - using inline widget instead
import 'package:metal/presentation/viewmodels/profile/profile_photo_viewmodel.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/res/colors/cr_colors.dart';

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({
    super.key,
    required this.child,
    required this.metalId,
    this.eye = true,
    this.myProfile = false,
    this.profileUrl,
  });

  final Widget child;
  final String metalId;
  final String? profileUrl;
  final bool eye;
  final bool myProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilePhotoState = ref.watch(profilePhotoViewModelProvider);

    return SingleChildScrollView(
      child: Stack(
        children: [
          // Background gradient for profile header - using brand color with rounded corners
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.metalPinkColour,
                  AppColors.metalPinkColour.withOpacity(0.7),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
          ),
          child,
          Positioned(
            top: 19,
            left: 0,
            right: 0,
            child: profilePhotoState.isUploading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : GestureDetector(
                    onTap: () {
                      if (myProfile) {
                        ImagePickerUtil.pickImage(context, ref);
                      }
                    },
                    child: ProfilePhoto(
                      size: 170,
                      verfly: false,
                      imgUrl: profileUrl?.isNotEmpty == true ? profileUrl : null,
                      meltId: metalId,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

