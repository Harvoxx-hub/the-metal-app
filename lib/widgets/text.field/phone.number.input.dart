import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:metal/widgets/text_views.dart';

import '../../res/colors/cr_colors.dart';

class PhoneInput extends StatelessWidget {
  const PhoneInput({super.key, this.phoneController});
// ignore: prefer_typing_uninitialized_variables
  final phoneController;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextView(
                text: 'Phone number',
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
                color: AppColors.metalBrownColourForText,
                textAlign: TextAlign.left,
              ), 
              Gap(8),
        IntlPhoneField(
          dropdownIconPosition: IconPosition.trailing,
          style: TextStyle(
              fontFamily: 'Plus_Jakarta',
              color: AppColors.metalBrownColourForText,
              fontWeight: FontWeight.w300,
              fontSize: 16.sp,
              fontStyle: FontStyle.normal),
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
          flagsButtonPadding: EdgeInsets.all(10),
          onChanged: (phone) {
            print(phone.completeNumber);
          },
        ),
      ],
    );
  }
}
