import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppError {
  final String code;
  final String message;
  final Map? errorData;

  AppError({
    required this.code,
    required this.message,

    this.errorData
  });
}

class ErrorHandler {
  static void handleError(AppError appError) {
    // Customize this method to handle errors
    print('Error Code: ${appError.code}');
    print('Error Message: ${appError.message}');

    // Example: Show a snackbar with error details
    Fluttertoast.showToast(
        msg: "Error: ${appError.message}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
