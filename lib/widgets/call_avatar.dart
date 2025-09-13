import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:metal/gen/assets.gen.dart'; // Adjust if needed

class CallAvatar extends StatelessWidget {
  const CallAvatar({
    super.key,
    required this.user,
    required this.size,
  });

  final ZegoUIKitUser? user;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return _buildRobohashAvatar();
  }

  Widget _buildRobohashAvatar() {
    if (user?.id != null && user!.id.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: 'https://robohash.org/${user!.id}.png',
        imageBuilder: (context, imageProvider) => Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            _buildLoadingAvatar(downloadProgress.progress),
        errorWidget: (context, url, error) => _buildMetalIcon(),
      );
    }

    // Fallback if user ID is empty
    return _buildMetalIcon();
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
