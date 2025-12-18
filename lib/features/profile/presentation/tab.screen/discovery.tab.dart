import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';
import 'package:metal/presentation/widgets/settings/edit_field.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/widgets/button/plain.button.dart';
import 'package:metal/route/routes.dart';

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
    final userState = ref.watch(userStateProvider).data;

    return Column(
      children: [
        EditField(
          text: userState?.location?.address ?? "Location",
          floatingLabel: "Location",
          onSubLabel: (value) {},
        ),
        const Gap(20),

        // Communities Section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.metalWhite,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.metalBlack.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.group,
                    color: AppColors.metalPinkColour,
                    size: 20,
                  ),
                  const Gap(8),
                  Text(
                    'Communities',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.metalBrownColourForText,
                    ),
                  ),
                ],
              ),
              const Gap(8),
              Text(
                'Join communities based on your interests and connect with like-minded people.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.metalBrownColourForText.withOpacity(0.7),
                ),
              ),
              const Gap(12),
              PlainButton(
                buttonText: 'Explore Communities',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.communityDiscovery);
                },
                height: 40,
                fontSize: 14,
              ),
            ],
          ),
        ),

        // EditField(
        //   text: userState?.connection_option?.join(",") ??
        //       "What are you looking for in a person?",
        //   floatingLabel: "What are you looking for in a person?",
        //   subLabel: "Edit",
        //   onSubLabel: () {

        //   },
        // ),
        const Gap(20),
      ],
    );
  }
}
