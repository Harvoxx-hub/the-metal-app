/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

class $AssetsGifsGen {
  const $AssetsGifsGen();

  /// File path: assets/gifs/logo.gif
  AssetGenImage get logo => const AssetGenImage('assets/gifs/logo.gif');

  /// File path: assets/gifs/onboarding.gif
  AssetGenImage get onboarding =>
      const AssetGenImage('assets/gifs/onboarding.gif');

  /// File path: assets/gifs/onboarding2.gif
  AssetGenImage get onboarding2 =>
      const AssetGenImage('assets/gifs/onboarding2.gif');

  /// File path: assets/gifs/onboarding3.gif
  AssetGenImage get onboarding3 =>
      const AssetGenImage('assets/gifs/onboarding3.gif');

  /// List of all assets
  List<AssetGenImage> get values =>
      [logo, onboarding, onboarding2, onboarding3];
}

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/NewspaperClipping.svg
  SvgGenImage get newspaperClipping =>
      const SvgGenImage('assets/icons/NewspaperClipping.svg');

  /// File path: assets/icons/User.2.svg
  SvgGenImage get user2 => const SvgGenImage('assets/icons/User.2.svg');

  /// File path: assets/icons/User.3.svg
  SvgGenImage get user3 => const SvgGenImage('assets/icons/User.3.svg');

  /// File path: assets/icons/User.svg
  SvgGenImage get user => const SvgGenImage('assets/icons/User.svg');

  /// File path: assets/icons/back.svg
  SvgGenImage get back => const SvgGenImage('assets/icons/back.svg');

  /// File path: assets/icons/check-verified.svg
  SvgGenImage get checkVerified =>
      const SvgGenImage('assets/icons/check-verified.svg');

  /// File path: assets/icons/checked.svg
  SvgGenImage get checked => const SvgGenImage('assets/icons/checked.svg');

  /// File path: assets/icons/hambuger.svg
  SvgGenImage get hambuger => const SvgGenImage('assets/icons/hambuger.svg');

  /// File path: assets/icons/notification.svg
  SvgGenImage get notification =>
      const SvgGenImage('assets/icons/notification.svg');

  /// File path: assets/icons/password.icon.svg
  SvgGenImage get passwordIcon =>
      const SvgGenImage('assets/icons/password.icon.svg');

  /// File path: assets/icons/password.svg
  SvgGenImage get password => const SvgGenImage('assets/icons/password.svg');

  /// File path: assets/icons/sms.svg
  SvgGenImage get sms => const SvgGenImage('assets/icons/sms.svg');

  /// File path: assets/icons/unchecked.png
  AssetGenImage get unchecked =>
      const AssetGenImage('assets/icons/unchecked.png');

  /// File path: assets/icons/verification.call.svg
  SvgGenImage get verificationCall =>
      const SvgGenImage('assets/icons/verification.call.svg');

  /// File path: assets/icons/verification.text.svg
  SvgGenImage get verificationText =>
      const SvgGenImage('assets/icons/verification.text.svg');

  /// File path: assets/icons/welcome.item.svg
  SvgGenImage get welcomeItem =>
      const SvgGenImage('assets/icons/welcome.item.svg');

  /// List of all assets
  List<dynamic> get values => [
        newspaperClipping,
        user2,
        user3,
        user,
        back,
        checkVerified,
        checked,
        hambuger,
        notification,
        passwordIcon,
        password,
        sms,
        unchecked,
        verificationCall,
        verificationText,
        welcomeItem
      ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/apple.png
  AssetGenImage get apple => const AssetGenImage('assets/images/apple.png');

  /// File path: assets/images/bg.1.png
  AssetGenImage get bg1 => const AssetGenImage('assets/images/bg.1.png');

  /// File path: assets/images/bg.2.png
  AssetGenImage get bg2 => const AssetGenImage('assets/images/bg.2.png');

  /// File path: assets/images/google.png
  AssetGenImage get google => const AssetGenImage('assets/images/google.png');

  /// File path: assets/images/like.click.png
  AssetGenImage get likeClick =>
      const AssetGenImage('assets/images/like.click.png');

  /// File path: assets/images/logo.png
  AssetGenImage get logo => const AssetGenImage('assets/images/logo.png');

  /// File path: assets/images/melt.click.png
  AssetGenImage get meltClick =>
      const AssetGenImage('assets/images/melt.click.png');

  /// File path: assets/images/push.click.png
  AssetGenImage get pushClick =>
      const AssetGenImage('assets/images/push.click.png');

  /// File path: assets/images/rocket emoji 1.png
  AssetGenImage get rocketEmoji1 =>
      const AssetGenImage('assets/images/rocket emoji 1.png');

  /// List of all assets
  List<AssetGenImage> get values => [
        apple,
        bg1,
        bg2,
        google,
        likeClick,
        logo,
        meltClick,
        pushClick,
        rocketEmoji1
      ];
}

class Assets {
  Assets._();

  static const $AssetsGifsGen gifs = $AssetsGifsGen();
  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName);

  final String _assetName;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class SvgGenImage {
  const SvgGenImage(this._assetName);

  final String _assetName;

  SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    SvgTheme theme = const SvgTheme(),
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    return SvgPicture.asset(
      _assetName,
      key: key,
      matchTextDirection: matchTextDirection,
      bundle: bundle,
      package: package,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      theme: theme,
      // colorFilter: colorFilter,
      color: color,
      colorBlendMode: colorBlendMode,
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
