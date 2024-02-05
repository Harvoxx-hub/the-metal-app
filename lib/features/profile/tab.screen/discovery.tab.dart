import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/profile/widget/edit.field.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:range_slider_flutter/range_slider_flutter.dart';

class DiscoveryTab extends ConsumerStatefulWidget {
  const DiscoveryTab({super.key});

  @override
  ConsumerState<DiscoveryTab> createState() => _DiscoveryTabState();
}

class _DiscoveryTabState extends ConsumerState<DiscoveryTab> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _lookingeController = TextEditingController();
  @override
  void didChangeDependencies() {
    _locationController.text = "My current location";
    _lookingeController.text = "Marriage, Romance";

    super.didChangeDependencies();
  }

  double _value = 0;

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authProvider).data;
    return Column(
      children: [
        EditField(
          text: userState?.location?.address ?? "Location",
          floatingLabel: "Location",
          subLabel: "Edit",
          onSubLabel: () {
            // context.pushNamed(UpdateEmailPage.name);
          },
        ),
        Gap(20.h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextView(
              text: "Maximum distance",
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
              color: AppColors.metalBrownColourForText,
              textAlign: TextAlign.left,
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
              height: 73,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                      color: AppColors.metalButtonStroke, width: 1.0)),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0, top: 4.0),
                      child: TextView(
                        text: "${_value.toInt()} km",
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                        color: AppColors.metalBrownColourForText,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  Slider(
                    min: 0.0,
                    activeColor: AppColors.metalPinkColour,
                    inactiveColor: Colors.grey.withOpacity(0.5),
                    max: 100.0,
                    value: _value,
                    onChanged: (value) {
                      setState(() {
                        _value = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        Gap(20.h),
        EditField(
          text: userState?.connection_option?.join(",") ??
              "What are you looking for in a person?",
          floatingLabel: "What are you looking for in a person?",
          subLabel: "Edit",
          onSubLabel: () {
            // context.pushNamed(UpdateEmailPage.name);
          },
        ),
        Gap(20.h),
      ],
    );
  }
}
