import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
 
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/services/countries.service.dart';
import 'package:metal/core/utils/input/validators/validators.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/update.profile.notifier.dart';
 
import 'package:metal/gen/assets.gen.dart';

 
import 'package:metal/features/authentication/presentation/widget/create.profile.header2.dart';
import 'package:metal/route/routes.dart';

import 'package:metal/widgets/agree.click.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/dropdown/metal.dropdown.dart';
import 'package:metal/widgets/text.field/text.field.dart';

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

  final TextEditingController _addressController = TextEditingController();

  final TextEditingController _townController = TextEditingController();
  List<String> country = [];
  List<String> states = [];

  CountriesService _countriesService = CountriesService();

  @override
  void initState() {
    // TODO: implement initState
    getCountries();
    super.initState();
  }

  Future<void> getCountries() async {
    final data = await _countriesService.getCountryNames();
    setState(() {
      country = data;
    });
  }

  Future<void> getState(String state) async {
    final data = await _countriesService.getStateNames(state);
    setState(() {
      states = data;
    });
  }

  String? _selectedCountries;
  String? _selectedState;

  @override
  Widget build(BuildContext context) {
    getCountries();

    final _updateProfile = ref.watch(updateProfileProvider);

    ref.listen<UpdateProfileState>(updateProfileProvider, (prev, current) {
      if (current.isSuccess) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.dashboardPage, (route) => true);
      }
    });
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
                title: "Let us know your home address",
                subtitle:
                    "Choose the data you wish to omit from your feed. The metals containing the highlighted details will be removed from your feed. This filtered information is intended solely for the purpose of fitting."),
            Gap(26.h),
            Form(
                key: _form,
                child: Column(
                  children: [
                    EditFormField(
                      floatingLabel: 'House Address',
                      label: 'Type here...',
                      controller: _addressController,
                      keyboardType: TextInputType.text,
                      suffixWidget: CustomCheckWidget(
                        initialValue: false,
                        onChanged: (bool value) {
                          print('Value changed to $value');
                        },
                      ),
                      validator: Validators.validateString(),
                      radius: 10,
                    ),
                    Gap(16.h),
                    MentalDropdown(
                      items: country,
                      onChanged: (String? value) {
                        getState(value!);
                        setState(() {
                          _selectedCountries = value;
                        });
                      },
                      value: _selectedCountries,
                      hint: "Please Select",
                      floatingLabel: "Country",
                    ),
                    Gap(16.h),
                    MentalDropdown(
                      items: states,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedState = value;
                        });
                      },
                      value: _selectedState,
                      hint: "Please Select",
                      floatingLabel: "State",
                    ),
                    Gap(16.h),
                    EditFormField(
                      floatingLabel: 'Town',
                      label: 'Type here...',
                      controller: _townController,
                      keyboardType: TextInputType.name,
                      validator: Validators.validateString(),
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
                        if (_form.currentState!.validate()) {
                          _onNextPressed();
                        }
                      },
                    ),
                    Gap(64.h),
                  ],
                )),
          ],
        )));
  }

  void _onNextPressed() {
    final userData = ref.watch(updateProfileProvider).data;
    final Address address = Address();

    address.town = _townController.text;
    address.state = _selectedState;
    address.country = _selectedCountries;
    address.house_address = _addressController.text;
    userData!.address = address;

    ref.read(updateProfileProvider.notifier).completeUserUpdate(userData);
  }
}
