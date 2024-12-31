import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/services/countries.service.dart';
import 'package:metal/core/utils/input/validators/validators.dart';
import 'package:metal/core/utils/screen.size.dart';

import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/widgets/agree.click.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dropdown/metal.dropdown.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

class EditAddress extends StatefulWidget {
  const EditAddress({super.key, required this.onPress});

  final Function(Address) onPress;

  @override
  State<EditAddress> createState() => _EditAddressState();
}

class _EditAddressState extends State<EditAddress> {
  List<String> country = [];
  List<String> states = [];
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  final TextEditingController _apartmentNoController = TextEditingController();

  final TextEditingController _houseNumberController = TextEditingController();

  final TextEditingController _streetNameController = TextEditingController();

  final TextEditingController _postalCodeController = TextEditingController();
  String? _selectedCountries;
  String? _selectedState;

  @override
  void initState() {
    getCountries();
    super.initState();
  }

  final CountriesService _countriesService = CountriesService();

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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getDeviceHeight(context) / 1.5,
      child: SingleChildScrollView(
        child: Column(children: [
          const Gap(15),
          const TextView(
            text: "Edit Address",
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
          const Gap(15),
          SingleChildScrollView(
              child: Form(
                  //   key: _form,
                  child: Column(
            children: [
              EditFormField(
                floatingLabel: 'Apartment number',
                label: 'Enter number.',
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
                floatingLabel: 'House number',
                label: 'Enter number.',
                controller: _houseNumberController,
                keyboardType: TextInputType.number,
                validator: Validators.validateInt(),
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
                floatingLabel: 'Street name',
                label: 'Enter street name.',
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
                hint: "Please Select",
                floatingLabel: "Country",
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
                hint: "Please Select",
                floatingLabel: "State",
              ),
              const Gap(16),
              EditFormField(
                floatingLabel: 'Postal Code',
                label: 'Enter Postal Code',
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
            ],
          ))),
          const Gap(38),
          BaseButton(
              buttonText: "Save",
              onPressed: () {
                final address = Address(
                    apartmentNumber: _apartmentNoController.text,
                    houseNumber: _houseNumberController.text,
                    postalCode: _postalCodeController.text,
                    streetName: _streetNameController.text,
                    state: _selectedState,
                    country: _selectedCountries);
                widget.onPress(address);
              }),
          const Gap(23),
        ]),
      ),
    );
  }
}
