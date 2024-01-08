import 'package:flutter/foundation.dart';

enum LoginStatus {
  initial, // Initial state
  loading, // Loading state, e.g., when making an API request
  success, // Successful login
  error, // Error during login
}

class LoginState {
  final LoginStatus status;
  final String? errorMessage;

  LoginState({
    required this.status,
    this.errorMessage,
  });

  factory LoginState.initial() {
    return LoginState(status: LoginStatus.initial);
  }

  factory LoginState.loading() {
    return LoginState(status: LoginStatus.loading);
  }

  factory LoginState.success() {
    return LoginState(status: LoginStatus.success);
  }

  factory LoginState.error(String errorMessage) {
    return LoginState(status: LoginStatus.error, errorMessage: errorMessage);
  }

  bool get isInitial => status == LoginStatus.initial;
  bool get isLoading => status == LoginStatus.loading;
  bool get isSuccess => status == LoginStatus.success;
  bool get isError => status == LoginStatus.error;
}
