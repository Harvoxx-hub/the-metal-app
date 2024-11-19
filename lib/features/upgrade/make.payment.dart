import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/agree.click.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

enum PaymentType { metalPlan, Spark, push }

enum PaymentState { success, failed }

class MakePayment extends ConsumerStatefulWidget {
  const MakePayment({
    required this.price,
    required this.paymentType,
    super.key,
  });
  static const name = 'makePayment';
  static const route = name;
  final PaymentType paymentType;
  final double price;

  static final GlobalKey<FormState> _form = GlobalKey<FormState>();

  @override
  ConsumerState<MakePayment> createState() => _MakePaymentState();
}

class _MakePaymentState extends ConsumerState<MakePayment> {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(Assets.images.paymentCard.path),
                Image.asset(Assets.images.stripe.path),
                Image.asset(Assets.images.squareLogo.path)
              ],
            ),
            const Gap(40),
            Form(
                key: MakePayment._form,
                child: Column(
                  children: [
                    EditFormField(
                      floatingLabel: 'Debit Card Number',
                      label: '0000 0000 0000 0000',
                      controller: _cardNumberController,
                      keyboardType: TextInputType.number,
                      radius: 10,
                    ),
                    const Gap(20),
                    Row(
                      children: [
                        Expanded(
                          child: EditFormField(
                            floatingLabel: 'Expiry Date',
                            label: '00/00',
                            controller: _cardNumberController,
                            keyboardType: TextInputType.datetime,
                            radius: 10,
                          ),
                        ),
                        const Gap(20),
                        Expanded(
                          child: EditFormField(
                            floatingLabel: 'CVV',
                            label: '000',
                            controller: _cardNumberController,
                            keyboardType: TextInputType.number,
                            radius: 10,
                          ),
                        ),
                      ],
                    ),
                    const Gap(20),
                    EditFormField(
                      floatingLabel: 'Name On Card',
                      label: 'Type the name on your debit card',
                      controller: _nameOnCardController,
                      keyboardType: TextInputType.name,
                      radius: 10,
                    ),
                    const Gap(20),
                  ],
                )),
            CustomCheckWidget(
              title: 'Auto Renewal',
              initialValue: false,
              onChanged: (bool value) {
                print('Value changed to $value');
              },
            ),
            const Gap(20),
            CustomCheckWidget(
              title: "Securely save card details",
              initialValue: false,
              onChanged: (bool value) {
                print('Value changed to $value');
              },
            ),
            const Gap(20),
            const TextView(
              text:
                  "We use available sparks balance first before other payment options",
              fontSize: 12,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
            ),
            const Gap(20),
            BaseButton(
                //   loading: _subscribeState.isLoading,
                buttonText: "Pay ${widget.price}.00 ",
                onPressed: () {
                  Navigator.pop(context, PaymentState.success);
                })
          ],
        ));
  }
}
