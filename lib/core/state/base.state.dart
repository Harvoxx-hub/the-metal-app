import 'package:flutter/foundation.dart';

enum Status {
  initial,
  loading,
  success,
  error,
}

class BaseState<T> {
  final Status status;
  final String? errorMessage;
  final T? data;

  BaseState({
    required this.status,
    this.errorMessage,
    this.data,
  });

  factory BaseState.initial() {
    return BaseState<T>(status: Status.initial);
  }

  factory BaseState.loading() {
    return BaseState<T>(status: Status.loading);
  }

  factory BaseState.success(T data) {
    return BaseState<T>(status: Status.success, data: data);
  }

  factory BaseState.error(String errorMessage) {
    return BaseState<T>(status: Status.error, errorMessage: errorMessage);
  }

  bool get isInitial => status == Status.initial;
  bool get isLoading => status == Status.loading;
  bool get isSuccess => status == Status.success;
  bool get isError => status == Status.error;
}
