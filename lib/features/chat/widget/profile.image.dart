import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/colors/cr_colors.dart';

class ProfileImage extends StatelessWidget {
  const ProfileImage(
      {super.key, this.imageUrl, this.height, this.width, this.onTap, this.id});
  final String? imageUrl;
  final double? height;
  final String? id;
  final double? width;
  final bool isEdit = false;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // if(id != null)
        // context.pushNamed(SecoundaryProfile.name,  extra: id  );
      },
      child: Container(
          width: width ?? 66.w,
          height: height ?? 66.h,
          padding: const EdgeInsets.all(2),
          decoration: const ShapeDecoration(
            color: Colors.white,
            shape: OvalBorder(
              side: BorderSide(width: 2, color: Color(0xFFF27121)),
            ),
          ),
          child: Center(
            child: Image.asset(
              Assets.images.silver.path,
              height: 40,
              width: 40,
              fit: BoxFit.fill,
            ),
          )),
    );
  }
}
