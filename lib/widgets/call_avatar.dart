import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
 
import 'package:metal/gen/assets.gen.dart'; // Adjust if needed

class CallAvatar extends StatelessWidget {
  const CallAvatar({
    super.key,
 
    required this.size,
  });

 
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container();
  }

 
  Widget _buildLoadingAvatar(double? progress) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey,
      ),
      child: Center(
        child: CircularProgressIndicator(
          value: progress,
          strokeWidth: 2,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildMetalIcon() {
    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black87,
      ),
      child: Center(
        child: SvgPicture.asset(
          Assets.icons.icon.path,
          width: size.width * 0.6,
          height: size.height * 0.6,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
