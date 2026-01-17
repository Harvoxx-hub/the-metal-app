import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/domain/entities/user_dto.dart';
import 'package:metal/presentation/viewmodels/connection/connection_providers.dart';
import 'package:metal/presentation/widgets/settings/edit_field.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/presentation/widgets/settings/block_user_helper.dart';

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
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // View Profile
            EditField(
              text: "Go to ${widget.user.username ?? 'User'} metal profile",
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.userProfile,
                  arguments: widget.user.id,
                );
              },
              floatingLabel: "View profile",
              suffixIcon: SvgPicture.asset(
                Assets.icons.meltedMetalsArrowUpRight.path,
                height: 21,
                width: 21,
              ),
            ),

            // Show melt-related options only if connected
            if (widget.isConnected) ...[
              const Gap(20),
              // De-melt option
              EditField(
                text:
                    "De-melt ${widget.user.username ?? 'User'} from your metal list",
                floatingLabel: "Remove from my list of metals",
                suffixIcon: SvgPicture.asset(
                  Assets.icons.meltedMetalsTrash01.path,
                  height: 21,
                  width: 21,
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomDialog(
                        content: _buildDeMeltDialog(context),
                      );
                    },
                  );
                },
              ),

              // Un-melt option (only if not yet unmelted/anonymous)
              if (widget.isAnonymous) ...[
                const Gap(20),
                EditField(
                  text:
                      "Un-melt ${widget.user.username ?? 'User'} from your metal list",
                  floatingLabel: "Un-metals",
                  suffixIcon: SvgPicture.asset(
                    Assets.icons.meltedMetalsTrash01.path,
                    height: 21,
                    width: 21,
                  ),
                  onTap: () {
                    _showUnmeltDialog(context);
                  },
                ),
              ],
            ],

            const Gap(20),
            // Block option
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

  Widget _buildDeMeltDialog(BuildContext context) {
    return Column(
      children: [
        const Gap(38),
        SvgPicture.asset(
          Assets.icons.meltedMetalsTrash01.path,
          height: 45,
          width: 45,
        ),
        const Gap(15),
        TextView(
          text: "De-melt ${widget.user.username ?? 'User'}",
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        const Gap(15),
        const TextView(
          text:
              "De-melted metals will have to request to melt with you again",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        const Gap(38),
        BaseButton(
          buttonText: "De-melt ${widget.user.username ?? 'User'}",
          onPressed: () async {
            final success = await ref
                .read(meltActionProvider.notifier)
                .unmeltUser(widget.user.id);

            if (!mounted) return;

            if (success) {
              // Refresh connections list
              ref.read(connectionViewModelProvider.notifier).refresh();

              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.dashboardPage,
                (route) => false,
              );
            } else {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to de-melt user'),
                  backgroundColor: Colors.red,
                ),
              );
            }
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

  void _showUnmeltDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        content: Column(
          children: [
            const Gap(38),
            SvgPicture.asset(
              Assets.icons.meltedMetalsTrash01.path,
              height: 45,
              width: 45,
            ),
            const Gap(15),
            TextView(
              text: "Un-melt ${widget.user.username ?? 'User'}",
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            const Gap(15),
            const TextView(
              text:
                  "Un-melting will reveal your identity to this user. Are you sure you want to continue?",
              fontSize: 16,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w400,
            ),
            const Gap(38),
            BaseButton(
              buttonText: "Un-melt",
              onPressed: () {
                // TODO: Implement unmelt (reveal identity) functionality
                Navigator.pop(context);
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
        ),
      ),
    );
  }
}
