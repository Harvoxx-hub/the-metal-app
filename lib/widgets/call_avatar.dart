import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallAvatar extends StatelessWidget {
  const CallAvatar({
    super.key,
    required this.user,
    required this.size,
    this.userModel,
  });

  final ZegoUIKitUser? user;
  final Size size;
  final UserModel? userModel;

  @override
  Widget build(BuildContext context) {
    // Check if we have a profile photo from the UserModel
    final String? profilePhotoUrl = userModel?.profilePhoto;

    if (profilePhotoUrl != null && profilePhotoUrl.isNotEmpty) {
      // Use user's actual profile picture
      return _buildProfileImage(profilePhotoUrl);
    }

    // Try robohash as secondary option, then fallback to Metal icon
    return _buildFallbackAvatar();
  }

  Widget _buildProfileImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
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
      errorWidget: (context, url, error) {
        // Log error for debugging
        ZegoLoggerService.logInfo(
          'Profile image failed to load: $url',
          tag: 'call avatar',
          subTag: 'profile image',
        );
        return _buildFallbackAvatar();
      },
    );
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

  Widget _buildFallbackAvatar() {
    // Try robohash if we have a user ID, otherwise go straight to Metal icon
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
        errorWidget: (context, url, error) {
          // Log robohash failure
          ZegoLoggerService.logInfo(
            'Robohash avatar failed for user ${user?.id}',
            tag: 'call avatar',
            subTag: 'robohash fallback',
          );
          return _buildMetalIcon();
        },
      );
    }

    // Final fallback to Metal icon
    return _buildMetalIcon();
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

/// Builder function for ZegoUIKit integration
/// This maintains backward compatibility with existing ZegoUIKit setup
Widget callAvatarBuilder(
  BuildContext context,
  Size size,
  ZegoUIKitUser? user,
  Map<String, dynamic> extraInfo,
) {
  // Extract UserModel from extraInfo if provided
  final UserModel? userModel = extraInfo['userModel'] as UserModel?;

  return CallAvatar(
    user: user,
    size: size,
    userModel: userModel,
  );
}
