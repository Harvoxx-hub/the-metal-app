import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/domain/entities/user_dto.dart';
import 'package:metal/presentation/widgets/settings/edit_field.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/presentation/widgets/settings/block_user_helper.dart';
import 'package:metal/res/colors/cr_colors.dart';

/// Metal details tab showing actions for a connection
class MetalDetailsTabNew extends ConsumerStatefulWidget {
  const MetalDetailsTabNew({
    super.key,
    required this.isConnected,
    required this.user,
    required this.connectionId,
    required this.connectedOn,
    this.isAnonymous = true,
  });

  final UserDto user;
  final bool isConnected;
  final String connectionId;
  final String connectedOn;
  final bool isAnonymous;

  @override
  ConsumerState<MetalDetailsTabNew> createState() => _MetalDetailsTabNewState();
}

class _MetalDetailsTabNewState extends ConsumerState<MetalDetailsTabNew> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Username
            if (widget.user.username != null) ...[
              _buildInfoField(
                label: 'Username',
                value: '@${widget.user.username}',
              ),
              const Gap(20),
            ],

            // Gender
            if (widget.user.gender != null) ...[
              _buildInfoField(
                label: 'Gender',
                value: widget.user.gender!,
              ),
              const Gap(20),
            ],

            // Age
            if (widget.user.dob != null && widget.user.dob!.isNotEmpty) ...[
              _buildInfoField(
                label: 'Age Range',
                value: _calculateAgeDisplay(widget.user.dob!),
              ),
              const Gap(20),
            ],

            // Metal
            if (widget.user.metal != null) ...[
              _buildInfoField(
                label: 'Metal that represents your value',
                value: widget.user.metal!,
              ),
              const Gap(20),
            ],

            // Passion/Interests
            if (widget.user.passion != null && widget.user.passion!.isNotEmpty) ...[
              _buildInfoField(
                label: 'Passion/Interests',
                value: widget.user.passion!.join(', '),
              ),
              const Gap(20),
            ],

            // Marital Status
            if (widget.user.extraData?.marriageStatus != null) ...[
              _buildInfoField(
                label: 'Marital status',
                value: widget.user.extraData!.marriageStatus!,
              ),
              const Gap(20),
            ],

            // Religion
            if (widget.user.extraData?.religion != null) ...[
              _buildInfoField(
                label: 'Religion',
                value: widget.user.extraData!.religion!,
              ),
              const Gap(20),
            ],

            // Profession
            if (widget.user.extraData?.profession != null) ...[
              _buildInfoField(
                label: 'Profession',
                value: widget.user.extraData!.profession!,
              ),
              const Gap(20),
            ],

            // Interested in
            if (widget.user.connectionOption != null && widget.user.connectionOption!.isNotEmpty) ...[
              _buildInfoField(
                label: 'Interested in',
                value: widget.user.connectionOption!.join(', '),
              ),
              const Gap(20),
            ],

            const Gap(40),
            
            // Block User Option at the bottom
            EditField(
              text: "Block ${widget.user.username ?? 'User'} from reaching you",
              floatingLabel: "Block from viewing my profile",
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomDialog(
                      content: _buildBlockDialog(context),
                    );
                  },
                );
              },
              suffixIcon: SvgPicture.asset(
                Assets.icons.meltedMetalsSmileyXEyes.path,
                height: 21,
                width: 21,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build an info field similar to the images - label on top, value in a white box
  Widget _buildInfoField({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextView(
          text: label,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.metalBrownColourForText,
        ),
        const Gap(8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.metalWhite,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: AppColors.metalButtonStroke,
              width: 1.0,
            ),
          ),
          child: TextView(
            text: value,
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.metalBrownColourForText,
          ),
        ),
      ],
    );
  }

  /// Calculate age display from date of birth
  String _calculateAgeDisplay(String dobString) {
    try {
      final dob = DateTime.parse(dobString);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return '$age years';
    } catch (e) {
      return 'Age not available';
    }
  }

  Widget _buildBlockDialog(BuildContext context) {
    return Column(
      children: [
        const Gap(38),
        SvgPicture.asset(
          Assets.icons.meltedMetalsSmileyXEyes.path,
          height: 45,
          width: 45,
        ),
        const Gap(15),
        TextView(
          text: "Block ${widget.user.username ?? 'User'}",
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        const Gap(15),
        const TextView(
          text:
              "Blocked metals cannot call or send you messages. This Metal will not be notified",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        const Gap(38),
        BaseButton(
          buttonText: "Block ${widget.user.username ?? 'User'}",
          onPressed: () {
            final username = widget.user.username ?? 'User';

            Navigator.pop(context);
            showBlockReasonDialog(
              context,
              userId: widget.user.id,
              username: username,
            );
          },
        ),
        const Gap(23),
        TextView(
          text: "Cancel",
          fontSize: 16,
          fontWeight: FontWeight.w500,
          onTap: () => Navigator.pop(context),
        ),
        const Gap(21),
      ],
    );
  }

}
