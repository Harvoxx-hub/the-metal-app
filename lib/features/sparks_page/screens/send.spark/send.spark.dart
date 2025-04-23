import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/core/utils/input/validators/validators.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/home_page/provider/get.users.by.query.notifier.dart';

import 'package:metal/features/sparks_page/provider/send.spark.notifier.dart';
import 'package:metal/features/sparks_page/screens/widget/single.spark.header.card.dart';

import 'package:metal/gen/assets.gen.dart';

import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

class SendSpark extends ConsumerStatefulWidget {
  const SendSpark({super.key, this.recipient});
  static const name = 'sendSpark';
  static const route = name;

  final UserModel? recipient;

  @override
  ConsumerState<SendSpark> createState() => _SendSparkState();
}

class _SendSparkState extends ConsumerState<SendSpark> {
  final TextEditingController _userNameController = TextEditingController();

  final TextEditingController _sparkNumberController = TextEditingController();

  final TextEditingController _transferFeeController = TextEditingController();

  final TextEditingController _totalSparkController = TextEditingController();
  static final GlobalKey<FormState> _form = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userNameController.addListener(_userNameListener);
      if (widget.recipient != null) {
        _userNameController.text = widget.recipient!.username ?? '';
        selectedUserId = widget.recipient!.id ?? '';
      }
    });
  }

  void _userNameListener() {
    if (_userNameController.text != "") {
      ref
          .read(getUserByNameProvider.notifier)
          .getUserByquery(query: _userNameController.text);
    }
  }

  @override
  void dispose() async {
    _userNameController.removeListener(_userNameListener);

    super.dispose();
  }

  String selectedUserId = "";
  @override
  Widget build(BuildContext context) {
    final users = ref.watch(getUserByNameProvider);
    final sendSpark = ref.watch(sendSparkProvider);
    final currentUser = ref.watch(authProvider).data;
    ref.listen<SendsparkState>(sendSparkProvider, (prev, current) {
      if (current.isSuccess) {
        confirm(context);
      }
    });

    return BaseScreen(
        appBarState: AppBarState.BackWithHeader,
        Header: "Send Spark",
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                        color: AppColors.metalPinkColour,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(35),
                          bottomRight: Radius.circular(35),
                        )),
                  ),

                  // This container is for the background image decoration
                  Container()
                ],
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                        color: AppColors.metalWhite,
                        borderRadius: BorderRadius.circular(13)),
                    child: Form(
                      key: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleSparkHeaderCard(
                            title: "Send \nSparks",
                            path: Assets.images.sendSpark.path,
                          ),
                          const Gap(15),
                          EditFormField(
                            floatingLabel: 'I want to send Sparks to',
                            label: 'Type name of recipient',
                            controller: _userNameController,
                            keyboardType: TextInputType.name,
                            prefixWidget: SvgPicture.asset(
                              Assets.icons.iconlyLightProfile.path,
                              height: 24,
                              width: 24,
                            ),
                            validator: Validators.validateString(),
                            radius: 10,
                          ),
                          users.data == null
                              ? const Gap(15)
                              : Wrap(
                                  alignment: WrapAlignment.start,
                                  children: [
                                    for (var user in users.data!)
                                      //TODO: Add a condition to check if the user is the current user
                                      // _currentUser.
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextView(
                                            text: "@ ${user["username"]}",
                                            onTap: () {
                                              _userNameController.text =
                                                  user["username"];
                                              selectedUserId = user["id"];
                                            }),
                                      )
                                  ],
                                ),
                          const Gap(15),
                          EditFormField(
                            floatingLabel: 'Number of Sparks to send',
                            label: 'Number of sparks to send',
                            controller: _sparkNumberController,
                            keyboardType: TextInputType.number,
                            prefixWidget: SvgPicture.asset(
                              Assets.icons.star05.path,
                              height: 24,
                              width: 24,
                            ),
                            radius: 10,
                            validator: Validators.validateAmount(),
                          ),
                          const Gap(15),
                          // EditFormField(
                          //   floatingLabel: 'Transfer Fee',
                          //   label: '0.00',
                          //   controller: _transferFeeController,
                          //   keyboardType: TextInputType.number,
                          //   prefixWidget: SvgPicture.asset(
                          //     Assets.icons.star05.path,
                          //     height: 24,
                          //     width: 24,
                          //   ),
                          //   radius: 10,
                          //   enabled: false,
                          //   // validator: Validators.validateAmount(),
                          // ),
                          // const Gap(15),
                          // EditFormField(
                          //   floatingLabel: 'Total Sparks used ',
                          //   label: '0.00',
                          //   controller: _totalSparkController,
                          //   keyboardType: TextInputType.number,
                          //   prefixWidget: SvgPicture.asset(
                          //     Assets.icons.star05.path,
                          //     height: 24,
                          //     width: 24,
                          //   ),
                          //   radius: 10,
                          //   enabled: false,
                          //   //  validator: Validators.validateAmount(),
                          // ),
                          // const Gap(15),
                          BaseButton(
                            buttonText: "Send spark",
                            loading: sendSpark.isLoading,
                            onPressed: () {
                              if (_form.currentState!.validate() &&
                                  selectedUserId != "") {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CustomDialog(
                                      content: confirmationDialog(context),
                                    );
                                  },
                                );
                              } else {
                                Fluttertoast.showToast(
                                    msg:
                                        "Error: Please fill all fields and select a user to send to.",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 3,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ))
            ],
          ),
        ));
  }

  Widget confirmationDialog(
    BuildContext context,
  ) {
    return Column(
      children: [
        const Gap(38),
        Image.asset(Assets.images.eyesEmoji.path),
        const Gap(15),
        const TextView(
          text: "Confirmation",
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        const Gap(15),
        TextView(
          text:
              "Confirm you want to send *${_sparkNumberController.text} * to *@${_userNameController.text}",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        const Gap(38),
        BaseButton(
            buttonText: "Confirm",
            onPressed: () {
              Navigator.pop(context);
              ref.read(sendSparkProvider.notifier).sendSpark(
                  receiverId: selectedUserId,
                  numberOfSparks: double.parse(_sparkNumberController.text),
                  receiverName: _userNameController.text);
            }),
        const Gap(23),
        TextView(
            text: "Not Now",
            fontSize: 16,
            fontWeight: FontWeight.w500,
            onTap: () => Navigator.pop(context)),
        const Gap(21),
      ],
    );
  }

  Widget successDialog(BuildContext context) {
    return Column(
      children: [
        const Gap(38),
        Image.asset(Assets.images.partpoppercelebrationemoji.path),
        const Gap(15),
        const TextView(
          text: "Success",
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        const Gap(15),
        TextView(
          text:
              "*${_sparkNumberController.text} sparks* successfully sent to *@${_userNameController.text}*",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        const Gap(58),
        BaseButton(
            buttonText: "Go back to dashboard",
            onPressed: () {
              AppRoutes.navigateToSparks(context);
            })
      ],
    );
  }

  void confirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          content: successDialog(context),
        );
      },
    );
  }
}
