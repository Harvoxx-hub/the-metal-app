import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text_views.dart';

 

// ignore: must_be_immutable
class EditFormField extends StatefulWidget {
  EditFormField(
      {Key? key,
      this.label = '',
      this.hint = '',
      this.floatingLabel = '',
      this.prefixIcon,
      this.suffixIcon,
      this.onSaved,
      this.validator,
      this.controller,
      this.alignLabelWithHint = false,
      this.onPasswordToggle,
      this.initialValue,
      this.autoValidateMode = AutovalidateMode.disabled,
      this.autocorrect = true,
      this.enabled = true,
      this.obscureText = false,
      this.readOnly = false,
      this.onTapped,
      this.keyboardType,
      this.suffixWidget,
      this.maxLines = 1,
      this.minLines = 1,
      this.maxLength,
      this.floatingLabelBehavior = FloatingLabelBehavior.never,
      this.inputFormatters,
      this.focusedColorBorder,
      this.suffixIconColor,
      this.labelStyle,
      this.hintStyle,
      this.textStyle,
      this.decoration,
      this.onChange,
      this.edgeInsetsGeometry,
      this.textCapitalization = TextCapitalization.none,
      this.formKey,
      this.focusNode,
      this.textInputAction = TextInputAction.next,
      this.clickable,
      this.fontSize = 16,
      this.cursorColor,
      this.prefixIconColor,
      this.isFilled = true,
      this.fillColor,
      this.counterLength = 0,
      this.isTyping = false,
      this.autoValidate = false,
      this.showMaxLengthCounter = false,
      this.radius = 20,
      this.prefixWidget})
      : super(key: key);

  final TextCapitalization? textCapitalization;
  final String? label;
  final String? floatingLabel;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? suffixWidget;
  final Widget? prefixWidget;

  final FormFieldSetter<String>? onSaved;
  final Function(String)? onChange;
  final FormFieldValidator<String>? validator;
  final VoidCallback? onPasswordToggle;

  final String? initialValue;
  final TextEditingController? controller;
  final FloatingLabelBehavior? floatingLabelBehavior;

  final bool? autocorrect;
  final AutovalidateMode? autoValidateMode;
  final bool? enabled;
  bool? obscureText;
  final bool? readOnly;
  final bool? alignLabelWithHint;
  final bool? isTyping;

  final bool? clickable;
  final Function()? onTapped;

  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputFormatter? inputFormatters;
  final int fontSize;
  final Color? focusedColorBorder;
  final Color? fillColor;
  final Color? cursorColor;
  final Color? suffixIconColor;
  final Color? prefixIconColor;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final TextInputAction? textInputAction;
  final InputDecoration? decoration;
  final Key? formKey;

  final EdgeInsetsGeometry? edgeInsetsGeometry;
  final FocusNode? focusNode;
  bool isFilled;
  bool autoValidate;
  bool showMaxLengthCounter;
  final int counterLength;
  double radius;

  @override
  State<EditFormField> createState() => _EditFormFieldState();
}

class _EditFormFieldState extends State<EditFormField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        widget.floatingLabel != null
            ? TextView(
                text: widget.floatingLabel!,
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
                color: AppColors.metalBrownColourForText,
                textAlign: TextAlign.left,
              )
            : SizedBox(),
        const SizedBox(
          height: 8,
        ),
        TextFormField(
          readOnly: widget.readOnly!,
          onTap: widget.onTapped,
          key: widget.formKey,
          cursorColor: widget.cursorColor ?? AppColors.metalPinkColour,
          keyboardType: widget.keyboardType,
          enabled: widget.enabled,

          focusNode: widget.focusNode,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization!,
          // autovalidateMode: autoValidateMode,
          onSaved: widget.onSaved,
          onChanged: widget.onChange,
          maxLines: widget.maxLines,
          // ignore: deprecated_member_use
          // autovalidate: autoValidate,
          style: TextStyle(
              fontFamily: 'Plus_Jakarta',
              color: AppColors.metalBrownColourForText,
              fontWeight: FontWeight.w300,
              fontSize: widget.fontSize.sp,
              fontStyle: FontStyle.normal),
          autocorrect: widget.autocorrect!,
          minLines: widget.minLines,
          obscureText: widget.obscureText!,
          maxLength: widget.maxLength,
          validator: widget.validator,
          initialValue: widget.initialValue,
          controller: widget.controller,
          decoration: widget.decoration ??
              InputDecoration(
                  counterText: '',
                  counter: widget.showMaxLengthCounter
                      ? Text(
                          '${widget.counterLength}/${widget.maxLength} characters',
                          style: const TextStyle(color: Colors.green),
                        )
                      : null,
                  fillColor: widget.fillColor ?? AppColors.metalWhite,
                  filled: widget.isFilled,
                  floatingLabelBehavior: widget.floatingLabelBehavior,
                  alignLabelWithHint: widget.alignLabelWithHint,
                  errorStyle: const TextStyle(color: Colors.red),
                  contentPadding: widget.edgeInsetsGeometry ??
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: widget.focusedColorBorder != null
                            ? widget.focusedColorBorder!
                            : AppColors.metalButtonStroke),
                    borderRadius: BorderRadius.circular(widget.radius.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: widget.focusedColorBorder != null
                            ? widget.focusedColorBorder!
                            : AppColors.metalPinkColour),
                    borderRadius: BorderRadius.circular(widget.radius.r),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: widget.focusedColorBorder != null
                            ? widget.focusedColorBorder!
                            : AppColors.metalWhite),
                    borderRadius: BorderRadius.circular(widget.radius.r),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(widget.radius.r),
                  ),
                  hintText: widget.hint,
                  hintStyle: widget.hintStyle ??
                      TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                          fontStyle: FontStyle.normal),
                  labelText: widget.label,
                  labelStyle: widget.labelStyle ??
                      TextStyle(
                          fontFamily: 'Plus_Jakarta',
                          color: AppColors.metalBrownColourForText,
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                          fontStyle: FontStyle.normal),
                  prefixIcon: widget.prefixWidget != null
                      ? Padding(
                          padding: EdgeInsets.only(left: 16.w, right: 16.w),
                          child: widget.prefixWidget!)
                      : (widget.prefixIcon != null
                          ? IconButton(
                              onPressed: widget.onPasswordToggle,
                              icon: Icon(
                                widget.prefixIcon,
                                color: widget.prefixIconColor,
                              ))
                          : null),
                  suffixIcon: widget.suffixWidget ??
                      (widget.keyboardType == TextInputType.visiblePassword
                          ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  widget.obscureText = !widget.obscureText!;
                                });
                              },
                              child: Icon(
                                !widget.obscureText!
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.metalBrownColour,
                              ),
                            )
                          : null)),
        ),
      ],
    );
  }
}
