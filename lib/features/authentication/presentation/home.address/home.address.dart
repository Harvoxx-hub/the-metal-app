import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gap/gap.dart';

import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/core/services/countries.service.dart';
import 'package:metal/core/utils/input/validators/validators.dart';
import 'package:metal/core/utils/strings/app_strings.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/presentation/widget/create.profile.header2.dart';

import 'package:metal/features/authentication/provider/update.profile.notifier.dart';

import 'package:metal/gen/assets.gen.dart';
import 'package:metal/route/routes.dart';

import 'package:metal/widgets/agree.click.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/dropdown/metal.dropdown.dart';
import 'package:metal/widgets/text.field/text.field.dart';

class HomeAddressPage extends ConsumerStatefulWidget {
  const HomeAddressPage({super.key});
  static const name = 'homeAdress';
  static const route = name;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _HomeAddressPageState();
}

class _HomeAddressPageState extends ConsumerState<HomeAddressPage> {
  static final GlobalKey<FormState> _form = GlobalKey<FormState>();

  final TextEditingController _apartmentNoController = TextEditingController();

  final TextEditingController _houseNumberController = TextEditingController();

  final TextEditingController _streetNameController = TextEditingController();

  final TextEditingController _postalCodeController = TextEditingController();
  List<String> country = [];
  List<String> states = [];

  final CountriesService _countriesService = CountriesService();

  @override
  void initState() {
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

    final updateProfile = ref.watch(updateProfileProvider);

    ref.listen<UpdateProfileState>(updateProfileProvider, (prev, current) {
      if (current.isSuccess) {
        Navigator.pop(context);
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.dashboardPage, (route) => true);
      }
    });
    return BaseScreen(
        bgImage: Assets.images.bg2.path,
        appBarEnabled: false,
        Header: AppStrings.houseAddressTitle,
        authFlow: true,
        body: SingleChildScrollView(
            child: Column(
          children: [
            CreateProfileHeader2(
                path: Assets.images.homeAddress.path,
                title: AppStrings.homeAddressDesc,
                subtitle: AppStrings.homeAddressSubtitle),
            const Gap(26),
            Form(
                key: _form,
                child: Column(
                  children: [
                    EditFormField(
                      floatingLabel: AppStrings.apartmentNumber,
                      label: AppStrings.enterNumber,
                      controller: _apartmentNoController,
                      keyboardType: TextInputType.number,
                      suffixWidget: CustomCheckWidget(
                        initialValue: false,
                        onChanged: (bool value) {
                          print('Value changed to $value');
                        },
                      ),
                      radius: 10,
                    ),
                    const Gap(16),
                    EditFormField(
                      floatingLabel: AppStrings.houseNumber,
                      label: AppStrings.enterNumber,
                      controller: _houseNumberController,
                      keyboardType: TextInputType.number,
                      validator: Validators.validateInt(),
                      suffixWidget: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.info_outline, size: 20),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Information"),
                                    content: const Text(
                                      "The address is used to exclude people that live in the same home with you if you click the check boxes.",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("OK"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          CustomCheckWidget(
                            initialValue: false,
                            onChanged: (bool value) {
                              print('Value changed to $value');
                            },
                          ),
                        ],
                      ),
                      radius: 10,
                    ),
                    const Gap(16),
                    EditFormField(
                      floatingLabel: AppStrings.streetName,
                      label: AppStrings.enterStreetName,
                      controller: _streetNameController,
                      validator: Validators.validateString(),
                      keyboardType: TextInputType.streetAddress,
                      suffixWidget: CustomCheckWidget(
                        initialValue: false,
                        onChanged: (bool value) {
                          print('Value changed to $value');
                        },
                      ),
                      radius: 10,
                    ),
                    const Gap(16),
                    MentalDropdown(
                      items: country,
                      onChanged: (String? value) {
                        getState(value!);
                        setState(() {
                          _selectedCountries = value;
                        });
                      },
                      value: _selectedCountries,
                      hint: AppStrings.pleaseSelect,
                      floatingLabel: AppStrings.country,
                    ),
                    const Gap(16),
                    MentalDropdown(
                      items: states,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedState = value;
                        });
                      },
                      value: _selectedState,
                      hint: AppStrings.pleaseSelect,
                      floatingLabel: AppStrings.state,
                    ),
                    const Gap(16),
                    EditFormField(
                      floatingLabel: AppStrings.postalCode,
                      label: AppStrings.enterPostalCode,
                      controller: _postalCodeController,
                      keyboardType: TextInputType.text,
                      validator: Validators.validateString(),
                      suffixWidget: CustomCheckWidget(
                        initialValue: false,
                        onChanged: (bool value) {
                          print('Value changed to $value');
                        },
                      ),
                    ),
                    const Gap(16),
                    BaseButton(
                      loading: updateProfile.isLoading,
                      buttonText: AppStrings.next,
                      onPressed: () {
                        if (_form.currentState!.validate()) {
                          _onNextPressed();
                        }
                      },
                    ),
                    const Gap(64),
                  ],
                )),
          ],
        )));
  }

  void _onNextPressed() {
    final userData = ref.watch(updateProfileProvider).data;
    Address address = Address(
        country: _selectedCountries,
        streetName: _streetNameController.text,
        apartmentNumber: _apartmentNoController.text,
        state: _selectedState,
        postalCode: _postalCodeController.text,
        houseNumber: _houseNumberController.text);
    final updated =
        userData!.copyWith(address: address, completedProfile: true);

    ref.read(updateProfileProvider.notifier).sendUserUpdate(updated);
  }
}
