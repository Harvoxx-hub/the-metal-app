import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/pages/authentication/models/passion.card.model.dart';
import 'package:metal/pages/authentication/presentation/home.address/location.dart';
import 'package:metal/pages/authentication/presentation/widget/create.profile.header2.dart';
import 'package:metal/utils/screen.size.dart';
import 'package:metal/widgets/agree.click.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/dropdown/metal.dropdown.dart';
import 'package:metal/widgets/text.field/text.field.dart';
import 'package:metal/widgets/text_views.dart';

import '../widget/passions.card.dart';

class HomeAddressPage extends ConsumerStatefulWidget {
  HomeAddressPage({Key? key}) : super(key: key);
  static const name = 'homeAdress';
  static const route = '$name';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _HomeAddressPageState();
}

class _HomeAddressPageState extends ConsumerState<HomeAddressPage> {
  static final GlobalKey<FormState> _form = GlobalKey<FormState>();

  final TextEditingController _apartmentNumberController =
      TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _streetNameController = TextEditingController();

  final TextEditingController _townController = TextEditingController();

  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        bgImage: Assets.images.bg2.path,
        appBarEnabled: false,
        Header: 'House Address',
        authFlow: true,
        body: SingleChildScrollView(
            child: Column(
          children: [
            CreateProfileHeader2(
                path: Assets.images.homeAddress.path,
                title: "Let us know your address",
                subtitle:
                    "Select the information you want us to exclude from your feed and the Metals that reside in that address "),
            Gap(26.h),
            Form(
                key: _form,
                child: Column(
                  children: [
                    EditFormField(
                      floatingLabel: 'Apartment number',
                      label: 'Type here...',
                      controller: _apartmentNumberController,
                      keyboardType: TextInputType.number,
                      suffixWidget: CustomCheckWidget(
                        initialValue: false,
                        onChanged: (bool value) {
                          print('Value changed to $value');
                        },
                      ),

                      // validator: EmailValidator.validate(email),
                      radius: 10,
                      // fillColor: AppColors.appGrey,
                    ),
                    Gap(16.h),
                    EditFormField(
                      floatingLabel: 'House number',
                      label: 'Type here...',
                      controller: _houseNumberController,
                      keyboardType: TextInputType.number,
                      radius: 10,
                      suffixWidget: CustomCheckWidget(
                        initialValue: false,
                        onChanged: (bool value) {
                          print('Value changed to $value');
                        },
                      ),
                    ),
                    Gap(16.h),
                    EditFormField(
                      floatingLabel: 'Street name',
                      label: 'Type here...',
                      controller: _streetNameController,
                      keyboardType: TextInputType.name,
                      radius: 10,
                      suffixWidget: CustomCheckWidget(
                        initialValue: false,
                        onChanged: (bool value) {
                          print('Value changed to $value');
                        },
                      ),
                    ),
                    Gap(16.h),
                    EditFormField(
                      floatingLabel: 'Town',
                      label: 'Type here...',
                      controller: _townController,
                      keyboardType: TextInputType.name,
                      radius: 10,
                      suffixWidget: CustomCheckWidget(
                        initialValue: false,
                        onChanged: (bool value) {
                          print('Value changed to $value');
                        },
                      ),
                    ),
                    Gap(16.h),
                    EditFormField(
                      floatingLabel: 'State',
                      label: 'Type here...',
                      controller: _stateController,
                      keyboardType: TextInputType.name,
                      radius: 10,
                      suffixWidget: CustomCheckWidget(
                        initialValue: false,
                        onChanged: (bool value) {
                          print('Value changed to $value');
                        },
                      ),
                    ),
                    Gap(16.h),
                    EditFormField(
                      floatingLabel: 'Country',
                      label: 'Type here...',
                      controller: _countryController,
                      keyboardType: TextInputType.name,
                      radius: 10,
                      suffixWidget: CustomCheckWidget(
                        initialValue: false,
                        onChanged: (bool value) {
                          print('Value changed to $value');
                        },
                      ),
                    ),
                    Gap(16.h),
                    BaseButton(
                      buttonText: "Next",
                      onPressed: () {
                        context.pushNamed(LocationEnablePage.name);
                      },
                    ),
                    Gap(64.h),
                  ],
                )),
          ],
        )));
  }

  void _onNextPressed() {
    // widget.onNextPress();
  }
}
