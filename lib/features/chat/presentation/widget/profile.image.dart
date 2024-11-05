import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
 
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/gen/assets.gen.dart';

class ProfileImage extends ConsumerWidget {
  const ProfileImage(
      {super.key, required this.imageUrl, this.height, this.width, this.onTap, this.id, });
  final String imageUrl;
  final double? height;
  final String? id;
  final double? width;
  final bool isEdit = false;
  final Function()? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userdata = ref.watch(authProvider).data;
    return GestureDetector(
      onTap:  onTap,
      child: Container(
          width: width ?? 66,
          height: height ?? 66,
          padding: const EdgeInsets.all(2),
          decoration: const ShapeDecoration(
            color: Colors.white,
            shape: OvalBorder(
              side: BorderSide(width: 2, color: Color(0xFFF27121)),
            ),
          ),
          child: Center(
            child: CachedNetworkImage(
                            imageUrl:   imageUrl!,
                            imageBuilder: (context, imageProvider) =>
                                CircleAvatar(
                                  radius: 33, // Image radius
                                  backgroundImage: imageProvider,
                                ),
                            placeholder: (context, url) => const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator
                                      .adaptive(), // Loading indicator
                                ),
                            errorWidget: (context, url, error) =>
                                Assets.images.logo.image(height: 24, width: 24))
                
                
                
          )),
    );
  }
}
