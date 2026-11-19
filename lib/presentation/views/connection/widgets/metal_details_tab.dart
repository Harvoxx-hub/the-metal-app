import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:metal/domain/entities/user_dto.dart';
import 'package:metal/presentation/viewmodels/connection/connection_providers.dart';
import 'package:metal/presentation/viewmodels/profile/metal_properties_provider.dart';
import 'package:metal/presentation/viewmodels/user/user_profile_viewmodel_providers.dart';
import 'package:metal/presentation/widgets/settings/edit_field.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/presentation/widgets/settings/block_user_helper.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';

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

            // Metal (resolve ID to name via metal properties)
            if (widget.user.metal != null) ...[
              _buildInfoField(
                label: 'Metal that represents your value',
                value: _getMetalDisplayName(ref),
              ),
              const Gap(20),
            ],

            // Passion/Interests
            if (widget.user.passion != null &&
                widget.user.passion!.isNotEmpty) ...[
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
            if (widget.user.connectionOption != null &&
                widget.user.connectionOption!.isNotEmpty) ...[
              _buildInfoField(
                label: 'Interested in',
                value: widget.user.connectionOption!.join(', '),
              ),
              const Gap(20),
            ],

            const Gap(24),
            if (widget.isConnected) ...[
              EditField(
                text: "Demelt ${widget.user.username ?? 'User'}",
                floatingLabel: "Demelt ${widget.user.username ?? 'User'}",
                onTap: () => _showDemeltConfirmation(context),
                suffixIcon: SvgPicture.asset(
                  Assets.icons.meltedMetalsSmileyXEyes.path,
                  height: 21,
                  width: 21,
                ),
              ),
            ],
            const Gap(24),
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

  /// Resolve user's metal ID to display name using metal properties; fallback to ID if not found.
  String _getMetalDisplayName(WidgetRef ref) {
    final metalId = widget.user.metal!;
    final metalProperties = ref.watch(metalPropertiesProvider);
    if (metalProperties.isLoading || metalProperties.data?.metals == null) {
      return metalId;
    }
    final metals = metalProperties.data!.metals!;
    if (metals.isEmpty) return metalId;
    try {
      final metal = metals.firstWhere((e) => e.id == metalId);
      return metal.title;
    } catch (_) {
      return metalId;
    }
  }

  /// Calculate age display from date of birth.
  /// Supports ISO (2000-04-03) and slash format (04/03/2000 as dd/MM/yyyy).
  String _calculateAgeDisplay(String dobString) {
    final dob = _parseDob(dobString);
    if (dob == null) return 'Age not available';
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return '$age years';
  }

  /// Parse DOB from ISO (2000-04-03) or slash format (04/03/2000 as dd/MM/yyyy = 4 Mar 2000).
  DateTime? _parseDob(String dobString) {
    final trimmed = dobString.trim();
    if (trimmed.isEmpty) return null;
    try {
      return DateTime.parse(trimmed);
    } catch (_) {
      // Try dd/MM/yyyy or MM/dd/yyyy (e.g. 04/03/2000)
      final parts = trimmed.split('/');
      if (parts.length != 3) return null;
      final a = int.tryParse(parts[0].trim());
      final b = int.tryParse(parts[1].trim());
      final c = int.tryParse(parts[2].trim());
      if (a == null || b == null || c == null) return null;
      // Assume dd/MM/yyyy (day/month/year)
      if (a > 31) return null; // first part is year (yyyy/dd/MM or yyyy/MM/dd)
      if (b > 12) return null; // second part must be month
      if (c < 100) return null; // third part must be 4-digit year
      return DateTime(c, b, a);
    }
  }

  /// Show confirmation then unmelt (remove connection) from this user
  Future<void> _showDemeltConfirmation(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove connection?'),
        content: Text(
          'If you DEMELT, you and ${widget.user.username ?? 'this user'} will no longer be connected. They will no longer see you in their connections.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('DEMELT', style: TextStyle(color: AppColors.metalRed)),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    try {
      final repository = ref.read(connectionRepositoryProvider);
      final result = await repository.unmeltUser(widget.user.id);
      if (!context.mounted) return;
      if (result.isSuccess) {
        ref.read(connectionViewModelProvider.notifier).refresh();
        ref
            .read(userProfileViewModelProvider(widget.user.id).notifier)
            .refresh();
        Fluttertoast.showToast(msg: 'Connection removed');
        // Navigate back to dashboard home so user sees updated connections
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.dashboardPage,
          (route) => false,
          arguments: 0, // Home tab
        );
      } else {
        Fluttertoast.showToast(
            msg: result.errorMessage ?? 'Failed to remove connection');
      }
    } catch (e) {
      if (context.mounted) {
        Fluttertoast.showToast(msg: 'Failed to remove connection');
      }
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
