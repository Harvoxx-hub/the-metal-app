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
  const EditAddress({super.key, required this.onPress, this.initialAddress});

  final Function(Address) onPress;
  final Address? initialAddress;

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
    super.initState();
    if (widget.initialAddress != null) {
      _apartmentNoController.text =
          widget.initialAddress!.apartmentNumber ?? '';
      _houseNumberController.text = widget.initialAddress!.houseNumber ?? '';
      _streetNameController.text = widget.initialAddress!.streetName ?? '';
      _postalCodeController.text = widget.initialAddress!.postalCode ?? '';
      _selectedCountries = widget.initialAddress!.country;
      _selectedState = widget.initialAddress!.state;
      if (_selectedCountries != null) {
        getState(_selectedCountries!);
      }
    }
    getCountries();
  }

  final CountriesService _countriesService = CountriesService();

  Future<void> getCountries() async {
    final data = await _countriesService.getCountryNames();
    if (mounted) {
      setState(() {
        country = data;
      });
    }
  }

  Future<void> getState(String state) async {
    final data = await _countriesService.getStateNames(state);
    if (mounted) {
      setState(() {
        states = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(children: [
          const Gap(15),
          const TextView(
            text: "Edit Address",
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
          const Gap(15),
          Form(
              key: _form,
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
                      if (value != null) {
                        getState(value);
                        setState(() {
                          _selectedCountries = value;
                          _selectedState = null;
                        });
                      }
                    },
                    value: _selectedCountries,
                    hint: "Please Select Country",
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
                    hint: "Please Select State",
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
              )),
          const Gap(38),
          BaseButton(
              buttonText: "Save",
              onPressed: () {
                if (_form.currentState!.validate()) {
                  final address = Address(
                      apartmentNumber: _apartmentNoController.text,
                      houseNumber: _houseNumberController.text,
                      postalCode: _postalCodeController.text,
                      streetName: _streetNameController.text,
                      state: _selectedState,
                      country: _selectedCountries);
                  widget.onPress(address);
                  Navigator.pop(context);
                }
              }),
          const Gap(23),
        ]),
      ),
    );
  }
}
