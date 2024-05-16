import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
 
import 'package:metal/features/authentication/provider/auth.notifier.dart';

class ProfileImage extends ConsumerWidget {
  const ProfileImage(
      {super.key, this.imageUrl, this.height, this.width, this.onTap, this.id, });
  final String? imageUrl;
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
            child: imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(33),
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(33),
                    child: Image.network(
                      userdata!.metal!.img!,
                      fit: BoxFit.cover,
                    ),
                  ),
          )),
    );
  }
}
