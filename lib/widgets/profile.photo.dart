import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

 
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/presentation/viewmodels/profile/metal_properties_provider.dart';

class ProfilePhoto extends ConsumerWidget {
  final double size;
  final bool verfly;
  final String? imgUrl;
  final String meltId;

  const ProfilePhoto(
      {super.key,
      this.size = 40,
      this.verfly = false,
      this.imgUrl,
      required this.meltId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final getMetalProperties = ref.watch(metalPropertiesProvider);

    final metal = getMetalProperties.data!.metals!.firstWhere(
      (element) => element.id == meltId,
      orElse: () => getMetalProperties
          .data!.metals![0], // Fallback in case no match is found
    );
    return Stack(
      children: [
        Center(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: DottedBorder(
            borderType: BorderType.Circle,
            radius: const Radius.circular(12),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: Container(
                width: size,
                height: size,
                decoration: const ShapeDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-0.40, -0.92),
                    end: Alignment(0.4, 0.92),
                    colors: [
                      Colors.white,
                      Color(0x359B8787),
                      Color(0x00755C5C)
                    ],
                  ),
                  shape: OvalBorder(),
                ),
                child: CachedNetworkImage(
                  imageUrl: imgUrl ?? metal.img,
                  fit: BoxFit.cover,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Assets.images.logo.image(
                      height: size * 0.5,
                      width: size * 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        )),
        Positioned(
          bottom: 0,
          right: size >= 57 ? size / 1.3 : 0,
          child: verfly
              ? SvgPicture.asset(
                  Assets.icons.checkVerified.path,
                  height: 23,
                  width: 23,
                )
              : const SizedBox(),
        ),
      ],
    );
  }
}

LinearGradient generateRandomGradient() {
  Color randomColor1 =
      Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(0.8);
  Color randomColor2 =
      Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(0.8);
  Color randomColor3 =
      Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(0.8);

  return LinearGradient(
    begin: const Alignment(-0.40, -0.92),
    end: const Alignment(0.4, 0.92),
    colors: [Colors.white, randomColor1, randomColor2, randomColor3],
  );
}
