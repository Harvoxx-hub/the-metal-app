import 'package:flutter/material.dart';

class AppError {
  final String code;
  final String message;

  AppError({
    required this.code,
    required this.message,
  });
}

class ErrorHandler {
  static void handleError(BuildContext context, AppError appError) {
    // Customize this method to handle errors
    print('Error Code: ${appError.code}');
    print('Error Message: ${appError.message}');

    // Example: Show a snackbar with error details
    _showErrorSnackbar(context, 'Error: ${appError.message}');
  }

  static void _showErrorSnackbar(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
