import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/agree.click.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

class MakePayment extends StatelessWidget {
  MakePayment({super.key});
  static const name = 'makePayment';
  static const route = '$name';

  static final GlobalKey<FormState> _form = GlobalKey<FormState>();

  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expireDateController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();
  final TextEditingController _nameOnCardController = TextEditingController();

  final bool _autoValidate = false;
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        bgImage: Assets.images.bg2.path,
        appBarEnabled: false,
        authFlow: true,
        Header: "Make Payment",
        body: Column(
          children: [
            Gap(40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(Assets.images.paymentCard.path),
                Image.asset(Assets.images.stripe.path),
                Image.asset(Assets.images.squareLogo.path)
              ],
            ),
            Gap(40),
            Form(
                key: _form,
                child: Column(
                  children: [
                    EditFormField(
                      floatingLabel: 'Debit Card Number',
                      label: '0000 0000 0000 0000',
                      controller: _cardNumberController,
                      keyboardType: TextInputType.number,
                      // autoValidate: _autoValidate,

                      // validator: EmailValidator.validate(email),
                      radius: 10,
                      // fillColor: AppColors.appGrey,
                    ),
                    Gap(20),
                    Row(
                      children: [
                        Expanded(
                          child: EditFormField(
                            floatingLabel: 'Expiry Date',
                            label: '00/00',
                            controller: _cardNumberController,
                            keyboardType: TextInputType.datetime,
                            // autoValidate: _autoValidate,

                            // validator: EmailValidator.validate(email),
                            radius: 10,
                            // fillColor: AppColors.appGrey,
                          ),
                        ),
                        Gap(20),
                        Expanded(
                          child: EditFormField(
                            floatingLabel: 'CVV',
                            label: '000',
                            controller: _cardNumberController,
                            keyboardType: TextInputType.number,
                            // autoValidate: _autoValidate,

                            // validator: EmailValidator.validate(email),
                            radius: 10,
                            // fillColor: AppColors.appGrey,
                          ),
                        ),
                      ],
                    ),
                    Gap(20),
                    EditFormField(
                      floatingLabel: 'Name On Card',
                      label: 'Type the name on your debit card',
                      controller: _nameOnCardController,
                      keyboardType: TextInputType.name,
                      // autoValidate: _autoValidate,

                      // validator: EmailValidator.validate(email),
                      radius: 10,
                      // fillColor: AppColors.appGrey,
                    ),
                    Gap(20),
                  ],
                )),
            CustomCheckWidget(
              title: 'Auto Renewal',
              initialValue: false,
              onChanged: (bool value) {
                print('Value changed to $value');
              },
            ),
            Gap(20),
            CustomCheckWidget(
              title: "Securely save card details",
              initialValue: false,
              onChanged: (bool value) {
                print('Value changed to $value');
              },
            ),
            Gap(20),
            TextView(
              text:
                  "We use available sparks balance first before other payment options",
              fontSize: 12,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
            ),
            Gap(20),
            BaseButton(
                buttonText: "Pay 5.00 ",
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomDialog(content: _upgreadeDialog(context));
                    },
                  );
                })
          ],
        ));
  }

  Widget _upgreadeDialog(BuildContext context) {
    return Column(
      children: [
        Gap(38.h),
        SvgPicture.asset(
          Assets.icons.meltedMetalsSmileyXEyes.path,
          height: 45,
          width: 45,
        ),
        Gap(15.h),
        TextView(
          text: "Metal Plus Upgrade",
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        Gap(15.h),
        TextView(
          text:
              "Woohoo! You have successfully upgraded to Metal Plus Monthly. Now you have:"
              "1 Month of subscription"
              "Ad-Free for a month"
              "See who read your messages"
              "See previous profile feeds"
              "See profiles you liked/pushed"
              "Send voice note to metals",
          fontSize: 16,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        Gap(38.h),
        BaseButton(buttonText: "Go to dashboard", onPressed: () {}),
        Gap(21.h),
      ],
    );
  }
}
