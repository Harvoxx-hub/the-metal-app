import 'package:flutter/material.dart';

import 'package:responsive_framework/responsive_framework.dart';
import 'package:shimmer/shimmer.dart';

enum ShimmerItemType {
  single,
  list,
  responsive,
}

class CustomShimmerLoader extends StatelessWidget {
  const CustomShimmerLoader({
    super.key,
    required this.itemType,
    required this.loaderWidget,
  });
  final ShimmerItemType itemType;
  final Widget loaderWidget;

  @override
  Widget build(BuildContext context) {
    switch (itemType) {
      case ShimmerItemType.single:
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade100,
          child: loaderWidget,
        );
      case ShimmerItemType.list:
        return ListView.separated(
          padding: EdgeInsets.only(top: 10),
          shrinkWrap: true,
          itemBuilder: (context, index) => Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade100,
            child: loaderWidget,
          ),
          separatorBuilder: (context, index) => SizedBox(
            height: 10,
          ),
          itemCount: 4,
        );
      case ShimmerItemType.responsive:
        return GridView.builder(
          padding: EdgeInsets.only(top: 10),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: ResponsiveValue<int>(
              context,
              defaultValue: 2,
              conditionalValues: [
                Condition.smallerThan(name: MOBILE, value: 2),
                Condition.largerThan(name: TABLET, value: 3),
              ],
            ).value!,
            childAspectRatio: 0.8,
          ),
          itemCount: 10,
          itemBuilder: (context, index) {
            return Shimmer.fromColors(
              baseColor: Colors.grey.shade400,
              highlightColor: Colors.grey.shade300,
              child: loaderWidget,
            );
          },
        );
    }
  }
}
