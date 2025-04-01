import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/core/utils/screen.size.dart';

import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/sparks_page/provider/redeem.referral.notifier.dart';
import 'package:metal/features/sparks_page/screens/widget/single.spark.header.card.dart';

import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:share_plus/share_plus.dart';
import 'package:metal/res/colors/cr_colors.dart';

import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/button/outiline.button.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/core/utils/validators.dart';

class ReferEarnSpark extends ConsumerStatefulWidget {
  const ReferEarnSpark({super.key});
  static const name = 'referEarnSpark';
  static const route = name;

  @override
  ConsumerState<ReferEarnSpark> createState() => _ReferEarnSparkState();
}

class _ReferEarnSparkState extends ConsumerState<ReferEarnSpark> {
  final TextEditingController _referralCodeController = TextEditingController();
  bool _showRedeemForm = false;

  @override
  void dispose() {
    _referralCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userdata = ref.watch(authProvider).data;
    final redeemState = ref.watch(redeemReferralProvider);

    // Listen for redemption state changes
    ref.listen(redeemReferralProvider, (prev, current) {
      if (current.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Referral code redeemed successfully!')),
        );
        // Refresh user data to show updated spark balance
        ref.read(authProvider.notifier).getUpdatedUser();
        setState(() {
          _showRedeemForm = false;
          _referralCodeController.clear();
        });
      } else if (current.isError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(current.errorMessage ?? 'Failed to redeem code')),
        );
      }
    });

    return BaseScreen(
        appBarState: AppBarState.BackWithHeader,
        Header: "Refer & Earn",
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
                    child: Column(
                      children: [
                        SingleSparkHeaderCard(
                          title: "Refer \n& Earn",
                          path: Assets.images.refer.path,
                        ),
                        Gap(getDeviceHeight(context) * 0.05),

                        // Redeem Referral Button
                        if (!_showRedeemForm)
                          OutilineButton(
                            buttonText: "Redeem a Referral Code",
                            onPressed: () {
                              setState(() {
                                _showRedeemForm = true;
                              });
                            },
                          ),

                        // Redeem Form
                        if (_showRedeemForm) ...[
                          const TextView(
                            text: "Enter a referral code to get bonus sparks",
                            fontSize: 14,
                          ),
                          const Gap(10),
                          EditFormField(
                            floatingLabel: 'Referral Code',
                            label: 'Enter code',
                            controller: _referralCodeController,
                            keyboardType: TextInputType.text,
                            radius: 10,
                            validator: Validators.validateNotEmpty(),
                          ),
                          const Gap(10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              OutilineButton(
                                buttonText: "Cancel",
                                width: 120,
                                onPressed: () {
                                  setState(() {
                                    _showRedeemForm = false;
                                    _referralCodeController.clear();
                                  });
                                },
                              ),
                              BaseButton(
                                buttonText: "Redeem",
                                width: 120,
                                loading: redeemState.isLoading,
                                onPressed: () {
                                  if (_referralCodeController.text.isNotEmpty) {
                                    ref
                                        .read(redeemReferralProvider.notifier)
                                        .redeemReferralCode(
                                          _referralCodeController.text.trim(),
                                        );
                                  }
                                },
                              ),
                            ],
                          ),
                          const Gap(15),
                        ],

                        Gap(getDeviceHeight(context) * 0.05),
                        Container(
                          width: 200,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              color: AppColors.metalTabBg,
                              borderRadius: BorderRadius.circular(5)),
                          child: Column(
                            children: [
                              const TextView(
                                text: "Your Referal Code",
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              const Gap(8),
                              TextView(
                                text: userdata!.referralCode!,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              )
                            ],
                          ),
                        ),
                        Gap(getDeviceHeight(context) * 0.05),
                        const TextView(
                          text:
                              "Share your code with friends to earn bonus sparks!",
                          fontSize: 14,
                          textAlign: TextAlign.center,
                        ),
                        const Gap(15),
                        BaseButton(
                          buttonText: "Invite to Metal",
                          onPressed: () {
                            Share.share(
                                "Hey there! 👋 I'm using Metal App Plus, if you sign up using my referral code and download the app from Https://metalapp.com, we both get bonus sparks: ${userdata.referralCode}. Give it a try and let's explore Metal App together! 🚀",
                                subject: 'Join me at Metal');
                          },
                        ),
                        const Gap(16),
                        OutilineButton(
                          buttonText: "Copy invite Code ",
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                    text:
                                        "Your Referal Code: ${userdata.referralCode}"))
                                .then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Your have copied your Referal Code')));
                            });
                          },
                        ),
                      ],
                    ),
                  ))
            ],
          ),
        ));
  }
}
