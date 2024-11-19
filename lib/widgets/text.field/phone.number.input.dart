import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:metal/widgets/text_views.dart';
import '../../res/colors/cr_colors.dart';

class PhoneInput extends StatelessWidget {
  final String floatingLabel;
  final TextEditingController phoneController;
  final void Function(String)? onPhoneNumberChanged;

  const PhoneInput({
    Key? key,
    required this.phoneController,
    this.floatingLabel = "Phone number",
    this.onPhoneNumberChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextView(
          text: floatingLabel,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: AppColors.metalBrownColourForText,
          textAlign: TextAlign.left,
        ),
        const Gap(8),
        IntlPhoneField(
          dropdownIconPosition: IconPosition.trailing,
          style: const TextStyle(
            fontFamily: 'Plus_Jakarta',
            color: AppColors.metalBrownColourForText,
            fontWeight: FontWeight.w300,
            fontSize: 16,
            fontStyle: FontStyle.normal,
          ),
          decoration: InputDecoration(
            labelText: '81033000333',
            focusColor: AppColors.metalPinkColour,
            fillColor: AppColors.metalWhite,
            errorStyle: const TextStyle(color: Colors.red),
            contentPadding: const EdgeInsets.all(10),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.metalButtonStroke),
              borderRadius: BorderRadius.circular(20),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.metalPinkColour),
              borderRadius: BorderRadius.circular(20),
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.metalWhite),
              borderRadius: BorderRadius.circular(20),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          initialCountryCode: 'US',
          controller: phoneController,
          flagsButtonPadding: const EdgeInsets.all(10),
          onChanged: onPhoneNumberChanged != null
              ? (phone) => onPhoneNumberChanged!(phone.completeNumber ?? '')
              : null,
          onSubmitted: onPhoneNumberChanged != null
              ? (phone) => onPhoneNumberChanged!(phone)
              : null,
        ),
      ],
    );
  }
}
