import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/core/utils/input/validators/validators.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';

import 'package:metal/features/sparks_page/provider/buy.spark.notifier.dart';
import 'package:metal/features/sparks_page/screens/widget/single.spark.header.card.dart';
import 'package:metal/features/upgrade/payment.config.dart';

import 'package:metal/features/upgrade/payment.core.dart';
import 'package:metal/gen/assets.gen.dart';

import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

class BuySpark extends ConsumerWidget {
  BuySpark({super.key});
  static const name = 'buySpark';
  static const route = name;
  static final GlobalKey<FormState> _form = GlobalKey<FormState>();

  final TextEditingController _sparkNumberController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buySpark = ref.watch(buySparkProvider);
    ref.listen<BuysparkState>(buySparkProvider, (prev, current) {
      if (current.isSuccess) {
        Navigator.pop(context);
      }
    });
    return BaseScreen(
        appBarState: AppBarState.BackWithHeader,
        Header: "Buy Spark",
        body: SingleChildScrollView(
            child: Stack(children: [
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
                      children: [
                        SingleSparkHeaderCard(
                          title: "Buy \n Sparks",
                          path: Assets.images.buySpark.path,
                        ),
                        const Gap(15),
                        EditFormField(
                          floatingLabel: 'Number of sparks to buy',
                          label: 'Type number of sparks to buy',
                          controller: _sparkNumberController,
                          keyboardType: TextInputType.number,
                          validator: Validators.validateAmount(),

                          prefixWidget: SvgPicture.asset(
                            Assets.icons.iconlyLightProfile.path,
                            height: 24,
                            width: 24,
                          ),
                          // validator: EmailValidator.validate(email),
                          radius: 10,
                        ),
                        const Gap(15),
                        EditFormField(
                          floatingLabel: 'Dollar equivalence',
                          label: 'Dollar equivalence',
                          controller: _sparkNumberController,
                          keyboardType: TextInputType.name,
                          enabled: false,
                          prefixWidget: SvgPicture.asset(
                            Assets.icons.star05.path,
                            height: 24,
                            width: 24,
                          ),
                          radius: 10,
                        ),
                        const Gap(15),
                        BaseButton(
                          buttonText: "Buy",
                          loading: buySpark.isLoading,
                          onPressed: () {
                            if (_form.currentState!.validate()) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CustomDialog(
                                    content: confirmationDialog(context,
                                        ammount: _sparkNumberController.text,
                                        ref: ref),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  )))
        ])));
  }

  Widget confirmationDialog(BuildContext context,
      {String? ammount, WidgetRef? ref}) {
    final userData = ref!.watch(authProvider).data;
    return Column(
      children: [
        Gap(38),
        Image.asset(Assets.images.eyesEmoji.path),
        Gap(15),
        const TextView(
          text: "Confirmation",
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        Gap(15),
        TextView(
          text:
              "Confirm you want to buy *$ammount sparks* with Dollar equivalence of *$ammount*",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        Gap(38),
        BaseButton(
            buttonText: "Confirm",
            onPressed: () {
              Navigator.pop(context);
              // StripePaymentHandle().stripeMakePayment(
              //     context: context,
              //     amount: ammount.toString(),
              //     userModel: userData!,
              //     onSuccess: () {
              //       ref.read(buySparkProvider.notifier).buySpark(
              //             amount: double.parse(ammount!),
              //             numberOfSpark: double.parse(ammount),
              //           );
              //     });
            }),
        Gap(23),
        TextView(
          text: "Not Now",
          fontSize: 16,
          fontWeight: FontWeight.w500,
          onTap: () => Navigator.pop(context),
        ),
        Gap(21),
      ],
    );
  }

  void onGooglePayResult(paymentResult) {
    debugPrint(paymentResult.toString());
  }

  void onApplePayResult(paymentResult) {
    debugPrint(paymentResult.toString());
  }
}
