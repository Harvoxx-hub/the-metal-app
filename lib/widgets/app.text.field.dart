import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';


import '../res/colors/cr_colors.dart';
import 'text_views.dart';

class AppTextField extends StatelessWidget {
  AppTextField(
      {this.minLines = 1,
      this.maxLines,
      this.controller,
      required this.hintText,
      required this.onchange,
      this.color,
      this.textColor,
      this.radius = 16,
      this.floatingLable,
      this.required = false,
      this.suffixIcon,
      this.padding,
      this.type,
      this.suffixText,
      this.validator,
      this.maxLength,
      this.onSummit,
      super.key});

  ValueChanged<String> onchange;
  ValueChanged<String>? onSummit;
  int minLines;
  int? maxLines;
  TextEditingController? controller;
  String hintText;
  String? floatingLable;
  String? suffixText;
  double radius;
  Color? color;
  bool required;
  int? maxLength;
  TextInputType? type;
  FormFieldValidator<String>? validator;
  Color? textColor;
  EdgeInsets? padding;
  Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (floatingLable != null) ...[
          TextView(
            text: floatingLable ?? '',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.metalBlack,
            heading: true,
          ),
          const Gap(16),
        ],
        TextFormField(
          onChanged: (value) {
            onchange(value);
          },
          onFieldSubmitted: (value) {
            onSummit!(value);
          },
          minLines: minLines,
          maxLines: maxLines ?? 6,
          validator: validator,
          keyboardType: type ?? TextInputType.text,
          style: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 10,
              fontFamily: 'Merri_weather',
              color: AppColors.metalBlack50),
          controller: controller,
          cursorColor: AppColors.metalBlack50,
          textAlign: TextAlign.start,
          inputFormatters: [
            LengthLimitingTextInputFormatter(maxLength),
          ],
          decoration: InputDecoration(
            filled: true,
            isDense: true,
            hintText: hintText + (required ? '*' : ''),
            suffixIcon: suffixIcon,
            suffixText: suffixText,
            hintStyle: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 10,
                fontFamily: 'Merri_weather',
                color: required
                    ? AppColors.metalBlack50
                    : textColor ?? AppColors.metalBlack50),
            contentPadding: padding ??
                const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            fillColor: color ?? AppColors.metalBrownColourForText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: const BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
