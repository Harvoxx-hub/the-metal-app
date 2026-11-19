import 'package:fluttertoast/fluttertoast.dart';

enum Status { initial, loading, success, error, action }

class BaseState<T> {
  final Status status;
  final String? errorMessage;
  final T? data;
  final Map? errorData;
  final Map? action;
  /// Present when the error originated from an HTTP response (e.g. Dio).
  final int? errorHttpStatus;

  BaseState(
      {required this.status,
      this.errorMessage,
      this.data,
      this.errorData,
      this.action,
      this.errorHttpStatus});

  factory BaseState.initial() {
    return BaseState<T>(status: Status.initial);
  }

  factory BaseState.loading() {
    return BaseState<T>(status: Status.loading);
  }

  factory BaseState.success(T data, {Map? action}) {
    return BaseState<T>(status: Status.success, data: data, action: action);
  }

  /// Success with no data (e.g. RSVP success; caller will refresh).
  static BaseState<T> successNoData<T>() {
    return BaseState<T>(status: Status.success, data: null);
  }
  factory BaseState.action({required Map action}) {
    return BaseState<T>(status: Status.action, action: action);
  }

  factory BaseState.error(String errorMessage,
      {Map? errorData, StackTrace? stackTrace}) {
    if (!errorMessage.contains('refresh')) {
      Fluttertoast.showToast(msg: errorMessage);
    }
    return BaseState<T>(
      status: Status.error,
      errorMessage: errorMessage,
      errorData: errorData,
    );
  }

  bool get isInitial => status == Status.initial;
  bool get isLoading => status == Status.loading;
  bool get isSuccess => status == Status.success;
  bool get isError => status == Status.error;
  bool get isAction => status == Status.action;
}
