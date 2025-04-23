import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:image_picker/image_picker.dart';
import 'package:metal/core/utils/image_picker_util.dart';

import 'package:metal/features/profile/presentation/widget/appbar.background.dart';
import 'package:metal/features/profile/provider/upload.profile.image.notifier.dart';

import 'package:metal/widgets/profile.photo.dart';

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
    final profileImage = ref.watch(profileImageProvider);

    return SingleChildScrollView(
      child: Stack(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppbarBackground(),
            ],
          ),
          child,
          Positioned(
            top: 19,
            left: 0,
            right: 0,
            child: profileImage.isLoading
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
                      imgUrl:
                          profileUrl?.isNotEmpty == true ? profileUrl : null,
                      meltId: metalId,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

 