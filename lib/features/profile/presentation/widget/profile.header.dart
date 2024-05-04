import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:metal/features/authentication/domain/entries/metal.properties.model.dart';
import 'package:metal/features/profile/presentation/widget/appbar.background.dart';
import 'package:metal/features/profile/provider/upload.profile.image.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/profile.photo.dart';

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({
    Key? key,
    required this.child,
    required this.metal,
    this.eye = true,
    this.profileUrl,
  }) : super(key: key);

  final Widget child;
  final Metal metal;
  final String? profileUrl;
  final bool eye;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileImage = ref.watch(profileImageProvider);
    return SingleChildScrollView(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              AppbarBackground(),
            ],
          ),
          child,
          Positioned(
            top: 19,
            left: 0,
            right: 0,
            child: profileImage.isLoading
                ? const Center(child: CircularProgressIndicator())
                : GestureDetector(
                    onTap: () => _pickImage(context, ref),
                    child: ProfilePhoto(
                      size: 170,
                      verfly: false,
                      photourl: profileUrl?.isNotEmpty == true
                          ? profileUrl
                          : metal.img,
                    ),
                  ),
          ),
          if (eye)
            Positioned(
              top: 140,
              right: 50.w,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.eyesIntro,
                ),
                child: SvgPicture.asset(
                  Assets.icons.eye.path,
                  height: 40,
                  width: 40,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, WidgetRef ref) async {
    final ImagePicker _picker = ImagePicker();

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
      final pickedFile = await _picker.pickImage(source: option);
      if (pickedFile != null) {
        ref
            .read(profileImageProvider.notifier)
            .UploadProfileImage(File(pickedFile.path));
      }
    }
  }
}
