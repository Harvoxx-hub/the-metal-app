import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/utils/input/validators/validators.dart';
import 'package:metal/features/home_page/provider/get.all.users.notifier.dart';
import 'package:metal/features/settings/provider/block.user.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

import '../domain/entries/all.user.model.dart';

class PostCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            const BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProfilePhoto(
                  verfly: false,
                  size: 40,
                ),
                SizedBox(width: 10.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TextView(
                          text: 'Chioma Cliton_gold',
                        ),
                        SizedBox(width: 5.0),
                        Assets.icons.checkVerified.svg(height: 16),
                      ],
                    ),
                    Text(
                      '22/24/24',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Spacer(),
                    IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      backgroundColor: Colors.white,
                      context: context,
                      builder: (BuildContext context) {
                        return SafeArea(
                          child: Wrap(
                            children: <Widget>[
                              ListTile(
                                title: const Text('Block Metal'),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CustomDialog(
                                          content: _blockDialog(
                                              context, widget.user, ref));
                                    },
                                  );
                                },
                              ),
                              ListTile(
                                  title: const Text('Block and Report'),
                                  onTap: () => showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomDialog(
                                              content: _blockAndReportDialog(
                                                  context, widget.user, ref));
                                        },
                                      )),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.more_vert))
          
              ],
            ),
            const SizedBox(height: 10.0),
            const TextView(
              text:
                  'I term myself an Aluminium because I am light and emotional. I like to be cared for as I have some tendencies to get rusty. It would be great to connect with you! Let’s melt!',
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                BaseButton(
                  onPressed: () {},
                  width: 110,
                  height: 32,
                  fontSize: 15,
                  buttonText: "View Metal",
                ),
                Spacer(),
                Image.asset(
                  Assets.images.melt.path,
                  scale: 2,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

    Widget _blockDialog(BuildContext context, ALLUserModel data, WidgetRef ref) {
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
              ref
                  .read(blockUserProvider.notifier)
                  .BlockUser(data.username!, data.id!);
              ref.read(getAllUserProvider.notifier).removeUser(data.id!);
              Navigator.pop(context);
              Navigator.pop(context);
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

  Widget _blockAndReportDialog(
      BuildContext context, ALLUserModel data, WidgetRef ref) {
    TextEditingController _controller = TextEditingController();
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
          text: "Block and Report  ${data.username} ",
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
        EditFormField(
          floatingLabel: '',
          label: 'Reason for Reporting ',
          controller: _controller,
          keyboardType: TextInputType.name,
          minLines: 5,
          maxLines: 5,
          validator: Validators.validateString(),
          autoValidate: true,
        ),
        const Gap(38),
        BaseButton(
            buttonText: "Block ${data.username}",
            onPressed: () {
              ref
                  .read(blockUserProvider.notifier)
                  .BlockUser(data.username!, data.id!);
              ref.read(getAllUserProvider.notifier).removeUser(data.id!);
              Navigator.pop(context);
              Navigator.pop(context);
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
