import 'package:flutter/widgets.dart';

class Validators {
  static FormFieldValidator<String> validateNotEmpty({String? errorMessage}) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return errorMessage ?? 'This field is required';
      }
      return null;
    };
  }

  static FormFieldValidator<String> validateAmount({String? errorMessage}) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return errorMessage ?? 'Please enter an amount';
      }

      try {
        final amount = double.parse(value);
        if (amount <= 0) {
          return errorMessage ?? 'Amount must be greater than 0';
        }
      } catch (e) {
        return errorMessage ?? 'Please enter a valid number';
      }

      return null;
    };
  }

  static FormFieldValidator<String> validateEmail({String? errorMessage}) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return errorMessage ?? 'Email is required';
      }

      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );

      if (!emailRegex.hasMatch(value)) {
        return errorMessage ?? 'Please enter a valid email address';
      }

      return null;
    };
  }
}
