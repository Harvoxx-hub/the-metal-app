import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/features/unmetal/widgets/unmetal_dialog.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';

import 'package:metal/features/home_page/domain/entries/connection.model.dart';

import 'package:metal/features/my.metals/provider/unmelt.user.notifier.dart';
import 'package:metal/features/profile/presentation/widget/edit.field.dart';

import 'package:metal/gen/assets.gen.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/features/settings/presentation/widget/block_user_helper.dart';

class MetalDetailsTab extends ConsumerStatefulWidget {
  const MetalDetailsTab({
    super.key,
    required this.melted,
    required this.userModel,
    required this.connectionModel,
    required this.connectedOn,
    this.isUnmelted = false,
  });
  final UserModel userModel;
  final bool melted;
  final String connectionModel;
  final String connectedOn;
  final bool isUnmelted;
  @override
  ConsumerState<MetalDetailsTab> createState() => _MetalDetailsTabState();
}

class _MetalDetailsTabState extends ConsumerState<MetalDetailsTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              EditField(
                text: "Go to ${widget.userModel.username} metal profile",
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.userProfilePage,
                      arguments: widget.userModel);
                },
                floatingLabel: " View profile",
                suffixIcon: SvgPicture.asset(
                  Assets.icons.meltedMetalsArrowUpRight.path,
                  height: 21,
                  width: 21,
                ),
              ),
              if (widget.melted)
                Column(
                  children: [
                    const Gap(20),
                    EditField(
                      text:
                          "De-melt ${widget.userModel.username}  from your metal list",
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
                                content: _ceMeltDialog(
                                    context, widget.userModel, ref));
                          },
                        );
                      },
                    ),
                    const Gap(20),

                    /// check if user have un-metal
                    if (!widget.isUnmelted)
                      EditField(
                        text:
                            "Un-melt ${widget.userModel.username}  from your metal list",
                        floatingLabel: "Un-metals",
                        suffixIcon: SvgPicture.asset(
                          Assets.icons.meltedMetalsTrash01.path,
                          height: 21,
                          width: 21,
                        ),
                        onTap: () {
                          // Create a minimal ConnectionModel for the notifier
                          final connectionModel = ConnectionModel(
                            connectionId: widget.connectionModel,
                            users: [widget.userModel.id ?? ''],
                            connectedOn: widget.connectedOn,
                          );

                          showDialog(
                            context: context,
                            builder: (context) => UnmetalDialog(
                              otherUser: widget.userModel,
                              connectionModel: connectionModel,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              const Gap(20),
              EditField(
                text: "Block ${widget.userModel.username}  from reaching you",
                floatingLabel: "Block from viewing my profile",
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomDialog(
                          content:
                              _blockDialog(context, widget.userModel, ref));
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
      ),
    );
  }

  Widget _blockDialog(BuildContext context, UserModel data, WidgetRef ref) {
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
          text: "Block  ${data.username} ",
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
            buttonText: "Block  ${data.username}",
            onPressed: () {
              // Close the current dialog
              Navigator.pop(context);

              // Show the enhanced block reason dialog
              showBlockReasonDialog(
                context,
                userId: data.id!,
                username: data.username!,
              );
            }),
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

  Widget _ceMeltDialog(BuildContext context, UserModel data, WidgetRef ref) {
    // ref.watch(unmeltUserProvider(data.id!));
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
          text: "De-melt  ${data.username}",
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        const Gap(15),
        const TextView(
          text: "De-melted metals will have to request to melt with you again",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        const Gap(38),
        BaseButton(
            buttonText: "De-melt  ${data.username}",
            onPressed: () {
              ref
                  .read(demeltUserProvider.notifier)
                  .deMeltUser(widget.connectionModel, widget.userModel.id!);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.dashboardPage,
                (route) => false,
              );
            }),
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
