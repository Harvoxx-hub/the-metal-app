import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:metal/features/authentication/domain/entries/metal.properties.model.dart';
import 'package:metal/features/eyes/provider/get.current.eyes.notifier.dart';
import 'package:metal/features/profile/presentation/widget/appbar.background.dart';
import 'package:metal/features/profile/provider/upload.profile.image.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/profile.photo.dart';

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({
    super.key,
    required this.child,
    required this.metal,
    this.eye = true,
    this.profileUrl,
  });

  final Widget child;
  final Metal metal;
  final String? profileUrl;
  final bool eye;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileImage = ref.watch(profileImageProvider);
    final eyes = ref.watch(getCurrentEyesProvider);
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
              right: 50,
              child: GestureDetector(
                onTap: () {
                   eyes.data != null || eyes.data!.isNotEmpty ?? false ?
                  showModalBottomSheet(
                    backgroundColor: Colors.white,
                    context: context,
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: Wrap(
                          children: <Widget>[
                            ListTile(
                              title: const Text('View Eyes'),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.viewEyes,
                                  arguments: eyes.data
                                );
                              },
                            ),
                            ListTile(
                                title: const Text('Upload Eyes'),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.eyesIntro,
                                  );
                                }),
                          ],
                        ),
                      );
                    },
                  )
               :  Navigator.pushNamed(
                                    context,
                                    AppRoutes.eyesIntro,
                                  );
                },
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
    final ImagePicker picker = ImagePicker();

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
      final pickedFile = await picker.pickImage(source: option);
      if (pickedFile != null) {
        ref
            .read(profileImageProvider.notifier)
            .UploadProfileImage(File(pickedFile.path));
      }
    }
  }
}
