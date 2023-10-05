 
import 'package:flutter/widgets.dart';
import 'package:metal/utils/constant/constants.dart';
import 'package:metal/utils/input/validators/email_validator.dart';

class Validators {
  Validators._();

  static String? emailValidator(String? text, BuildContext context) {
    final trimmedText = text?.trim();
    if (trimmedText == null   || !EmailValidator.validate(trimmedText)) {
      return  'Email is not valid';
    }

    return null;
  }

  static String? newEmailValidator(
    String? currentEmail,
    String? newEmail,
    BuildContext context,
  ) {
    if (currentEmail?.trim() == newEmail?.trim()) {
      return  'Wrong New Email Address';
    } else if (emailValidator(newEmail, context) != null) {
      return  'Wrong New Email Address';
    }

    return null;
  }

  static String? passwordValidator(String? text, BuildContext context) {
    final trimmedText = text?.trim();

    if (trimmedText == null ||
        trimmedText.isEmpty ||
        trimmedText.length < kPasswordMinLength ||
        trimmedText.length > kPasswordMaxLength ||
        // must contain at least 1 digit
        !trimmedText.contains(RegExp('[0-9]')) ||
        // must contain at least 1 uppercase letter
        !trimmedText.contains(RegExp('[A-Z]')) ||
        // must contain at least 1 lowercase letter
        !trimmedText.contains(RegExp('[a-z]'))) {
      return 'Password must be at least 8 characters long and contain at least 1 digit, 1 uppercase letter and 1 lowercase letter';
    }

    return null;
  }

  static String? newPWValidator(
    String? currentPassword,
    String? newPassword,
    BuildContext context,
  ) {
    if (newPassword?.trim() == currentPassword?.trim()) {
      return  'Wrong New Password';
    }

    return passwordValidator(newPassword, context);
  }

  static String? confirmPWValidator(
    String? pw,
    String? confirmPw,
    BuildContext _,
  ) {
    if (confirmPw == null) {
      return 'Confirm password is invalid';
    } else if (pw != null) {
      if (pw.trim() != confirmPw.trim()) {
        return 'Password and password confirmation must match';
      }
    }

    return null;
  }

  static String? nickname(String? name, BuildContext _) {
    final trimmedText = name?.trim() ?? '';
    if (trimmedText.isEmpty) {
      return 'Nickname is not allowed to be empty';
    } else if (trimmedText.length < 3 || trimmedText.length > 20) {
      return 'Nickname should be from 3 to 20 symbols';
    }

    return null;
  }

  static String? nameValidator(BuildContext context, String? name) {
    if (name != null) {
      if (!RegExp(r"^[a-zA-Z0-9\s]+$").hasMatch(name)) {
        return  'Name should contain only letters and numbers';
      }
      if (name.trim().isEmpty || name.length > 25) {
        return  'Name should be from 1 to 25 symbols';
      }
    }

    return null;
  }

  static bool isAdult(DateTime? birthDate) {
    if (birthDate == null) {
      return false;
    }

    final today = DateTime.now();

    final yearDiff = today.year - birthDate.year;
    final monthDiff = today.month - birthDate.month;
    final dayDiff = today.day - birthDate.day;

    return yearDiff > 18 || yearDiff == 18 && monthDiff >= 0 && dayDiff >= 0;
  }

  // static String? cardNumberValidator(String? number, BuildContext _) {
  //   if (number == null || number.isEmpty) {
  //     return 'Card number should not be empty';
  //   }

  //   final text = number.replaceAll(' ', '');
  //   if (text.length < kMinCardNumberLength || text.length > kMaxCardNumberLength) {
  //     return 'Card number does not meet length validation criteria';
  //   }
  //   final isCardValid = CardValidator.validateCardNumber(text);

  //   return isCardValid ? null : 'Card number is not valid';
  // }

  // static String? expireDateValidator(String? date, BuildContext _) {
  //   final text = date?.trim();
  //   if (text == null || text.isEmpty) {
  //     return 'Expiration date field is empty';
  //   }
  //   final monthAndYear = text.split('/');
  //   if (monthAndYear.length < 2) {
  //     return 'Expiration date is not valid';
  //   }

  //   final isDateValid = CardValidator.validateExpDate(
  //     ExpMonthYear(
  //       monthAndYear.first,
  //       monthAndYear.second,
  //     ),
  //   );

  //   return isDateValid ? null : 'Expiration date is not valid';
  // }

  // static String? cvvValidator(
  //   String? cvv,
  //   CardType? cardType,
  //   BuildContext _,
  // ) {
  //   final text = cvv?.trim();
  //   if (text == null || text.isEmpty) {
  //     return 'CSC/CVV field is empty';
  //   }
  //   if (cardType != null) {
  //     final isValid = CardValidator.validateCVC(
  //       text,
  //       cardType.securityCodeLength ?? 3,
  //     );
  //     if (!isValid) {
  //       return 'CSC/CVV does not meet length validation criteria';
  //     }
  //   }
  //   if (text.length < kMinCVVLength && text.length > kMaxCVVLength) {
  //     return 'CSC/CVV does not meet length validation criteria';
  //   }

  //   return null;
  // }

  static String? notEmptyValidator(String? text, BuildContext context) {
    final trimmedText = text?.trim();
    if (trimmedText == null || trimmedText.isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  static String? eventDateValidator(BuildContext context, String? text) {
    final trimmedText = text?.trim();
    if (trimmedText == null || trimmedText.isEmpty) {
      return  'Select Session Date';
    }

    return null;
  }

  // static String? eventEndDateValidator(
  //   BuildContext context,
  //   DateTime? date,
  //   DateTime? endDate,
  // ) {
  //   if (date != null && endDate != null && date.date.isAfter(endDate.date)) {
  //     return  'End date must be after start date';
  //   }

  //   return null;
  // }

  // static String? eventTimeValidator(BuildContext context, String? text) {
  //   final trimmedText = text?.trim();
  //   if (trimmedText == null || trimmedText.isEmpty) {
  //     return S.of(context).selectSessionTime;
  //   }

  //   return null;
  // }

  // static String? eventRemindValidator(BuildContext context, String? text) {
  //   final trimmedText = text?.trim();
  //   if (trimmedText == null || trimmedText.isEmpty) {
  //     return S.of(context).selectRemind;
  //   }

  //   return null;
  // }

  // static String? eventSessionTypeValidator(BuildContext context, String? text) {
  //   final trimmedText = text?.trim();
  //   if (trimmedText == null || trimmedText.isEmpty) {
  //     return S.of(context).selectSessionType;
  //   }

  //   return null;
  // }

   
}
