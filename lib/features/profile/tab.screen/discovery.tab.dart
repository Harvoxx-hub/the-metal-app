import 'package:dartx/dartx.dart';
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
          
          },
        ),
        Gap(20.h),
      
        EditField(
          text: userState?.connection_option?.join(",") ??
              "What are you looking for in a person?",
          floatingLabel: "What are you looking for in a person?",
          subLabel: "Edit",
          onSubLabel: () {
       
          },
        ),
        Gap(20.h),
      ],
    );
  }
}
